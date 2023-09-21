-- SENTENCIA 1: PRODUCTO MÁS VENDIDO POR MES
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

--SETENCIA 3: VENTAS POR MES, SEPARADAS ENTRE BOLETAS Y FACTURAS
SELECT
    EXTRACT(MONTH FROM fecha) AS Mes,
    SUM(CASE WHEN tipo = 'Boleta' THEN 1 ELSE 0 END) AS Boletas,
    SUM(CASE WHEN tipo = 'Factura' THEN 1 ELSE 0 END) AS Facturas
FROM
    Venta
    INNER JOIN Tipo_doc ON Venta.ID_DOC = Tipo_doc.ID_DOC
GROUP BY
    EXTRACT(MONTH FROM fecha)
ORDER BY
    EXTRACT(MONTH FROM fecha);

--SETENCIA 4: EMPLEADO QUE GANO MAS POR TIENDA 2020, INDICANDO LA COMUNA DONDE VIVE Y EL CARGO QUE TIENE EN LA EMPRESA
WITH EmpleadosOrdenados AS (
    SELECT
        ti.ID_TIENDA AS id_tienda,
        e.nombre AS nombre_empleado,
        c.nombre_cargo AS cargo,
        s.cantidad AS mayor_sueldo_2020,
        ROW_NUMBER() OVER (PARTITION BY ti.ID_TIENDA ORDER BY s.cantidad DESC) AS num_empleado
    FROM
        Tienda AS ti
    JOIN
        Tienda_Empleado AS te ON ti.ID_TIENDA = te.ID_TIENDA
    JOIN
        Empleado AS e ON te.ID_EMPLEADO = e.ID_EMPLEADO
    JOIN
        Cargo AS c ON e.ID_CARGO = c.ID_CARGO
    JOIN
        Sueldo AS s ON e.ID_EMPLEADO = s.ID_EMPLEADO
    WHERE
        EXTRACT(YEAR FROM s.fecha_pago) = 2020
)

SELECT
    id_tienda,
    nombre_empleado,
    cargo,
    mayor_sueldo_2020
FROM
    EmpleadosOrdenados
WHERE
    num_empleado = 1;

-- SENTENCIA 5: LA TIENDA QUE TIENE MENOS EMPLEADOS
SELECT t.nombre AS nombre_tienda, COUNT(te.ID_EMPLEADO) AS cantidad_empleados
FROM Tienda AS t
LEFT JOIN Tienda_Empleado AS te ON t.ID_TIENDA = te.ID_TIENDA
GROUP BY t.nombre
HAVING COUNT(te.ID_EMPLEADO) = (
    SELECT MIN(cantidad_empleados)
    FROM (
        SELECT COUNT(te.ID_EMPLEADO) AS cantidad_empleados
        FROM Tienda AS t
        LEFT JOIN Tienda_Empleado AS te ON t.ID_TIENDA = te.ID_TIENDA
        GROUP BY t.nombre
    ) AS subconsulta
);

-- SENTENCIA 6: EL VENDEDOR CON MAS VENTAS POR MES
WITH Meses AS (
    SELECT generate_series(
        date_trunc('month', '2023-01-01'::date),
        date_trunc('month', CURRENT_DATE),
        interval '1 month'
    ) AS Mes
),
VentasPorVendedor AS (
    SELECT
        EXTRACT(MONTH FROM Mes.Mes) AS Mes,
        VD.ID_VENDEDOR,
        E.nombre AS NombreVendedor,
        COUNT(*) AS VentasDelMes,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM Mes.Mes) ORDER BY COUNT(*) DESC) AS Orden
    FROM Meses Mes
    LEFT JOIN Venta V ON EXTRACT(YEAR FROM Mes.Mes) = EXTRACT(YEAR FROM V.fecha)
                      AND EXTRACT(MONTH FROM Mes.Mes) = EXTRACT(MONTH FROM V.fecha)
    LEFT JOIN Prod_Venta PV ON V.ID_VENTA = PV.ID_VENTA
    LEFT JOIN Vendedor VD ON PV.ID_VENDEDOR = VD.ID_VENDEDOR
    LEFT JOIN Empleado E ON VD.ID_EMPLEADO = E.ID_EMPLEADO
    GROUP BY EXTRACT(MONTH FROM Mes.Mes), VD.ID_VENDEDOR, E.nombre
)
SELECT Mes, ID_VENDEDOR, NombreVendedor, VentasDelMes
FROM VentasPorVendedor
WHERE Orden = 1
ORDER BY Mes;

