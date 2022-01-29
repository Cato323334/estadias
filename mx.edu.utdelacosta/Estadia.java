/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package mx.edu.utdelacosta;

import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author rhekh
 */
public class Estadia {
    
    private int cveTipoArchivo;
    private int cveEstadoEstadia;
    private int cveEstadiaArchivo;
    private int cveArchivo;
    private String nombreProyecto;
    private String fechaAlta;
    private String descripcion;
    private String cveAlumno;
    private String comentarios;
    private String estado;
    
    Datos siest = null;

    public Estadia() {
        siest = new Datos();
    }
    
    private Estadia(int cveEstadiaArchivo) {
        this.cveEstadiaArchivo = cveEstadiaArchivo;
    }

    public static Estadia construir(int cveAlumno) {
        Estadia e = new Estadia(cveAlumno);
        e.construir();
        return e;
    }
    private void construir() {
        try {
            ArrayList<CustomHashMap> datos = siest.ejecutarConsulta("SELECT ea.cve_archivo as clave, ea.nombre_proyecto as proyecto,"
                    + " ta.descripcion as documento, CONVERT(VARCHAR, ee.fecha_alta, 103) as fecha,"
                    + " ISNULL(ee.comentario, 'sin comentarios') as comentarios, e.descripcion as estado"
                    + " FROM estadia_archivo ea"
                    + " LEFT JOIN estadia_estado ee on ee.cve_estadia_archivo=ea.cve_estadia_archivo"
                    + " INNER JOIN alumno_grupo as ag on ag.cve_alumno_grupo=ea.cve_alumno_grupo"
                    + " INNER JOIN tipo_archivo as ta on ta.cve_tipo_archivo=ea.tipo_archivo"
                    + " INNER JOIN estado_estadia e on e.cve_estado_estadia=ee.cve_estado_estadia"
                    + " WHERE ag.cve_alumno="+cveAlumno);

            if (!datos.isEmpty()) {
                CustomHashMap d = datos.get(0);
                this.cveArchivo = d.getInt("clave");
                this.nombreProyecto = d.getString("proyecto");
                this.descripcion = d.getString("documento");
                this.comentarios = d.getString("comentarios");
                this.estado = d.getString("estado");
                this.fechaAlta = d.getString("fecha");
            }

        } catch (ErrorGeneral ex) {
            Logger.getLogger(Convenio.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public int getCveTipoArchivo() {
        return cveTipoArchivo;
    }

    public int getCveEstadoEstadia() {
        return cveEstadoEstadia;
    }

    public int getCveEstadiaArchivo() {
        return cveEstadiaArchivo;
    }

    public String getNombreProyecto() {
        return nombreProyecto;
    }

    public String getDescripcion() {
        return descripcion;
    }
    
     public String getComentarios() {
        return comentarios;
    }
    
    public int getCveArchivo() {
        return cveArchivo;
    }
    
    public String getFechaAlta() {
        return fechaAlta;
    }

    public void setFechaAlta(String FechaAlta) {
        this.fechaAlta = FechaAlta;
    }
    
    public String getestado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
    
     public void guardarEstadiaAlumno(int cveAlumnoGrupo, int archivo, String proyecto, int archivo_subido) throws ErrorGeneral {
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO estadia_archivo(cve_alumno_grupo, cve_archivo, tipo_archivo, nombre_proyecto) "
         + "VALUES("+cveAlumnoGrupo+","+archivo+","+archivo_subido+",'"+proyecto+"');");
        siest.finalizarTransaccion();
    }
    
    public void guardarEstadiaEstado(int cveEnvioUltimo, int cvePersona) throws ErrorGeneral {
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO estadia_estado(cve_estado_estadia,cve_estadia_archivo,cve_persona,fecha_alta,activo)"
         + "VALUES(1,"+cveEnvioUltimo+","+cvePersona+",GETDATE(),1);");
        siest.finalizarTransaccion();
    }
    
    public void validaEstadiaEstado(int cveEstadia, int cvePersona,int status, String comentario, int cveEstadiaEstado) throws ErrorGeneral {
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO estadia_estado(cve_estado_estadia,cve_estadia_archivo,cve_persona, comentario,fecha_alta,activo)"
         + "VALUES("+status+","+cveEstadia+","+cvePersona+",'"+comentario+"',GETDATE(),1)");
        siest.finalizarTransaccion();
        bajaEstadiaEstado(cveEstadiaEstado);
        System.out.println("fin");
    }
    
