import { Router } from 'express';
import type Stripe from 'stripe';

import { transactions } from '../db/transactions.js';

interface CreateIntentBody {
  orderId: string;
  amountMinor: number;
  currency: string;
  tipMinor?: number;
  customerId?: string;
  metadata?: Record<string, string>;
}

export function paymentsRouter(stripe: Stripe): Router {
  const router = Router();

  router.post('/intent', async (req, res, next) => {
    try {
      const cashier = req.cashier;
      if (!cashier?.tenantId || !cashier.locationId) {
        // Cashier exists but isn't fully provisioned (no tenant/location in
        // app_metadata). Run bootstrap_cashier first.
        res.status(403).json({ error: 'cashier_not_provisioned' });
        return;
      }

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
          automatic_payment_methods: { enabled: true },
          metadata: {
            order_id: body.orderId,
            cashier_id: cashier.id,
            tenant_id: cashier.tenantId,
            location_id: cashier.locationId,
            tip_minor: String(body.tipMinor ?? 0),
            ...(body.metadata ?? {}),
          },
        },
        { idempotencyKey },
      );

      // Optimistic transaction row. The webhook is the source of truth —
      // clients should poll GET /payments/:id, not trust this row.
      await transactions.insert({
        tenantId: cashier.tenantId,
        locationId: cashier.locationId,
        cashierId: cashier.id,
        orderId: body.orderId,
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
      // Tenant scope: cashiers can only read transactions in their own tenant.
      // (Service role hits don't carry a cashier; permit those.)
      if (req.cashier && req.cashier.tenantId && row.tenantId !== req.cashier.tenantId) {
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
      // Tenant scope: only allow refunding transactions in the caller's tenant.
      if (req.cashier?.tenantId) {
        const row = await transactions.findByProviderId('stripe', paymentIntentId);
        if (!row || row.tenantId !== req.cashier.tenantId) {
          res.status(404).json({ error: 'not_found' });
          return;
        }
      }
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
