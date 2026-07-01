-- ============================================================
-- Fono Gestión — Migración v1
-- Módulo: Pacientes + catálogo de Obras Sociales
-- ============================================================
-- Convenciones (Fase 1, monousuario):
--   * owner_id en TODAS las tablas, con DEFAULT auth.uid().
--     La app no necesita mandarlo: lo pone la base sola.
--   * RLS prendido y filtrando por owner_id = (select auth.uid()).
--   * Índice en owner_id y en cada FK.
--
-- FASE 2 (multiusuario, NO ahora): cuando entre una supervisora
--   con acceso a varias profesionales, habrá que agregar policies
--   extra basadas en un rol; el owner_id ya deja todo preparado.
-- ============================================================

-- ---------- OBRAS SOCIALES ----------
create table if not exists obras_sociales (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nombre        text not null,
  valor_sesion  numeric(12,2),            -- lo que paga la OS por sesión
  demora_dias   int,                      -- demora estimada de pago (días)
  activo        boolean not null default true,
  created_at    timestamptz not null default now()
);

create index if not exists idx_obras_sociales_owner on obras_sociales(owner_id);

alter table obras_sociales enable row level security;

create policy "os_select" on obras_sociales for select using (owner_id = (select auth.uid()));
create policy "os_insert" on obras_sociales for insert with check (owner_id = (select auth.uid()));
create policy "os_update" on obras_sociales for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "os_delete" on obras_sociales for delete using (owner_id = (select auth.uid()));


-- ---------- PACIENTES ----------
create table if not exists pacientes (
  id                uuid primary key default gen_random_uuid(),
  owner_id          uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nombre            text not null,
  fecha_nacimiento  date,                 -- todos menores
  tutor_nombre      text,
  tutor_contacto    text,                 -- teléfono / lo que use Nancy
  cobertura_tipo    text not null default 'particular'
                      check (cobertura_tipo in ('particular','obra_social')),
  obra_social_id    uuid references obras_sociales(id) on delete set null,
  foto_url          text,                 -- Storage privado (módulo posterior)
  estado            text not null default 'activo'
                      check (estado in ('activo','inactivo')),
  created_at        timestamptz not null default now()
);

create index if not exists idx_pacientes_owner       on pacientes(owner_id);
create index if not exists idx_pacientes_obra_social on pacientes(obra_social_id);

alter table pacientes enable row level security;

create policy "pac_select" on pacientes for select using (owner_id = (select auth.uid()));
create policy "pac_insert" on pacientes for insert with check (owner_id = (select auth.uid()));
create policy "pac_update" on pacientes for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "pac_delete" on pacientes for delete using (owner_id = (select auth.uid()));
