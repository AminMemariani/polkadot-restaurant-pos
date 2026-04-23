import { createClient, type SupabaseClient } from '@supabase/supabase-js';

import { getEnv } from '../middleware/env.js';
import type { TransactionRow, TransactionStore } from './transactions.js';

let cached: SupabaseClient | null = null;

/// Service-role Supabase client. Use for backend writes — bypasses RLS.
/// Never construct one from the anon key here.
export function supabaseAdmin(): SupabaseClient {
  if (cached) return cached;
  const env = getEnv();
  cached = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  return cached;
}

/// Postgres-backed [TransactionStore]. Mirrors the in-memory implementation
/// so swapping it in is just a re-export. Column names are snake_case in the
/// DB; we normalise to camelCase here so callers see the same shape.
export class SupabaseTransactionStore implements TransactionStore {
  private get db() {
    return supabaseAdmin().from('transactions');
  }

  async insert(
    input: Omit<TransactionRow, 'id' | 'createdAt' | 'updatedAt'>,
  ): Promise<TransactionRow> {
    const { data, error } = await this.db
      .insert(toRow(input))
      .select()
      .single();
    if (error) throw error;
    return fromRow(data);
  }

  async upsertByProviderId(
    provider: TransactionRow['provider'],
    providerPaymentId: string,
    patch: Partial<TransactionRow>,
  ): Promise<TransactionRow> {
    // Try to update first; if no row matches, fall back to insert. We don't
    // use Postgres `INSERT ... ON CONFLICT` here because the patch may not
    // include all NOT NULL columns (caller relies on insert defaults).
    const { data: existing } = await this.db
      .select('*')
      .eq('provider', provider)
      .eq('provider_payment_id', providerPaymentId)
      .maybeSingle();

    if (existing) {
      const { data, error } = await this.db
        .update(toRow(patch as Partial<TransactionRow>))
        .eq('provider', provider)
        .eq('provider_payment_id', providerPaymentId)
        .select()
        .single();
      if (error) throw error;
      return fromRow(data);
    }

    return this.insert({
      orderId: '',
      tenantId: '',
      locationId: '',
      cashierId: null,
      provider,
      providerPaymentId,
      amountMinor: 0,
      currency: 'usd',
      tipMinor: 0,
      status: 'pending',
      failureCode: null,
      failureReason: null,
      rawEvent: null,
      ...patch,
    } as Omit<TransactionRow, 'id' | 'createdAt' | 'updatedAt'>);
  }

  async findByProviderId(
    provider: TransactionRow['provider'],
    providerPaymentId: string,
  ): Promise<TransactionRow | null> {
    const { data, error } = await this.db
      .select('*')
      .eq('provider', provider)
      .eq('provider_payment_id', providerPaymentId)
      .maybeSingle();
    if (error) throw error;
    return data ? fromRow(data) : null;
  }

  async findById(id: string): Promise<TransactionRow | null> {
    const { data, error } = await this.db
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (error) throw error;
    return data ? fromRow(data) : null;
  }
}

/// Idempotency check for webhook delivery — relies on the `webhook_events`
/// table created in the initial migration. Returns true if the event was
/// already recorded (caller should short-circuit to a 200).
export async function isWebhookProcessed(eventId: string): Promise<boolean> {
  const { data } = await supabaseAdmin()
    .from('webhook_events')
    .select('id')
    .eq('id', eventId)
    .maybeSingle();
  return data !== null;
}

export async function recordWebhook(
  eventId: string,
  type: string,
  payload: unknown,
): Promise<void> {
  const { error } = await supabaseAdmin()
    .from('webhook_events')
    .insert({ id: eventId, type, payload });
  // Swallow conflict errors — another concurrent delivery already inserted.
  if (error && error.code !== '23505') throw error;
}

// ---------------------------------------------------------------------------
// snake_case <-> camelCase translation
// ---------------------------------------------------------------------------

interface DbRow {
  id?: string;
  tenant_id?: string;
  location_id?: string;
  cashier_id?: string | null;
  order_id?: string;
  provider?: TransactionRow['provider'];
  provider_payment_id?: string | null;
  amount_minor?: number;
  currency?: string;
  tip_minor?: number;
  status?: TransactionRow['status'];
  failure_code?: string | null;
  failure_reason?: string | null;
  raw_event?: unknown;
  created_at?: string;
  updated_at?: string;
}

function toRow(input: Partial<TransactionRow>): DbRow {
  const out: DbRow = {};
  if (input.tenantId !== undefined) out.tenant_id = input.tenantId;
  if (input.locationId !== undefined) out.location_id = input.locationId;
  if (input.cashierId !== undefined) out.cashier_id = input.cashierId;
  if (input.orderId !== undefined) out.order_id = input.orderId;
  if (input.provider !== undefined) out.provider = input.provider;
  if (input.providerPaymentId !== undefined) {
    out.provider_payment_id = input.providerPaymentId;
  }
  if (input.amountMinor !== undefined) out.amount_minor = input.amountMinor;
  if (input.currency !== undefined) out.currency = input.currency;
  if (input.tipMinor !== undefined) out.tip_minor = input.tipMinor;
  if (input.status !== undefined) out.status = input.status;
  if (input.failureCode !== undefined) out.failure_code = input.failureCode;
  if (input.failureReason !== undefined) out.failure_reason = input.failureReason;
  if (input.rawEvent !== undefined) out.raw_event = input.rawEvent;
  return out;
}

function fromRow(row: DbRow): TransactionRow {
  return {
    id: row.id!,
    tenantId: row.tenant_id!,
    locationId: row.location_id!,
    cashierId: row.cashier_id ?? null,
    orderId: row.order_id!,
    provider: row.provider!,
    providerPaymentId: row.provider_payment_id ?? null,
    amountMinor: row.amount_minor!,
    currency: row.currency!,
    tipMinor: row.tip_minor ?? 0,
    status: row.status!,
    failureCode: row.failure_code ?? null,
    failureReason: row.failure_reason ?? null,
    rawEvent: row.raw_event,
    createdAt: row.created_at!,
    updatedAt: row.updated_at!,
  };
}
