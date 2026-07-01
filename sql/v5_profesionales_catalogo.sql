-- ============================================================
-- Fono Gestión — Migración v5
-- Reestructura del equipo profesional:
--   * profesionales = CATÁLOGO global reutilizable entre pacientes
--   * paciente_profesional = vínculo (un profesional atiende a varios pacientes)
--   * informes = historial con fecha por paciente/profesional (B2)
-- Los adjuntos de informes (B3) van con Storage, en otra migración.
-- NOTA: recrea profesionales (no había datos cargados).
-- ============================================================

drop table if exists profesionales cascade;

-- ---------- PROFESIONALES (catálogo) ----------
create table profesionales (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  especialidad text,
  nombre       text,
  apellido     text,
  telefono     text,
  created_at   timestamptz not null default now()
);
create index idx_profesionales_owner on profesionales(owner_id);

alter table profesionales enable row level security;
create policy "prof_select" on profesionales for select using (owner_id = (select auth.uid()));
create policy "prof_insert" on profesionales for insert with check (owner_id = (select auth.uid()));
create policy "prof_update" on profesionales for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "prof_delete" on profesionales for delete using (owner_id = (select auth.uid()));

-- ---------- VÍNCULO paciente ↔ profesional ----------
create table paciente_profesional (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id    uuid not null references pacientes(id) on delete cascade,
  profesional_id uuid not null references profesionales(id) on delete cascade,
  created_at     timestamptz not null default now(),
  unique (paciente_id, profesional_id)
);
create index idx_pacprof_owner      on paciente_profesional(owner_id);
create index idx_pacprof_paciente   on paciente_profesional(paciente_id);
create index idx_pacprof_profesional on paciente_profesional(profesional_id);

alter table paciente_profesional enable row level security;
create policy "pacprof_select" on paciente_profesional for select using (owner_id = (select auth.uid()));
create policy "pacprof_insert" on paciente_profesional for insert with check (owner_id = (select auth.uid()));
create policy "pacprof_update" on paciente_profesional for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "pacprof_delete" on paciente_profesional for delete using (owner_id = (select auth.uid()));

-- ---------- INFORMES (historial, B2) ----------
create table informes (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id    uuid not null references pacientes(id) on delete cascade,
  profesional_id uuid references profesionales(id) on delete set null,  -- null = observación general de Nancy
  fecha          date not null default current_date,
  texto          text,
  created_at     timestamptz not null default now()
);
create index idx_informes_owner      on informes(owner_id);
create index idx_informes_paciente   on informes(paciente_id);
create index idx_informes_profesional on informes(profesional_id);

alter table informes enable row level security;
create policy "inf_select" on informes for select using (owner_id = (select auth.uid()));
create policy "inf_insert" on informes for insert with check (owner_id = (select auth.uid()));
create policy "inf_update" on informes for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "inf_delete" on informes for delete using (owner_id = (select auth.uid()));
