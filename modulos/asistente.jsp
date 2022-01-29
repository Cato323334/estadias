<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*" %>
<%
HttpSession sesion = request.getSession();	

if(sesion.getAttribute("usuario") == null){
	response.sendRedirect("login.jsp?modulo=14");		
}else{
	
	Usuario usuario =  (Usuario)sesion.getAttribute("usuario");
	
	if(!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Asistente") && !usuario.getRol().equals("Academia") && !usuario.getRol().equals("Director")){
              response.sendRedirect("../../login.jsp");
        }
		
	int tab;
	try{
		tab = Integer.parseInt(request.getParameter("tab"));
	}catch(Exception e){
		tab = 1;
	}
		
	int cveAsistente;
	try{
		cveAsistente = (Integer) sesion.getAttribute("cvePersona");
	}catch(Exception e){
		cveAsistente = 0;
	}
	if(cveAsistente==0){
 cveAsistente = usuario.getCvePersona();
}
	int cveGrupo;
	try{
		cveGrupo = (Integer) sesion.getAttribute("cveGrupo");
	}catch(Exception e){
		cveGrupo = 0;
	}
	Datos siest = new Datos();
	int cveCuatrimestre;
	try{
		ArrayList<CustomHashMap> cveCuatrimestres = siest.ejecutarConsulta("SELECT c.cve_cuatrimestre, c.cve_nivel_estudio, CAST(c.consecutivo AS INTEGER) AS consecutivo"
		+ " FROM grupo g"
		+ " INNER JOIN cuatrimestre c ON c.cve_cuatrimestre = g.cve_cuatrimestre"
		+ " WHERE g.cve_grupo = " + cveGrupo);
		
		cveCuatrimestre = cveCuatrimestres.get(0).getInt("cve_cuatrimestre");
		sesion.setAttribute("cveCuatrimestre", cveCuatrimestre);
		sesion.setAttribute("cveNivelEstudio", cveCuatrimestres.get(0).getInt("cve_nivel_estudio"));
		sesion.setAttribute("noCuatrimestre", cveCuatrimestres.get(0).get("consecutivo"));
	}catch(Exception e){
		cveCuatrimestre = 0;
	}
%>

<script type="text/javascript" src="js/plugins/mode.js"></script>
<script type="text/javascript" language="javascript">	
	$(document).ready(function(){
		$("ul.fichas > li").click(function(event){
			$('ul.fichas > li').removeClass('selected');
			$(this).addClass("selected");
			cambiaGrupo($(this).attr("id"));
			event.preventDefault();
			$("#cargarDatos").submit();
		});
		
		$('#asignarCarga').click(function(event){
			var grupo = $('#grupo').val();
			if(grupo ==  '0'){
				alert('Por favor elige un grupo.');
			}else{
				$("#cargahoraria").submit();
			}
			event.preventDefault();
		});
		
		function cambiaGrupo(cve_grupo){
			$("#cveGrupo").val(cve_grupo);
		}		
		$("#tab").val(tab);
		$("#s" + tab).addClass('selected'); $("#submodulo" + tab).css({"display": "block"});
		$.ajax({
				url: 'modulos/submodulos/asistente/submodulo' + tab + '.jsp',
				success: function(datos) {
					$('#submodulo' + tab).html(datos);
				},
				error: function(){
					
					$('#submodulo' + tab).html('<b>Error</b>');
				}
			});
	});
	
	function eAjax (idSub, modulo){

			$("#submodulo" + tab).css({"display": "block"});
			$.ajax({
				url: 'modulos/submodulos/' + modulo + '/submodulo' + idSub + '.jsp',
				success: function(datos) {
					$('#submodulo' + idSub).html(datos);
				},
				error: function(){					
					$('#submodulo' + idSub).html('<b>Error.');
				}
			});
			$("#tab").val(idSub);
			$("#tabA").val(idSub);
		}
	
</script>

<form style="display:none" name="eliminarCarga" id="eliminarCarga" method="post" action="eliminarCarga">
<input type="hidden" name="cveECarga" id="cveECarga" value="0" />
</form>

<form style="display:none" name="cargarDatos" id="cargarDatos" method="post" action="datosParaAsistente">
	<input type="hidden" name="cveGrupo" id="cveGrupo" value="<%=cveGrupo%>" />
    <input type="hidden" name="tab" id="tab" value="1" />
    <input type="hidden" name="cveCuatrimestre" id="cveCuatrimestre" value="<%=cveCuatrimestre%>" />
    <input type="hidden" name="cveModulo" value="14" />
</form>

<ul class="modo">
	<li><a id="s1" onclick="javascript:eAjax(1, 'asistente')" href="" rel="submodulo1">Carga horaria</a></li>
    <li><a id="s2" onclick="javascript:eAjax(2, 'asistente')" href="" rel="submodulo2">Calificaciones</a></li>
    <li><a id="s3" onclick="javascript:eAjax(3, 'asistente')" href="" rel="submodulo3">Evaluación docente</a></li>
    <li><a id="s4" onclick="javascript:eAjax(4, 'asistente')" href="" rel="submodulo4">Profesores</a></li>
    <li><a id="s5" onclick="javascript:eAjax(5, 'asistente')" href="" rel="submodulo5">Grupos</a></li>
    <li><a id="s6" onclick="javascript:eAjax(6, 'asistente')" href="" rel="submodulo6">Asistencias</a></li>
    <li><a id="s7" onclick="javascript:eAjax(7, 'asistente')" href="" rel="submodulo7">Pagos</a></li>
    <li><a id="s8" onclick="javascript:eAjax(8, 'asistente')" href="" rel="submodulo8">Adeudos</a></li>
    <li><a id="s9" onclick="javascript:eAjax(9, 'asistente')" href="" rel="submodulo9">Usuarios</a></li>
    <li><a id="s10" onclick="javascript:eAjax(10, 'asistente')" href="" rel="submodulo10">No reinscritos</a></li>
    <!-- Submodulo de estadia -->
    <li><a id="s11" onclick="javascript:eAjax(11, 'asistente')" href="" rel="submodulo11">Estadias</a></li>
    <!-- Fin Submodulo de estadia -->
</ul>

   <p>Grupos creados para el periodo actual:</p>
    <ul class="fichas">
		<%
		
              ArrayList<CustomHashMap> grupos = siest.ejecutarConsulta("SELECT DISTINCT(g.cve_grupo), g.cve_carrera, g.consecutivo, "
                        + "t.nombre as turno, g.nombre as grupo "
                        + "FROM grupo g "
                        + "INNER JOIN turno t ON g.cve_turno = t.cve_turno "
                        + "INNER JOIN carrera_asistente ca ON ca.cve_carrera=g.cve_carrera "
                        + "WHERE g.cve_carrera = " + usuario.getCveCarrera() + " AND g.cve_turno = ca.cve_turno "
                        + "AND g.cve_periodo = " + usuario.getCvePeriodo() + " "
                        + "AND g.activo = true AND g.cve_turno="+usuario.getCveTurno()+" AND ca.cve_asistente="+cveAsistente+" AND ca.activo=true");
			
			for(CustomHashMap grupo: grupos){
				%>
        			<li <%if(grupo.getInt("cve_grupo") == cveGrupo){%>class="selected"<%}%> id="<%=grupo.getInt("cve_grupo")%>">
						<dt>
							<h1><%=grupo.getString("grupo")%></h1>
                            <h2><%=grupo.getString("turno")%></h2>
                        </dt>
					</li>
           		<%
				}
		%>
	</ul> 
                    
<!--------------------------------------- ----------SubMódulo-1----Carga-horaria---------------------------->

<div class="submodulo" style="display:none" id="submodulo1">
	<div class="cargando"><img title="Cargando" alt="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!---------------------------------------------- ----SubMódulo-2---------------------------------------------->

<div class="submodulo" style="display:none" id="submodulo2" >
	<div class="cargando"><img title="Cargando" alt="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-------------------------------------------------SubMódulo 3 Alumnos---------------------------------->

<div class="submodulo" style="display:none" id="submodulo3">
	<div class="cargando"><img title="Cargando" alt="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-------------------------------------------------SubMódulo 4 Horario-------------------------------------->

<div class="submodulo" style="display:none" id="submodulo4">
	<div class="cargando"><img title="Cargando" alt="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-------------------------------------------------SubMódulo 5 Grupos-------------------------------------->

<div class="submodulo" style="display:none" id="submodulo5">
	<div class="cargando">
		<img title="Cargando" alt="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
	</div>
</div>

<!-------------------------------------------------SubMódulo 6 Asistencias ------------------------>

<div class="submodulo" style="display:none" id="submodulo6">
	<div class="cargando"><img title="Cargando" alt="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
        <!-------------------------------------------------SubMódulo 7 Pagos ------------------------>

<div class="submodulo" style="display:none" id="submodulo7">
	<div class="cargando"><img title="Cargando" alt="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-------------------------------------------------SubMódulo 8 Adeudos ------------------------>

<div class="submodulo" style="display:none" id="submodulo8">
	<div class="cargando"><img title="Cargando" alt="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
        
     <!---------------------------------------- SubM�dulo 9 Usuarios -------------------------------------->

<div class="submodulo" style="display:none" id="submodulo9" >
    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>    	
</div>
        <div class="submodulo" style="display:none" id="submodulo10" >
    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>    	
</div>
    
    <!---------------------------------------- SubM�dulo 11 estadia-------------------------------------->
       <div class="submodulo" style="display:none" id="submodulo11" >
    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>    	
</div>
<%
}
%>