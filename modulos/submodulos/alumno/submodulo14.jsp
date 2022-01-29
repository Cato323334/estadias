<%-- 
    Document   : submodulo13
    Created on : Nov 24, 2021, 12:08:00 PM
    Author     : rhekh
--%>

<%@page import="mx.edu.utdelacosta.Estadia"%>
<%@page import="mx.edu.utdelacosta.Persona"%>
<%@page import="mx.edu.utdelacosta.Configuracion"%>
<%@page import="mx.edu.utdelacosta.RequisitoTitulacion"%>
<%@page import="mx.edu.utdelacosta.Factura"%>
<%@page import="mx.edu.utdelacosta.PrestamoLibro"%>
<%@page import="mx.edu.utdelacosta.Carrera"%>
<%@page import="mx.edu.utdelacosta.Grupo"%>
<%@page import="mx.edu.utdelacosta.Alumno"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page import="java.text.DecimalFormat"%>
<%@page contentType="text/html; charset=utf-8"%>
<%
    HttpSession sesion = request.getSession();
    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("login.jsp");
    } else {

        Usuario usuario = (Usuario) sesion.getAttribute("usuario");
        int cvePersona;
        try {
            cvePersona = (Integer) sesion.getAttribute("cvePersona");
        } catch (Exception e) {
            cvePersona = usuario.getCvePersona(); 
        }
        
        Datos siest = new Datos();
        ArrayList<CustomHashMap> isAlumno = siest.ejecutarConsulta("SELECT cve_alumno "
                + "FROM alumno a WHERE a.cve_persona=" + cvePersona + " AND activo=1");
        if (!isAlumno.isEmpty()) {
            int cveAlumno = isAlumno.get(0).getInt("cve_alumno");
            
            ArrayList<CustomHashMap> estadia = siest.ejecutarConsulta("SELECT COUNT(cve_asesor) AS contar "
                    + "FROM estadia_alumno ea "
                    + "INNER JOIN alumno_grupo ag on ea.cve_alumno_grupo=ag.cve_alumno_grupo "
                    + "WHERE cve_alumno="+cveAlumno);
            int contar_estadia=estadia.get(0).getInt("contar"); 
            
            if (contar_estadia>0) { //verificamos que el usuario ya esta dado de alta como estudiante de estadia
                    
            ArrayList<CustomHashMap> entregas = siest.ejecutarConsulta("SELECT CAST(ee.cve_estadia_estado AS INTEGER) as clave, ea.nombre_proyecto as proyecto,"
                    + " ta.descripcion as documento, CONVERT( VARCHAR, ee.fecha_alta, 103) as fecha, a.url as directorio,"
                    + " ISNULL(ee.comentario, 'Sin Comentarios') as comentarios, e.descripcion as estado, ee.cve_estado_estadia "
                    + " FROM estadia_archivo ea"
                    + " LEFT JOIN estadia_estado ee on ee.cve_estadia_archivo=ea.cve_estadia_archivo"
                    + " INNER JOIN alumno_grupo as ag on ag.cve_alumno_grupo=ea.cve_alumno_grupo"
                    + " INNER JOIN tipo_archivo as ta on ta.cve_tipo_archivo=ea.tipo_archivo"
                    + " INNER JOIN estado_estadia e on e.cve_estado_estadia=ee.cve_estado_estadia"
                    + " INNER JOIN archivo a on ea.cve_archivo=a.cve_archivo"
                    + " WHERE ag.cve_alumno="+cveAlumno+" and ee.activo=1");
            
            ArrayList<CustomHashMap> t_envio = siest.ejecutarConsulta("SELECT TOP (2) * from tipo_archivo ORDER BY cve_tipo_archivo");
            
            ArrayList<CustomHashMap> asesor = siest.ejecutarConsulta("SELECT (p.apellido_paterno+' '+ p.apellido_materno+' '+ p.nombre) as nombre_completo "
                     + "FROM persona p "
                     + "INNER JOIN estadia_alumno ea on ea.cve_asesor=p.cve_persona "
                     + "INNER JOIN alumno_grupo ag on ea.cve_alumno_grupo=ag.cve_alumno_grupo "
                     + "WHERE ag.cve_alumno="+cveAlumno);
            String name_asesor =asesor.get(0).getString("nombre_completo");
             
            
            
            
            ArrayList<CustomHashMap> aceptacion = siest.ejecutarConsulta("SELECT count(*) as contar "
            + "FROM estadia_archivo ea "
            + "INNER JOIN estadia_alumno aa on ea.cve_alumno_grupo=aa.cve_alumno_grupo "
            + "INNER JOIN estadia_estado ee on ea.cve_estadia_archivo=ee.cve_estadia_archivo "
            + "INNER JOIN alumno_grupo ag on ea.cve_alumno_grupo=ag.cve_alumno_grupo "
            + "WHERE cve_alumno="+cveAlumno+" AND tipo_archivo=3 AND ee.cve_estado_estadia=4 AND aa.numero_avance >=2");
            int carta_aceptacion=aceptacion.get(0).getInt("contar");
            
%>
<form id="estadia-form" class="tablaScroll" enctype="multipart/form-data"> 
    <fieldset>
        <legend>Envio de Archivos de Estadia:</legend>
        <ol>  
            <li>
                <input type="hidden" name="persona" value="<%=cvePersona%>" />
                <label for="cveTipoArchivo">Seleccione un tipo de documento:</label>
                <select name="cveTipoArchivo" id="cveTipoArchivo" required title="Selecciona un grupo">
                    <option value="">Seleccione...</option>
                    <option value="3">Carta de Aceptacion</option>
                    <%
                        if (carta_aceptacion>0) {
                                
                            
                        for (CustomHashMap t : t_envio) {
                    %>

                    <option value="<%=t.getInt("cve_tipo_archivo")%>"><%=t.getString("descripcion")%></option>
                    <%
                        }
                        }
                    %>
                </select>
            </li>
            <li><label for="">Asesor:</label>
                <label><%=name_asesor%></label>
            </li>
            <li>	   
                <label for="proyecto">Proyecto</label>
                <textarea id="proyecto" name="proyecto" rows="2" cols="80" maxlength="50" style="resize:none;" required title="proyecto">Nombre de su proyecto de estadía</textarea>
            </li>
            <li>	   
                <label for="archivo_subido">Archivo PDF</label>
                <input id="archivo_subido" type="file" name="archivo_subido">
                <input type="hidden" name="accion" value="subir" />
                
            </li>
            
            <li>
                <label>&nbsp;</label>
                <input type="submit" clas="btn-subir" value=" Enviar " />
            </li>
        </ol>
    </fieldset>
</form>
    <!-- en esta parte termina el formulario y empiezan los registros previos -->
                <%
                if(!entregas.isEmpty()){
                %>
                <form class="tablaScroll">
                <fieldset>
                    <legend>Entregas</legend>
                    <table>
                        <thead>
                            <tr>
                                <th>No.</th>
                                <th>Nombre Proyecto</th>
                                <th>Documento Entregado</th>
                                <th>Comentarios</th>
                                <th>Estado</th>
                                <th>Fecha</th>
                                <th colspan="2" style="text-align: center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            boolean alt = false;
                            int n = 0;
                            for(CustomHashMap e: entregas){
                            %>
                            <tr class="<%out.print(alt == true?"alt":""); alt = !alt;%>">
                                <td clas="index"><%=++n%></td>
                                <td><%=e.getString("proyecto") %></td>
                                <td><%=e.getString("documento") %></td>
                                <td><%=e.getString("comentarios") %></td>
                                <td><%=e.getString("estado") %></td>
                                <td><%=e.getString("fecha") %></td>
                                <td><a target="_blank" href="/dexter/document/estadias/<%=e.getString("directorio")%>">Descargar</a></td>
                                <td><input type="button" data-ref="<%=e.getInt("clave")%>" class="eliminaEnvio" <%if (e.getInt("cve_estado_estadia")!=1)out.print("hidden");%> value="Cancelar" /></td>
                            </tr>
                            <%
                            }
                            %>
                        </tbody>
                    </table>
                </fieldset>
                        </form>
                        <%
                        }
                        %>
<script> 
    $(".eliminaEnvio").click(function (i) {
        i.preventDefault();
        var c = confirm("Eliminarás este envio, ¿continuar?");
        mensaje("Eliminando...");
        var cveT = $(this).attr("data-ref");
        var parametros = {
               cveEstadiaArchivo: cveT,
               action: 'eliminar-envio' 
           };
        if (c) {
            $.post("estadias",parametros, res).fail(error);
            function res(data) { 
                var datos = data.split("-"); //tomamos los datos que se nos responden del servelet
                if (datos[0] === "401") { //comparamos el resultado del servelet
                    mensaje("El alumno no está logeado"); //aplicamos la respuesta dependiendo del resultado
                }else if (datos[0] === "202") {
                   mensaje("No puedes cancelar un envio ya validado!");
                   location.href = "?modulo=23&tab=14";
                }else if (datos[0] === "201") { 
                   mensaje("Archivo Eliminado");
                   location.href = "?modulo=23&tab=14"; //redireccionamos a una pestana en especifico
                } else {
                    console.log("Algo salió feo :( -- " + data); //en caso de error, enviamos el mensaje de error y la causa de este.
                }
            }
             function error(data) {
                mensaje("Algo salió mal :( "+data); //aqui enviamos el error en caso de salir algo mal
                $("input").attr("disabled", false); //bloaquemos para no volver a mandar archivos
            }
        }
    });
    
    $("#estadia-form").on("submit", function (e) {
        e.preventDefault();
        $(".btn-subir").attr("disabled", true);
        var file = document.getElementById("archivo_subido").value;
        var extArray = new Array(".pdf");
        var ext = file.slice(file.indexOf(".")).toLowerCase();
        var aprobado = false;
        for (var i = 0; i < extArray.length; i++)
        {
            if (extArray[i] === ext)
            {
                aprobado = true;
                mensaje("Enviando...");
                break;
            }
        }
        if (aprobado === false) {
            mensaje("El archivo no es un documento (formato .pdf) o supera el paso maximo (5mb)");
            return false;
        }
        
        $.ajax({
            type: "POST",
            url: "subirEstadia",
            data: new FormData($(this)[0]),
            cache: false,
            contentType: false,
            processData: false,
            success: function (data) {
                var dato = data.split("-");
                console.log(data);
                switch (dato[0]) {
                    case "201":
                        mensaje("Documento enviado");
                        location.href = "?modulo=23&tab=14";
                        break;
                    case "202":
                        mensaje("Los datos son incorrectos");
                        location.href = "?modulo=23&tab=14";
                        break;
                    case "203":
                        mensaje("Ya tienes un archivo pendiente de revisión!");
                        location.href = "?modulo=23&tab=14";
                        break;
                    case "204":
                        mensaje("Ocurrio un problema enviando el correo :c");
                        location.href = "?modulo=23&tab=14";
                        break;
                    default:
                        mensaje("Ocurrió un error al procesaro los datos. " + data);
                        location.href = "?modulo=23&tab=14";
                        break;
                }
            }, error: function (data) {
                console.log(data);
                mensaje("¡Ups! No se pudo conectar con el servidor :(!");
            }
        });
    });

</script>
<%
    }else{
%>
<div class="tabla"> <div class="error" style="display:block"><img src="temas/defecto/imagenes/icons/knownUser.png"> Alerta: aún no estás dado de alta en el servicio de estadías, si continuas con problemas contacta a tu asesor de estadía asignado o a servicios escolares</div></div>
<%
}
}//cerramos la lista de alumnos
}//cerramos el codigo de login
%>