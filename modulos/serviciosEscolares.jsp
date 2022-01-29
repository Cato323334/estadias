<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*" %>
<%
	HttpSession sesion = request.getSession();
	Usuario usuario =  (Usuario)sesion.getAttribute("usuario");
	
	if(!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Servicios escolares")){
            response.sendRedirect("login.jsp");
        }
	
	Plantilla plantilla = new Plantilla(null, usuario);
	
	int cveCarrera;
	try{
		cveCarrera = (Integer) sesion.getAttribute("cveCarrera");
	}catch(Exception e){
		cveCarrera = usuario.getCveCarrera();
	}
	
	int cveTurno;
	try{
		cveTurno = (Integer) sesion.getAttribute("cveTurno");
	}catch(Exception e){
		cveTurno = usuario.getCveTurno();
	}
	
	int cveCuatrimestre;
	try{
		cveCuatrimestre = (Integer) sesion.getAttribute("cveCuatrimestre");
	}catch(Exception e){
		cveCuatrimestre = 0;
	}
        Datos siest = new Datos();
%>
<script type="text/javascript" src="js/plugins/mode.js"></script>
<script type="text/javascript" src="js/plugins/jquery.nyroModal-1.6.2.min.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.1.custom.min.js"></script>
<script type="text/javascript" language="javascript">
	$('a.nyroModal').nyroModal({minHeight: 50});
	
	$(document).ready(function(){
		$("ul.fichas > li").click(function(event){
			$('ul.fichas > li').removeClass('selected');
			$(this).addClass("selected");
			cambiaGrupo($(this).attr("id"));
			event.preventDefault();
		});
		
		$('#nuevoGrupo').click(function(event){
			cambiaGrupo(0);							
			event.preventDefault();
		});
	
		function cambiaGrupo(cve_grupo){
			$("#grupo").val(cve_grupo);
			if(cve_grupo == 0){
					$('#inscribir').submit();
				}
		}
		
		$("#tab").val(tab);
		$("#tabA").val(tab);
		$("#s" + tab).addClass('selected'); 
		$("#submodulo" + tab).css({"display": "block"});
		
		$.ajax({			   
				url: 'modulos/submodulos/escolares/submodulo' + tab + '.jsp',
				success: function(datos) {
					$('#submodulo' + tab).html(datos);
				},
				error: function(){
					$('#submodulo' + tab).html('<b>Error</b>');
				}
			});
	});
	
			function formatearFecha(val){
			
			var fechaParse = val.split("/");
			var fechaParseada = fechaParse[2] + "-" + fechaParse[1] + "-" + fechaParse[0];
			$("#fechaNacimiento").val(fechaParseada);
		}
		
			function cambiaCuatri(cuatri){
				$("#cuatrimestre").val(cuatri);
			}
			
		function eAjax (idSub, modulo){
			$("#submodulo" + idSub).css({"display": "block"});
			$.ajax({
				url: 'modulos/submodulos/' + modulo + '/submodulo' + idSub + '.jsp',
				success: function(datos) {
					$('#submodulo' + idSub).html(datos);
				},
				error: function(){					
					$('#submodulo' + idSub).html('<b>Error. <h4>Vuelva a iniciar sesi&oacute;n, si el problema continua favor de comunicarlo al administrador del sistema. <a href="http://172.16.64.121:8080/dexter/login.jsp">Iniciar sesi�n aqu&iacute;</a></h4></b>');
				}
			});
			$("#tab").val(idSub);
			$("#tabA").val(idSub);
		}
		
	
</script>
<ul class="modo">
    <li><a id="s2" onclick="javascript:eAjax(2, 'escolares')" href="" rel="submodulo2">Calificaciones</a></li>
    <li><a id="s1" onclick="javascript:eAjax(1, 'escolares')" href="" rel="submodulo1">Materías</a></li>
    <li><a id="s4" onclick="javascript:eAjax(4, 'escolares')" href="" rel="submodulo4">Pagos por carrera</a></li>
    <li><a id="s5" onclick="javascript:eAjax(5, 'escolares')" href="" rel="submodulo5">No reinscritos</a></li>
    <li><a id="s6" onclick="javascript:eAjax(6, 'escolares')" href="" rel="submodulo6">Promedios</a></li>
    <li><a id="s7" onclick="javascript:eAjax(7, 'escolares')" href="" rel="submodulo7">Requisito de inscripción</a></li>
    <!-- Submodulo de estadia -->
    <li><a id="s8" onclick="javascript:eAjax(8, 'escolares')" href="" rel="submodulo8">Estadias</a></li>
    <!-- Submodulo de estadia -->
