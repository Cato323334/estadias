CREATE TABLE estado_estadia(
cve_estado_estadia int identity(1,1) primary key,
descripcion text,
activo bit
);

CREATE TABLE tipo_archivo(
cve_tipo_archivo int identity(1,1) primary key,
descripcion varchar (50)
);

CREATE TABLE numero_avance_estadia(
cve_numero_avance_estadia int identity(1,1) primary key,
descripcion varchar (10)
); ---tabla post revision

CREATE TABLE tipo_carta_estadia(
cve_tipo_carta_estadia int identity(1,1) primary key,
descripcion varchar (35)
); -- tabla post revision

CREATE TABLE estadia_carta( --dependiendo del tipo de carta son los campos que se tomaran, a su vez tambien varia el archivo de creacion
cve_carta_estadia int identity(1,1) primary key,
tipo_carta_estadia int,
cve_estadia_alumno int,
folio varchar (12),
nombre_alumno varchar (120),
carrera varchar(120),
matricula varchar(12),
fecha_inicio date,
fecha_entrega date,
nombre_asesor varchar (120),
nombre_division varchar (60),
abreviatura_area varchar (10),
numero_seguro varchar (14),
nombre_proyecto varchar(120),
FOREIGN KEY (tipo_carta_estadia) REFERENCES tipo_carta_estadia(cve_tipo_carta_estadia),
FOREIGN KEY (cve_estadia_alumno) REFERENCES estadia_alumno(cve_estadia_alumno)
);


CREATE TABLE estadia_alumno( --tabla modificada post revision
cve_estadia_alumno int identity(1,1) primary key,
cve_asesor int,
cve_coordinador int,
cve_alumno_grupo int,
fecha_registros date,
numero_avance int,
activo bit,
asesor_empresarial varchar(120),
empresa varchar (60),
puesto_asesor_empresarial varchar(20),
FOREIGN KEY (cve_asesor) REFERENCES persona(cve_persona),
FOREIGN KEY (cve_alumno_grupo) REFERENCES alumno_grupo(cve_alumno_grupo),
FOREIGN KEY (cve_coordinador) REFERENCES persona(cve_persona),
FOREIGN KEY (numero_avance) REFERENCES numero_avance_estadia(cve_numero_avance_estadia)
);

CREATE TABLE estadia_archivo(
cve_estadia_archivo int identity(1,1) primary key,
cve_alumno_grupo integer,
cve_archivo integer,
tipo_archivo integer,
nombre_proyecto varchar (50),
FOREIGN KEY (cve_alumno_grupo) REFERENCES alumno_grupo(cve_alumno_grupo),
FOREIGN KEY(cve_archivo) REFERENCES archivo(cve_archivo),
FOREIGN KEY (tipo_archivo) REFERENCES tipo_archivo(cve_tipo_archivo)
);

CREATE TABLE estadia_estado(
cve_estadia_estado int identity(1,1) primary key,
cve_estado_estadia integer,
cve_estadia_archivo integer,
cve_persona integer,
comentario text,
fecha_alta date,
activo bit,
FOREIGN KEY (cve_estado_estadia) REFERENCES estado_estadia(cve_estado_estadia),
FOREIGN KEY (cve_persona) REFERENCES persona(cve_persona),
FOREIGN KEY (cve_estadia_archivo) REFERENCES estadia_archivo(cve_estadia_archivo) 
);


-- Insercciones

-- tabla tipo de archivo
INSERT INTO public.tipo_archivo(descripcion)
VALUES
('Carta de Conclusion'),
('Memoria de Estadia'),
('Carta de Aceptacion');

-- Numero Avance
INSERT INTO numero_avance_estadia(descripcion)
VALUES ('Primer'),
('Segundo'),
('Tercer');

-- Estado Estadia
INSERT INTO public.estado_estadia(descripcion, activo)
VALUES ('Pendiente', True),
('Validada por el Asesor',True),
('Autorizada por el Director',True),
('Aprobada por Servicios Escolares',True);
('Rechazada por el Asesor',True);
('Rechazada por el Director',True);
('Rechazada por Servicios Escolares',True);

INSERT INTO tipo_carta_estadia(descripcion)
VALUES ('Carta de presentación'),
('Carta de liberación de memoria');
