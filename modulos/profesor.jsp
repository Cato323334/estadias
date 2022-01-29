
<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*, java.text.*"%>
<%
	HttpSession sesion = request.getSession();	
	
	Plantilla plantilla = new Plantilla();
	if(sesion.getAttribute("usuario") == null){
		response.sendRedirect("login.jsp?modulo=13&tab=1");		
	}
	
	Usuario usuario = (Usuario)sesion.getAttribute("usuario");
	
	if(!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Director") && !usuario.getRol().equals("Profesor") && !usuario.getRol().equals("Academia")){
            response.sendRedirect("../../login.jsp");
        }
	
	int cierre = 16;
	int tab;
	try{
		tab = Integer.parseInt(request.getParameter("tab"));
	}catch(Exception e){
		tab = 1;
	}
	
	int cveCarga;
	try{
		cveCarga = (Integer) sesion.getAttribute("cveCambioGrupo");
	}catch(Exception e){
		cveCarga = 0;
	}
	
	int cveGrupo;
	try{
		ArrayList<CustomHashMap> grupo = new Datos().ejecutarConsulta("SELECT cve_grupo "
 + "FROM carga_horaria WHERE cve_carga_horaria = " + cveCarga);
		
		cveGrupo = grupo.get(0).getInt("cve_grupo");
		sesion.setAttribute("cveGrupo", cveGrupo);
	}catch(Exception e){
		cveGrupo = 0;
	}
	
	int utActiva;
	try{
		utActiva = (Integer) sesion.getAttribute("utActiva");
	}catch(Exception e){
		utActiva = 0;
	}
	
	int horasTotales = 0;
	int noCalif;
	
	 Calendar today = Calendar.getInstance();
	 
	 int asistenciaDia;
	 try{
		 asistenciaDia = (Integer) sesion.getAttribute("asistenciaDia");
	 }catch(Exception e){
     asistenciaDia = today.get(Calendar.DAY_OF_MONTH);
	 }
	 
	 int asistenciaMes;
	 try{
		 asistenciaMes = (Integer) sesion.getAttribute("asistenciaMes");
	 }catch(Exception e){
     asistenciaMes = today.get(Calendar.MONTH) + 1;
	 }
	 
	 int asistenciaAnho;
	 try{
		 asistenciaAnho = (Integer) sesion.getAttribute("asistenciaAnho");
	 }catch(Exception e){
     asistenciaAnho = today.get(Calendar.YEAR);
	 }
	 
	 int mesReporte;
	 try{
		 mesReporte = (Integer) sesion.getAttribute("mesReporte");
	 }catch(Exception e){
		 mesReporte = today.get(Calendar.MONTH);
	 }
	 
	 int diaSemana;
	 try{
		 diaSemana = (Integer) sesion.getAttribute("diaSemana");
	 }catch(Exception e){
		 diaSemana = today.get(Calendar.DAY_OF_WEEK);
	 }
	
	int cvePersona = 0;
	try{
		cvePersona = (Integer) sesion.getAttribute("cvePersona");
	}catch(Exception e){
		cvePersona = usuario.getCvePersona();
	}
	 
