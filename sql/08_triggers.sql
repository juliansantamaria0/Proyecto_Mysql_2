USE inmobiliaria_db;

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

  SELECT id_estado INTO v_estado_arrendada 
  FROM estado_propiedad WHERE nombre='ARRENDADA';

  SELECT id_estado INTO v_estado_vendida   
  FROM estado_propiedad WHERE nombre='VENDIDA';

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