USE inmobiliaria_db;

DELIMITER $$

CREATE EVENT ev_reporte_morosidad_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS (TIMESTAMP(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')) + INTERVAL 1 MONTH)
DO
BEGIN
  DECLARE v_mes CHAR(7);
  SET v_mes = DATE_FORMAT(CURRENT_DATE() - INTERVAL 1 MONTH, '%Y-%m');

  INSERT INTO reporte_morosidad_mensual 
  (mes_reporte, id_contrato, id_cliente, id_propiedad, deuda_pendiente)
  SELECT
    v_mes,
    c.id_contrato,
    c.id_cliente,
    c.id_propiedad,
    fn_deuda_pendiente_arriendo(c.id_contrato)
  FROM contrato c
  WHERE c.tipo = 'ARRIENDO'
    AND c.estado = 'VIGENTE'
    AND fn_deuda_pendiente_arriendo(c.id_contrato) > 0
  ON DUPLICATE KEY UPDATE
    deuda_pendiente = VALUES(deuda_pendiente),
    generado_en = CURRENT_TIMESTAMP;
END$$

DELIMITER ;