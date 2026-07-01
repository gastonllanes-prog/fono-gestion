-- ============================================================
-- Fono Gestión — Migración v3
-- Ficha completa de paciente (datos que dictó Nancy)
-- ============================================================
alter table pacientes
  add column if not exists direccion             text,
  add column if not exists madre_nombre          text,
  add column if not exists padre_nombre          text,
  add column if not exists hermanos              text,
  add column if not exists pediatra              text,
  add column if not exists tiene_cud             boolean default false,  -- Certificado Único de Discapacidad
  add column if not exists institucion_educativa text,
  add column if not exists grado                 text,
  add column if not exists integradora           text,  -- maestra integradora (vacío = no tiene)
  add column if not exists equipo_profesional    text,  -- otros profesionales que acompañan
  add column if not exists diagnostico_medico    text,
  add column if not exists diagnostico_fono      text;
