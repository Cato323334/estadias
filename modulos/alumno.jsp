<%@page import="mx.edu.utdelacosta.Configuracion"%>
<%@page import="mx.edu.utdelacosta.ParserDate"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.Grupo"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
﻿<%@page language="java" contentType="text/html; charset=utf-8"%>
<%
	HttpSession sesion = request.getSession();	
	
	if(sesion.getAttribute("usuario") == null){
		response.sendRedirect("login.jsp?tab=1&modulo=23");		
	}
	
	Usuario usuario = (Usuario)sesion.getAttribute("usuario");
	Grupo grupo = (Grupo) sesion.getAttribute("grupo");
	
	int cvePersona;
	try{
		cvePersona = (Integer) sesion.getAttribute("cvePersona");
	}catch(Exception e){
		cvePersona = usuario.getCvePersona();
	}
	
	int cveGrupo;
	try{
		cveGrupo = grupo.getCveGrupo();
	}catch (Exception e){
		cveGrupo = 0;
	}
        
%>

<script type="text/javascript" src="js/plugins/mode.js"></script>
<script type="text/javascript" src="js/plugins/jquery.nyroModal-1.6.2.min.js"></script>

<script type="text/javascript" language="javascript">
	$(document).ready(function(){
							   
		$("ul.fichas > li").click(function(event){
			$('ul.fichas > li').removeClass('selected');
			$(this).addClass("selected");
			cambiaGrupo($(this).attr("id"));
			$("#datosAlumno").submit();
		});		
		
		function cambiaGrupo(cveGrupo){
			$("#cveGrupo").val(cveGrupo);
		}	
		
		$("#tab").val(tab);
		$("#tabA").val(tab);
		$("#s" + tab).addClass('selected'); 
		$("#submodulo" + tab).css({"display": "block"});
		
		$.ajax({			   
				url: 'modulos/submodulos/alumno/submodulo' + tab + '.jsp',
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
					$('#submodulo' + idSub).html('<b>Error. <h4>Vuelva a iniciar sesi&oacute;n, si el problema continua favor de comunicarlo al administrador del sistema. <a href="login.jsp">Iniciar sesión aqu&iacute;</a></h4></b>');
				}
			});
			$("#tab").val(idSub);
			$("#tabA").val(idSub);
		}
</script>
<%	
	ArrayList<CustomHashMap> grupos = new Datos().ejecutarConsulta("SELECT g.nombre AS nombre_grupo, p.fecha_inicio, p.fecha_fin, g.cve_grupo, g.cve_periodo "
	 + " FROM grupo g"
	 + " INNER JOIN alumno_grupo ag ON ag.cve_grupo = g.cve_grupo"
	 + " INNER JOIN periodo p ON p.cve_periodo = g.cve_periodo"
	 + " INNER JOIN alumno a ON a.cve_alumno = ag.cve_alumno"
	 + " WHERE a.cve_persona = " + cvePersona 
                + " AND ag.activo = 1 AND p.activo = 1 "
         + " AND g.cve_periodo <= "+(Configuracion.PERIODO_ACTIVO)
	 + " ORDER BY p.fecha_inicio DESC");
%>


