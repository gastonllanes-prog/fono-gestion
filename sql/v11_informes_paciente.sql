-- ============================================================
-- Fono Gestión — Migración v11
-- Historia clínica · Bloque 2: informes formales del paciente
-- (tabla nueva, NO pisa la tabla `informes` del equipo profesional)
-- Los archivos van al bucket privado `adjuntos` (ya existe), URL firmada.
-- ============================================================
create table if not exists informes_paciente (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id  uuid not null references pacientes(id) on delete cascade,
  titulo       text not null,
  fecha        date not null default current_date,
  archivo_path text,
  texto        text,
  created_at   timestamptz not null default now()
);
create index if not exists idx_infpac_owner    on informes_paciente(owner_id);
create index if not exists idx_infpac_paciente on informes_paciente(paciente_id);

alter table informes_paciente enable row level security;
create policy "ip_select" on informes_paciente for select using (owner_id = (select auth.uid()));
create policy "ip_insert" on informes_paciente for insert with check (owner_id = (select auth.uid()));
create policy "ip_update" on informes_paciente for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "ip_delete" on informes_paciente for delete using (owner_id = (select auth.uid()));
