<%-- 
    Document   : submodulo11
    Created on : Dec 21, 2021, 11:51:19 AM
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
 int cvePersona = 0;
	try{
		cvePersona = (Integer) sesion.getAttribute("cvePersona");

	}catch(Exception e){
		cvePersona = usuario.getCvePersona();
	}

        int cveGrupo = (Integer) sesion.getAttribute("cveGrupo");
        Datos siest = new Datos();


       ArrayList<CustomHashMap> coordinador= siest.ejecutarConsulta("SELECT COUNT(*) AS contar "
            + "FROM estadia_alumno "
            + "WHERE activo=1 and cve_coordinador="+cvePersona);
            int concordinador = coordinador.get(0).getInt("contar");


        if (concordinador>0) {

              ArrayList<CustomHashMap> alumnosEstadia = siest.ejecutarConsulta("SELECT g.nombre as grupo, ag.activo, a.matricula, ISNULL(ea.cve_asesor, 0) as asesor, "
                      + "(p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as nombre_completo, CAST(ag.cve_alumno_grupo as integer) as clave "
                      + "FROM alumno a "
                      + "INNER JOIN alumno_grupo ag on a.cve_alumno=ag.cve_alumno "
                      + "INNER JOIN grupo g on ag.cve_grupo=g.cve_grupo "
                      + "INNER JOIN persona p on a.cve_persona=p.cve_persona "
                      + "LEFT JOIN estadia_alumno ea on ag.cve_alumno_grupo=ea.cve_alumno_grupo "
                      + "WHERE ag.activo=1 and ea.cve_coordinador="+cvePersona);
              
   if (!alumnosEstadia.isEmpty()) {

    ArrayList<CustomHashMap> asesores = siest.ejecutarConsulta("SELECT p.cve_persona, pf.cve_profesor, pf.cve_area, "
            + "(p.apellido_paterno+' '+p.apellido_materno+' '+p.nombre) as nombre_completo "
            + "FROM profesor pf "
            + "INNER JOIN persona p on pf.cve_persona=p.cve_persona "
            + "WHERE pf.activo=1 and p.nombre NOT LIKE '%RECESO%' and p.nombre NOT LIKE '%PRENSA%' "
            + "ORDER BY cve_profesor ASC");
    
    int numero = 0;
    boolean alt = false;
    
%>
<form>
    <legend>Asesores de Estadía</legend>
    <table>
        <thead>
            <tr>
                <th rowspan="2">No.</th>
                <th rowspan="2">Nombre Completo</th>
                <th>matrícula</th>
                <th>Asesor</th>
            </tr>
        </thead>
        <tbody>
            <%
                for(CustomHashMap ae: alumnosEstadia){
            %>
            <tr class="<%out.print(alt == true?"alt":""); alt = !alt;%>">
                <td class="index"><%=++numero%></td>
                <td  title="nombre_alumno"><%=ae.getString("nombre_completo")%></td>
                <td title="grupo"><%=ae.getString("matricula")%></td>
                <td>
                    <select class="sAsesor">
                        <option value="0">Selecciona...</option>
                            <%
                                for(CustomHashMap as: asesores){
                            %>
                        <option class="ref-op" value="<%=as.getInt("cve_persona")%>-<%=ae.getInt("clave")%>" <%if(ae.getInt("asesor")==as.getInt("cve_persona"))out.print("selected");%>><%=as.getString("nombre_completo")%></option>
                         
                        <%
                            }
                        %>
                    </select>
                </td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>
</form>

<script>   
    $(".sAsesor").change(function (e) { //funcion para el cambio de asesor
        e.preventDefault();
        var data = $(this).val();
        var datos = data.split("-");
        var cveCoordinador = datos[0];
        var cveAlumno = datos[1];
         var parametros = {cveCoordinador, cveAlumno, campo:'cve_asesor',action: 'alta-coordinador'
           };
        if (e) {
            $.post("estadias",parametros, res).fail(error);
            function res(data) { 
                var datos = data.split("-"); //tomamos los datos que se nos responden del servelet
                if (datos[0] === "401") { //comparamos el resultado del servelet
                    mensaje("El alumno no está logeado"); //aplicamos la respuesta dependiendo del resultado
                }else if (datos[0] === "203") {
                   var p = confirm("Este alumno ya cuenta con un Asesor asignado, ¿Actualizar asesor?");
                       var parametres = { cveCoordinador, cveAlumno, campo:'cve_asesor', action: 'actualiza-coordinador'};
                        if(p){   
                            $.post("estadias",parametres, res).fail(error);
                                function res(dats) {
                                    var dates = dats.split("-"); //tomamos los datos que se nos responden del servelet
                                    if (dates[0] === "205") { //comparamos el resultado del servelet
                                        mensaje("Asesor reasignado correctamente"); //aplicamos la respuesta dependiendo del resultado
                                    }else{
                                         console.log("Algo salió feo :( -- " + dats); //en caso de error, enviamos el mensaje de error y la causa de este.
                                    }
                                }function error(dats) {
                                    mensaje("Algo salió mal :( "+dats); //aqui enviamos el error en caso de salir algo mal
                                }
                        }else{
                            mensaje("Reasignación cancelada");   
                        }      
                }else if (datos[0] === "202") {
                   mensaje("Los datos ingresados son incorrectos");
                }else if (datos[0] === "201") { 
                   mensaje("Asesor asignado"); //redireccionamos a una pestana en especifico
                }else{
                    console.log("Algo salió feo :( -- " + data); //en caso de error, enviamos el mensaje de error y la causa de este.
                }
            }function error(data) {
                mensaje("Algo salió mal :( "+data); //aqui enviamos el error en caso de salir algo mal
                $("input").attr("disabled", false); //bloaquemos para no volver a mandar archivos
            }
        }
        
    }); 
</script>
        <%
       }else{
//si la lista no tiene datos ejecutamos eto otro
%>
<div class="error" style="display:block; padding-left: 35px;">
        El grupo seleccionado no se encuentra en periodo de estadias
</div>
        <%

} //cerramos el else de arriba

}else{

%><div class="error" style="display:block; padding-left: 35px;">
      Usted no ha sido asignado como un coordinador
</div><%
}
}
}//cerramos el else de selecicon de grupo
%>
