<%-- 
    Document   : submodulo12
    Created on : Jan 8, 2022, 2:06:42 PM
    Author     : rhekh
--%>
<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*, java.text.*"%>
<%
HttpSession sesion = request.getSession();  

if(sesion.getAttribute("usuario") == null)
{
        response.sendRedirect("../../login.jsp?modulo=13&tab=12");
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
<form class="tablaScroll">
    <fieldset class="si">
        <legend>Alumnos en Periodo de Estadia</legend>
        <table class="datos">
            <thead>
                <tr>
                    <th rowspan='2'>No.</th>
                    <th rowspan='2'>Nombre Alumno</th>
                    <th rowspan='2'>Matricula</th>
                    <th rowspan='2'>Grupo</th>
                    <th rowspan="2">Empresa</th>
                    <th rowspan="2">Asesor Empresarial</th>
                    <th rowspan="2">Puesto</th>
                    <th colspan='3' style='text-align: center;'>Avances</th>
                    <th colspan='2' rowspan="2" style='text-align: center;'>Acciones</th>
                </tr>
                <tr>
                    <th>1ro</th>
                    <th>2do</th>
                    <th>3ro</th>
                </tr>
            </thead>
            <tbody>
                               <%
                    
                    ArrayList<CustomHashMap> alumnoAvance = siest.ejecutarConsulta("SELECT g.nombre as grupo, ag.activo, a.matricula, ISNULL(ea.cve_asesor, 0) as asesor, "
                      + "(p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as nombre_completo, ag.cve_alumno_grupo as agr, ISNULL(ea.numero_avance,0) as avances, "
                      + "a.cve_persona as alumno "
                      + "FROM alumno a "
                      + "INNER JOIN alumno_grupo ag on a.cve_alumno=ag.cve_alumno "
                      + "INNER JOIN grupo g on ag.cve_grupo=g.cve_grupo "
                      + "INNER JOIN persona p on a.cve_persona=p.cve_persona "
                      + "INNER JOIN carrera c on g.cve_carrera=c.cve_carrera "
                      + "INNER JOIN estadia_alumno ea on ag.cve_alumno_grupo=ea.cve_alumno_grupo "
                      + "WHERE ag.activo=1 and (g.cve_cuatrimestre=15 or g.cve_cuatrimestre=21) and ea.cve_asesor="+cvePersona+" and ag.cve_periodo="+periodo+" "
                      + "ORDER BY g.nombre asc , nombre_completo asc");
                    
                    int n = 0;
                    boolean alt = false;
                    if (!alumnoAvance.isEmpty()) {
                    for (CustomHashMap av : alumnoAvance) {
                %>
                <tr class="<%out.print(alt == true?"alt":""); alt = !alt;%>">
                    <td class="index"><%=++n%></td>
                    <td><%=av.getString("nombre_completo")%></td>
                    <td><%=av.getString("matricula")%></td>
                    <td><%=av.getString("grupo")%></td>
                    <td ><textarea id="empresa<%=av.getInt("agr")%>" name="empresa<%=av.getInt("agr")%>" rows="1" cols="25" maxlength="60"  style="resize:none;" required></textarea></td>
                    <td ><textarea id="asesor<%=av.getInt("agr")%>" name="asesor<%=av.getInt("agr")%>" rows="1" cols="25" maxlength="20"  style="resize:none;" required></textarea></td>
                    <td ><textarea id="puesto<%=av.getInt("agr")%>" name="puesto<%=av.getInt("agr")%>" rows="1" cols="15" maxlength="20"  style="resize:none;" required></textarea></td>
                    <td><select class="sAvance" <%if(av.getInt("avances")>2)out.print("disabled");%>>
                            <option class="ref-op" value="2-<%=av.getInt("agr")%>-<%=cvePersona%>-<%=av.getInt("alumno")%>-2" <%if(av.getInt("avances")>=2)out.print("selected");%>>Activo</option>
                            <option class="ref-op" value="1-<%=av.getInt("agr")%>-<%=cvePersona%>-<%=av.getInt("alumno")%>-2" <%if(av.getInt("avances")<2)out.print("selected");%>>In-activo</option>
                        </select></td>
                    <td><select class="sAvance" <%if(av.getInt("avances")<2 || av.getInt("avances")>3)out.print("disabled");%>>
                            <option class="ref-op" value="3-<%=av.getInt("agr")%>-<%=cvePersona%>-<%=av.getInt("alumno")%>-3" <%if(av.getInt("avances")>=3)out.print("selected");%>>Activo</option>
                            <option class="ref-op" value="2-<%=av.getInt("agr")%>-<%=cvePersona%>-<%=av.getInt("alumno")%>-3" <%if(av.getInt("avances")<3)out.print("selected");%>>In-activo</option>
                        </select>
                    </td>
                    <td><select class="sAvance" <%if(av.getInt("avances")<3)out.print("disabled");%>>
                            <option class="ref-op" value="6-<%=av.getInt("agr")%>-<%=cvePersona%>-<%=av.getInt("alumno")%>-6" <%if(av.getInt("avances")>=6)out.print("selected");%>>Activo</option>
                            <option class="ref-op" value="3-<%=av.getInt("agr")%>-<%=cvePersona%>-<%=av.getInt("alumno")%>-6" <%if(av.getInt("avances")<6)out.print("selected");%>>In-activo</option>
                        </select>
                   </td>
                    <td><input type="button" value="C. Aceptacion" class="carta" data-val="1-<%=av.getInt("agr")%>-1"></td> 
                </tr> 
                <%
                    }
}else{
%>
            <td colspan="11">
                
<div class="error" style="display:block; padding-left: 35px;">
        Ningún alumno ha sido dado de alta aun...
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
                }
  
%>

<script>   
 $(".sAvance").change(function (u) { //funcion para el cambio de asesor
        u.preventDefault();
        var data = $(this).val();
        var datos = data.split("-");
        var eleccion = datos[0];
        var cveAlumnoGrupo = datos[1];
        var cvePersona = datos[2];
        var cveAlumno = datos[3];
        var avancePrevio = datos[4];
         var parametros = {eleccion,cveAlumnoGrupo, cveAlumno, cvePersona, avancePrevio, action: 'actualiza-avance'
           };
        mensaje("Actualizando...")
        if (u) {
            $.post("estadias",parametros, res).fail(error);
            function res(data) { 
                var datos = data.split("-"); //tomamos los datos que se nos responden del servelet
                if (datos[0] === "401") { //comparamos el resultado del servelet
                    mensaje("El alumno no está logeado"); //aplicamos la respuesta dependiendo del resultado
                }else if (datos[0] === "205") { 
                   mensaje("Avance Actualizado");
                   location.href = "?modulo=13&tab=12"; //redireccionamos a una pestana en especifico
                }else{
                    console.log("Algo salió feo :( -- " + data); //en caso de error, enviamos el mensaje de error y la causa de este.
                    location.href = "?modulo=13&tab=12"; //redireccionamos a una pestana en especifico
                }
            }function error(data) {
                mensaje("Algo salió mal :( "+data); //aqui enviamos el error en caso de salir algo mal
                $("input").attr("disabled", false); //bloaquemos para no volver a mandar archivos
            }
        }
        
    });
    
    $(".carta").on("click", function (c) {
        c.preventDefault();
        var data = $(this).attr("data-val");
        var datos = data.split("-");
        var numero = datos[0];
        var cveAlumno = datos[1];
        var tipoCarta = datos[2];
        var empresa = $("#empresa"+cveAlumno).val().toUpperCase();
        var asesor = $("#asesor"+cveAlumno).val().toUpperCase();
        var puesto = $("#puesto"+cveAlumno).val().toUpperCase();
        if (asesor!=="" & puesto!=="" & empresa!=="") {
        window.open("modulos/submodulos/profesor/terciarios/generaCartaPresentacion.jsp?numero="+numero+"&cveAlumno="+cveAlumno+"&tipoCarta="+tipoCarta+"&empresa="+empresa+"&asesor="+asesor+"&puesto="+puesto, "_blank");
        }else{
            alert("Rellena todos los campos");
        }
    });
</script>