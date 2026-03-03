USE inmobiliaria_db;

CREATE ROLE IF NOT EXISTS 'rol_admin';
CREATE ROLE IF NOT EXISTS 'rol_agente';
CREATE ROLE IF NOT EXISTS 'rol_contador';

GRANT ALL PRIVILEGES ON inmobiliaria_db.* TO 'rol_admin';

GRANT SELECT, INSERT, UPDATE ON inmobiliaria_db.propiedad TO 'rol_agente';
GRANT SELECT, INSERT, UPDATE ON inmobiliaria_db.direccion TO 'rol_agente';
GRANT SELECT, INSERT, UPDATE ON inmobiliaria_db.cliente TO 'rol_agente';
GRANT SELECT, INSERT, UPDATE ON inmobiliaria_db.contrato TO 'rol_agente';
GRANT SELECT ON inmobiliaria_db.tipo_propiedad TO 'rol_agente';
GRANT SELECT ON inmobiliaria_db.estado_propiedad TO 'rol_agente';
GRANT SELECT ON inmobiliaria_db.audit_propiedad_estado TO 'rol_agente';
GRANT SELECT ON inmobiliaria_db.audit_contrato TO 'rol_agente';

GRANT SELECT ON inmobiliaria_db.* TO 'rol_contador';
GRANT INSERT, UPDATE ON inmobiliaria_db.pago TO 'rol_contador';
GRANT SELECT, INSERT, UPDATE ON inmobiliaria_db.reporte_morosidad_mensual TO 'rol_contador';

GRANT EXECUTE ON FUNCTION inmobiliaria_db.fn_calcular_comision_venta 
TO 'rol_admin', 'rol_agente', 'rol_contador';

GRANT EXECUTE ON FUNCTION inmobiliaria_db.fn_deuda_pendiente_arriendo 
TO 'rol_admin', 'rol_agente', 'rol_contador';

GRANT EXECUTE ON FUNCTION inmobiliaria_db.fn_total_disponibles_por_tipo 
TO 'rol_admin', 'rol_agente', 'rol_contador';

CREATE USER IF NOT EXISTS 'admin_inmo'@'%' IDENTIFIED BY 'Admin#2026!';
CREATE USER IF NOT EXISTS 'agente_inmo'@'%' IDENTIFIED BY 'Agente#2026!';
CREATE USER IF NOT EXISTS 'contador_inmo'@'%' IDENTIFIED BY 'Conta#2026!';

GRANT 'rol_admin' TO 'admin_inmo'@'%';
GRANT 'rol_agente' TO 'agente_inmo'@'%';
GRANT 'rol_contador' TO 'contador_inmo'@'%';

SET DEFAULT ROLE 'rol_admin' TO 'admin_inmo'@'%';
SET DEFAULT ROLE 'rol_agente' TO 'agente_inmo'@'%';
SET DEFAULT ROLE 'rol_contador' TO 'contador_inmo'@'%';

FLUSH PRIVILEGES;