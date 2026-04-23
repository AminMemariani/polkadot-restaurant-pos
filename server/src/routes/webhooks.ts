import express, { Router } from 'express';
import type Stripe from 'stripe';

import { isWebhookProcessed, recordWebhook } from '../db/supabase.js';
import { transactions, type TransactionRow } from '../db/transactions.js';

/// Webhook receiver. Mounted with `express.raw()` so the Stripe signature
/// verification can read the raw body — JSON parsing must NOT happen first.
export function webhooksRouter(stripe: Stripe, signingSecret: string): Router {
  const router = Router();

  router.post(
    '/',
    express.raw({ type: 'application/json' }),
    async (req, res) => {
      const sig = req.header('Stripe-Signature');
      if (!sig) {
        res.status(400).send('Missing signature');
        return;
      }

      let event: Stripe.Event;
      try {
        event = stripe.webhooks.constructEvent(req.body, sig, signingSecret);
      } catch (err) {
        // Treat any verification failure as 400 — Stripe will retry.
        res.status(400).send(`Invalid signature: ${(err as Error).message}`);
        return;
      }

      // Idempotency: Stripe retries on 5xx, and very rarely delivers an event
      // twice. Skip if we've already recorded this event id.
      if (await isWebhookProcessed(event.id)) {
        res.sendStatus(200);
        return;
      }

      try {
        await handleEvent(event);
        await recordWebhook(event.id, event.type, event);
        res.sendStatus(200);
      } catch (err) {
        // 5xx triggers a Stripe retry. Only return 5xx for genuinely transient
        // failures (DB down, etc.); never for validation problems we can't
        // recover from.
        console.error('[webhook handler]', event.id, err);
        res.sendStatus(500);
      }
    },
  );

  return router;
}

async function handleEvent(event: Stripe.Event): Promise<void> {
  switch (event.type) {
    case 'payment_intent.succeeded': {
      const intent = event.data.object;
      await transactions.upsertByProviderId('stripe', intent.id, {
        status: 'succeeded',
        rawEvent: event,
      });
      return;
    }
    case 'payment_intent.payment_failed': {
      const intent = event.data.object;
      const lastError = intent.last_payment_error;
      await transactions.upsertByProviderId('stripe', intent.id, {
        status: 'failed',
        failureCode: lastError?.code ?? null,
        failureReason: lastError?.message ?? null,
        rawEvent: event,
      });
      return;
    }
    case 'charge.refunded': {
      const charge = event.data.object;
      const intentId =
        typeof charge.payment_intent === 'string'
          ? charge.payment_intent
          : charge.payment_intent?.id;
      if (!intentId) return;
      const fullyRefunded = charge.amount_refunded === charge.amount;
      const status: TransactionRow['status'] = fullyRefunded
        ? 'refunded'
        : 'partial_refund';
      await transactions.upsertByProviderId('stripe', intentId, {
        status,
        rawEvent: event,
      });
      return;
    }
    case 'payment_intent.canceled': {
      const intent = event.data.object;
      await transactions.upsertByProviderId('stripe', intent.id, {
        status: 'cancelled',
        rawEvent: event,
      });
      return;
    }
    default:
      // Ignore the rest. Add cases as we need them.
      return;
  }
}
