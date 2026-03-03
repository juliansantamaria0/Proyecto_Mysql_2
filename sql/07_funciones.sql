USE inmobiliaria_db;

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