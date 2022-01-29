package mx.edu.utdelacosta.servlets;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import mx.edu.utdelacosta.Archivo;
import mx.edu.utdelacosta.Configuracion;
import mx.edu.utdelacosta.ErrorGeneral;
import mx.edu.utdelacosta.Estadia;
import mx.edu.utdelacosta.PasswordGenerator;
import mx.edu.utdelacosta.Usuario;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 *
 * @author rhekh
 */
@WebServlet(name = "SubirEstadia", urlPatterns = {"/subirEstadia"})
public class SubirEstadia extends HttpServlet {

    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        PrintWriter salida = response.getWriter();
        salida.write("203-err");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession sesion = request.getSession();
        PrintWriter salida = response.getWriter();
        Archivo arc = new Archivo();
        Estadia estadia = new Estadia();
        if (sesion.getAttribute("usuario") == null) {
            salida.write("error-401-El usuario no está logueado.");
        } else {

            Usuario usuario = (Usuario) sesion.getAttribute("usuario");
            try {
                FileItemFactory factory = new DiskFileItemFactory(); //creamos archivo file

                ServletFileUpload upload = new ServletFileUpload(factory); //creamos el servicio de subida
                
                boolean isMultipart = ServletFileUpload.isMultipartContent(request);
                if (isMultipart) {
                    
                    //definimos variables y parametros
                    
                    upload.setSizeMax(1024 * 5000);
                    List<FileItem> items = upload.parseRequest(request);
                    
                    int cvePersona = usuario.getCvePersona(); //cvePersona del alumno que la sube
                    
                    String proyecto=""; //nombre del proyecto que el alumno pone
                    int tipo_documento=0; //si es memoria o carta de conclusion
                    String accion="";
                    String nombre="";
                    
                    String fileName = ""; //nombre que recibe el archivo ya cambiado de nombre
                    
                    PasswordGenerator pg = new PasswordGenerator();
                    String pin = pg.getPinNumber() + "_" + cvePersona;
                    for (FileItem item : items) {
                        
                        /*Si es un archivo y no un elemento de formulario*/
                        
                        if (!item.isFormField()) {
                            
                            /*cual sera la ruta al archivo en el servidor*/
                            String ruta = Configuracion.URL_APP +"document/estadias/"+nombre+"-"+pin+".pdf";
                            File archivoServer = new File(ruta);
                            
                            /*y lo escribimos en el servido*/
                            item.write(archivoServer);
                            //String fileName = item.getName();
                            fileName = nombre+"-"+pin+".pdf";
                        } else {
                            String texto = item.getFieldName();
                            String value = item.getString();
                            if (texto.equals("proyecto")) {
                                proyecto = value;
                            }
                            if (texto.equals("accion")) {
                                accion = value;
                            }
                            if (item.getFieldName().equals("cveTipoArchivo")) {
                                tipo_documento = Integer.parseInt(item.getString());
                            }
                            if (item.getFieldName().equals("persona")) {
                                cvePersona = Integer.parseInt(item.getString());
                                nombre = estadia.getNombreCompleto(cvePersona);
                            }
                        }
                        
                        
                    }

                    switch (accion){
                        case "subir":
                            int cveAlumnoGrupo = estadia.getAlumnoGrupoPersona(cvePersona);
                            int existente = estadia.revisarExistente(cveAlumnoGrupo, tipo_documento);
                            if (existente>0) {
                                arc.eliminar("document/estadias/" + fileName);
                                salida.write("203-duplicated");
                            }else{
                            int cveArchivoNuevo = arc.nuevo(nombre, proyecto, fileName, cvePersona);
                            estadia.guardarEstadiaAlumno(cveAlumnoGrupo, cveArchivoNuevo, proyecto, tipo_documento);
                            int cveAsesor=estadia.GetAsesorAlumno(cveAlumnoGrupo);
                            int cveEnvioUltimo=estadia.GetUltimoArchivo(cveAlumnoGrupo, tipo_documento);
                            estadia.guardarEstadiaEstado(cveEnvioUltimo, cvePersona);
                            estadia.enviaCorreoAlumno(cveAsesor);
                            salida.write("201-save");
                            }
                            break;
                    }
                } else {
                    salida.write("202-nomp");
                }
            } catch (FileUploadException ex) {
                salida.write("Error al subir archivo: " + ex.getMessage());
            } catch (Exception ex) {
                Logger.getLogger(SubirEstadia.class.getName()).log(Level.SEVERE, null, ex);
                salida.write("Error: " + ex.getMessage());
            } catch (ErrorGeneral ex) {
                Logger.getLogger(SubirEstadia.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        salida.flush();
    }
}
