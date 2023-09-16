--SENTENCIA 2: PRODUCTO MAS ECONOMICO POR TIENDA
WITH ProductosPorTienda AS (SELECT T.ID_TIENDA AS ID, T.nombre AS Tienda, P.nombre AS Producto, P.valor AS Precio
FROM Tienda AS T
INNER JOIN producto_tienda as PT ON T.id_tienda = PT.id_tienda
INNER JOIN producto as P ON PT.id_prod = P.id_prod
ORDER BY ID, T.nombre, Precio),

RankProductos AS (
    SELECT ID, Tienda, Producto, Precio,
    RANK() OVER (PARTITION BY ID ORDER BY Precio) AS ranking
    FROM ProductosPorTienda
)

SELECT ID, Tienda, Producto, Precio
FROM RankProductos
WHERE ranking = 1;
