<%-- 
    Document   : submodulo19
    Created on : Dec 3, 2021, 9:05:40 AM
    Author     : rhekh
--%>

<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*, java.text.*"%>
<%
HttpSession sesion = request.getSession();
if(sesion.getAttribute("usuario") == null){
        response.sendRedirect("../../login.jsp");		
}else{

        Usuario usuario =  (Usuario)sesion.getAttribute("usuario");

       if(!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Director") && !usuario.getRol().equals("Academia")){
            response.sendRedirect("../../login.jsp");
        }

        int cveGrupo;
	try{
		cveGrupo = (Integer) sesion.getAttribute("cveGrupo");
	}catch(Exception e){
		cveGrupo = 0;
	}

%>
<%
    int periodo = usuario.getCvePeriodo();

        Datos siest = new Datos();

        int cvePersona = 0;
	try{
		cvePersona = (Integer) sesion.getAttribute("cvePersona");

	}catch(Exception e){
		cvePersona = usuario.getCvePersona();
	}
        ArrayList<CustomHashMap> consulta = siest.ejecutarConsulta("SELECT cve_division as clave "
                + "FROM director_division "
                + "WHERE cve_director="+cvePersona+" and activo=1 and cve_turno=1 ");
                int claveDivision = consulta.get(0).getInt("clave");
        
%>
<form class="tablaScroll">
    <fieldset class="si">
        <table class="datos">
            <thead>
                <tr>
                    <th>No.</th>
                    <th>Nombre Alumno</th>
                    <th>Matricula</th>
                    <th>Grupo</th>
                    <th>Carrera</th>
                    <th>Nombre Proyecto</th>
                    <th>Documento</th>
                    <th>Estado</th>
                    <th colspan="3" style="text-align: center">Acciones</th>
                </tr>
            </thead>
            <tbody>
                               <%
                    
                    ArrayList<CustomHashMap> alumnosEstadia = siest.ejecutarConsulta("SELECT a.matricula, ea.nombre_proyecto, ta.descripcion as documento, g.nombre as grupo, c.nombre as carrera, "
                      + "(p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as nombre_completo, ea.cve_estadia_archivo as ea, ee.cve_estadia_estado as clave, "
                      + "ea.cve_estadia_archivo as cve_estadia, ar.url as directorio, ee.cve_estado_estadia, es.descripcion as status, ag.cve_alumno_grupo as agr "
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
                      + "WHERE ag.activo=1 and (ee.cve_estado_estadia BETWEEN 2 and 4) and ee.activo=1 and c.cve_division="+claveDivision+" and ag.cve_periodo="+periodo+" "
                      + "ORDER BY ee.cve_estado_estadia asc, grupo asc, nombre_completo asc ");
                    
                    int n = 0;
                    boolean alt = false;
                    if (!alumnosEstadia.isEmpty()) {
                    for (CustomHashMap a : alumnosEstadia) {
                %>
                <tr class="<%out.print(alt == true?"alt":""); alt = !alt;%>">
                    <td class="index"><%=++n%></td>
                    <td><%=a.getString("nombre_completo")%></td>
                    <td><%=a.getString("matricula")%></td>
                    <td><%=a.getString("grupo")%></td>
                    <td><%=a.getString("carrera")%></td>
                    <td ><%=a.getString("nombre_proyecto")%></td>
                    <td><%=a.getString("documento")%></td>
                    <td><%=a.getString("status")%></td>
                    <td><a target="_blank" href="/dexter/document/estadias/<%=a.getString("directorio")%>">Descargar</a></td>
                    <td><input type="button" class="validaEstadia"  data-val="1-<%=a.getInt("cve_estadia")%>-<%=a.getInt("clave")%>-<%=cvePersona%>-<%=a.getInt("ea")%>-<%=a.getString("nombre_completo")%>-<%=a.getInt("agr")%>" value="Aprobar" <%if (a.getInt("cve_estado_estadia")!=2)out.print("hidden");%>></td>
                    <td><input type="button" class="validaEstadia"  data-val="2-<%=a.getInt("cve_estadia")%>-<%=a.getInt("clave")%>-<%=cvePersona%>-<%=a.getInt("ea")%>-<%=a.getString("nombre_completo")%>-<%=a.getInt("agr")%>" value="Rechazar" <%if (a.getInt("cve_estado_estadia")!=2)out.print("hidden");%> ></td>
                </tr> 
                <%
                    }
}else{
%>
            <td colspan="9">
                
<div class="error" style="display:block; padding-left: 35px;">
        Ningún alumno ha realizado entregas aun
</div>
                </td>
<%
}
%>            </tbody>
        </table>
    </fieldset>
</form>
<% 
    }
%>

<script>   
    $(".validaEstadia").click(function (e) {
        e.preventDefault();
        var data = $(this).attr("data-val");
        var datos = data.split("-");
        var eleccion = datos[0];
        var cveEstadia = datos[1];
        var cveEstadiaEstado = datos[2];
        var cvePersona = datos[3];
        var cveAlumnoGrupo = datos[6];
        
        var comentario;
        
        if (eleccion==='1') {
            var p = confirm("Esta a punto de validar este envío, ¿Continuar?");
            comentario = "Sin Comentarios";
            eleccion = 3;
        }else{
            comentario = prompt("Ingrese la razón de su cancelación");
            var p = confirm("Esta a punto de rechazar este envío, ¿Continuar?");
            eleccion = 6;
        }
        
        var parametros = {cveEstadia, comentario, cveEstadiaEstado, eleccion, cvePersona, cveAlumnoGrupo, action: 'valida-asesor'};
        
        if (p) {
            
            $.post("estadias",parametros, res).fail(error);
            function res(data) { 
                var datos = data.split("-"); 
                if (datos[0] === "401") { 
                    mensaje("El alumno no está logeado");
                }else if (datos[0] === "207") {
                   mensaje("Archivo rechazado");
                   location.href = "?modulo=17&tab=19";
                }else if (datos[0] === "208") { 
                   mensaje("Archivo validado");
                   location.href = "?modulo=17&tab=19";
                }else{
                    console.log("Algo salió feo :( -- " + data); 
                }
            }function error(data) {
                mensaje("Algo salió mal :( "+data);
                $("input").attr("disabled", false); 
            }
        }
        
    });
 
</script>