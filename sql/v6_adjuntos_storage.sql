-- ============================================================
-- Fono Gestión — Migración v6
-- Adjuntos de informes (PDF, Word, Excel, fotos) en Storage PRIVADO
-- ============================================================
-- Seguridad: bucket privado (no accesible por URL pública). Cada usuario
-- solo puede leer/subir/borrar archivos dentro de SU carpeta (primer
-- segmento del path = su auth.uid()). La descarga se hace con URL firmada
-- temporal desde la app. FASE 2 multiusuario: el owner_id ya deja todo listo.
-- ============================================================

-- ---------- BUCKET privado ----------
insert into storage.buckets (id, name, public)
values ('adjuntos', 'adjuntos', false)
on conflict (id) do nothing;

-- ---------- Políticas de acceso al bucket (storage.objects) ----------
drop policy if exists "adj_select" on storage.objects;
drop policy if exists "adj_insert" on storage.objects;
drop policy if exists "adj_delete" on storage.objects;

create policy "adj_select" on storage.objects for select
  using (bucket_id = 'adjuntos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "adj_insert" on storage.objects for insert
  with check (bucket_id = 'adjuntos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "adj_delete" on storage.objects for delete
  using (bucket_id = 'adjuntos' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- ---------- Metadatos de cada adjunto ----------
create table if not exists informe_adjuntos (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  informe_id  uuid not null references informes(id) on delete cascade,
  nombre      text,            -- nombre original del archivo
  path        text not null,   -- ruta dentro del bucket
  mime        text,
  tamano      bigint,
  created_at  timestamptz not null default now()
);
create index if not exists idx_informe_adjuntos_owner   on informe_adjuntos(owner_id);
create index if not exists idx_informe_adjuntos_informe on informe_adjuntos(informe_id);

alter table informe_adjuntos enable row level security;

drop policy if exists "adj_meta_select" on informe_adjuntos;
drop policy if exists "adj_meta_insert" on informe_adjuntos;
drop policy if exists "adj_meta_delete" on informe_adjuntos;

create policy "adj_meta_select" on informe_adjuntos for select using (owner_id = (select auth.uid()));
create policy "adj_meta_insert" on informe_adjuntos for insert with check (owner_id = (select auth.uid()));
create policy "adj_meta_delete" on informe_adjuntos for delete using (owner_id = (select auth.uid()));
