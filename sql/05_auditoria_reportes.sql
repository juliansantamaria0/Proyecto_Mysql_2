CREATE TABLE audit_propiedad_estado (
  id_audit        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_propiedad    BIGINT UNSIGNED NOT NULL,
  estado_anterior VARCHAR(20) NOT NULL,
  estado_nuevo    VARCHAR(20) NOT NULL,
  cambiado_en     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cambiado_por    VARCHAR(100),
  FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
) ENGINE=InnoDB;

CREATE TABLE audit_contrato (
  id_audit    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_contrato BIGINT UNSIGNED NOT NULL,
  tipo        ENUM('VENTA','ARRIENDO') NOT NULL,
  evento      VARCHAR(40) NOT NULL,
  creado_en   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por  VARCHAR(100),
  FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato)
) ENGINE=InnoDB;

CREATE TABLE reporte_morosidad_mensual (
  id_reporte      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  mes_reporte     CHAR(7) NOT NULL,
  id_contrato     BIGINT UNSIGNED NOT NULL,
  id_cliente      BIGINT UNSIGNED NOT NULL,
  id_propiedad    BIGINT UNSIGNED NOT NULL,
  deuda_pendiente DECIMAL(14,2) NOT NULL,
  generado_en     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_reporte (mes_reporte, id_contrato),
  FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato),
  FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
) ENGINE=InnoDB;