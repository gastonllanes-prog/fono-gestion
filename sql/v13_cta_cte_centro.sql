-- ============================================================
-- Fono Gestión — Migración v13
-- Módulo financiero · F2: cuenta corriente con el centro
-- ============================================================
-- Movimientos: tipo 'comision' = débito semanal (congelado al cerrar la
-- semana; el desglose queda en `detalle` y NUNCA se recalcula) ·
-- tipo 'pago' = pago de Nancy al centro.
-- Saldo = Σ pagos − Σ comisiones (negativo = le debe al centro).
-- ============================================================
create table if not exists cta_cte_centro (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tipo          text not null check (tipo in ('comision','pago')),
  semana_inicio date,                -- lunes de la semana (solo en tipo 'comision')
  monto         numeric(12,2) not null,
  detalle       jsonb,               -- desglose congelado del cálculo / nota del pago
  fecha         date not null default current_date,
  created_at    timestamptz not null default now()
);
create index if not exists idx_ctacte_owner on cta_cte_centro(owner_id);
create index if not exists idx_ctacte_fecha on cta_cte_centro(fecha);
-- una sola comisión por semana (no se puede cerrar dos veces)
create unique index if not exists uq_ctacte_semana
  on cta_cte_centro(owner_id, semana_inicio) where (tipo = 'comision');

alter table cta_cte_centro enable row level security;
create policy "cc_select" on cta_cte_centro for select using (owner_id = (select auth.uid()));
create policy "cc_insert" on cta_cte_centro for insert with check (owner_id = (select auth.uid()));
create policy "cc_update" on cta_cte_centro for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "cc_delete" on cta_cte_centro for delete using (owner_id = (select auth.uid()));
