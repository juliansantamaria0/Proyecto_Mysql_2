DROP DATABASE IF EXISTS inmobiliaria_db;
CREATE DATABASE inmobiliaria_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE inmobiliaria_db;

SET sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

/* ---------------------------
   1) CATALOGOS
   --------------------------- */
CREATE TABLE tipo_propiedad (
  id_tipo TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre  VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE estado_propiedad (
  id_estado TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre    VARCHAR(20) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE configuracion (
  clave VARCHAR(50) PRIMARY KEY,
  valor VARCHAR(200) NOT NULL
) ENGINE=InnoDB;

/* Insert inicial  */
INSERT INTO tipo_propiedad (nombre) VALUES ('CASA'), ('APARTAMENTO'), ('LOCAL');
INSERT INTO estado_propiedad (nombre) VALUES ('DISPONIBLE'), ('ARRENDADA'), ('VENDIDA'), ('EN_MANTENIMIENTO');
INSERT INTO configuracion (clave, valor) VALUES ('COMISION_VENTA_DEFECTO', '0.03');

/* ---------------------------
   2) ENTIDADES PRINCIPALES
   --------------------------- */
CREATE TABLE direccion (
  id_direccion BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  ciudad       VARCHAR(80) NOT NULL,
  barrio       VARCHAR(80) NULL,
  direccion    VARCHAR(120) NOT NULL,
  referencia   VARCHAR(200) NULL
) ENGINE=InnoDB;

CREATE TABLE propiedad (
  id_propiedad   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_tipo        TINYINT UNSIGNED NOT NULL,
  id_estado      TINYINT UNSIGNED NOT NULL,
  id_direccion   BIGINT UNSIGNED NOT NULL,
  area_m2        DECIMAL(10,2) NOT NULL,
  habitaciones   TINYINT UNSIGNED NULL,
  banos          TINYINT UNSIGNED NULL,
  precio_venta   DECIMAL(14,2) NULL,
  canon_mensual  DECIMAL(14,2) NULL,
  descripcion    VARCHAR(300) NULL,
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prop_tipo   FOREIGN KEY (id_tipo) REFERENCES tipo_propiedad(id_tipo),
  CONSTRAINT fk_prop_estado FOREIGN KEY (id_estado) REFERENCES estado_propiedad(id_estado),
  CONSTRAINT fk_prop_dir    FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion)
) ENGINE=InnoDB;

CREATE TABLE cliente (
  id_cliente BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tipo_doc   VARCHAR(10) NOT NULL,
  nro_doc    VARCHAR(30) NOT NULL,
  nombres    VARCHAR(80) NOT NULL,
  apellidos  VARCHAR(80) NOT NULL,
  telefono   VARCHAR(30) NULL,
  email      VARCHAR(120) NULL,
  fecha_alta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_cliente_doc (tipo_doc, nro_doc)
) ENGINE=InnoDB;

CREATE TABLE empleado (
  id_empleado BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tipo_doc    VARCHAR(10) NOT NULL,
  nro_doc     VARCHAR(30) NOT NULL,
  nombres     VARCHAR(80) NOT NULL,
  apellidos   VARCHAR(80) NOT NULL,
  email       VARCHAR(120) NULL,
  telefono    VARCHAR(30) NULL,
  rol_negocio ENUM('AGENTE','CONTADOR','ADMIN') NOT NULL DEFAULT 'AGENTE',
  activo      TINYINT(1) NOT NULL DEFAULT 1,
  fecha_alta  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_empleado_doc (tipo_doc, nro_doc)
) ENGINE=InnoDB;

/* ---------------------------
   3) CONTRATOS Y PAGOS
   --------------------------- */
CREATE TABLE contrato (
  id_contrato  BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tipo         ENUM('VENTA','ARRIENDO') NOT NULL,
  id_propiedad BIGINT UNSIGNED NOT NULL,
  id_cliente   BIGINT UNSIGNED NOT NULL,
  id_agente    BIGINT UNSIGNED NOT NULL,
  fecha_firma  DATE NOT NULL,
  fecha_inicio DATE NULL,
  fecha_fin    DATE NULL,
  valor_total  DECIMAL(14,2) NULL,
  canon_mensual DECIMAL(14,2) NULL,
  deposito     DECIMAL(14,2) NULL,
  comision_rate DECIMAL(6,4) NULL,
  estado       ENUM('BORRADOR','VIGENTE','TERMINADO','ANULADO') NOT NULL DEFAULT 'VIGENTE',
  creado_en    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_contrato_prop    FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad),
  CONSTRAINT fk_contrato_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_contrato_agente  FOREIGN KEY (id_agente) REFERENCES empleado(id_empleado)
) ENGINE=InnoDB;

