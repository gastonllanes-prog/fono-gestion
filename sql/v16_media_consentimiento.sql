-- ============================================================
-- Fono Gestión — Migración v16
-- Historia clínica · Bloque 3: fotos/videos/archivos + consentimiento
-- ============================================================
alter table pacientes
  add column if not exists consentimiento_firmado boolean not null default false,
  add column if not exists consentimiento_fecha   date;

create table if not exists media (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  paciente_id  uuid not null references pacientes(id) on delete cascade,
  tipo         text not null check (tipo in ('foto','video','archivo')),
  archivo_path text not null,           -- bucket privado `adjuntos`, acceso solo por URL firmada
  nota         text,
  fecha_subida date not null default current_date,
  created_at   timestamptz not null default now()
);
create index if not exists idx_media_owner    on media(owner_id);
create index if not exists idx_media_paciente on media(paciente_id);

alter table media enable row level security;
create policy "md_select" on media for select using (owner_id = (select auth.uid()));
create policy "md_insert" on media for insert with check (owner_id = (select auth.uid()));
create policy "md_update" on media for update using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "md_delete" on media for delete using (owner_id = (select auth.uid()));