-- SENTENCIA 7: EL VENDEDOR QUE HA RECAUDADO MÁS DINERO PARA LA TIENDA POR AÑO
WITH VentasPorVendedor AS (
    SELECT
        EXTRACT(YEAR FROM V.fecha) AS Anio,
        T.ID_TIENDA AS ID_Tienda,
        PV.ID_VENDEDOR AS ID_Vendedor,
        SUM(P.valor) AS Total_Recaudado
    FROM Venta V

    INNER JOIN Prod_Venta PV ON V.ID_VENTA = PV.ID_VENTA
    INNER JOIN Producto P ON PV.ID_PROD = P.ID_PROD
    INNER JOIN Tienda T ON V.ID_TIENDA = T.ID_TIENDA

	GROUP BY
        EXTRACT(YEAR FROM V.fecha),
        T.ID_TIENDA,
        PV.ID_VENDEDOR
)

SELECT
    Anio,
    T.nombre AS Nombre_Tienda,
    E.nombre AS Nombre_Vendedor,
    Total_Recaudado
FROM (
    SELECT
		Anio,
		ID_Tienda,
	    ID_Vendedor,
        RANK() OVER (PARTITION BY Anio, ID_Tienda ORDER BY Total_Recaudado DESC) AS Ranking,
        Total_Recaudado
    FROM VentasPorVendedor VPV
) AS RankedSales

INNER JOIN Tienda T ON RankedSales.ID_Tienda = T.ID_TIENDA
INNER JOIN Vendedor VPV ON RankedSales.ID_Vendedor = VPV.ID_VENDEDOR
INNER JOIN Empleado E ON VPV.ID_EMPLEADO = E.ID_EMPLEADO
WHERE Ranking = 1;


-- SENTENCIA 8: EL VENDEDOR CON MAS PRODUCTOS VENDIDOS POR TIENDA
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

-- SENTENCIA 9: EL EMPLEADO CON MAYOR SUELDO POR MES
WITH sueldos_mensuales AS (SELECT DISTINCT ON (date_trunc('year', S.fecha_pago), date_trunc('month', S.fecha_pago), S.cantidad)
       date_trunc('year', S.fecha_pago) AS Anio,
       date_trunc('month', S.fecha_pago) AS Mes,
       Emp.Nombre AS Empleado_Con_Mayor_Sueldo,
       S.cantidad AS Sueldo_Mensual
FROM Sueldo as S
INNER JOIN Empleado as Emp ON S.id_empleado = Emp.id_empleado
ORDER BY date_trunc('year', S.fecha_pago), date_trunc('month', S.fecha_pago), S.cantidad DESC),

RankSueldosMes AS (
    SELECT Anio, Mes, Empleado_Con_Mayor_Sueldo, Sueldo_Mensual,
    RANK() OVER (PARTITION BY Mes ORDER BY Sueldo_Mensual DESC) AS ranking
    FROM sueldos_mensuales
)

SELECT Anio, Mes, Empleado_Con_Mayor_Sueldo, Sueldo_Mensual
FROM RankSueldosMes
WHERE ranking = 1;

-- SENTENCIA 10: LA TIENDA CON MENOR RECAUDACIÓN POR MES
WITH Meses AS (
    SELECT generate_series(
        date_trunc('month', '2023-01-01'::date),
        date_trunc('month', CURRENT_DATE),
        interval '1 month'
    ) AS Mes
),
VentasPorTienda AS (
    SELECT
        EXTRACT(MONTH FROM Mes.Mes) AS Mes,
        T.ID_TIENDA,
        T.nombre AS NombreTienda,
        SUM(TD.precio_total) AS RecaudacionDelMes,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM Mes.Mes) ORDER BY SUM(TD.precio_total)) AS Orden
    FROM Meses Mes
    LEFT JOIN Venta V ON EXTRACT(YEAR FROM Mes.Mes) = EXTRACT(YEAR FROM V.fecha)
                      AND EXTRACT(MONTH FROM Mes.Mes) = EXTRACT(MONTH FROM V.fecha)
    LEFT JOIN Tienda T ON V.ID_TIENDA = T.ID_TIENDA
    LEFT JOIN Tipo_Doc TD ON V.ID_DOC = TD.ID_DOC
    GROUP BY EXTRACT(MONTH FROM Mes.Mes), T.ID_TIENDA, T.nombre
)
SELECT Mes, ID_TIENDA, NombreTienda, RecaudacionDelMes
FROM VentasPorTienda
WHERE Orden = 1
ORDER BY Mes;