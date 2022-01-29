<%-- 
    Document   : submodulo10
    Created on : Nov 26, 2021, 11:47:16 AM
    Author     : rhekh
--%>

<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*, java.text.*"%>
<%
HttpSession sesion = request.getSession();  

if(sesion.getAttribute("usuario") == null)
{
        response.sendRedirect("../../login.jsp?modulo=13&tab=4");
}
else{

        Usuario usuario = (Usuario)sesion.getAttribute("usuario");
        Grupo grupo = (Grupo) sesion.getAttribute("grupo");
       
        if(!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Director") && !usuario.getRol().equals("Profesor") && !usuario.getRol().equals("Academia")){
            response.sendRedirect("../../login.jsp");
        }
        if(grupo == null){
%>

<%
}else{
        int cveGrupo = (Integer) sesion.getAttribute("cveGrupo");
        Datos siest = new Datos();
        
        int periodo = usuario.getCvePeriodo();

        int cvePersona = 0;
	try{
		cvePersona = (Integer) sesion.getAttribute("cvePersona");

	}catch(Exception e){
		cvePersona = usuario.getCvePersona();
	}
        
%>

        <%
            ArrayList<CustomHashMap> alumnosEstadia = siest.ejecutarConsulta("SELECT a.matricula, ea.nombre_proyecto, ta.descripcion as documento, g.nombre as grupo, c.nombre as carrera, "
                      + "(p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as nombre_completo, ea.cve_estadia_archivo as ea, ee.cve_estadia_estado as clave, ee.cve_estado_estadia, "
                      + "ea.cve_estadia_archivo as cve_estadia, ar.url as directorio, es.descripcion as status, ag.cve_alumno_grupo as agr "
                      + "FROM alumno a "
                      + "INNER JOIN alumno_grupo ag on a.cve_alumno=ag.cve_alumno "
                      + "INNER JOIN estadia_archivo ea on ag.cve_alumno_grupo=ea.cve_alumno_grupo "
                      + "INNER JOIN grupo g on ag.cve_grupo=g.cve_grupo "
                      + "INNER JOIN estadia_alumno aa on ag.cve_alumno_grupo=aa.cve_alumno_grupo "
                      + "INNER JOIN persona p on a.cve_persona=p.cve_persona "
                      + "INNER JOIN estadia_estado ee on ea.cve_estadia_archivo=ee.cve_estadia_archivo "
                      + "INNER JOIN tipo_archivo ta on ea.tipo_archivo=ta.cve_tipo_archivo "
                      + "INNER JOIN archivo ar on ea.cve_archivo=ar.cve_archivo "
                      + "INNER JOIN carrera c on g.cve_carrera=c.cve_carrera "
                      + "INNER JOIN estado_estadia es on ee.cve_estado_estadia=es.cve_estado_estadia "
                      + "WHERE ag.activo=1 and (ee.cve_estado_estadia BETWEEN 1 and 4)and ee.activo=1 and aa.cve_asesor="+cvePersona+" and ag.cve_periodo="+periodo+" "
                      + "ORDER BY ee.cve_estado_estadia asc, carrera asc, grupo asc, nombre_completo asc ");

                     int n = 0;
                     boolean alt = false;
                    if (!alumnosEstadia.isEmpty()) {
        %>
<form class="tablaScroll">
    <fieldset class="si">
        <legend>Documentos por Aprobar</legend>
        <table class="datos">
            <thead>
                <tr>
                    <th>No.</th>
                    <th>Nombre Alumno</th>
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
                    
                    
                    for (CustomHashMap a : alumnosEstadia) {
                %>
                <tr class="<%out.print(alt == true?"alt":""); alt = !alt;%>">
                    <td class="index"><%=++n%></td>
                    <td><%=a.getString("nombre_completo")%></td>
                    <td><%=a.getString("grupo")%></td>
                    <td><%=a.getString("carrera")%></td>
                    <td ><textarea id="proyecto<%=a.getInt("cve_estadia")%>" name="proyecto"  rows="1" cols="50" maxlength="50"  style="resize:none;" required <%if (a.getInt("cve_estado_estadia")!=1)out.print("disabled");%>><%=a.getString("nombre_proyecto")%></textarea></td>
                    <td><%=a.getString("documento")%></td>
                    <td><%=a.getString("status")%></td>
                    <td><a target="_blank" href="/dexter/document/estadias/<%=a.getString("directorio")%>">Descargar</a></td>
                    <td><input type="button" class="validaEstadia" data-val="1-<%=a.getInt("cve_estadia")%>-<%=a.getInt("clave")%>-<%=cvePersona%>-<%=a.getInt("ea")%>-<%=a.getString("nombre_completo")%>-<%=a.getInt("agr")%>" value="Aprobar" <%if (a.getInt("cve_estado_estadia")!=1)out.print("hidden");%> ></td>
                    <td><input type="button" class="validaEstadia" data-val="2-<%=a.getInt("cve_estadia")%>-<%=a.getInt("clave")%>-<%=cvePersona%>-<%=a.getInt("ea")%>-<%=a.getString("nombre_completo")%>-<%=a.getInt("agr")%>" value="Rechazar"<%if (a.getInt("cve_estado_estadia")!=1)out.print("hidden");%> ></td>
                </tr> 
                <%
                    }
%></tbody>
        </table>
    </fieldset>
</form>
<%
                    }else{

%>                
<div class="error" style="display:block; padding-left: 35px;">
        Ningún alumno ha realizado entregas aun...
</div>
 <%
            }
        }
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
        var cveEarchivo = datos[4];
        var cveAlumnoGrupo = datos[6];
        var proyecto = $("#proyecto"+cveEstadia).val();
        var comentario; 
        if (eleccion==='1') {
            var p = confirm("Esta a punto de validar este envío, ¿Continuar?");
            comentario = "Sin Comentarios";
            eleccion = 2;
        }else{
            comentario = prompt("Ingrese la razón de su cancelación");
            var p = confirm("Esta a punto de rechazar este envío, ¿Continuar?");
            eleccion = 5;
        } 
        
        var parametros = {cveEstadia, comentario, cveEstadiaEstado, eleccion, cvePersona, cveAlumnoGrupo, proyecto, cveEarchivo, action: 'valida-asesor'};
        
        if (p) {
            $.post("estadias",parametros, res).fail(error);
            function res(data) { 
                var datos = data.split("-"); 
                if (datos[0] === "401") { 
                    mensaje("El alumno no está logeado");
                }else if (datos[0] === "207") {
                   mensaje("Archivo rechazado");
                   location.href = "?modulo=13&tab=10";
                }else if (datos[0] === "208") { 
                   mensaje("Archivo validado");
                   location.href = "?modulo=13&tab=10";
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