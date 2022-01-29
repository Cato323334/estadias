<%@ page contentType="text/html; charset=utf-8" language="java" import="mx.edu.utdelacosta.*, java.sql.*, java.util.*, java.text.*" errorPage="" %>
<%
HttpSession sesion = request.getSession();
if(sesion.getAttribute("usuario") == null){
        response.sendRedirect("../../login.jsp");
}else{
Usuario usuario = (Usuario) sesion.getAttribute("usuario");
Sesion objetoSesion = new Sesion(sesion);

RequestParamParser parser = new RequestParamParser(request);
int tab = parser.getIntParameter("tab", 0);
int cveModulo = parser.getIntParameter("modulo", 0);


String like = parser.getStringParameter("like", null);

String consulta = "";

if(like != null || like!="" ){
consulta = ("SELECT l.cve_libro, l.nombre,  l.codigo_barras, l.activo, COALESCE(l.isbn, 'No registrado')AS isbn, "
        + "l.edicion, l.cantidad, l.stock, l.paginas, l.autor, l.fecha_alta, l.autor as autor, "
        + "g.cve_genero, g.nombre as genero, e.cve_editorial, e.nombre as editorial, l.cve_genero "
        + "FROM libro l "
        + "INNER JOIN libro_editorial e ON l.cve_editorial=e.cve_editorial "
        + "INNER JOIN libro_genero g ON l.cve_genero=g.cve_genero "
        + "WHERE l.nombre LIKE '" + like + "' + '%' COLLATE MODERN_SPANISH_CI_AI AND g.nombre LIKE '" + like + "'  + '%' COLLATE MODERN_SPANISH_CI_AI AND l.autor LIKE '" + like + "'  + '%' COLLATE MODERN_SPANISH_CI_AI "
        + "UNION "
        + "SELECT ea.cve_archivo, ea.nombre_proyecto,'NA',1,'NA',CAST(YEAR(GETDATE()) as varchar(4)), "
        + "1,1,1,(p.apellido_paterno+' '+p.apellido_materno+' '+p.nombre),ee.fecha_alta, "
        + "(p.apellido_paterno+' '+p.apellido_materno+' '+p.nombre),75,'Estadias',414,'UT de la Costa', 75 "
        + "FROM estadia_archivo ea "
        + "INNER JOIN alumno_grupo ag on ea.cve_alumno_grupo=ag.cve_alumno_grupo "
        + "INNER JOIN alumno a on ag.cve_alumno=a.cve_alumno "
        + "INNER JOIN persona p on a.cve_persona=p.cve_persona "
        + "INNER JOIN estadia_estado ee on ea.cve_estadia_archivo=ee.cve_estadia_archivo "
        + "WHERE cve_estado_estadia=4 and ea.tipo_archivo=2 "
        + "AND ea.nombre_proyecto LIKE '" + like + "' + '%' COLLATE MODERN_SPANISH_CI_AI ");
}
ArrayList<CustomHashMap> libros = new Datos().ejecutarConsulta(consulta);
%>
<ul class="lista">
   <%
   if (libros.isEmpty()){
   %>
   <li><label>No se encontraron resultados con ese dato</label></li>
   <%   
   }else{
    for(CustomHashMap lib: libros){
   %>
   <li>
       <a class="ver-libro" data-val="<%=lib.getInt("cve_libro")%>-<%=lib.getInt("cve_genero")%>" style="cursor: default;">
           <h4><%=lib.getString("nombre")%> (<%=lib.getString("codigo_barras")%>)</h4>
           <span class="fecha"><h3><%=lib.getString("genero")%></h3> </span>
           <h5><%=lib.getString("autor")%></h5> 
           <h6>Edición: <%=lib.getString("edicion")%>, Editorial: <%=lib.getString("editorial")%>, ISBN: <%=lib.getString("isbn")%>, Cantidad: <%=lib.getInt("cantidad")%></h6>
       </a>
   </li>
   <%
       }
   }
   %>
</ul>
   <div id="divisor">
       
   </div>
<%
}
%>

<script>  
        $(".ver-libro").on("click", function () {
        var data = $(this).attr("data-val");
        var datos = data.split("-");
        var genero = datos[1];
        var cve_archivo = datos[0];
        if (genero==75) {
             cargarContenido("#content", "modulos/biblioteca/vizualizarMemoria.jsp?cveArchivo="+cve_archivo+"");
        }
      
    });
</script>