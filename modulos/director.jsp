<%@page import="mx.edu.utdelacosta.Configuracion"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page language="java" contentType="text/html; charset=utf-8"%>
<%
        HttpSession sesion = request.getSession();
        
        Usuario usuario = (Usuario)sesion.getAttribute("usuario");
	
        if((!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Director") && !usuario.getRol().equals("Academia")) || (sesion.getAttribute("usuario") == null)){
            response.sendRedirect("../login.jsp?modulo=17&tab=1");
        }
	
        int cveGrupo;
        try{
                cveGrupo = (Integer) sesion.getAttribute("cveGrupo");
        }catch(Exception e){
                cveGrupo = 0;
        }
	
        int cveMateria;
        try{
                cveMateria = (Integer) sesion.getAttribute("cveMateria");
        }catch(Exception e){
                cveMateria = 0;
        }
	
        int cveDirector;
        try{
                cveDirector = (Integer) sesion.getAttribute("cvePersona");
        }catch(Exception e){
                cveDirector = usuario.getCvePersona();
        }

        String idPanel;
        try{
                idPanel = sesion.getAttribute("idPanel").toString();
                //idPanel = "p1";
        }catch(Exception e){
                idPanel = "p1";
        }
        Datos siest = new Datos();
%>
<script type="text/javascript" src="js/plugins/mode.js"></script>
<script type="text/javascript" src="js/plugins/jquery.nyroModal-1.6.2.min.js"></script>
<script type="text/javascript" language="javascript">
    $(document).ready(function () {
        $("ul.fichas > li").click(function (event) {
            $('ul.fichas > li').removeClass('selected');
            $(this).addClass("selected");
            cambiaGrupo($(this).attr("id"));
            event.preventDefault();
            $("#datosDirector").submit();
        });

        function cambiaGrupo(cveGrupo) {
            $("#cveGrupo").val(cveGrupo);
        }

        $("#tab").val(tab);
        $("#tabA").val(tab);
        $("#s" + tab).addClass('selected');
        $("#submodulo" + tab).css({"display": "block"});

        $.ajax({
            url: 'modulos/submodulos/director/submodulo' + tab + '.jsp',
            success: function (datos) {
                $('#submodulo' + tab).html(datos);
            },
            error: function () {
                $('#submodulo' + tab).html('<b>Error</b>');
            }
        });
    });

    function eAjax(idSub, modulo) {

        $("#submodulo" + tab).css({"display": "block"});
        $.ajax({
            url: 'modulos/submodulos/' + modulo + '/submodulo' + idSub + '.jsp',
            success: function (datos) {
                $('#submodulo' + idSub).html(datos);
            },
            error: function () {
                $('#submodulo' + idSub).html('<b>Error.</b>');
            }
        });
        $("#tab").val(idSub);
        $("#tabA").val(idSub);
    }
</script>

<ul class="modo">
    <li><a id="s1" onclick="javascript:eAjax(1, 'director')" href="" rel="submodulo1">Dosificaci&oacute;n</a></li>
    <li><a id="s2" onclick="javascript:eAjax(2, 'director')" href="" rel="submodulo2">Fechas de entrega</a></li>
    <li><a id="s3" onclick="javascript:eAjax(3, 'director')" href="" rel="submodulo3">Listado de profesores</a></li>
    <li><a id="s4" onclick="javascript:eAjax(4, 'director')" href="" rel="submodulo4">Listado de alumnos</a></li>
    <li><a id="s5" onclick="javascript:eAjax(5, 'director')" href="" rel="submodulo5">Calificaciones</a></li>
    <li><a id="s6" onclick="javascript:eAjax(6, 'director')" href="" rel="submodulo6">Asistencias</a></li>
    <li><a id="s10" onclick="javascript:eAjax(10, 'director')" href="" rel="submodulo10">Acción remedial</a></li>
    <li><a id="s11" onclick="javascript:eAjax(11, 'director')" href="" rel="submodulo11">Reporte acción remedial</a></li>
    <li><a id="s12" onclick="javascript:eAjax(12, 'director')" href="" rel="submodulo12">Horario</a></li>
    <li><a id="s18" onclick="javascript:eAjax(18, 'director')" href="" rel="submodulo18">Evaluaciones profesor</a></li>
    <li><a id="s17" onclick="javascript:eAjax(17, 'director')" href="" rel="submodulo17">Evaluaciones grupo</a></li>
    <!-- Submodulo de estadia -->
    <li><a id="s19" onclick="javascript:eAjax(19, 'director')" href="" rel="submodulo19">Estadias</a></li>
    <li><a id="s20" onclick="javascript:eAjax(20, 'director')" href="" rel="submodulo20">Coordinador Estadia</a></li>
    <!-- Fin Submodulo de estadia -->
</ul>

<ol class="pestanas">
    <li id="pestana-p1" title="Grupos de TSU" class="<%if(idPanel.equals("p1"))out.print("selected");%>" >TSU Escolarizado</li>
    <li id="pestana-p2" title="Grupos de Despresurizado" class="<%if(idPanel.equals("p2"))out.print("selected");%>" >TSU Despresurizado</li>
    <li id="pestana-p3" title="Grupos de Ingeniería" class="<%if(idPanel.equals("p3"))out.print("selected");%>" >Ingenier&iacute;a</li>
</ol>

<ul class="fichas panelPestana" id="panelPestana-p1" style="<%if(!idPanel.equals("p1"))out.print("display:none");%>" >
    <%
ArrayList<CustomHashMap> escolarizado = siest.ejecutarConsulta("EXEC sp_getGruposPanelDirector "+cveDirector+", "+usuario.getCvePeriodo()+",1,1;");
            for(CustomHashMap grupo: escolarizado){
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

<ul class="fichas panelPestana" id="panelPestana-p2" style="<%if(!idPanel.equals("p2"))out.print("display:none");%>">
    <%
            ArrayList<CustomHashMap> despresurizado = siest.ejecutarConsulta("EXEC sp_getGruposPanelDirector "+cveDirector+", "+usuario.getCvePeriodo()+",1,2;");
            for(CustomHashMap grupo: despresurizado){
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
<ul class="fichas panelPestana" id="panelPestana-p3" style="<%if(!idPanel.equals("p3"))out.print("display:none");%>">
    <%
            ArrayList<CustomHashMap> ingenieria = siest.ejecutarConsulta("EXEC sp_getGruposPanelDirector "+cveDirector+", "+usuario.getCvePeriodo()+",2,0;");
            for(CustomHashMap grupo: ingenieria){
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
<form action="datosDirector" method="post" name="datosDirector" id="datosDirector" style="display:none" >
    <input type="hidden" name="cveGrupo" id="cveGrupo" value="<%=cveGrupo%>" />
    <input type="hidden" name="tab" id="tab" value="1" />
    <input type="hidden" name="cveMateria" value="<%=cveMateria%>" />
</form>

<!----------------------------------- -----SUBMODULO-1------------------------------------------------------------>

<div class="submodulo" style="display:none" id="submodulo1">

    <div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>

</div>

<!-------------------------------------- SubM�dulo 2 ---------------------------------------------------------------->

<div class="submodulo" style="display:none" id="submodulo2">

    <div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>

</div>

<!----------------------------------------------------- SubM�dulo 3 ---------------------------------------------->

<div class="submodulo" style="display:none" id="submodulo3">

    <div class="cargando"><img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" /></div>

</div>

<!----------------------------------------------------- SubM�dulo 4 -------------------------------------------------->

<div class="submodulo" style="display:none" id="submodulo4">

    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>

</div>

<!---------------------------------------- SubM�dulo Calificaciones -------------------------------------->

<div class="submodulo" style="display:none" id="submodulo5" >
    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>    	
</div>

<!---------------------------------------- SubM�dulo Asistencias -------------------------------------->

<div class="submodulo" style="display:none" id="submodulo6" >
    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>    	
</div>

<!---------------------------------------- SubM�dulo Pagos -------------------------------------->

<div class="submodulo" style="display:none" id="submodulo7" >
    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>    	
</div>

<!---------------------------------------- SubM�dulo Deudas -------------------------------------->

<div class="submodulo" style="display:none" id="submodulo8" >
    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>    	
</div>
    
    <!---------------------------------------- SubM�dulo 9 tutoria -------------------------------------->

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
    <div class="submodulo" style="display:none" id="submodulo11" >
    <div class="cargando">
        <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
    </div>    	
</div>
        <div class="submodulo" style="display:none" id="submodulo12" >
            <div class="cargando">
                <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
            </div>    	
        </div>
        <div class="submodulo" style="display:none" id="submodulo13" >
            <div class="cargando">
                <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
            </div>    	
        </div>
            <div class="submodulo" style="display:none" id="submodulo14" >
            <div class="cargando">
                <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
            </div>    	
        </div>
            <div class="submodulo" style="display:none" id="submodulo15" >
            <div class="cargando">
                <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
            </div>    	
            </div>
            <div class="submodulo" style="display:none" id="submodulo16" >
                <div class="cargando">
                    <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
                </div>    	
            </div>
            <div class="submodulo" style="display:none" id="submodulo17" >
                <div class="cargando">
                    <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
                </div>    	
            </div>
            <div class="submodulo" style="display:none" id="submodulo18" >
                <div class="cargando">
                    <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
                </div>    	
            </div>
            
                <!-- Modulo de Estadias -->
                
            <div class="submodulo" style="display:none" id="submodulo19" >
                <div class="cargando">
                    <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
                </div>    	
            </div>
                
            <div class="submodulo" style="display:none" id="submodulo20" >
                <div class="cargando">
                    <img title="Cargando" align="Cargando" src="<%=Configuracion.URL_TEMA%>imagenes/cargando.gif" />
                </div>    	
            </div>
<script>
    startDexterScript();
    $("ol.pestanas > li").on('click', cargarPanelSesion);
    function cargarPanelSesion() {
        var aid = this.id.split("-");
        cargarEnSesion('idPanel', aid[1]);
    }
</script>