-- Base utilizada: TechStore_Clase5
USE TechStore_Clase5;

-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: unir ventas con clientes, productos y categorías en una sola vista, que será la fuente principal de datos para Power BI.
SELECT v.id_venta,
       v.fecha_venta,
       c.nombre            AS cliente,
       c.ciudad,
       p.nombre_producto   AS producto,
       cat.nombre_categoria AS categoria,
       v.cantidad,
       v.precio_unitario,
       v.cantidad * v.precio_unitario AS total
FROM ventas v
INNER JOIN clientes   c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.id_venta;
-- Hallazgo: la vista devuelve 26 de las 28 ventas: las 2 ventas de mostrador (120 en total) quedan afuera porque no tienen cliente asociado. María López es la cliente que más compró, con 4360 (cerca de un 26% de la facturación).


-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.
SELECT c.nombre, c.email, c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo: Ana Duarte, registrada el 2026-05-02, es la cliente que aún no hizo una compra. Para CRM implica que puede contactarla con una propuesta de primera compra.


-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: detectar productos del catálogo que no tienen ninguna venta, para que el área de producto evalúe su rotación.
SELECT p.nombre_producto, p.precio, cat.nombre_categoria
FROM productos p
LEFT JOIN ventas v ON p.id_producto = v.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL;
-- Hallazgo: 1 de los 8 productos del catálogo no tiene ventas: Disco SSD 1TB (categoría Computacion, precio 95). Conviene evaluar precio, visibilidad o una promoción.


-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: comparar cuántas ventas y cuánta facturación vienen de clientes identificados y cuántas del mostrador.
WITH por_canal AS (
  SELECT fecha_venta, cantidad * precio_unitario AS total, 'Cliente' AS canal
  FROM ventas
  WHERE id_cliente IS NOT NULL
  UNION ALL
  SELECT fecha_venta, cantidad * precio_unitario, 'Mostrador'
  FROM ventas
  WHERE id_cliente IS NULL
)
SELECT canal,
       COUNT(*) AS cantidad_ventas,
       SUM(total) AS facturado
FROM por_canal
GROUP BY canal;
-- Hallazgo: el canal Cliente concentra 26 ventas y 16450 (más del 99% de la facturación); el Mostrador aporta apenas 2 ventas y 120, un peso casi nulo en el total de 16570.