-- ============================================================
-- Fono Gestión — Migración v2
-- Agrega apellido y DNI a pacientes (para las tarjetas)
-- ============================================================
alter table pacientes add column if not exists apellido text;
alter table pacientes add column if not exists dni      text;
