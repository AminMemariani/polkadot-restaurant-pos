import { randomUUID } from 'node:crypto';

/// Provider-agnostic transaction row. Mirrors the table sketched in the
/// payments architecture doc. In-memory for now — swap to Postgres / Firestore
/// when reporting moves off the client.
export interface TransactionRow {
  id: string;
  orderId: string;
  locationId: string;
  cashierId: string;
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

class InMemoryTransactionStore implements TransactionStore {
  private rows = new Map<string, TransactionRow>();
  // (provider + providerPaymentId) → row id
  private byProvider = new Map<string, string>();

  async insert(
    input: Omit<TransactionRow, 'id' | 'createdAt' | 'updatedAt'>,
  ): Promise<TransactionRow> {
    const now = new Date().toISOString();
    const row: TransactionRow = {
      ...input,
      id: randomUUID(),
      createdAt: now,
      updatedAt: now,
    };
    this.rows.set(row.id, row);
    if (row.providerPaymentId) {
      this.byProvider.set(this.key(row.provider, row.providerPaymentId), row.id);
    }
    return row;
  }

  async upsertByProviderId(
    provider: TransactionRow['provider'],
    providerPaymentId: string,
    patch: Partial<TransactionRow>,
  ): Promise<TransactionRow> {
    const k = this.key(provider, providerPaymentId);
    const existingId = this.byProvider.get(k);
    if (existingId) {
      const existing = this.rows.get(existingId)!;
      const next: TransactionRow = {
        ...existing,
        ...patch,
        provider,
        providerPaymentId,
        updatedAt: new Date().toISOString(),
      };
      this.rows.set(existingId, next);
      return next;
    }
    return this.insert({
      orderId: '',
      locationId: '',
      cashierId: '',
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
    });
  }

  async findByProviderId(
    provider: TransactionRow['provider'],
    providerPaymentId: string,
  ): Promise<TransactionRow | null> {
    const id = this.byProvider.get(this.key(provider, providerPaymentId));
    return id ? this.rows.get(id) ?? null : null;
  }

  async findById(id: string): Promise<TransactionRow | null> {
    return this.rows.get(id) ?? null;
  }

  private key(provider: string, id: string): string {
    return `${provider}:${id}`;
  }
}

export const transactions: TransactionStore = new InMemoryTransactionStore();
