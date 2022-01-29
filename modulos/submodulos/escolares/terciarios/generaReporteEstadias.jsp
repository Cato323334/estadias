<%-- 
    Document   : generaReporteEstadias
    Created on : Dec 28, 2021, 12:57:14 PM
    Author     : rhekh
--%>

<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*, java.text.*"%>
<% 
    RequestParamParser parser = new RequestParamParser(request);
    HttpSession sesion = request.getSession();
    Usuario usuario = (Usuario) sesion.getAttribute("usuario");
    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("../../login.jsp");
    } else {
        //conexión a base de datos
        Datos siest = new Datos();
                
        CarearFecha cf = new CarearFecha(); 
        int periodo = parser.getIntParameter("periodo", 0);
        
        if(periodo==0){
            periodo = usuario.getCvePeriodo();
        }
        
        ArrayList<CustomHashMap> fechas_periodo = siest.ejecutarConsulta("SELECT CONVERT(VARCHAR(10),fecha_inicio, 103) as inicio, CONVERT(VARCHAR(10),fecha_fin, 103) as final "
                + "FROM periodo "
                + "WHERE cve_periodo="+periodo);
        String fechaInicio = fechas_periodo.get(0).getString("inicio");
        String fechaFin = fechas_periodo.get(0).getString("final");

        ArrayList<CustomHashMap> alumnosEstadia = siest.ejecutarConsulta("SELECT a.matricula, ea.nombre_proyecto, ta.descripcion as documento, g.nombre as grupo, c.nombre as carrera, "
                      + "(p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as nombre_completo "
                      + "FROM alumno a "
                      + "INNER JOIN alumno_grupo ag on a.cve_alumno=ag.cve_alumno "
                      + "INNER JOIN estadia_archivo ea on ag.cve_alumno_grupo=ea.cve_alumno_grupo "
                      + "INNER JOIN grupo g on ag.cve_grupo=g.cve_grupo "
                      + "INNER JOIN persona p on a.cve_persona=p.cve_persona "
                      + "INNER JOIN estadia_estado ee on ea.cve_estadia_archivo=ee.cve_estadia_archivo "
                      + "INNER JOIN tipo_archivo ta on ea.tipo_archivo=ta.cve_tipo_archivo "
                      + "INNER JOIN archivo ar on ea.cve_archivo=ar.cve_archivo "
                      + "INNER JOIN carrera c on g.cve_carrera=c.cve_carrera "
                      + "INNER JOIN estado_estadia es on ee.cve_estado_estadia=es.cve_estado_estadia "
                      + "WHERE ag.activo=1 and ee.cve_estado_estadia=7 and ee.activo=1 and ag.cve_periodo=41 and (tipo_archivo=1 or tipo_archivo=2) "
                      + "ORDER BY ee.cve_estado_estadia asc, carrera asc, grupo asc, nombre_completo asc ");
%>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reporte Alumnos Estadia</title>
        <link rel="stylesheet" href="../../../../temas/defecto/normalize.css" />
        <link rel="stylesheet" href="../../../../temas/defecto/boleta-121105_escolares.css" />
        <script src="../../../../js/prefixfree.min.js"></script>
        <script src="../../../../js/jquery-1.8.2.min.js"></script>
    </head>
    <body>
        <header>
            <div style="text-align: left;"> <!-- logo de la UT -->
                <img src="../../../../temas/defecto/imagenes/logoutc.jpg" style="text-align:  left;"  alt="Logo UTC" />
            </div><br>
        </header>
        <div>
            <div style="text-align: center;"> <!-- leyenda centro-->
                <h3><strong>UNIVERSIDAD TECNOLÓGICA DE LA COSTA</strong></h3>
            </div><br>
            <div style="text-align: center;"> <!-- datos de la UT -->
                <strong>
                CARRETERA SANTIAGO ENTRONQUE INTERNACIONAL NO. 15 KM. 5<br>
                </strong>
            </div><br>
            <div style="text-align: center"><strong>R.F.C. UTC0206053R1</strong><br></div>
            <div style="text-align: center"><strong>REPORTE DOCUMENTOS ESTADIA ACEPTADOS</strong><br></div>
            <br>
            <div style="text-align: left">Fecha de Impresión: <%=cf.diaHoy%>/<%=cf.mesHoy%>/<%=cf.anhoHoy%><br>
                Periodo: <%=fechaInicio%> - <%=fechaFin%><br>
            </div><br>
            <form action="" class="formReportes">
            <div class="table-responsive"> <!-- datos de la empresa -->
                <table class="table" id="tabla-conv">
                    <thead>
                    <tr>
                    <td>No.</td>
                    <td>Alumno</td>
                    <td>Matricula</td>
                    <td>Carrera</td>
                    <td>Grupo</td>
                    <td>Proyecto</td>
                    <td>Documento</td>
                </tr>
                    </thead>
                    <tbody>
                    <%
                    int n = 0;
                    if (!alumnosEstadia.isEmpty()) {
                    for (CustomHashMap a : alumnosEstadia) {
                    %>
                    <tr>
                    <td><%=++n%></td>
                    <td><%=a.getString("nombre_completo")%></td>
                    <td><%=a.getString("matricula")%></td>
                    <td><%=a.getString("carrera")%></td>
                    <td><%=a.getString("grupo")%></td>
                    <td><%=a.getString("nombre_proyecto")%></td>
                    <td><%=a.getString("documento")%></td>
                    </tr>
                    <%
                        }
                    }
                    %>
                    </tbody>
            </table>
            </div>
           </form>
        </div>
    </body>
    
        <script>
        window.print();
        </script>
        <%
    }
%>
