 SELECT
    
    T.nombre AS Nombre_Tienda,
    E.nombre AS Nombre_Vendedor,
    COUNT(PV.ID_PROD) AS Total_Productos_Vendidos

FROM Tienda T

INNER JOIN Tienda_Empleado TE ON T.ID_TIENDA = TE.ID_TIENDA
INNER JOIN Empleado E ON TE.ID_EMPLEADO = E.ID_EMPLEADO
INNER JOIN Vendedor V ON E.ID_EMPLEADO = V.ID_EMPLEADO
INNER JOIN Prod_Venta PV ON V.ID_VENDEDOR = PV.ID_VENDEDOR

GROUP BY
    T.ID_TIENDA,
    T.nombre,
    E.ID_EMPLEADO,
    E.nombre

HAVING
    COUNT(PV.ID_PROD) = (
        SELECT
            MAX(Total_Productos_Vendidos)
        FROM (
            SELECT
                T1.ID_TIENDA AS ID_Tienda,
                E1.ID_EMPLEADO AS ID_Vendedor,
                COUNT(PV1.ID_PROD) AS Total_Productos_Vendidos
            FROM
                Tienda T1
            INNER JOIN
                Tienda_Empleado TE1 ON T1.ID_TIENDA = TE1.ID_TIENDA
            INNER JOIN
                Empleado E1 ON TE1.ID_EMPLEADO = E1.ID_EMPLEADO
            INNER JOIN
                Vendedor V1 ON E1.ID_EMPLEADO = V1.ID_EMPLEADO
            INNER JOIN
                Prod_Venta PV1 ON V1.ID_VENDEDOR = PV1.ID_VENDEDOR
            GROUP BY
                T1.ID_TIENDA,
                E1.ID_EMPLEADO
        ) AS MaxProductosVendidos
        WHERE
            MaxProductosVendidos.ID_Tienda = T.ID_TIENDA
    )
ORDER BY Nombre_Tienda;