</ul>

<form name="datosEscolares" id="datosEscolares" class="fichas" method="post" action="datosEscolares">
<input type="hidden" name="tab" id="tab" value="1" />
<input type="hidden" name="cveModulo" id="cveModulo" value="18" />
	<li>
    	<label>Turno:</label> 
        <label><input type="radio" name="cveTurno" value="1" <%if(cveTurno == 1)out.print("checked=\"checked\"");%> class="report" /> Escolarizado</label>
        <label><input type="radio" name="cveTurno" value="2" <%if(cveTurno == 2)out.print("checked=\"checked\"");%> class="report" /> Despresurizado</label>    
   </li>
   <li>
        <label>Carrera:</label>
        <select name="cveCarrera" class="report">
        	<%
				ArrayList<CustomHashMap> carreras = siest.ejecutarConsulta("SELECT c.cve_carrera, c.nombre, ne.descripcion"
																				 + " FROM carrera c"
																				 + " INNER JOIN nivel_estudio ne ON ne.cve_nivel_estudio = c.cve_nivel_estudio"
																				 + " WHERE c.activo = 1"
																				 + " ORDER BY c.cve_nivel_estudio, c.nombre");
				String nivelEstudio = "";
				for(CustomHashMap carrera: carreras){
					if(!nivelEstudio.equals(carrera.getString("descripcion"))){
						nivelEstudio = carrera.getString("descripcion");
						
						out.print("<optgroup label=\" " + nivelEstudio + "\">");
					}
			%>
            	<option value="<%=carrera.get("cve_carrera")%>"<%if(cveCarrera == carrera.getInt("cve_carrera")) out.print("selected=\"selected\"");%> ><%=carrera.get("nombre")%></option>
            <%
				}
			%>
            </optgroup>
        </select>
   </li>
   <li>
        <label>Cuatrimestre:</label> 
        <select name="cveCuatrimestre" class="report">
                	<option value="0">Seleccione..</option>
            		<%
						ArrayList <CustomHashMap> cuatrimestres = siest.ejecutarConsulta("SELECT c.cve_cuatrimestre AS cve_cuatrimestre, c.descripcion AS cuatrimestre, g.nombre AS grupo"
																							   + " FROM cuatrimestre c"
																							   + " INNER JOIN grupo g ON c.cve_cuatrimestre = g.cve_cuatrimestre"
																							   + " INNER JOIN periodo p ON p.cve_periodo = g.cve_periodo"
																							   + " WHERE g.cve_periodo = " + usuario.getCvePeriodo() + " AND g.cve_carrera = " + cveCarrera
																							   + " ORDER BY g.cve_cuatrimestre");
						int cveCuatri = 0;
						for(CustomHashMap cuatrimestre: cuatrimestres){
							if(cuatrimestre.getInt("cve_cuatrimestre") != cveCuatri){
								cveCuatri = cuatrimestre.getInt("cve_cuatrimestre");
					%>   
                    	<option <%if(cveCuatrimestre == cuatrimestre.getInt("cve_cuatrimestre")){%>selected="selected"<%}%> value="<%=cuatrimestre.getInt("cve_cuatrimestre")%>" ><%=cuatrimestre.getString("cuatrimestre")%></option>     
                    <%
							}
						}
					%>
            	</select>
   </li>
</form>


<script>
    $(".report").on("change", function () {
        $("#datosEscolares").submit();
    });
</script>
<!---------------------------------------------------------SubModulo-1- -------------------------------------------------------------->

<div id="submodulo1" class="submodulo" style="display:none;">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<div id="submodulo2" class="submodulo" style="display:none;">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<div id="submodulo3" class="submodulo" style="display:none;">
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>


<div id="submodulo4" class="submodulo" style="display:none;">
    
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<div id="submodulo5" class="submodulo" style="display:none;">
    
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>

<div id="submodulo6" class="submodulo" style="display:none;">
    
	<div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<div class="submodulo" style="display:none" id="submodulo7">
    <div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
<!---------------------------------------------------------- Submodulo 8 - Estadias ----------------------------------------------------->
<div class="submodulo" style="display:none" id="submodulo8">
    <div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>
</div>
