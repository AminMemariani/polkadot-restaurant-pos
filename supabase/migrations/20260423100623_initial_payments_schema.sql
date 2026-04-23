-- Restaurant POS payments schema.
-- Single source of truth for every payment attempt across every rail
-- (Stripe, blockchain, cash). RLS enforces multi-tenant isolation; writes
-- are gated to the service role so the Node payments backend mediates them.

-- ---------------------------------------------------------------------------
-- Multi-tenant scaffolding
-- ---------------------------------------------------------------------------
create table if not exists public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.locations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  name text not null,
  created_at timestamptz not null default now()
);

create index if not exists locations_tenant_id_idx on public.locations(tenant_id);

-- Cashiers extend Supabase auth.users with POS-specific fields. JWT claims
-- (set via app_metadata at provisioning time) carry tenant_id / location_id
-- so the backend can enforce scope without trusting request bodies.
create table if not exists public.cashiers (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  location_id uuid references public.locations(id) on delete set null,
  display_name text not null,
  role text not null check (role in ('cashier','manager','admin')),
  created_at timestamptz not null default now()
);

create index if not exists cashiers_tenant_id_idx on public.cashiers(tenant_id);

-- ---------------------------------------------------------------------------
-- Transactions: unified across all payment rails
-- ---------------------------------------------------------------------------
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  location_id uuid not null references public.locations(id) on delete restrict,
  cashier_id uuid references public.cashiers(id) on delete set null,
  order_id text not null,
  provider text not null check (provider in ('stripe','polkadot','kusama','cash')),
  provider_payment_id text,
  amount_minor integer not null check (amount_minor >= 0),
  currency char(3) not null,
  tip_minor integer not null default 0 check (tip_minor >= 0),
  status text not null check (status in
    ('pending','succeeded','failed','refunded','partial_refund','cancelled')),
  failure_code text,
  failure_reason text,
  raw_event jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_payment_id)
);

create index if not exists transactions_order_id_idx on public.transactions(order_id);
create index if not exists transactions_location_created_idx
  on public.transactions(location_id, created_at desc);
create index if not exists transactions_pending_idx
  on public.transactions(created_at)
  where status = 'pending';

-- Auto-bump updated_at on any row update.
create or replace function public.touch_updated_at() returns trigger
  language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists transactions_touch on public.transactions;
create trigger transactions_touch
  before update on public.transactions
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Webhook idempotency: dedupe by Stripe event id so retries are safe.
-- ---------------------------------------------------------------------------
create table if not exists public.webhook_events (
  id text primary key,                     -- e.g. evt_3OhAbc...
  type text not null,
  received_at timestamptz not null default now(),
  payload jsonb
);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.tenants        enable row level security;
alter table public.locations      enable row level security;
alter table public.cashiers       enable row level security;
alter table public.transactions   enable row level security;
alter table public.webhook_events enable row level security;

-- Helper: current cashier's tenant_id from the cashiers table.
create or replace function public.current_tenant_id() returns uuid
  language sql stable security definer set search_path = public as $$
  select tenant_id from public.cashiers where id = auth.uid();
$$;

-- tenants: read your own tenant only; writes service-role only.
create policy "tenants self read" on public.tenants
  for select using (id = public.current_tenant_id());

-- locations: read your tenant's locations only.
create policy "locations tenant read" on public.locations
  for select using (tenant_id = public.current_tenant_id());

-- cashiers: read peers in your tenant.
create policy "cashiers tenant read" on public.cashiers
  for select using (tenant_id = public.current_tenant_id());

-- transactions: read your tenant only. Writes are service-role only — the
-- Node backend is the only thing that should INSERT/UPDATE here.
create policy "transactions tenant read" on public.transactions
  for select using (tenant_id = public.current_tenant_id());

-- webhook_events: no anon/authenticated access at all (service role bypasses RLS).

-- ---------------------------------------------------------------------------
-- Seed: default tenant + location so the app has somewhere to point before
-- real multi-tenant onboarding is wired up. Idempotent via fixed UUIDs.
-- ---------------------------------------------------------------------------
insert into public.tenants (id, name) values
  ('00000000-0000-0000-0000-000000000001', 'Default Tenant')
  on conflict (id) do nothing;

insert into public.locations (id, tenant_id, name) values
  ('00000000-0000-0000-0000-000000000010',
   '00000000-0000-0000-0000-000000000001',
   'Default Location')
  on conflict (id) do nothing;
