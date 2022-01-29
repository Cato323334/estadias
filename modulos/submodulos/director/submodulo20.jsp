<%-- 
    Document   : submodulo20
    Created on : Dec 21, 2021, 10:48:23 AM
    Author     : rhekh
--%>

<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*, java.text.*"%>
<%
HttpSession sesion = request.getSession();
if(sesion.getAttribute("usuario") == null){
        response.sendRedirect("../../login.jsp?modulo=17&tab=2");		
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
<br>
<form class="tablaScroll">
    <fieldset class="si">
        <legend>Alumnos en Periodo de Estadia</legend>
        <table class="datos">
            <thead>
                <tr>
                    <th rowspan="2">No.</th>
                    <th rowspan="2">Nombre Alumno</th>
                    <th rowspan="2">Matricula</th>
                    <th rowspan="2">Grupo</th>
                    <th rowspan="2">Coordinador</th>
                    <th colspan="3" style="text-align: center;">Avances</th>
                </tr>
                <tr>
                    <th>Primer</th>
                    <th>Segundo</th>
                    <th>Tercer</th>
                </tr>
            </thead>
            <tbody>
                               <%
                    
                    ArrayList<CustomHashMap> alumnosEstadia = siest.ejecutarConsulta("SELECT g.nombre as grupo, ag.activo, a.matricula, ISNULL(ea.cve_coordinador, 0) as coordinador, "
                      + "(p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as nombre_completo, CAST(ag.cve_alumno_grupo as integer) as clave, ISNULL(na.cve_numero_avance_estadia,0) as avances "
                      + "FROM alumno a "
                      + "INNER JOIN alumno_grupo ag on a.cve_alumno=ag.cve_alumno "
                      + "INNER JOIN grupo g on ag.cve_grupo=g.cve_grupo "
                      + "INNER JOIN persona p on a.cve_persona=p.cve_persona "
                      + "INNER JOIN carrera c on g.cve_carrera=c.cve_carrera "
                      + "LEFT JOIN estadia_alumno ea on ag.cve_alumno_grupo=ea.cve_alumno_grupo "
                      + "LEFT JOIN numero_avance_estadia na on ea.numero_avance=na.cve_numero_avance_estadia "
                      + "WHERE ag.activo=1 and (g.cve_cuatrimestre=15 or g.cve_cuatrimestre=21) and c.cve_division="+claveDivision+" and ag.cve_periodo="+periodo);
                    
                    ArrayList<CustomHashMap> asesores = siest.ejecutarConsulta("SELECT p.cve_persona, pf.cve_profesor, pf.cve_area, "
                    + "(p.apellido_paterno+' '+p.apellido_materno+' '+p.nombre) as nombre_completo "
                    + "FROM profesor pf "
                    + "INNER JOIN persona p on pf.cve_persona=p.cve_persona "
                    + "WHERE pf.activo=1 and p.nombre NOT LIKE '%RECESO%' and p.nombre NOT LIKE '%PRENSA%' "
                    + "ORDER BY cve_profesor ASC");
                    
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
                    <td>
                    <select class="sCoordinador">
                        <option value="0">Selecciona...</option>
                            <%
                                for(CustomHashMap as: asesores){
                            %>
                        <option class="ref-op" value="<%=as.getInt("cve_persona")%>-<%=a.getInt("clave")%>" <%if(a.getInt("coordinador")==as.getInt("cve_persona"))out.print("selected");%>><%=as.getString("nombre_completo")%></option>
                         
                        <%
                            }
                        %>
                    </select>
                    </td>
                    <td><%if(a.getInt("avances")>=1){out.print("Entregado");}else{out.print("Sin Entregar");}%></td>
                    <td><%if(a.getInt("avances")>=2){out.print("Entregado");}else{out.print("Sin Entregar");}%></td>
                    <td><%if(a.getInt("avances")>=3){out.print("Entregado");}else{out.print("Sin Entregar");}%></td>
                </tr> 
                <%
                    }
}else{
%>
    <td colspan="9">
        <div class="error" style="display:block; padding-left: 35px;">
            Ningún grupo se encuentra en periodo de estadías
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
  $(".sCoordinador").change(function (e) { //funcion para el cambio de asesor
        e.preventDefault();
        var data = $(this).val();
        var datos = data.split("-");
        var cveCoordinador = datos[0];
        var cveAlumno = datos[1];
         var parametros = {cveCoordinador,cveAlumno, campo: 'cve_coordinador' ,action: 'alta-coordinador'};
        if (e) {
            $.post("estadias",parametros, res).fail(error);
            function res(data) { 
                var datos = data.split("-"); //tomamos los datos que se nos responden del servelet
                if (datos[0] === "401") { //comparamos el resultado del servelet
                    mensaje("El alumno no está logeado"); //aplicamos la respuesta dependiendo del resultado
                }else if (datos[0] === "203") {
                   var p = confirm("Este alumno ya cuenta con un Coordinador asignado, ¿Actualizar Coordinador?");
                       var parametres = { cveCoordinador, cveAlumno, campo:'cve_coordinador', action: 'actualiza-coordinador'};
                        if(p){   
                            $.post("estadias",parametres, res).fail(error);
                                function res(dats) {
                                    var dates = dats.split("-"); //tomamos los datos que se nos responden del servelet
                                    if (dates[0] === "205") { //comparamos el resultado del servelet
                                        mensaje("Coordinador reasignado correctamente"); //aplicamos la respuesta dependiendo del resultado
                                        location.href = "?modulo=17&tab=20";
                                    }else{
                                         console.log("Algo salió mal :( -- " + dats); //en caso de error, enviamos el mensaje de error y la causa de este.
                                    }
                                }function error(dats) {
                                    mensaje("Algo salió mal :( "+dats); //aqui enviamos el error en caso de salir algo mal
                                }
                        }else{
                            mensaje("Reasignación cancelada");   
                        }      
                }else if (datos[0] === "202") {
                   mensaje("Ocurrio un error con el manejo de datos");
                }else if (datos[0] === "201") { 
                   mensaje("Coordinador asignado");
                   location.href = "?modulo=17&tab=20";
                }else{
                    console.log("Algo salió mal :( -- " + data); //en caso de error, enviamos el mensaje de error y la causa de este.
                }
            }function error(data) {
                mensaje("Algo salió mal :( "+data); //aqui enviamos el error en caso de salir algo mal
            }
        }
        
    });
</script>