%>
<script type="text/javascript" src="js/plugins/mode.js"></script>
<script type="text/javascript" language="javascript">
	$(document).ready(function(){
							   
		$("ul.fichas > li").click(function(event){
			$('ul.fichas > li').removeClass('selected');
			$(this).addClass("selected");
			cambiaGrupo($(this).attr("id"));
			document.getElementById("myform").submit();
		});		
		
		function cambiaGrupo(cve_carga){
			$("#cveCambioGrupo").val(cve_carga);
		}	
		
		$("#tab").val(tab);
		$("#tabA").val(tab);
		$("#s" + tab).addClass('selected'); 
		$("#submodulo" + tab).css({"display": "block"});
		
		$.ajax({			   
			url: 'modulos/submodulos/profesor/submodulo' + tab + '.jsp',
			success: function(datos) {
				$('#submodulo' + tab).html(datos);
			},
			error: function(){
				$('#submodulo' + tab).html('<b>Error</b>');
			}
		});
		
	});
	
	
	if(<%=cveCarga%> != 0){
            $("#error").css({"display": "none"});
			}
	function eAjax (idSub, modulo){

			$("#submodulo" + tab).css({"display": "block"});
			$.ajax({
				url: 'modulos/submodulos/' + modulo + '/submodulo' + idSub + '.jsp',
				success: function(datos) {
					$('#submodulo' + idSub).html(datos);
				},
				error: function(){					
					$('#submodulo' + idSub).html('<b>Error.</b>');
				}
			});
			$("#tab").val(idSub);
			$("#tabA").val(idSub);
		}
		
		function agregarCriterio(id){
			if(document.getElementById(id+"f").style.display=="none")
			{
				$("#"+id+"f").show("slow");
			}
			else
			{
				$("#"+id+"f").hide("slow");
			}
		}

		function cantidadHoras(cant){
			$("#submodulo" + tab).html('<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>');
			$.ajax({
				url: 'modulos/submodulos/profesor/submodulo' + tab + '.jsp?noClases=' + cant,
				success: function(datos) {
					$('#submodulo' + tab).html(datos);
				},
				error: function(){					
					$('#submodulo' + tab).html('<b>Error. <h4>Vuelva a iniciar sesi&oacute;n, si el problema continua favor de comunicarlo al administrador del sistema. <a href="http://172.16.64.121:8080/dexter/login.jsp">Iniciar sesión aqu&iacute;</a></h4></b>');
				}
			});
		}

		function eliminarAsistencias(cveHorario){
			$("#submodulo" + tab).html('<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>');
			
			$.ajax({
				url: 'modulos/submodulos/profesor/submodulo2.jsp?cveHorario=' + cveHorario,
				success: function(datos) {
					$('#submodulo' + tab).html(datos);
				},
				error: function(){					
					$('#submodulo2').html('<b>Error. <h4>Vuelva a iniciar sesi&oacute;n, si el problema continua favor de comunicarlo al administrador del sistema. <a href="http://172.16.64.121:8080/dexter/login.jsp">Iniciar sesión aqu&iacute;</a></h4></b>');
				}
			});
		}
		
		function confirmar(mensaje){
		return confirm(mensaje);
	}
</script>
<ul class="modo">
    <li><a id="s1" onclick="javascript:eAjax(1, 'profesor')" href="" rel="submodulo1">Dosificación</a></li>
    <li><a id="s2" onclick="javascript:eAjax(2, 'profesor')" href="" rel="submodulo2">Tomar asistencia</a></li>
    <li><a id="s3" onclick="javascript:eAjax(3, 'profesor')" href="" rel="submodulo3">Reporte de asistencias</a></li>
    <li><a id="s4" onclick="javascript:eAjax(4, 'profesor')" href="" rel="submodulo4">Calificar</a></li>
    <li><a id="s5" onclick="javascript:eAjax(5, 'profesor')" href="" rel="submodulo5">Reporte de calificaciones</a></li>
    <li><a id="s6" onclick="javascript:eAjax(6, 'profesor')" href="" rel="submodulo6">Horario de clases</a></li>
    <li><a id="s7" onclick="javascript:eAjax(7, 'profesor')" href="" rel="submodulo7">Fechas de entrega</a></li>
    <li><a id="s8" onclick="javascript:eAjax(8, 'profesor')" href="" rel="submodulo8">Resultados de evaluaciones</a></li>
    <li><a id="s9" onclick="javascript:eAjax(9, 'profesor')" href="" rel="submodulo9">Datos de contacto</a></li>
    <!-- Submodulos de estadia -->
    <li><a id="s10" onclick="javascript:eAjax(10, 'profesor')" href="" rel="submodulo10">Asesor Estadia</a></li>
    <li><a id="s11" onclick="javascript:eAjax(11, 'profesor')" href="" rel="submodulo11">Coordinador Estadia</a></li>
    <li><a id="s12" onclick="javascript:eAjax(12, 'profesor')" href="" rel="submodulo12">Avance Estadia</a></li>
    <!-- Submodulos de estadia-->
</ul>
<!-- -------------------------------Mensajes al profesor------------------------------ -->

<div class="noChrome" style="display:none"> 
	Si algún alumno aparece con calificación cero en el campo de la nivelación es porque ya realizó el pago correspondiente. Puede capturar nivelaciones aunque el alumno no haya pagado, el estado del alumno será deudor.
</div>

<!-- -------------------------Fin de Mensajes al profesor------------------------ -->
							
<p>Tus grupos en el periodo actual:<%//=tab%></p>