<ul class="modo">
    <li><a id="s1" onclick="javascript:eAjax(1, 'alumno')" href="" rel="submodulo1">Información general</a></li>
    <li><a id="s2" onclick="javascript:eAjax(2, 'alumno')" href="" rel="submodulo2">Calificaciones</a></li>
    <li><a id="s7" onclick="javascript:eAjax(7, 'alumno')" href="" rel="submodulo7">Asistencias</a></li>
    <li><a id="s3" onclick="javascript:eAjax(3, 'alumno')" href="" rel="submodulo3">Horario</a></li>
    <li><a id="s4" onclick="javascript:eAjax(4, 'alumno')" href="" rel="submodulo4">Pagos</a></li>
    <li><a id="s5" onclick="javascript:eAjax(5, 'alumno')" href="" rel="submodulo5">Adeudos</a></li>
    <li><a id="s12" onclick="javascript:eAjax(12, 'alumno')" href="" rel="submodulo12">Reportar pagos</a></li>
    <li><a id="s6" onclick="javascript:eAjax(6, 'alumno')" href="" rel="submodulo6">Acción remedial</a></li>
    <li><a id="s8" onclick="javascript:eAjax(8, 'alumno')" href="" rel="submodulo8">Documentación</a></li>
    <li><a id="s9" onclick="javascript:eAjax(9, 'alumno')" href="" rel="submodulo9">Solicitud de convenio</a></li>
    <li><a id="s10" onclick="javascript:eAjax(10, 'alumno')" href="" rel="submodulo10">Requisito de titulación</a></li>
    <!-- Submodulo de estadia -->
    <li><a id="s14" onclick="javascript:eAjax(14, 'alumno')" href="" rel="submodulo14">Estadia</a></li>
    <!-- Submodulo de estadia -->
    <li><a id="s11" onclick="javascript:eAjax(11, 'alumno')" href="" rel="submodulo11">Manual</a></li>
    
</ul>

<p>Periodos/grupos:</p>
<ul class="fichas">
<%
	for(CustomHashMap g: grupos){
		String[] fechaInicio = g.get("fecha_inicio").toString().split("-");
%>
	<li id="<%=g.getInt("cve_grupo")%>" class="<%if(cveGrupo == g.getInt("cve_grupo"))out.print("selected");%>">
        <dt>
            <h1><%=g.getString("nombre_grupo")%></h1>
            <h3><%=fechaInicio[0]%></h3>
            <h2><%= new ParserDate().rangoMeses(g.get("fecha_inicio").toString(), g.get("fecha_fin").toString())%></h2> 
                            
        </dt>
    </li>
<%
	}
%>
</ul>

<form style="display:none" id="datosAlumno" action="datosAlumno" method="post">
<input type="hidden" name="cveGrupo" id="cveGrupo" value="<%=cveGrupo%>" />
<input type="hidden" name="tab" id="tab" value="1" />
<input type="hidden" name="cveModulo" id="tab" value="23" />
</form>


<!-- ------------------------------------------------------ Submódulo 1----------------------------------------------------------- -->
<div class="submodulo" style="display:none" id="submodulo1">

	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>

</div>

<!-- ------------------------------------------------------ Submódulo 2----------------------------------------------------------- -->
<div class="submodulo" style="display:none" id="submodulo2">

	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-- ------------------------------------------------------ Submódulo 3----------------------------------------------------------- -->
<div class="submodulo" style="display:none" id="submodulo3">

	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-- ------------------------------------------------------ Submódulo 4----------------------------------------------------------- -->
<div class="submodulo" style="display:none" id="submodulo4">

	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-- ------------------------------------------------------ Submódulo 5----------------------------------------------------------- -->
<div class="submodulo" style="display:none" id="submodulo5">

	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-- ------------------------------------------------------ Submódulo 6----------------------------------------------------------- -->
<div class="submodulo" style="display:none" id="submodulo6">

	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<!-- ------------------------------------------------------ Submódulo 7 Asistencias ----------------------------------------------------------- -->
<div class="submodulo" style="display:none" id="submodulo7">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<!--Documentación alumno -->
<div class="submodulo" style="display:none" id="submodulo8">

	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<!--Convenios alumno -->
<div class="submodulo" style="display:none" id="submodulo9">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<!--Requisitos de titulacion-->
<div class="submodulo" style="display:none" id="submodulo10">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<!--Referencias-->
<div class="submodulo" style="display:none" id="submodulo12">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<!-- Estadias -->
<div class="submodulo" style="display:none" id="submodulo14">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<!--Manual de usuario-->
<div class="submodulo" style="display:none" id="submodulo11">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