CREATE TABLE pago (
  id_pago           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_contrato       BIGINT UNSIGNED NOT NULL,
  periodo           CHAR(7) NOT NULL, -- YYYY-MM
  fecha_vencimiento DATE NOT NULL,
  monto_programado  DECIMAL(14,2) NOT NULL,
  monto_pagado      DECIMAL(14,2) NOT NULL DEFAULT 0,
  fecha_pago        DATE NULL,
  estado            ENUM('PENDIENTE','PAGADO','PARCIAL','VENCIDO') NOT NULL DEFAULT 'PENDIENTE',
  registrado_en     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pago_contrato FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato),
  UNIQUE KEY uk_pago_periodo (id_contrato, periodo)
) ENGINE=InnoDB;

/* ---------------------------
   4) AUDITORÍA
   --------------------------- */
CREATE TABLE audit_propiedad_estado (
  id_audit        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_propiedad    BIGINT UNSIGNED NOT NULL,
  estado_anterior VARCHAR(20) NOT NULL,
  estado_nuevo    VARCHAR(20) NOT NULL,
  cambiado_en     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cambiado_por    VARCHAR(100) NULL,
  CONSTRAINT fk_audit_prop FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
) ENGINE=InnoDB;

CREATE TABLE audit_contrato (
  id_audit    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_contrato BIGINT UNSIGNED NOT NULL,
  tipo        ENUM('VENTA','ARRIENDO') NOT NULL,
  evento      VARCHAR(40) NOT NULL,
  creado_en   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por  VARCHAR(100) NULL,
  CONSTRAINT fk_audit_contrato FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato)
) ENGINE=InnoDB;

/* ---------------------------
   5) REPORTES
   --------------------------- */
CREATE TABLE reporte_morosidad_mensual (
  id_reporte      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  mes_reporte     CHAR(7) NOT NULL, -- YYYY-MM
  id_contrato     BIGINT UNSIGNED NOT NULL,
  id_cliente      BIGINT UNSIGNED NOT NULL,
  id_propiedad    BIGINT UNSIGNED NOT NULL,
  deuda_pendiente DECIMAL(14,2) NOT NULL,
  generado_en     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_reporte (mes_reporte, id_contrato),
  CONSTRAINT fk_rep_contrato  FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato),
  CONSTRAINT fk_rep_cliente   FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_rep_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
) ENGINE=InnoDB;

/* ---------------------------
   6) ÍNDICES
   --------------------------- */
CREATE INDEX idx_prop_estado_tipo ON propiedad (id_estado, id_tipo);
CREATE INDEX idx_contrato_prop_tipo_estado ON contrato (id_propiedad, tipo, estado);
CREATE INDEX idx_contrato_cliente ON contrato (id_cliente);
CREATE INDEX idx_pago_contrato_estado_venc ON pago (id_contrato, estado, fecha_vencimiento);

/* =========================================================
   7) FUNCIONES 
   ========================================================= */
DELIMITER $$

CREATE FUNCTION fn_calcular_comision_venta(p_id_contrato BIGINT UNSIGNED)
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN
  DECLARE v_tipo VARCHAR(10);
  DECLARE v_valor DECIMAL(14,2);
  DECLARE v_rate DECIMAL(6,4);
  DECLARE v_def  DECIMAL(6,4);

  SELECT tipo, COALESCE(valor_total,0), comision_rate
    INTO v_tipo, v_valor, v_rate
  FROM contrato
  WHERE id_contrato = p_id_contrato;

  IF v_tipo <> 'VENTA' THEN
    RETURN 0;
  END IF;

  SELECT CAST(valor AS DECIMAL(6,4)) INTO v_def
  FROM configuracion
  WHERE clave = 'COMISION_VENTA_DEFECTO';

  RETURN ROUND(v_valor * COALESCE(v_rate, v_def), 2);
END$$

CREATE FUNCTION fn_deuda_pendiente_arriendo(p_id_contrato BIGINT UNSIGNED)
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN
  DECLARE v_tipo VARCHAR(10);
  DECLARE v_deuda DECIMAL(14,2);

  SELECT tipo INTO v_tipo
  FROM contrato
  WHERE id_contrato = p_id_contrato;

  IF v_tipo <> 'ARRIENDO' THEN
    RETURN 0;
  END IF;

  SELECT COALESCE(SUM(monto_programado - monto_pagado), 0)
    INTO v_deuda
  FROM pago
  WHERE id_contrato = p_id_contrato
    AND fecha_vencimiento <= CURRENT_DATE()
    AND (monto_programado - monto_pagado) > 0;

  RETURN ROUND(v_deuda, 2);
