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