<ul class="fichas">
	<%
		ArrayList<CustomHashMap> grupos = new Datos().ejecutarConsulta("SELECT ch.cve_carga_horaria AS cve_carga_horaria, g.cve_grupo AS cve_grupo, g.nombre AS grupo, t.nombre as turno, m.cve_materia AS cve_materia, m.abreviatura AS materia"
		   + " FROM carga_horaria ch "
                   + " INNER JOIN grupo g ON ch.cve_grupo = g.cve_grupo"
		   + " INNER JOIN turno t ON g.cve_turno = t.cve_turno"
		   + " INNER JOIN materia m ON ch.cve_materia = m.cve_materia" 
		   + " INNER JOIN profesor p ON ch.cve_profesor = p.cve_profesor"
		   + " INNER JOIN persona per ON per.cve_persona = p.cve_persona"
		   + " WHERE per.cve_persona = " + cvePersona + " AND ch.cve_periodo = " + usuario.getCvePeriodo() + " AND g.cve_periodo = " + usuario.getCvePeriodo() + " AND g.activo = 1 "
		   + " AND m.calificacion != 0 "
		   + " ORDER BY g.nombre, m.nombre, t.nombre");
		for(CustomHashMap grupo: grupos){
		%>
			<li <%if(grupo.getInt("cve_carga_horaria")==cveCarga){%> class="selected" <%}%> id="<%=grupo.getInt("cve_carga_horaria")%>">
        		<dt>
					<h1 id="<%%>"><%=grupo.getString("grupo")%></h1>
                    <h3 id="<%%>"><%=grupo.getString("materia")%> <%if(usuario.getRol().equals("Administrador"))out.print(grupo.getInt("cve_carga_horaria"));%></h3>
                    <h2 id="<%%>"><%=grupo.getString("turno")%></h2> 
                                    
            	</dt>
          		<dd>
                </dd>
            </li>
        <%
		}
		%>
        
         <form action="datosGrupo" method="post" name="myform" id="myform" style="display:none" >
                 <input type="hidden" value="<%=cveCarga%>" name="cveCambioGrupo" id="cveCambioGrupo" />
                 <input type="hidden" value="<%=asistenciaDia%>" name="asistenciaDia" id="asistenciaDia" />
                 <input type="hidden" value="<%=asistenciaMes%>" name="asistenciaMes" id="asistenciaMes" />
                 <input type="hidden" value="<%=asistenciaAnho%>" name="asistenciaAnho" id="asistenciaAnho" />
                 <input type="hidden" value="<%=diaSemana%>" name="diaSemana" id="diaSemana" />
                 <input type="hidden" value="<%=mesReporte%>" name="mesReporte" id="mesReporte" />
                 <input type="hidden" value="1" name="tab" id="tab" />
                 <input type="hidden" value="<%=utActiva%>" name="utActiva" id="utActiva" />
         </form>
        
        <div class="tabla"  <% if (cveCarga != 0) out.print("style=\"display:none\""); %>>
        <div class="error" style="display:block">
		<img alt="Inscribir" src="<%=Configuracion.URL_TEMA%>imagenes/icons/knownUser.png"  />Por favor seleccione un grupo.</div>
        </div>                                          
</ul>

<!--------------------------------SUBMODULO-1------------------------------------------- -->

<div class="submodulo" style="display:none" id="submodulo1">

	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>

</div>

<!----------------------------------SUBMODULO-2-------------------------------------------->

<div class="submodulo" style="display:none" id="submodulo2">	    
    <div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-------------------------SUBMODULO-3------------------------------------->

<!-- Inicia lista de asistencia mensual -->
<div class="submodulo" style="display:none" id="submodulo3">
		<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<!-- Finaliza la lista de asistencia mensual -->


<!-------------------------------SUBMODULO-4-------------------------------------------->

<div class="submodulo" style="display:none" id="submodulo4" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!------------------------------SUBMODULO-5--------------------------------------------->
<div class="submodulo" style="display:none" id="submodulo5" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!----------------------------SubMódulo-6---Horario---------------------------------------->

<div class="submodulo" style="display:none" id="submodulo6" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-----------------------------SubMódulo-7---Horario-------------------------------------->

<div class="submodulo" style="display:none" id="submodulo7" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<div class="submodulo" style="display:none" id="submodulo8" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<div class="submodulo" style="display:none" id="submodulo9" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-----------------------------SubMódulo- 10 - 11 --- Estadias -------------------------------------->
<div class="submodulo" style="display:none" id="submodulo10" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<div class="submodulo" style="display:none" id="submodulo11" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<div class="submodulo" style="display:none" id="submodulo12" >
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>