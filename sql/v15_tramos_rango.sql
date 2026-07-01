-- ============================================================
-- Fono Gestión — Migración v15
-- Tramos de comisión con rango (de X a Y) + base de cálculo configurable
-- ============================================================
alter table reglas_comision add column if not exists hasta int;  -- null = sin tope ("desde X en adelante")

alter table config add column if not exists base_comision text not null default 'sesiones';
alter table config drop constraint if exists chk_base_comision;
alter table config add constraint chk_base_comision check (base_comision in ('sesiones','pacientes'));
