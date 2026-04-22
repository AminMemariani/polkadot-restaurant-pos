# Payments backend

Express + TypeScript service that owns Stripe credentials, creates Payment
Intents, verifies webhooks, and stores transactions. The Flutter POS app
talks to this server — never directly to Stripe with secret keys.

## Endpoints

| Method | Path | Notes |
|--------|------|-------|
| POST | `/payments/intent` | Create a PaymentIntent. Header: `Idempotency-Key`. |
| GET | `/payments/:id` | Fetch current state for client-side reconciliation polling. |
| POST | `/payments/refund` | Refund full or partial. Header: `Idempotency-Key`. |
| POST | `/webhooks/stripe` | Stripe → us. Signature verified. |

## Local development

```bash
cd server
cp .env.example .env
# Fill STRIPE_SECRET_KEY (test) and STRIPE_WEBHOOK_SECRET below
npm install
npm run dev          # http://localhost:8080
```

In another terminal, forward webhooks to your local server:

```bash
stripe listen --forward-to localhost:8080/webhooks/stripe
# Copy the whsec_... it prints into .env as STRIPE_WEBHOOK_SECRET
```

The Flutter app reads the backend URL from `--dart-define=PAYMENTS_BACKEND_URL`;
default is `http://localhost:8080`.

## Storage

Transactions are kept in-memory by default (see `src/db/transactions.ts`).
Switch to Postgres or Cloud Firestore when you're ready to persist; the
interface (`TransactionStore`) is a single file to swap.

## Deploy

This codebase is portable to any container host. Cloud Run is the most
straightforward — it scales to zero and bills only on requests.

```bash
# One-time
gcloud run deploy payments-server \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars "STRIPE_SECRET_KEY=sk_live_...,STRIPE_WEBHOOK_SECRET=whsec_..."
```

Then set the webhook endpoint URL in the Stripe Dashboard to
`https://<your-cloud-run-url>/webhooks/stripe` and copy the new signing
secret back into the env vars.

## Security

- Never log the request body verbatim — it can contain card metadata.
- All mutating endpoints expect an `Idempotency-Key` header from the client.
  This is forwarded to Stripe so retries don't double-charge.
- The webhook handler must read the raw body before any JSON parser runs;
  see how `express.raw()` is mounted only on `/webhooks/stripe` in
  `src/index.ts`.
