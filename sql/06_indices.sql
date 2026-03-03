CREATE INDEX idx_prop_estado_tipo ON propiedad (id_estado, id_tipo);
CREATE INDEX idx_contrato_prop_tipo_estado ON contrato (id_propiedad, tipo, estado);
CREATE INDEX idx_contrato_cliente ON contrato (id_cliente);
CREATE INDEX idx_pago_contrato_estado_venc ON pago (id_contrato, estado, fecha_vencimiento);