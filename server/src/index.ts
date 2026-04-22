import express from 'express';
import Stripe from 'stripe';

import { paymentsRouter } from './routes/payments.js';
import { webhooksRouter } from './routes/webhooks.js';
import { getEnv } from './middleware/env.js';

const env = getEnv();
const stripe = new Stripe(env.STRIPE_SECRET_KEY);

const app = express();

// Webhook MUST be mounted before express.json() — Stripe signature
// verification needs the raw request body, not the parsed JSON.
app.use('/webhooks/stripe', webhooksRouter(stripe, env.STRIPE_WEBHOOK_SECRET));

app.use(express.json({ limit: '64kb' }));

app.use((req, res, next) => {
  // Trivial CORS for development. Tighten in prod via ALLOWED_ORIGINS.
  const origin = req.headers.origin ?? '';
  const allowed = env.ALLOWED_ORIGINS.length === 0 || env.ALLOWED_ORIGINS.includes(origin);
  if (allowed) {
    res.setHeader('Access-Control-Allow-Origin', env.ALLOWED_ORIGINS.length === 0 ? '*' : origin);
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Idempotency-Key');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  }
  if (req.method === 'OPTIONS') {
    res.sendStatus(204);
    return;
  }
  next();
});

app.get('/healthz', (_req, res) => {
  res.json({ ok: true });
});

app.use('/payments', paymentsRouter(stripe));

app.use((err: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  // Final-resort error handler. Real logging belongs in a structured logger.
  console.error('[unhandled]', err);
  res.status(500).json({ error: 'internal_error' });
});

app.listen(env.PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`payments-server listening on :${env.PORT}`);
});
