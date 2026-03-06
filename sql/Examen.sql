-- examen



  -- CONSULTA 1 Mostrar el nombre del vendedor y la cantidad total de propiedades vendidas


SELECT 
    e.id_empleado,
    CONCAT(e.nombres, ' ', e.apellidos) AS vendedor,
    COUNT(c.id_contrato) AS total_propiedades_vendidas
FROM empleado e
JOIN contrato c 
    ON e.id_empleado = c.id_agente
WHERE c.tipo = 'VENTA'
GROUP BY e.id_empleado, e.nombres, e.apellidos
ORDER BY total_propiedades_vendidas DESC;



 --  CONSULTA 2 Obtener las propiedades vendidas con un valor entre 150 millones y 400 millones
 

SELECT 
    p.id_propiedad,
    c.id_contrato,
    c.valor_total,
    c.fecha_firma
FROM contrato c
JOIN propiedad p 
    ON p.id_propiedad = c.id_propiedad
WHERE c.tipo = 'VENTA'
AND c.valor_total BETWEEN 150000000 AND 400000000
ORDER BY c.valor_total;



--   CONSULTA 3 Listar los clientes cuyos nombres contengan "Carlos"


SELECT 
    id_cliente,
    nombres,
    apellidos,
    telefono,
    email
FROM cliente
WHERE nombres LIKE '%Carlos%';



--   CONSULTA 4 Mostrar todos los vendedores y las propiedades que han vendido (incluye vendedores sin ventas)


SELECT 
    e.id_empleado,
    CONCAT(e.nombres, ' ', e.apellidos) AS vendedor,
    p.id_propiedad,
    c.id_contrato,
    c.valor_total
FROM contrato c
RIGHT JOIN empleado e
    ON c.id_agente = e.id_empleado
   AND c.tipo = 'VENTA'
LEFT JOIN propiedad p
    ON c.id_propiedad = p.id_propiedad
ORDER BY vendedor;



--   CONSULTA 5 Crear una vista con resumen de ventas por vendedor
  

CREATE OR REPLACE VIEW vista_resumen_ventas AS
SELECT 
    e.id_empleado,
    CONCAT(e.nombres, ' ', e.apellidos) AS vendedor,
    COALESCE(SUM(c.valor_total), 0) AS total_vendido,
    COUNT(DISTINCT c.id_cliente) AS numero_clientes_atendidos
FROM empleado e
LEFT JOIN contrato c
    ON e.id_empleado = c.id_agente
   AND c.tipo = 'VENTA'
GROUP BY e.id_empleado, e.nombres, e.apellidos;


-- vista

SELECT *
FROM vista_resumen_ventas
ORDER BY total_vendido DESC;
