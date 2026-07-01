-- ============================================================
-- Fono Gestión — Migración v9
-- Color identificatorio por paciente (se ve en la agenda)
-- ============================================================
alter table pacientes add column if not exists color text;
