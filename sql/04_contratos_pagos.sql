CREATE TABLE contrato (
  id_contrato  BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tipo         ENUM('VENTA','ARRIENDO') NOT NULL,
  id_propiedad BIGINT UNSIGNED NOT NULL,
  id_cliente   BIGINT UNSIGNED NOT NULL,
  id_agente    BIGINT UNSIGNED NOT NULL,
  fecha_firma  DATE NOT NULL,
  fecha_inicio DATE,
  fecha_fin    DATE,
  valor_total  DECIMAL(14,2),
  canon_mensual DECIMAL(14,2),
  deposito     DECIMAL(14,2),
  comision_rate DECIMAL(6,4),
  estado       ENUM('BORRADOR','VIGENTE','TERMINADO','ANULADO') NOT NULL DEFAULT 'VIGENTE',
  creado_en    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad),
  FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  FOREIGN KEY (id_agente) REFERENCES empleado(id_empleado)
) ENGINE=InnoDB;

CREATE TABLE pago (
  id_pago           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_contrato       BIGINT UNSIGNED NOT NULL,
  periodo           CHAR(7) NOT NULL,
  fecha_vencimiento DATE NOT NULL,
  monto_programado  DECIMAL(14,2) NOT NULL,
  monto_pagado      DECIMAL(14,2) NOT NULL DEFAULT 0,
  fecha_pago        DATE,
  estado ENUM('PENDIENTE','PAGADO','PARCIAL','VENCIDO') NOT NULL DEFAULT 'PENDIENTE',
  registrado_en     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato),
  UNIQUE KEY uk_pago_periodo (id_contrato, periodo)
) ENGINE=InnoDB;