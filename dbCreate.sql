-- Antes de crear cualquier tabla se debe crear la base de datos
CREATE DATABASE TiendasComerciales;

-- Se debe activar el SCRIPT en la QUERY TOOL para la BD TiendasComerciales
CREATE TABLE Producto(
    ID_PROD int primary key,
    nombre varchar(255) NOT NULL,
    valor int
);

CREATE TABLE Tipo_doc(
    ID_DOC int primary key,
    tipo varchar(255) NOT NULL,
    precio_total int NOT NULL
);

CREATE TABLE Tienda(
    ID_TIENDA int primary key,
    nombre varchar(255) NOT NULL
);

CREATE TABLE Empleado(
    ID_EMPLEADO int primary key,
    nombre varchar(255) NOT NULL
);

CREATE TABLE Comuna(
    ID_COMUNA int primary key,
    localidad_nombre varchar(255) NOT NULL
);

CREATE TABLE Vendedor(
    ID_VENDEDOR int primary key,
    ID_EMPLEADO int,
    foreign key(ID_EMPLEADO) references Empleado(ID_EMPLEADO)
);

CREATE TABLE Venta(
    ID_VENTA int primary key,
    ID_DOC int NOT NULL,
    ID_TIENDA int NOT NULL,
    fecha date NOT NULL,
    foreign key (ID_DOC) references Tipo_doc(ID_DOC),
    foreign key (ID_TIENDA) references Tienda(ID_TIENDA)
);

CREATE TABLE Prod_Venta (
    ID_VENTA int NOT NULL,
    ID_PROD int NOT NULL,
    ID_VENDEDOR int NOT NULL,
    foreign key (ID_VENTA) references Venta(ID_VENTA),
    foreign key (ID_PROD) references Producto(ID_PROD),
    foreign key (ID_VENDEDOR) references Vendedor(ID_VENDEDOR)
);

CREATE TABLE Sueldo(
    ID_SUELDO int primary key,
    cantidad int,
    fecha_pago date,
    ID_EMPLEADO int,
    foreign key (ID_EMPLEADO) references Empleado(ID_EMPLEADO)
);

CREATE TABLE Tienda_Empleado(
    ID_TIENDA int,
    ID_EMPLEADO int,
    foreign key (ID_EMPLEADO) references Empleado(ID_EMPLEADO),
    foreign key (ID_TIENDA) references Tienda(ID_TIENDA)
);

CREATE TABLE Empleado_Comuna(
    ID_COMUNA int,
    ID_EMPLEADO int,
    foreign key (ID_COMUNA) references Comuna(ID_COMUNA),
    foreign key (ID_EMPLEADO) references Empleado(ID_EMPLEADO)
);

CREATE TABLE Tienda_Comuna(
    ID_TIENDA int,
    ID_COMUNA int,
    foreign key (ID_TIENDA) references Tienda(ID_TIENDA),
    foreign key (ID_COMUNA) references Comuna(ID_COMUNA)
);