    public void bajaEstadiaEstado(int cveEstadiaEstado) throws ErrorGeneral {
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE estadia_estado SET activo=0 WHERE cve_estadia_estado="+cveEstadiaEstado);
        siest.finalizarTransaccion();
    }
    
    public int GetAsesorAlumno(int alumnoGrupo) throws ErrorGeneral {
        ArrayList<CustomHashMap> asesor = siest.ejecutarConsulta("SELECT TOP (1) cve_asesor as clave "
                + "FROM estadia_alumno "
                + "WHERE cve_alumno_grupo="+alumnoGrupo+" and activo=1 "
                + "ORDER BY cve_alumno_grupo DESC");
        int cve_asesor=asesor.get(0).getInt("clave");
        return cve_asesor;
    }
    
    public int GetUltimoArchivo(int alumnoGrupo, int tipoArchivo) throws ErrorGeneral {
        ArrayList<CustomHashMap> ultima_archivo = siest.ejecutarConsulta("SELECT TOP (1) cve_estadia_archivo as clave "
                + "FROM estadia_archivo "
                + "WHERE cve_alumno_grupo="+alumnoGrupo+" and tipo_archivo="+tipoArchivo+" "
                + "ORDER BY cve_estadia_archivo DESC");
        int uArchivo=ultima_archivo.get(0).getInt("clave");
        return uArchivo;
    }
    
    public String getNombreCompleto(int cvePersona) throws ErrorGeneral {
        ArrayList<CustomHashMap> nombre_c = siest.ejecutarConsulta("SELECT TOP (1)(p.apellido_paterno+''+p.apellido_materno+''+p.nombre) as nombre "
                + "FROM alumno a "
                + "INNER JOIN alumno_grupo ag on a.cve_alumno=ag.cve_alumno "
                + "INNER JOIN persona p on a.cve_persona=p.cve_persona "
                + "WHERE P.cve_persona="+cvePersona+" "
                + "ORDER BY nombre ASC");
        String nombre=nombre_c.get(0).getString("nombre");
        return nombre;
    }
    
    public String getNombreComplete(int cvePersona) throws ErrorGeneral {
        ArrayList<CustomHashMap> nombre_c = siest.ejecutarConsulta("SELECT (nombre+' '+apellido_paterno+' '+apellido_materno) as nombre "
                + "FROM persona "
                + "WHERE cve_persona="+cvePersona);
        String nombre=nombre_c.get(0).getString("nombre");
        return nombre;
    }
    
    public int getAlumnoGrupoPersona(int persona) throws ErrorGeneral {
        ArrayList<CustomHashMap> clavealumnogrupo = siest.ejecutarConsulta("SELECT TOP (1) cve_alumno_grupo as clave "
                + "FROM alumno_grupo ag "
                + "INNER JOIN alumno a on ag.cve_alumno=a.cve_alumno "
                + "WHERE cve_persona="+persona+" "
                + "ORDER BY cve_alumno_grupo DESC");
        int cve_alumno_grupo=clavealumnogrupo.get(0).getInt("clave");
        return cve_alumno_grupo;
    }
    
    public int getAlumnoGrupoAlumno(int cveAlumno) throws ErrorGeneral {
        ArrayList<CustomHashMap> cveag = siest.ejecutarConsulta("SELECT TOP (1) cve_alumno_grupo as clave "
                + "FROM alumno_grupo "
                + "WHERE cve_alumno="+cveAlumno+" "
                + "ORDER BY cve_alumno_grupo DESC");
        int cve_alumno_grupo=cveag.get(0).getInt("clave");
        return cve_alumno_grupo;
    }
    
