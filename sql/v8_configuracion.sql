-- ============================================================
-- Fono Gestión — Migración v8
-- Configuración: valor de sesión + reglas de comisión y cancelación (con vigencia)
-- ============================================================
-- El cálculo de una sesión usa la regla vigente a la FECHA de esa sesión
-- (cada regla tiene vigencia_desde). Un cambio NO recalcula el histórico.
-- El valor de cada sesión se congela en la propia sesión (campo sesiones.valor),
-- así config.valor_sesion es sólo el valor por defecto para las nuevas.
-- ============================================================

-- ---------- CONFIG (una fila por usuaria) ----------
create table if not exists config (
  owner_id      uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  valor_sesion  numeric(12,2),
  updated_at    timestamptz not null default now()
);
alter table config enable row level security;
create policy "cfg_select" on config for select using (owner_id = (select auth.uid()));
create policy "cfg_insert" on config for insert with check (owner_id = (select auth.uid()));
create policy "cfg_update" on config for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

-- ---------- TRAMOS DE COMISIÓN ----------
-- "a partir de desde_sesiones por semana, la comisión es porcentaje %"
create table if not exists reglas_comision (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  desde_sesiones int not null,
  porcentaje     numeric(5,2) not null,     -- % de comisión al centro
  vigencia_desde date not null default current_date,
  created_at     timestamptz not null default now()
);
create index if not exists idx_reglas_comision_owner on reglas_comision(owner_id);
alter table reglas_comision enable row level security;
create policy "rc_select" on reglas_comision for select using (owner_id = (select auth.uid()));
create policy "rc_insert" on reglas_comision for insert with check (owner_id = (select auth.uid()));
create policy "rc_update" on reglas_comision for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "rc_delete" on reglas_comision for delete using (owner_id = (select auth.uid()));

-- ---------- POLÍTICA DE CANCELACIÓN ----------
-- "con horas_aviso de aviso, el paciente paga pct_paciente % y se paga pct_comision % de comisión"
create table if not exists reglas_cancelacion (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  horas_aviso    int not null,              -- horas de aviso mínimas para este tramo
  pct_paciente   numeric(5,2) not null,     -- % del valor que paga el paciente
  pct_comision   numeric(5,2) not null,     -- % de comisión que se paga al centro
  vigencia_desde date not null default current_date,
  created_at     timestamptz not null default now()
);
create index if not exists idx_reglas_cancelacion_owner on reglas_cancelacion(owner_id);
alter table reglas_cancelacion enable row level security;
create policy "rcl_select" on reglas_cancelacion for select using (owner_id = (select auth.uid()));
create policy "rcl_insert" on reglas_cancelacion for insert with check (owner_id = (select auth.uid()));
create policy "rcl_update" on reglas_cancelacion for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "rcl_delete" on reglas_cancelacion for delete using (owner_id = (select auth.uid()));
