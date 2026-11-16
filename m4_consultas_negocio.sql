USE Ventas_Tech_DB

--CONSULTA 1 RESUMEN EJECUTIVO MENSUAL--
--Total facturado, cantidad de pedidos y ticket promedio,agrupados por mes--

SELECT YEAR(fecha_venta) AS año,
MONTH(fecha_venta) AS mes,
SUM(cantidad * precio_unitario) AS total_facturado,
COUNT(id_venta) AS cantidad_de_pedidos,
CAST(AVG(cantidad * precio_unitario) AS DECIMAL (10,2))
AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta),	MONTH(fecha_venta)
ORDER BY año, mes;

--CONSULTA 2 RANKING DE PRODUCTOS--
--Top 5 de id_producto por total facturado, mostrando las unidades vendidas y el total generado--

SELECT TOP 5 id_producto,
SUM(cantidad) AS unidades_vendidas,
SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

--CONSULTA 3 CLIENTES RECURRENTES--
--id_cliente que hayan realizado más de un pedido, mostrando la cantidad de pedidos y el total gastado--

SELECT id_cliente,
COUNT(*) AS cantidad_pedidos,
SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC

--CONSULTA 4 MESES POR ENCIMA/POR DEBAJO DEL PROMEDIO--
-- Total facturado por id_producto, con una columna adicional que etiquete 
--con CASE WHEN si ese producto quedó 'Por encima' o 'Por debajo' del promedio
--de facturación por producto. Ojo: es el promedio de los totales por producto,
--no el promedio de las filas de ventas. Resolvelo con WITH y una subconsulta,
--como en el ejemplo de meses de la unidad "Ordenar, resumir y agrupar resultados".

WITH ventas_por_producto AS (
    SELECT id_producto,
           SUM(cantidad * precio_unitario) AS facturacion
    FROM ventas
    GROUP BY id_producto
)
SELECT id_producto,
       facturacion,
       CASE WHEN facturacion >= (SELECT AVG(facturacion) FROM ventas_por_producto)
            THEN 'Por encima' ELSE 'Por debajo'
       END AS evaluacion_promedio
FROM ventas_por_producto
ORDER BY facturacion DESC;


--HALLAZGOS--
--El producto que generó más facturación en el mes de marzo de 2024 fue 'Laptop Pro 15' representando el 56% de la facturacion--
--El producto más vendido en unidades fue el 'Mouse inalámbrico' representa tan sólo un 6% de la facturacion--
--El cliente 'María López' es el principal cliente de la empresa, ya que sus pedidos representan un 40% de la facturacion--