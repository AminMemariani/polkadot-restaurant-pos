import { Router } from 'express';
import type Stripe from 'stripe';

import { transactions } from '../db/transactions.js';

interface CreateIntentBody {
  orderId: string;
  amountMinor: number;
  currency: string;
  tipMinor?: number;
  cashierId: string;
  locationId: string;
  customerId?: string;
  metadata?: Record<string, string>;
}

export function paymentsRouter(stripe: Stripe): Router {
  const router = Router();

  router.post('/intent', async (req, res, next) => {
    try {
      const body = req.body as CreateIntentBody;
      const idempotencyKey = req.header('Idempotency-Key');
      if (!idempotencyKey) {
        res.status(400).json({ error: 'idempotency_key_required' });
        return;
      }

      const total = body.amountMinor + (body.tipMinor ?? 0);
      const intent = await stripe.paymentIntents.create(
        {
          amount: total,
          currency: body.currency.toLowerCase(),
          // Allowed methods are enforced by the publishable key + dashboard
          // settings; the SDK picks the right one based on what's configured.
          automatic_payment_methods: { enabled: true },
          metadata: {
            order_id: body.orderId,
            cashier_id: body.cashierId,
            location_id: body.locationId,
            tip_minor: String(body.tipMinor ?? 0),
            ...(body.metadata ?? {}),
          },
        },
        { idempotencyKey },
      );

      // Optimistic transaction row. The webhook will upsert the terminal
      // status — clients should poll GET /payments/:id, not trust this row.
      await transactions.insert({
        orderId: body.orderId,
        locationId: body.locationId,
        cashierId: body.cashierId,
        provider: 'stripe',
        providerPaymentId: intent.id,
        amountMinor: body.amountMinor,
        currency: body.currency.toLowerCase(),
        tipMinor: body.tipMinor ?? 0,
        status: 'pending',
        failureCode: null,
        failureReason: null,
        rawEvent: intent,
      });

      res.json({
        id: intent.id,
        clientSecret: intent.client_secret,
        status: intent.status,
      });
    } catch (e) {
      next(e);
    }
  });

  router.get('/:id', async (req, res, next) => {
    try {
      const row = await transactions.findByProviderId('stripe', req.params.id);
      if (!row) {
        res.status(404).json({ error: 'not_found' });
        return;
      }
      res.json({
        id: row.providerPaymentId,
        status: row.status,
        amountMinor: row.amountMinor,
        currency: row.currency,
        tipMinor: row.tipMinor,
        failureCode: row.failureCode,
        failureReason: row.failureReason,
        updatedAt: row.updatedAt,
      });
    } catch (e) {
      next(e);
    }
  });

  router.post('/refund', async (req, res, next) => {
    try {
      const idempotencyKey = req.header('Idempotency-Key');
      if (!idempotencyKey) {
        res.status(400).json({ error: 'idempotency_key_required' });
        return;
      }
      const { paymentIntentId, amountMinor, reason } = req.body as {
        paymentIntentId: string;
        amountMinor?: number;
        reason?: string;
      };
      const refund = await stripe.refunds.create(
        {
          payment_intent: paymentIntentId,
          amount: amountMinor,
          reason: reason as Stripe.RefundCreateParams.Reason | undefined,
        },
        { idempotencyKey },
      );
      res.json({ id: refund.id, status: refund.status });
    } catch (e) {
      next(e);
    }
  });

  return router;
}
