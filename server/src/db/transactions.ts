import { SupabaseTransactionStore } from './supabase.js';

/// Provider-agnostic transaction row. Field names mirror the Postgres schema
/// (camelCase for TS, snake_case in the DB — see `supabase.ts` for the
/// translation layer).
export interface TransactionRow {
  id: string;
  tenantId: string;
  locationId: string;
  cashierId: string | null;
  orderId: string;
  provider: 'stripe' | 'polkadot' | 'kusama' | 'cash';
  providerPaymentId: string | null;
  amountMinor: number;
  currency: string;
  tipMinor: number;
  status:
    | 'pending'
    | 'succeeded'
    | 'failed'
    | 'refunded'
    | 'partial_refund'
    | 'cancelled';
  failureCode: string | null;
  failureReason: string | null;
  rawEvent: unknown;
  createdAt: string;
  updatedAt: string;
}

export interface TransactionStore {
  insert(input: Omit<TransactionRow, 'id' | 'createdAt' | 'updatedAt'>): Promise<TransactionRow>;
  upsertByProviderId(
    provider: TransactionRow['provider'],
    providerPaymentId: string,
    patch: Partial<TransactionRow>,
  ): Promise<TransactionRow>;
  findByProviderId(
    provider: TransactionRow['provider'],
    providerPaymentId: string,
  ): Promise<TransactionRow | null>;
  findById(id: string): Promise<TransactionRow | null>;
}

/// Singleton store used across the app. Backed by Supabase Postgres in
/// production; swap here for tests if you want an in-memory fake.
export const transactions: TransactionStore = new SupabaseTransactionStore();