    public int getCveAlumno(int cveAlumnoGrupo) throws ErrorGeneral {
        ArrayList<CustomHashMap> cvAlumno = siest.ejecutarConsulta("SELECT TOP (1) ISNULL(a.cve_persona,0) as clave "
                + "FROM persona p "
                + "INNER JOIN alumno a on p.cve_persona=a.cve_persona "
                + "INNER JOIN alumno_grupo as ag on a.cve_alumno=ag.cve_alumno "
                + "WHERE cve_alumno_grupo="+cveAlumnoGrupo+" "
                + "ORDER BY a.cve_alumno DESC");
        int c_alumno=cvAlumno.get(0).getInt("clave");
        return c_alumno;
    }
    
    public int revisarExistente(int alumnoGrupo, int tipoArchivo) throws ErrorGeneral {
        ArrayList<CustomHashMap> existente = siest.ejecutarConsulta("select count(ea.cve_estadia_archivo) as contar "
                    +"FROM estadia_estado ea "
                    +"INNER JOIN estadia_archivo ee on ea.cve_estadia_archivo=ee.cve_estadia_archivo "
                    +"WHERE cve_alumno_grupo="+alumnoGrupo+" and cve_estado_estadia NOT BETWEEN 5 AND 7 and activo=1 and tipo_archivo="+tipoArchivo);
        int existe = existente.get(0).getInt("contar");
        return existe;
    }
    
    public void bajaEstadia(int cveEstadiaEstado) throws ErrorGeneral {
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE estadia_estado SET cve_estado_estadia=6 WHERE cve_estadia_estado="+cveEstadiaEstado);
        siest.finalizarTransaccion();
    }
        //Revisar si no fucniona el cast con un convert
    public int status(int cveStatus) throws ErrorGeneral {
         ArrayList<CustomHashMap> status = siest.ejecutarConsulta("select cve_estado_estadia as contar " //esta parte puede quedar asi
                    +"FROM estadia_estado "
                    +"WHERE cve_estadia_estado="+cveStatus);
        int number = status.get(0).getInt("contar");
        return number;
    }
    