END$$

CREATE FUNCTION fn_total_disponibles_por_tipo(p_tipo VARCHAR(30))
RETURNS INT
READS SQL DATA
BEGIN
  DECLARE v_id_estado TINYINT UNSIGNED;
  DECLARE v_total INT;

  SELECT id_estado INTO v_id_estado
  FROM estado_propiedad
  WHERE nombre = 'DISPONIBLE';

  SELECT COUNT(*)
    INTO v_total
  FROM propiedad p
  JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo
  WHERE p.id_estado = v_id_estado
    AND t.nombre = p_tipo;

  RETURN v_total;
END$$

DELIMITER ;

/* =========================================================
   8) TRIGGERS
   ========================================================= */
DELIMITER $$

CREATE TRIGGER trg_propiedad_audit_estado
BEFORE UPDATE ON propiedad
FOR EACH ROW
BEGIN
  DECLARE v_old VARCHAR(20);
  DECLARE v_new VARCHAR(20);

  IF OLD.id_estado <> NEW.id_estado THEN
    SELECT nombre INTO v_old FROM estado_propiedad WHERE id_estado = OLD.id_estado;
    SELECT nombre INTO v_new FROM estado_propiedad WHERE id_estado = NEW.id_estado;

    INSERT INTO audit_propiedad_estado(id_propiedad, estado_anterior, estado_nuevo, cambiado_por)
    VALUES (OLD.id_propiedad, v_old, v_new, USER());
  END IF;
END$$

CREATE TRIGGER trg_contrato_audit_insert
AFTER INSERT ON contrato
FOR EACH ROW
BEGIN
  INSERT INTO audit_contrato(id_contrato, tipo, evento, creado_por)
  VALUES (NEW.id_contrato, NEW.tipo, 'NUEVO_CONTRATO', USER());
END$$

CREATE TRIGGER trg_contrato_actualiza_estado_prop
AFTER INSERT ON contrato
FOR EACH ROW
BEGIN
  DECLARE v_estado_arrendada TINYINT UNSIGNED;
  DECLARE v_estado_vendida   TINYINT UNSIGNED;

  SELECT id_estado INTO v_estado_arrendada FROM estado_propiedad WHERE nombre='ARRENDADA';
  SELECT id_estado INTO v_estado_vendida   FROM estado_propiedad WHERE nombre='VENDIDA';

  IF NEW.estado = 'VIGENTE' THEN
    IF NEW.tipo = 'ARRIENDO' THEN
      UPDATE propiedad
      SET id_estado = v_estado_arrendada
      WHERE id_propiedad = NEW.id_propiedad;
    ELSEIF NEW.tipo = 'VENTA' THEN
      UPDATE propiedad
      SET id_estado = v_estado_vendida
      WHERE id_propiedad = NEW.id_propiedad;
    END IF;
  END IF;
END$$

DELIMITER ;

/* =========================================================
   9) EVENTO PROGRAMADO MENSUAL
   ========================================================= */
DELIMITER $$

