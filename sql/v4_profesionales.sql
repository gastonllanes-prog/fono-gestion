-- ============================================================
-- Fono Gestión — Migración v4
-- Equipo profesional: varios profesionales por paciente,
-- cada uno con lo que está trabajando / informes.
-- ============================================================
create table if not exists profesionales (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id  uuid not null references pacientes(id) on delete cascade,
  especialidad text,                 -- Psicopedagoga, T.O., etc.
  nombre       text,
  apellido     text,
  telefono     text,
  trabajando   text,                 -- qué está trabajando / sugerencias / informes
  created_at   timestamptz not null default now()
);

create index if not exists idx_profesionales_owner    on profesionales(owner_id);
create index if not exists idx_profesionales_paciente on profesionales(paciente_id);

alter table profesionales enable row level security;

create policy "prof_select" on profesionales for select using (owner_id = (select auth.uid()));
create policy "prof_insert" on profesionales for insert with check (owner_id = (select auth.uid()));
create policy "prof_update" on profesionales for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "prof_delete" on profesionales for delete using (owner_id = (select auth.uid()));
