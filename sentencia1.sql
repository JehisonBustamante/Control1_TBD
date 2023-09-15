WITH VentasPorMes AS (
	SELECT DATE_TRUNC('month', V.fecha) AS Mes, P.nombre AS Producto_Mas_Vendido, 
	COUNT(PV.id_prod) AS total_vendido
	FROM venta AS V
	INNER JOIN Prod_Venta AS PV ON V.ID_VENTA = PV.ID_VENTA
	INNER JOIN Producto AS P ON PV.ID_PROD = P.ID_PROD
	WHERE V.fecha >= '2021-01-01' AND V.fecha <= '2021-12-31'
	GROUP BY Mes, Producto_Mas_Vendido
),
RankProductosMes AS (
	SELECT mes, producto_mas_vendido, total_vendido,
	RANK() OVER (PARTITION BY mes ORDER BY total_vendido DESC) AS ranking
	FROM VentasPorMes
)
SELECT mes, producto_mas_vendido
FROM RankProductosMes
WHERE ranking = 1;