CREATE EVENT ev_reporte_morosidad_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS (TIMESTAMP(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')) + INTERVAL 1 MONTH)
DO
BEGIN
  DECLARE v_mes CHAR(7);
  SET v_mes = DATE_FORMAT(CURRENT_DATE() - INTERVAL 1 MONTH, '%Y-%m');

  INSERT INTO reporte_morosidad_mensual (mes_reporte, id_contrato, id_cliente, id_propiedad, deuda_pendiente)
  SELECT
    v_mes,
    c.id_contrato,
    c.id_cliente,
    c.id_propiedad,
    fn_deuda_pendiente_arriendo(c.id_contrato) AS deuda
  FROM contrato c
  WHERE c.tipo = 'ARRIENDO'
    AND c.estado = 'VIGENTE'
    AND fn_deuda_pendiente_arriendo(c.id_contrato) > 0
  ON DUPLICATE KEY UPDATE
    deuda_pendiente = VALUES(deuda_pendiente),
    generado_en = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

/* =========================================================
   10) ROLES / USUARIOS / PRIVILEGIOS
   ========================================================= */
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

GRANT EXECUTE ON FUNCTION inmobiliaria_db.fn_calcular_comision_venta TO 'rol_admin', 'rol_agente', 'rol_contador';
GRANT EXECUTE ON FUNCTION inmobiliaria_db.fn_deuda_pendiente_arriendo TO 'rol_admin', 'rol_agente', 'rol_contador';
GRANT EXECUTE ON FUNCTION inmobiliaria_db.fn_total_disponibles_por_tipo TO 'rol_admin', 'rol_agente', 'rol_contador';

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

/* =========================================================
   11) DATOS DE PRUEBA
   ========================================================= */

-- CONFIGuaracion
INSERT INTO configuracion (clave, valor) VALUES
('IVA','0.19'),
('MONEDA','COP');

-- DIRECCIONES
INSERT INTO direccion (ciudad, barrio, direccion, referencia) VALUES
('Bogotá','Chapinero','Cra 7 #45-10','Frente a parque'),
('Medellín','El Poblado','Calle 10 #30-25','Cerca a centro comercial'),
('Cali','Granada','Av 6N #15-40','Zona gastronómica');

-- EMPLEADOS 
INSERT INTO empleado (tipo_doc, nro_doc, nombres, apellidos, email, telefono, rol_negocio, activo) VALUES
('CC','1001','Ana','Gómez','ana@inmo.com','3001111111','AGENTE',1),
('CC','1002','Luis','Pérez','luis@inmo.com','3002222222','CONTADOR',1),
('CC','1003','Laura','Martínez','laura@inmo.com','3003333333','ADMIN',1);

-- CLIENTES
INSERT INTO cliente (tipo_doc, nro_doc, nombres, apellidos, telefono, email) VALUES
('CC','3001','Carlos','Ruiz','3004444444','carlos@mail.com'),
('CC','3002','María','López','3005555555','maria@mail.com'),
('CC','3003','Jorge','Ramírez','3006666666','jorge@mail.com');

-- PROPIEDADES 
INSERT INTO propiedad (id_tipo, id_estado, id_direccion, area_m2, habitaciones, banos, precio_venta, canon_mensual, descripcion)
VALUES
(1, 1, 1, 120.00, 3, 2, 450000000.00, 3000000.00, 'Casa amplia familiar'),
(2, 1, 2,  80.00, 2, 2, 320000000.00, 2200000.00, 'Apartamento moderno'),
(3, 1, 3,  60.00, 1, 1, 250000000.00, 1800000.00, 'Local comercial céntrico');

-- CONTRATOS 
INSERT INTO contrato
(tipo, id_propiedad, id_cliente, id_agente, fecha_firma, fecha_inicio, fecha_fin, valor_total, canon_mensual, deposito, comision_rate, estado)
VALUES
('VENTA',    1, 1, 1, CURDATE(), NULL, NULL, 450000000.00, NULL, NULL, 0.03, 'VIGENTE'),
('ARRIENDO', 2, 2, 1, CURDATE(), CURDATE(), DATE_ADD(CURDATE(), INTERVAL 12 MONTH), NULL, 2200000.00, 2200000.00, NULL, 'VIGENTE'),
('ARRIENDO', 3, 3, 1, CURDATE(), CURDATE(), DATE_ADD(CURDATE(), INTERVAL 6 MONTH),  NULL, 1800000.00, 1800000.00, NULL, 'VIGENTE');

-- PAGOS 
INSERT INTO pago
(id_contrato, periodo, fecha_vencimiento, monto_programado, monto_pagado, fecha_pago, estado)
VALUES
(2, DATE_FORMAT(CURDATE(),'%Y-%m'), LAST_DAY(CURDATE()), 2200000.00, 2200000.00, CURDATE(), 'PAGADO'),
(2, DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL 1 MONTH),'%Y-%m'),
    LAST_DAY(DATE_ADD(CURDATE(),INTERVAL 1 MONTH)), 2200000.00, 0.00, NULL, 'PENDIENTE'),
(3, DATE_FORMAT(CURDATE(),'%Y-%m'), LAST_DAY(CURDATE()), 1800000.00, 1000000.00, CURDATE(), 'PARCIAL');

-- REPORTE MOROSIDAD 
INSERT INTO reporte_morosidad_mensual (mes_reporte, id_contrato, id_cliente, id_propiedad, deuda_pendiente)
VALUES
(DATE_FORMAT(CURDATE(),'%Y-%m'), 2, 2, 2, 2200000.00),
(DATE_FORMAT(CURDATE(),'%Y-%m'), 3, 3, 3, 800000.00),
(DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 MONTH),'%Y-%m'), 2, 2, 2, 0.00);


 --  prueba:
SELECT fn_calcular_comision_venta(1);
SELECT fn_deuda_pendiente_arriendo(2);
SELECT fn_total_disponibles_por_tipo('CASA');
SELECT * FROM audit_contrato;
SELECT * FROM audit_propiedad_estado;
