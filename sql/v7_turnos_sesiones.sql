-- ============================================================
-- Fono Gestión — Migración v7
-- Agenda: turnos fijos (plantilla recurrente) + sesiones (turnos concretos)
-- ============================================================
-- turnos_recurrentes = la grilla fija "quién viene qué día y horario"
--   (ej. Renzo, martes 15:00–15:45). Un paciente puede tener varios.
-- sesiones = el turno concreto de una fecha, con su estado y nota clínica.
--   Se puede mover de día sin tocar la plantilla. Es la base de la comisión (S3).
-- dia_semana: 1=Lunes ... 7=Domingo (ISO).
-- ============================================================

-- ---------- TURNOS FIJOS (plantilla) ----------
create table if not exists turnos_recurrentes (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id   uuid not null references pacientes(id) on delete cascade,
  dia_semana    int  not null check (dia_semana between 1 and 7),
  hora_inicio   time not null,
  hora_fin      time,
  activo        boolean not null default true,
  vigencia_desde date not null default current_date,
  created_at    timestamptz not null default now()
);
create index if not exists idx_turnos_owner    on turnos_recurrentes(owner_id);
create index if not exists idx_turnos_paciente on turnos_recurrentes(paciente_id);

alter table turnos_recurrentes enable row level security;
create policy "tr_select" on turnos_recurrentes for select using (owner_id = (select auth.uid()));
create policy "tr_insert" on turnos_recurrentes for insert with check (owner_id = (select auth.uid()));
create policy "tr_update" on turnos_recurrentes for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "tr_delete" on turnos_recurrentes for delete using (owner_id = (select auth.uid()));

-- ---------- SESIONES (turno concreto de una fecha) ----------
create table if not exists sesiones (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id   uuid not null references pacientes(id) on delete cascade,
  turno_id      uuid references turnos_recurrentes(id) on delete set null,  -- de qué plantilla salió (si salió de una)
  fecha         date not null,
  hora_inicio   time,
  hora_fin      time,
  estado        text not null default 'agendada'
                  check (estado in ('agendada','realizada','cancelada_con_aviso','cancelada_mismo_dia','ausente')),
  valor         numeric(12,2),     -- valor pleno de la sesión (base de la comisión). Default desde Configuración (S2).
  nota          text,              -- nota clínica de la sesión (historia clínica)
  created_at    timestamptz not null default now()
);
create index if not exists idx_sesiones_owner    on sesiones(owner_id);
create index if not exists idx_sesiones_paciente on sesiones(paciente_id);
create index if not exists idx_sesiones_fecha    on sesiones(fecha);

alter table sesiones enable row level security;
create policy "ses_select" on sesiones for select using (owner_id = (select auth.uid()));
create policy "ses_insert" on sesiones for insert with check (owner_id = (select auth.uid()));
create policy "ses_update" on sesiones for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "ses_delete" on sesiones for delete using (owner_id = (select auth.uid()));