    public void altaAsesorAlumno(int cveAsesor, int cveAlumno) throws ErrorGeneral{
        int cveAlumnoGrupo = getAlumnoGrupoAlumno(cveAlumno);
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO estadia_alumno(cve_persona, cve_alumno_grupo, fecha_registros, activo) "
                                 +"VALUES ("+cveAsesor+","+cveAlumnoGrupo+",GETDATE(),1);");
        siest.finalizarTransaccion();
    }
    
    public int existeAsesorAlumno(int cveAsesor, int cveAlumno) throws ErrorGeneral{
        int cveAlumnoGrupo = getAlumnoGrupoAlumno(cveAlumno);
        ArrayList<CustomHashMap> existe = siest.ejecutarConsulta("SELECT count(cve_estadia_alumno) as contar "
                + "FROM estadia_alumno "
                + "WHERE cve_alumno_grupo="+cveAlumnoGrupo+" and activo=1");
        int number = existe.get(0).getInt("contar");
        return number;
    }
    
    public int existeEstadiaAlumno(int cveAlumno) throws ErrorGeneral{
        ArrayList<CustomHashMap> existe = siest.ejecutarConsulta("SELECT count(cve_estadia_alumno) as contar "
                + "FROM estadia_alumno "
                + "WHERE cve_alumno_grupo="+cveAlumno+" and activo=1");
        int number = existe.get(0).getInt("contar");
        return number;
    }
    
    //Registro de Estadia - registrar/actualizar asesor y coordinador
    public int existeEstadiaCoordinadorAsesor(int cveAlumno, String campo) throws ErrorGeneral{
        ArrayList<CustomHashMap> existe = siest.ejecutarConsulta("SELECT count("+campo+")  as contar "
                + "FROM estadia_alumno "
                + "WHERE cve_alumno_grupo="+cveAlumno+" and activo=1");
        int number = existe.get(0).getInt("contar");
        return number;
    }
    
    public void actualizaCoordinadorAsesor(int cveCoordinador , int cveAlumno , String campo) throws ErrorGeneral{
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE estadia_alumno SET "+campo+"="+cveCoordinador+" WHERE cve_alumno_grupo="+cveAlumno+" and activo=1");
        siest.finalizarTransaccion();
    }
    
    public void altaAsesorCoordinador(int cveAsesor, int cveAlumno, String campo) throws ErrorGeneral{
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO estadia_alumno("+campo+", cve_alumno_grupo, fecha_registros, activo) "
                                 +"VALUES ("+cveAsesor+","+cveAlumno+",GETDATE(),1);");
        siest.finalizarTransaccion();
    }
    
    //Terminan Registro de Estadia
    
    public void ActualizarTutorAlumno(int cveAlumno, int cveAsesor) throws ErrorGeneral{
        int cveAlumnoGrupo = getAlumnoGrupoAlumno(cveAlumno);
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE estadia_alumno SET cve_persona="+cveAsesor+" WHERE cve_alumno_grupo="+cveAlumnoGrupo+" and activo=1");
        siest.finalizarTransaccion();
    }
    

    
    public void actualizaAvance(int cveAlumno, int eleccion) throws ErrorGeneral{
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE estadia_alumno SET numero_avance="+eleccion+" WHERE cve_alumno_grupo="+cveAlumno+" and activo=1");
        siest.finalizarTransaccion();
    }
    
    public void ActualizaDescripcion(int cveEstadiaArchivo, String info_proyecto) throws ErrorGeneral{
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE estadia_archivo SET nombre_proyecto='"+info_proyecto+"' WHERE cve_estadia_archivo="+cveEstadiaArchivo);
        siest.finalizarTransaccion();
    } 
    
    // ENVIO DE CORREOS 
    public void enviaCorreoAlumno(int cvePersona) throws ErrorGeneral{
            Persona persona = new Persona(cvePersona);
            String co = persona.getEmail();
            String contenido = "<p><strong>Tienes un archivo de estadía pendiente de revisión</strong><br> "
                    + "Para más información accede al Siest, apartado de estadía.</p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", co, "Revisión de documento de estadía pendiente", "Revision de Estadia Pendiente", contenido);
         //   ec.enviar();
    }
    
    public void enviaCorreoEstado(int cveAlumno, int cvePersona, String status) throws ErrorGeneral{
            Persona persona = new Persona(cveAlumno);
            String co = persona.getEmail();
            String nombrePersona = getNombreComplete(cvePersona);
            String contenido = "<p><strong>Tu documento de estadía ha sido "+status+" por "+nombrePersona+"</strong><br>"
                    + "para más información accede al Siest, apartado de estadía.</p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", "rhekhienth.reality@gmail.com", "Documento de Estadia Rechazado", co, contenido);
            //ec.enviar();
    }
    
    public void enviaCorreoEscolares() throws ErrorGeneral{
            String contenido = "<p><strong>Tienes un archivo de estadía pendiente de revisión</strong><br>"
                    + "para más información accede al Siest, apartado de estadía.</p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", "rhekhienth.reality@gmail.com", "Revisión de documento de estadía pendiente", "titulacion@utdelacosta.edu.mx", contenido);
            //ec.enviar();
    }
    
    public void correoAvanceEstadia(int cveAlumno, int cvePersona, String avance, String resultado) throws ErrorGeneral{
            Persona persona = new Persona(cveAlumno);
            String co = persona.getEmail();
            String nombrePersona = getNombreComplete(cvePersona);
            String contenido = "<p><strong>Tu "+avance+" avance de estadía ha sido "+resultado+" por "+nombrePersona+"</strong><br>"
                    + "para más información accede al Siest, apartado de estadías.</p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", "rhekhienth.reality@gmail.com", "Revisión de documento de estadía pendiente", co, contenido);
            //ec.enviar();
    }
    
    //TERMINA CORREOS
    
    public int getCveDirector(int cveDivision) throws ErrorGeneral{
            ArrayList<CustomHashMap> consulta = siest.ejecutarConsulta("SELECT TOP (1)cve_director as clave "
                    + "FROM director_division "
                    + "WHERE cve_turno=1 and activo=1 and cve_division="+cveDivision+" "
                    + "ORDER BY cve_director_division asc");
            int claveDire = consulta.get(0).getInt("clave");
            return claveDire;
    }
    
    public int getCveArea(int cveAlumnoGrupo) throws ErrorGeneral{
            ArrayList<CustomHashMap> consulta = siest.ejecutarConsulta("SELECT d.cve_division as clave "
                    + "FROM division d "
                    + "INNER JOIN carrera c on d.cve_division=c.cve_division "
                    + "INNER JOIN grupo g on c.cve_carrera=g.cve_carrera "
                    + "INNER JOIN alumno_grupo ag on g.cve_grupo=ag.cve_grupo "
                    + "WHERE ag.cve_alumno_grupo="+cveAlumnoGrupo+" and ag.activo=1" );
            int claveDivision = consulta.get(0).getInt("clave");
            int clave=getCveDirector(claveDivision);
            return clave;
    }
    
    public int getNivelEstudio(int cveAlumnoGrupo) throws ErrorGeneral{
            ArrayList<CustomHashMap> consulta = siest.ejecutarConsulta("SELECT c.cve_nivel_estudio "
                    + "FROM alumno_grupo ag "
                    + "INNER JOIN grupo g on ag.cve_grupo=g.cve_grupo "
                    + "INNER JOIN cuatrimestre c on g.cve_cuatrimestre=c.cve_cuatrimestre "
                    + "WHERE cve_alumno_grupo="+cveAlumnoGrupo);
            int claveNivelEstudio = consulta.get(0).getInt("clave");
            return claveNivelEstudio;
    }
    
    
    //metodos para la baja del alumno
    public void bajaEstadoDocumento(int cvePersona, int cveDocumento) throws ErrorGeneral{    
        switch (cveDocumento){ //obtenemos el tipo de documento a modificar
                case 27: cveDocumento=1; break;
                case 28: cveDocumento=2; break;
                case 30: cveDocumento=1; break;
                case 31: cveDocumento=2; break; 
            }
        int agp = getAlumnoGrupoPersona(cvePersona); //se obtiene el alumno grupo del cvePersona recibido
        int eea = existeEstadiaAlumno(agp); //utilizamos el metodo existente para saber si existe un registro de estadia
        if (eea==1) { //en caso de existir, revisamos si hay documento
            ArrayList<CustomHashMap> existeDocumento = siest.ejecutarConsulta("SELECT DISTINCT(ee.cve_estadia_estado) as clave_estado "
                + "FROM documento_persona dp "
                + "INNER JOIN persona p on dp.cve_persona=p.cve_persona "
                + "INNER JOIN alumno a on p.cve_persona=a.cve_persona "
                + "INNER JOIN alumno_grupo ag on a.cve_alumno=ag.cve_alumno "
                + "INNER JOIN estadia_archivo ea on ag.cve_alumno_grupo=ea.cve_alumno_grupo "
                + "INNER JOIN estadia_estado ee on ea.cve_estadia_archivo=ee.cve_estadia_archivo "
                + "WHERE ea.cve_alumno_grupo="+agp+" and ee.activo=1 and cve_estado_estadia=4 and ea.tipo_archivo="+cveDocumento);     
        int existe = existeDocumento.get(0).getInt("clave_estado");
            if(!existeDocumento.isEmpty()){ //en caso de existir el documento lo damos de baja por servicios escolares
                int cveEstadiaA = GetUltimoArchivo(agp, cveDocumento);  
                validaEstadiaEstado(cveEstadiaA, cvePersona, 7 , "Sin Comentarios",existe);
            }
        }
        
        //en caso de no existir registro de estadia, como lo es con los registros antiguos no se realiza nada y se deja pasar
    }
}
