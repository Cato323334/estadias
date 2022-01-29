/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package mx.edu.utdelacosta.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import mx.edu.utdelacosta.Archivo;
import mx.edu.utdelacosta.CarearFecha;
import mx.edu.utdelacosta.ErrorGeneral;
import mx.edu.utdelacosta.Estadia;
import mx.edu.utdelacosta.Persona;
import mx.edu.utdelacosta.RequestParamParser;
import mx.edu.utdelacosta.Usuario;

/**
 *
 * @author rhekh
 */
@WebServlet(name = "EstadiaSer", urlPatterns = {"/estadias"})
public class EstadiaSer extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("index.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
        HttpSession sesion = request.getSession();
        Archivo arc = new Archivo();
        PrintWriter salida = response.getWriter();
        RequestParamParser parser = new RequestParamParser(request);
        
        
        
        if (sesion.getAttribute("usuario") == null) {
            salida.write("401-El usuario no está logueado.");
        } else {
            try{
                String accion = parser.getStringParameter("action", "");
                Estadia estadia = new Estadia();
                int cveAlumnoGrupo;
                int cveProfesor;
                int cvePersona;
                int cveAlumno;
                int cveEstadiaArchivo;
                switch (accion) {
                    case "estadia-alumno":
                        Usuario usuario = (Usuario) sesion.getAttribute("usuario");
                        cvePersona = usuario.getCvePersona();
                        int cveTipoArchivo = parser.getIntParameter("cveTipoArchivo", 0); //se toman los valores de las variables
                        int archivo = parser.getIntParameter("cve", 0);
                        String proyecto = parser.getStringParameter("proyecto", null);
                        cveAlumnoGrupo = estadia.getAlumnoGrupoPersona(cvePersona); //llamamos el metodo para obtener cvaAlumnoGrupo
                        int existente = estadia.revisarExistente(cveAlumnoGrupo, cveTipoArchivo);
                        if (existente>0) {
                            salida.write("203-duplicated");
                        }else{
                        estadia.guardarEstadiaAlumno(cveAlumnoGrupo, archivo, proyecto, cveTipoArchivo); //guardamos en la tabla estadia alumno (1ra tabla del proceso)
                        int cveAsesor=estadia.GetAsesorAlumno(cveAlumnoGrupo); //obtenemos el asesor del alumno
                        int cveEnvioUltimo=estadia.GetUltimoArchivo(cveAlumnoGrupo, cveTipoArchivo);
                        estadia.guardarEstadiaEstado(cveEnvioUltimo, cveAsesor); //guardamos el estado de la estadia (2da parte del proceso)
                        salida.write("201-save");
                        }
                        break;
                        
                    case "eliminar-envio":
                         cveEstadiaArchivo = parser.getIntParameter("cveEstadiaArchivo", 0);
                        int cStatus = estadia.status(cveEstadiaArchivo);                      
                        if (cStatus==1) {
                            estadia.bajaEstadia(cveEstadiaArchivo);
                            salida.write("201-save");   
                        } else {
                            salida.write("202-invalid");
                        }
                        break;
                        
                    case "alta-asesor":
                        cveProfesor = parser.getIntParameter("cveProfesores", 0);
                        cveAlumno = parser.getIntParameter("cveAlumnos",0);
                        String asignar = parser.getStringParameter("base","");
                        if(cveAlumno>0 & cveProfesor>0){
                            int est = estadia.existeAsesorAlumno(cveProfesor, cveAlumno);
                            if (est==0) {
                                estadia.altaAsesorAlumno(cveProfesor, cveAlumno);
                                salida.write("201-save");
                            }else{
                                salida.write("203-duplicated");
                            }
                        }else{
                                salida.write("202-invalid");
                        }
                        break;
                        
                    case "actualiza-asesor":
                        cveProfesor = parser.getIntParameter("cveProfesores", 0);
                        cveAlumno = parser.getIntParameter("cveAlumnos",0);
                        asignar = parser.getStringParameter("base","");
                        estadia.ActualizarTutorAlumno(cveAlumno, cveProfesor);
                        salida.write("205-updated");
                        break;
                        
                    case "alta-coordinador": //Submodulo20 - Panel de Director
                    int cveAseCoor = parser.getIntParameter("cveCoordinador", 0);
                    cveAlumno = parser.getIntParameter("cveAlumno",0); //clave alumno grupo
                    String campo = parser.getStringParameter("campo", "");
                        if(cveAlumno>0 & cveAseCoor>0 & campo!=""){ //comprobamos que no sean datos vacios
                            int existePersona = estadia.existeEstadiaCoordinadorAsesor(cveAlumno, campo); //comprobamos si existe el coordinador
                            if (existePersona==0) { //en caso de no existir
                            int existeEstadia = estadia.existeEstadiaAlumno(cveAlumno); //comprobamos si el alumno ya tiene registro activo en estadia (es decir que antes se le haya ingresado un asesor)
                                if (existeEstadia==0) {
                                estadia.altaAsesorCoordinador(cveAseCoor, cveAlumno, campo);//creamos perfil y agregamos coordinador
                                salida.write("201-save");
                                }else{
                                estadia.actualizaCoordinadorAsesor(cveAseCoor, cveAlumno, campo); //actualizamos perfil y agregamos asesor
                                salida.write("201-save");
                                }
                            }else{
                                salida.write("203-duplicated"); //duplicado y regresamos el mensaje a la pagina
                            }
                        }else{
                                salida.write("202-invalid"); //datos invalidos
                        }
                    break;
                        
                    case "actualiza-coordinador":
                        cveProfesor = parser.getIntParameter("cveCoordinador", 0);
                        cveAlumno = parser.getIntParameter("cveAlumno",0);
                        campo = parser.getStringParameter("campo","");
                        estadia.actualizaCoordinadorAsesor(cveProfesor, cveAlumno, campo);
                        salida.write("205-updated");
                        break;
                    case "actualiza-avance":
                        int eleccion = parser.getIntParameter("eleccion", 0);
                        cveAlumno = parser.getIntParameter("cveAlumno",0);
                        cvePersona = parser.getIntParameter("cvePersona",0);
                        cveAlumnoGrupo = parser.getIntParameter("cveAlumnoGrupo",0);
                        int avancePrevio = parser.getIntParameter("avancePrevio",0);
                        String desEleccion="";
                        estadia.actualizaAvance(cveAlumnoGrupo, eleccion);
                        switch(eleccion){
                            case 1: desEleccion="Primer"; break;
                            case 2: desEleccion="Segundo"; break;
                            case 3: desEleccion="Tercer"; break;
                        }
                        String resultado="";
                        if (avancePrevio==eleccion) {
                            resultado = "aprovado";
                        }else if(avancePrevio>eleccion){
                            resultado = "rechazado";
                        }
                        estadia.correoAvanceEstadia(cveAlumno, cvePersona, desEleccion, resultado);
                        salida.write("205-updated");
                    break; 
                    
                    case "valida-asesor":
                        int cveEstadia = parser.getIntParameter("cveEstadia", 0);
                        int status = parser.getIntParameter("eleccion", 0);
                        String comentario = parser.getStringParameter("comentario", "");
                        String info_proyecto = parser.getStringParameter("proyecto", null);
                        cvePersona = parser.getIntParameter("cvePersona", 0); //clave del profesor
                        cveEstadiaArchivo = parser.getIntParameter("cveEarchivo", 0); //cve de la tabla estadia_archivo
                        int cveEstadiaEstado = parser.getIntParameter("cveEstadiaEstado", 0); //estado del envio de la tabla estadia_archivo
                        cveAlumnoGrupo = parser.getIntParameter("cveAlumnoGrupo", 0); //obtener el alumno grupo
                        cveTipoArchivo = parser.getIntParameter("cveTipoArchivo",1);
                        int cvePersonaAlumno = estadia.getCveAlumno(cveAlumnoGrupo);
                        int nivelEstudio = estadia.getNivelEstudio(cveAlumnoGrupo);
                        
                        estadia.validaEstadiaEstado(cveEstadia, cvePersona, status, comentario, cveEstadiaEstado);
                        if (comentario!= "") {
                            estadia.ActualizaDescripcion(cveEstadiaArchivo, info_proyecto);
                        }
                        switch (status){
                            case 1:
                                
                                break;
                            case 2:
                                //de aqui se envia a los directores
                                int dire = estadia.getCveArea(cveAlumnoGrupo);
                                estadia.enviaCorreoAlumno(dire);
                                estadia.enviaCorreoEstado(cvePersonaAlumno, cvePersona, "aprobado");
                                salida.write("208-validated");
                                break;
                            case 3:
                                //de aqui se envia a los servicios escolares
                                estadia.enviaCorreoEscolares();
                                salida.write("208-validated");
                                break;
                            case 4:
                                //enviar correo alumno
                                Persona persona = new Persona(cvePersonaAlumno); //se construye el alumno
                                int cveDocumento=0;
                                if (nivelEstudio==1) { //documentos de nivel de TSU
                                    if (cveTipoArchivo==2) { //memoria de estadia
                                        cveDocumento=28;
                                    }else if(cveTipoArchivo==1){ //carta de conclusion
                                        cveDocumento=27;
                                    }
                                }else{ //documentos de nivel de ingenieria-licenciatura
                                    if (cveTipoArchivo==2) { //memoria de estadia
                                        cveDocumento=31;
                                    }else if (cveTipoArchivo==1){ //carta de conclusion
                                        cveDocumento=30;
                                    }
                                }
                                CarearFecha cf = new CarearFecha(); //se crea la fecha para guardar el cuando se grabo
                                String s = persona.personaDocumento(cveDocumento, true, cf.anhoHoy, false);
                                salida.write("208-validated");
                                break;
                            case 5:
                                estadia.enviaCorreoEstado(cvePersonaAlumno, cvePersona, "rechazado");
                                salida.write("207-rejected");
                                break;
                            case 6:
                                estadia.enviaCorreoEstado(cvePersonaAlumno, cvePersona, "rechazado");
                                salida.write("207-rejected");
                                break;
                            case 7:
                                estadia.enviaCorreoEstado(cvePersonaAlumno, cvePersona, "rechazado");
                                salida.write("207-rejected");
                                break;

                        }
                        break;           
                }
                salida.flush();
            }catch(ErrorGeneral e){ 
                Logger.getLogger(EstadiaSer.class.getName()).log(Level.SEVERE, null, e);
            }
        }
    }
}
