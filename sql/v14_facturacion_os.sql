-- ============================================================
-- Fono Gestión — Migración v14
-- Módulo financiero · F3: facturación a obras sociales + aging
-- ============================================================
-- Lo facturado NO mapea 1 a 1 con las sesiones reales: se registran
-- por separado y la brecha queda siempre visible (regla 3).
-- Aging = días desde fecha_presentacion hasta que se cobra (regla 4).
create table if not exists facturacion_os (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid not null default auth.uid() references auth.users(id) on delete cascade,
  obra_social_id       uuid not null references obras_sociales(id) on delete cascade,
  paciente_id          uuid references pacientes(id) on delete set null,  -- null = factura global de la OS
  periodo              text not null,          -- mes facturado, formato YYYY-MM
  sesiones_facturadas  int not null default 0,
  monto                numeric(12,2) not null,
  fecha_presentacion   date not null default current_date,
  estado               text not null default 'pendiente' check (estado in ('pendiente','cobrada')),
  fecha_cobro          date,
  monto_cobrado        numeric(12,2),
  created_at           timestamptz not null default now()
);
create index if not exists idx_factos_owner   on facturacion_os(owner_id);
create index if not exists idx_factos_os      on facturacion_os(obra_social_id);
create index if not exists idx_factos_estado  on facturacion_os(estado);

alter table facturacion_os enable row level security;
create policy "fo_select" on facturacion_os for select using (owner_id = (select auth.uid()));
create policy "fo_insert" on facturacion_os for insert with check (owner_id = (select auth.uid()));
create policy "fo_update" on facturacion_os for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "fo_delete" on facturacion_os for delete using (owner_id = (select auth.uid()));
