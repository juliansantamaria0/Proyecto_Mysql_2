CREATE TABLE direccion (
  id_direccion BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  ciudad       VARCHAR(80) NOT NULL,
  barrio       VARCHAR(80),
  direccion    VARCHAR(120) NOT NULL,
  referencia   VARCHAR(200)
) ENGINE=InnoDB;

CREATE TABLE propiedad (
  id_propiedad   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_tipo        TINYINT UNSIGNED NOT NULL,
  id_estado      TINYINT UNSIGNED NOT NULL,
  id_direccion   BIGINT UNSIGNED NOT NULL,
  area_m2        DECIMAL(10,2) NOT NULL,
  habitaciones   TINYINT UNSIGNED,
  banos          TINYINT UNSIGNED,
  precio_venta   DECIMAL(14,2),
  canon_mensual  DECIMAL(14,2),
  descripcion    VARCHAR(300),
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tipo) REFERENCES tipo_propiedad(id_tipo),
  FOREIGN KEY (id_estado) REFERENCES estado_propiedad(id_estado),
  FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion)
) ENGINE=InnoDB;

CREATE TABLE cliente (
  id_cliente BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tipo_doc   VARCHAR(10) NOT NULL,
  nro_doc    VARCHAR(30) NOT NULL,
  nombres    VARCHAR(80) NOT NULL,
  apellidos  VARCHAR(80) NOT NULL,
  telefono   VARCHAR(30),
  email      VARCHAR(120),
  fecha_alta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_cliente_doc (tipo_doc, nro_doc)
) ENGINE=InnoDB;

CREATE TABLE empleado (
  id_empleado BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tipo_doc    VARCHAR(10) NOT NULL,
  nro_doc     VARCHAR(30) NOT NULL,
  nombres     VARCHAR(80) NOT NULL,
  apellidos   VARCHAR(80) NOT NULL,
  email       VARCHAR(120),
  telefono    VARCHAR(30),
  rol_negocio ENUM('AGENTE','CONTADOR','ADMIN') NOT NULL DEFAULT 'AGENTE',
  activo      TINYINT(1) NOT NULL DEFAULT 1,
  fecha_alta  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_empleado_doc (tipo_doc, nro_doc)
) ENGINE=InnoDB;