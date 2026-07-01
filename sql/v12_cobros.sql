-- ============================================================
-- Fono Gestión — Migración v12
-- Módulo financiero · F1: cobros de pacientes + congelar valor de sesión
-- ============================================================

-- ---------- COBROS ----------
create table if not exists cobros (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id uuid not null references pacientes(id) on delete cascade,
  sesion_id   uuid references sesiones(id) on delete set null,  -- null = pago suelto
  monto       numeric(12,2) not null,
  medio       text not null check (medio in ('efectivo','transferencia')),
  facturado   boolean not null default false,   -- transferencia ⇒ requiere factura
  fecha       date not null default current_date,
  nota        text,
  created_at  timestamptz not null default now()
);
create index if not exists idx_cobros_owner    on cobros(owner_id);
create index if not exists idx_cobros_paciente on cobros(paciente_id);
create index if not exists idx_cobros_sesion   on cobros(sesion_id);
create index if not exists idx_cobros_fecha    on cobros(fecha);

alter table cobros enable row level security;
create policy "cob_select" on cobros for select using (owner_id = (select auth.uid()));
create policy "cob_insert" on cobros for insert with check (owner_id = (select auth.uid()));
create policy "cob_update" on cobros for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "cob_delete" on cobros for delete using (owner_id = (select auth.uid()));

-- ---------- Congelar valor en sesiones existentes ----------
-- Las sesiones ya cargadas toman el valor global actual; las nuevas
-- lo congelan desde la app al crearse.
update sesiones s
set valor = c.valor_sesion
from config c
where c.owner_id = s.owner_id
  and s.valor is null
  and c.valor_sesion is not null;
