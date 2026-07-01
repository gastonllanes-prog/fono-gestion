-- ============================================================
-- Fono Gestión — Migración v10
-- Historia clínica · Bloque 1: notas de sesión
-- ============================================================
create table if not exists notas_sesion (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id uuid not null references pacientes(id) on delete cascade,
  fecha       date not null default current_date,
  texto       text,
  origen      text not null default 'manual' check (origen in ('manual','agenda')),
  sesion_id   uuid references sesiones(id) on delete set null,  -- si la nota nació de la agenda
  created_at  timestamptz not null default now()
);
create index if not exists idx_notas_owner    on notas_sesion(owner_id);
create index if not exists idx_notas_paciente on notas_sesion(paciente_id);
create index if not exists idx_notas_sesion   on notas_sesion(sesion_id);

alter table notas_sesion enable row level security;
create policy "ns_select" on notas_sesion for select using (owner_id = (select auth.uid()));
create policy "ns_insert" on notas_sesion for insert with check (owner_id = (select auth.uid()));
create policy "ns_update" on notas_sesion for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "ns_delete" on notas_sesion for delete using (owner_id = (select auth.uid()));
