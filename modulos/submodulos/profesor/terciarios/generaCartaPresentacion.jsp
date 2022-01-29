<%-- 
    Document   : generaCartaPresentacion
    Created on : Dec 26, 2021, 11:58:57 AM
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
        int numero = parser.getIntParameter("numero", 0);
        int cveAlumno = parser.getIntParameter("cveAlumno", 0);
        int tipoCarta = parser.getIntParameter("tipoCarta", 0);
        String empresa = parser.getStringParameter("empresa", "");
        String asesor = parser.getStringParameter("asesor", "");
        String puesto = parser.getStringParameter("puesto", "");      
        String nombre_asesor="";
        
        ArrayList<CustomHashMap> datosAsesor = siest.ejecutarConsulta("SELECT (p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as asesor "
                + "FROM persona p "
                + "INNER JOIN estadia_alumno ea on p.cve_persona=ea.cve_asesor "
                + "WHERE cve_alumno_grupo="+cveAlumno);
                nombre_asesor = datosAsesor.get(0).getString("asesor");
        
        ArrayList<CustomHashMap> datosAlumno = siest.ejecutarConsulta("SELECT (p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as nombre_completo, "
                + "u.nombre_usuario as matricula, g.nombre as grupo, c.nombre as carrera, CAST(dm.nss AS VARCHAR) as seguro "
                + "FROM persona p "
                + "INNER JOIN usuario u on p.cve_persona=u.cve_persona "
                + "INNER JOIN alumno a on p.cve_persona=a.cve_persona "
                + "INNER JOIN alumno_grupo ag on a.cve_alumno=ag.cve_alumno "
                + "INNER JOIN grupo g on ag.cve_grupo=g.cve_grupo "
                + "INNER JOIN carrera c on g.cve_carrera=c.cve_carrera "
                + "INNER JOIN dato_medico dm on p.cve_persona=dm.cve_persona "
                + "WHERE ag.cve_alumno_grupo="+cveAlumno);
        
        ArrayList<CustomHashMap> folio = siest.ejecutarConsulta("SELECT dbo.generafolioestadia ("+cveAlumno+") as folio");
        String numero_folio = folio.get(0).getString("folio");
                
        
        
        
%>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Carta de Presentacion</title>
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
        <div style="padding: 0px 55px;">
            <div style="text-align: center;"> <!-- leyenda centro-->
                <strong>"2020, Año de Leona Vicario, Benemérita Madre de la Patria"</strong>
            </div><br>
            <div style="text-align: right;"> <!-- datos de la UT -->
                <strong>
                UNIVERSIDAD TECNOLOGICA DE LA COSTA<br>
                RECTORIA <br>
                SECRETARIA ACADEMICA <br>
                No. OFICIO UTC/REC/SA/<%=numero_folio%>/2020 <br></strong>
            </div><br>
            <div style="text-align: center"><strong>CARTA DE PRESENTACION DEL ALUMNO A LA ESTADIA</strong><br></div>
            <div style="text-align: left;"> <!-- datos de la empresa -->
                <strong>
                AREA DE INNOVACION Y DESARROLLO TECNOLOGICA DE LA SECRETARIA DE SERVICIOS<br>
                <%=asesor%><br>
                <%=puesto%><br>
                P R E S E N T E</strong><br>
            </div>
            <br>
            <div style="text-align: justify; line-height: 120%"> <!-- cuerpo del documento -->
                <%for (CustomHashMap da : datosAlumno) { %> <!-- se obtiene la data del alumno -->
                Por este conducto, me permito presentar a Usted al (la) C. <strong><%=da.getString("nombre_completo")%></strong>, alumno (a) de nuestra Universidad inscrito (a) en la carrera: 
                <strong><%=da.getString("carrera")%></strong> con matrícula <strong><%=da.getString("matricula")%></strong> quien a partir del <strong>[DIA]</strong> de <strong>[MES]</strong> hasta el
                <strong>[DIA]</strong> de <strong>[MES]</strong> del <strong>[Año]</strong> 
                realizara su proyecto de Estadía y Servicio Social en la empresa que usted representa.<br>
                Durante el periodo de estadía, nuestro (a) alumno (a) deberá desarrollar un proyecto congruente con los intereses de la empresa,
                donde deberá dedicar hasta 8 horas diarias.<br>
                <br>
                Para dar seguimiento, asesoría y control de la estadía se ha nombrado a <strong><%=nombre_asesor%></strong> cómo asesor académico, 
                mismo que será su contacto directo con esta Institución.<br>
                <br>
                Por ultimo, informo a usted que el (la) alumno (a) cuanta con seguro Facultativo del Instituto Mexicano del Seguro Social
                con el numero de identificación <strong><%=da.getString("seguro")%></strong> el cual podrá hacer uso en caso necesario.<br>
                <br>
                <%
                    }
                %>
                Mucho agradeceré entregue al asesor académico la carta de aceptación de nuestro (a) alumno (a) en el formato tipo aceptación que le proporcionara,
                debiendo ser entregada en hoja membretada, en caso de contar con ella, en medio físico, escaneada o en email con dominio electrónico de su empresa 
                a mas tardar el <strong>[DIA]</strong> de <strong>[MES]</strong> del <strong>[2020]</strong>.<br>
                <br>
                Sin mas por el momento me despido de usted quedando en espera de su confirmación del nombramiento del proyecto que realizara  y del asesor empresarial que usted asigne para dar acompañamiento al (la) alumno (a) desde la empresa.
            </div><br>
            <br>
            <div style="text-align: center; line-height: 150%;"> <!-- final de la carta -->
                <strong>A T E N T A M E N T E</strong><br>
                <i><em>"Conocimiento Que Transforma Vidas"</em></i><br>
                <br>
                <strong>_____________________________________</strong><br>
                <strong>[LICENCIADO]</strong><br>
                JEFE DEL DEPARTAMENTO DE PRACTICAS Y ESTADÍAS
            </div>
        </div>
    </body>
</html>
        <script>
            window.print();
        </script>
        <%
    //llave de cierre de if de usuario
    }
%>
