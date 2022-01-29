package mx.edu.utdelacosta;

import java.io.Serializable;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Darel
 */
public class Persona implements Persistente, Serializable{

    private int cvePersona;
    private String nombre;
    private String apellidoPaterno;
    private String apellidoMaterno;
    private Date fechaNacimiento;
    private String curp;
    private String sexo;
    private String fechaNac;
    private TipoSexo tipoSexo;
    private UnidadAcademica unidadAcademica;
    private int cveEstadoCivil;
    private EstadoCivil estadoCivil;
    private TipoSangre tipoSangre;
    private Carrera carrera;
    private ArrayList<MedioComunicacion> mediosComunicacion;
    private DatosMedicos datosMedicos;
    private String rfc;
    private Asentamiento asentamientoNacio;

    private Datos siest = null;
    private String sql = "";

    public Persona() {
        this.siest = new Datos();
        tipoSexo = new TipoSexo();
    }

    public Persona(int cvePersona) throws ErrorGeneral {
        this.siest = new Datos();
        this.cvePersona = cvePersona;
        this.construir();
    }
    
    public Persona(int cvePersona, String nombrePersona){
        this.siest = new Datos();
        this.cvePersona = cvePersona;
        this.nombre = nombrePersona;
    }

    public Persona(String nombre, String apellidoPaterno, String apellidoMaterno, Date fechaNacimiento, String curp, String sexo) {
        this.siest = new Datos();
        this.nombre = nombre;
        this.apellidoPaterno = apellidoPaterno;
        this.apellidoMaterno = apellidoMaterno;
        this.fechaNacimiento = fechaNacimiento;
        this.curp = curp;
        this.sexo = sexo;
        this.mediosComunicacion = new ArrayList<MedioComunicacion>();
    }

    public Persona(String nombre, String apellidoPaterno, String apellidoMaterno, Date fechaNacimiento, String curp, String sexo, DatosMedicos datosMedicos) {
        this(nombre, apellidoPaterno, apellidoMaterno, fechaNacimiento, curp, sexo);
        this.siest = new Datos();
        this.datosMedicos = datosMedicos;
    }

    public void construir() {
        try {
            ArrayList<CustomHashMap> datosPersona = siest.ejecutarConsulta("SELECT p.cve_persona, p.nombre, "
                    + "p.apellido_paterno, p.apellido_materno, ISNULL(dp.fecha_nacimiento, '2020-06-11')AS fecha_nacimiento, ISNULL(dp.curp, 'AAAA000000')AS curp, ISNULL(ts.nombre, '') AS sexo, ISNULL(ts.cve_tipo_sexo, 1)AS cve_tipo_sexo, "
                    + "ISNULL(cve_estado_civil, 1)AS cve_estado_civil, ISNULL(df.RFC, 'AAAA000000AAA')AS rfc, ISNULL(dp.cve_asentamiento_nacio, 543)AS asentamiento_nacio "
                    + "FROM persona p "
                    + "LEFT JOIN dato_personal dp ON dp.cve_persona=p.cve_persona "
                    + "LEFT JOIN tipo_sexo ts ON ts.cve_tipo_sexo=dp.cve_tipo_sexo "
                    + "LEFT JOIN datos_fiscales_persona dfp ON dfp.cve_persona=p.cve_persona "
                    + "LEFT JOIN datos_fiscales df ON df.cve_datos_fiscales=dfp.cve_datos_fiscales "
                    + "WHERE p.cve_persona=" + cvePersona);
            if (!datosPersona.isEmpty()) {
                CustomHashMap persona = datosPersona.get(0);
                this.nombre = persona.getString("nombre");
                this.apellidoPaterno = persona.getString("apellido_paterno");
                this.apellidoMaterno = persona.getString("apellido_materno");
                this.curp = persona.getString("curp");
                this.cveEstadoCivil = persona.getInt("cve_estado_civil");
                this.estadoCivil = EstadoCivil.construir(persona.getInt("cve_estado_civil"));
                this.asentamientoNacio = new Asentamiento(persona.getInt("asentamiento_nacio"));
                this.fechaNac = persona.getString("fecha_nacimiento");
                this.tipoSexo = TipoSexo.construir(persona.getInt("cve_tipo_sexo"));
                this.rfc = persona.getString("rfc");
            } else {
                System.out.println("No se encontró a la persona con clave " + this.cvePersona);
            }
        } catch (ErrorGeneral ex) {
            Logger.getLogger(Persona.class.getName()).log(Level.SEVERE, null, ex);
            System.out.println("-- Error : " + ex.getMensaje());
            System.out.println("   El error se dió desde la clase " + Persona.class);
        } catch (Exception ex) {
            Logger.getLogger(Persona.class.getName()).log(Level.SEVERE, null, ex);
            System.out.println("-- Error : " + ex.getMessage());
            System.out.println("   El error se dió desde la clase " + Persona.class);
        }
    }

    public String getDomicilio() {
        String domicilio = "Conocido, Santiago Ixcuintla";
        try {
            ArrayList<CustomHashMap> datos = siest.ejecutarConsulta("SELECT ISNULL('C. '+d.calle, 'C. Conocida')AS calle,ISNULL('#'+d.numero, '#0')AS numero, "
                    + "d.colonia, ISNULL(a.nombre, 'Santiago Ixc')AS localidad "
                    + "FROM persona p "
                    + "LEFT JOIN domicilio_persona dp ON dp.cve_persona=p.cve_persona "
                    + "LEFT JOIN domicilio d ON d.cve_domicilio=dp.cve_domicilio "
                    + "LEFT JOIN asentamiento a ON a.cve_asentamiento=d.cve_asentamiento "
                    + "WHERE p.cve_persona  =" + this.cvePersona);
            if (!datos.isEmpty()) {
                CustomHashMap d = datos.get(0);
                domicilio = d.getString("calle") + ", " + d.getString("numero") + ", Loc. " + d.getString("localidad");
            }
        } catch (ErrorGeneral ex) {
            Logger.getLogger(Persona.class.getName()).log(Level.SEVERE, null, ex);
            domicilio = "Error";
        }
        return domicilio;
    }
    public String getAreaPertenece() throws ErrorGeneral{
        String area = "Sin área";
         ArrayList<CustomHashMap> data = siest.ejecutarConsulta("SELECT a.nombre AS area_pertenece "
                 + "FROM personal per "
                 + "INNER JOIN puesto pu ON pu.cve_puesto=per.cve_puesto "
                 + "INNER JOIN area_puesto ap ON ap.cve_puesto=pu.cve_puesto "
                 + "INNER JOIN area a ON a.cve_area=ap.cve_area "
                 + "WHERE per.cve_persona="+this.cvePersona);
         if(!data.isEmpty()){
             area = data.get(0).getString("area_pertenece");
         }
        return area;
    }
    public String getPuesto() throws ErrorGeneral{
        String puesto = "Sin asignar";
        ArrayList<CustomHashMap> data = siest.ejecutarConsulta("SELECT p.nombre AS puesto "
                + "FROM personal per "
                + "INNER JOIN puesto p ON p.cve_puesto=per.cve_puesto "
                + "WHERE per.activo=1 AND cve_persona="+this.cvePersona);
        if(!data.isEmpty()){
            puesto = data.get(0).getString("puesto");
        }
        return puesto;
    }
    public String getOficinaResponsable() throws ErrorGeneral{
        String oficina = "Sin oficina";
         ArrayList<CustomHashMap> data = siest.ejecutarConsulta("SELECT a.nombre "
                 + "FROM area_responsable ar "
                 + "INNER JOIN area a ON a.cve_area=ar.cve_area WHERE cve_persona="+this.cvePersona+" AND ar.activo=1");
         if(!data.isEmpty()){
             oficina = data.get(0).getString("nombre");
         }
        return oficina;
    }
    
    public String getNombreUsuario() throws ErrorGeneral{
        String user = "No tiene";
         ArrayList<CustomHashMap> data = siest.ejecutarConsulta("SELECT TOP (1) nombre_usuario "
                 + "FROM usuario "
                 + "WHERE activo=1 AND cve_persona="+this.cvePersona+" ");
         if(!data.isEmpty()){
             user = data.get(0).getString("nombre_usuario");
         }
        return user;
    }
    public String getNivelEstudioMasNombre() throws ErrorGeneral{
         ArrayList<CustomHashMap> data = siest.ejecutarConsulta("SELECT ISNULL(ne.abreviatura, 'Lic')AS nivel_estudio FROM persona p "
                 + "LEFT JOIN nivel_estudio ne ON ne.cve_nivel_estudio=p.cve_nivel_estudio "
                 + "WHERE p.cve_persona="+this.cvePersona);
         if(!data.isEmpty()){
             return data.get(0).getString("nivel_estudio")+" "+getNombre()+" "+getApellidoPaterno()+" "+getApellidoMaterno();
         }else{
             return "Lic. "+getNombre()+" "+getApellidoPaterno()+" "+getApellidoMaterno();
         }
    } 

    public ArrayList<CustomHashMap> getDatosDomicilio() throws ErrorGeneral {
        ArrayList<CustomHashMap> datosDomicilio = siest.ejecutarConsulta("SELECT p.cve_pais, e.cve_estado, m.cve_municipio, a.cve_asentamiento, "
                + "ISNULL(d.cve_domicilio, 0)AS cve_domicilio, ISNULL(d.calle, '')AS calle, ISNULL(d.numero, 0)AS numero, "
                + "ISNULL(d.colonia, '')AS colonia, ISNULL(d.comentarios, '')AS comentarios, ISNULL(d.referencias, '')AS referencias, "
                + "ISNULL(d.horario, '')AS horario "
                + "FROM domicilio d "
                + "LEFT JOIN domicilio_persona dp ON dp.cve_domicilio=d.cve_domicilio "
                + "LEFT JOIN asentamiento a ON a.cve_asentamiento = d.cve_asentamiento "
                + "LEFT JOIN municipio m ON m.cve_municipio=a.cve_municipio "
                + "LEFT JOIN estado e ON e.cve_estado=m.cve_estado "
                + "LEFT JOIN pais p ON p.cve_pais=e.cve_pais "
                + "WHERE dp.cve_persona=" + this.cvePersona + " AND d.cve_tipo_domicilio=2");
        return datosDomicilio;
    }

    public String getTelefono() throws ErrorGeneral {
        String tel = "000-000-0000";
        ArrayList<CustomHashMap> tels = siest.ejecutarConsulta("SELECT cve_persona_comunicacion, dato, comentarios "
                + "FROM persona_comunicacion "
                + "WHERE cve_comunicacion=1 AND cve_persona=" + this.cvePersona);
        if (!tels.isEmpty()) {
            tel = tels.get(0).getString("dato");
        }
        return tel;
    }

    public String getEmail() throws ErrorGeneral {
        String email = "";
        ArrayList<CustomHashMap> emails = siest.ejecutarConsulta("SELECT cve_persona_comunicacion, dato, comentarios "
                + "FROM persona_comunicacion "
                + "WHERE cve_comunicacion=4 AND cve_persona= " + this.cvePersona);
        if (!emails.isEmpty()) {
            email = emails.get(0).getString("dato");
        }
        return email;
    }

    /*Méthods*/
    public void nueva(String nombre, String apellidoPaterno, String apellidoMaterno, int cveCarrera, int cveNivelEstudio) {
        String apellidoPM = apellidoPaterno + " " + apellidoMaterno + " " + nombre;
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO persona(nombre, apellido_paterno, apellido_materno, cve_carrera, cve_nivel_estudio, indexar) "
                + "VALUES('" + nombre + "','" + apellidoPaterno + "', '" + apellidoMaterno + "'," + cveCarrera + ", " + cveNivelEstudio + ", '" + apellidoPM + " " + apellidoPM + "'); ");
        siest.finalizarTransaccion();
    }

    public void actualizarPersona(int cvePersona, String nombre, String apellidoPaterno, String apellidoMaterno, int cveCarrera, int cveNivelEstudio) {
        String apellidoPM = apellidoPaterno + " " + apellidoMaterno + " " + nombre;
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE persona SET nombre ='" + nombre + "', apellido_paterno='" + apellidoPaterno + "', apellido_materno='" + apellidoMaterno + "', "
                + "cve_carrera=" + cveCarrera + ", cve_nivel_estudio=" + cveNivelEstudio + ", indexar='" + apellidoPM + "' WHERE cve_persona=" + cvePersona);
        siest.finalizarTransaccion();
    }

    public void personaRfc(int cvePersona, String rfc) throws ErrorGeneral {
        ArrayList<CustomHashMap> person = siest.ejecutarConsulta("SELECT dfp.cve_datos_fiscales, df.RFC "
                + "FROM datos_fiscales_persona dfp "
                + "INNER JOIN datos_fiscales df ON df.cve_datos_fiscales=dfp.cve_datos_fiscales "
                + "WHERE dfp.cve_persona=" + cvePersona);

        if (person.isEmpty()) {
            //Insertamos
            sql = "INSERT INTO datos_fiscales(rfc, fecha_alta, activo) VALUES('" + rfc + "', GETDATE(), 'True'); "
                    + "DECLARE @cveDatosFiscales AS INTEGER; "
                    + "SET @cveDatosFiscales = (SELECT IDENT_CURRENT('datos_fiscales')); "
                     + "INSERT INTO datos_fiscales_persona(cve_datos_fiscales, cve_persona, fecha_alta, activo) "
                    + "VALUES(@cveDatosFiscales , " + cvePersona + ", GETDATE(), 'True'); ";
        } else {
            //Actualizamos
            int cveDatoFiscal = person.get(0).getInt("cve_datos_fiscales");
            sql = "UPDATE datos_fiscales SET RFC='" + rfc + "' WHERE cve_datos_fiscales=" + cveDatoFiscal;
        }
        siest.iniciarTransaccion();
        siest.serializarSentencia(sql);
        siest.finalizarTransaccion();
    }

    public void personaDomicilio(int cvePersona, int cveLocalidad, String calle, String numero, String colonia, String comentarios, String referencia, String horario) throws ErrorGeneral {
        ArrayList<CustomHashMap> person = siest.ejecutarConsulta("SELECT dp.cve_domicilio, d.* "
                + "FROM domicilio_persona dp "
                + "INNER JOIN domicilio d ON d.cve_domicilio=dp.cve_domicilio "
                + "WHERE dp.cve_persona=" + cvePersona + " AND d.cve_tipo_domicilio=2");

        //Insertamos
        if (person.isEmpty()) {
            sql = "INSERT INTO domicilio(cve_asentamiento, cve_tipo_domicilio, calle, numero, colonia, comentarios, referencias, horario, activo) "
                    + "VALUES(" + cveLocalidad + ", 2, '" + calle + "', '" + numero + "', '" + colonia + "', '" + comentarios + "', "
                    + "'" + referencia + "', '" + horario + "', 'True'); "
                    + "DECLARE @cveDomicilio AS INTEGER; SET @cveDomicilio = (SELECT IDENT_CURRENT('domicilio')); "
                    + "INSERT INTO domicilio_persona(cve_domicilio, cve_persona, fecha_alta, activo) "
                    + "VALUES(@cveDomicilio, " + cvePersona + ", GETDATE(), 'True'); ";
        } else {
            //actualizamos
            int cveDomicilio = person.get(0).getInt("cve_domicilio");
            sql = "UPDATE domicilio SET cve_asentamiento= " + cveLocalidad + ", calle='" + calle + "', numero='" + numero + "', colonia='" + colonia + "', "
                    + "comentarios = '" + comentarios + "', referencias='" + referencia + "', horario='" + horario + "' "
                    + "WHERE cve_domicilio=" + cveDomicilio;
        }
        siest.iniciarTransaccion();
        siest.serializarSentencia(sql);
        siest.finalizarTransaccion();

    }

    public void personaTelefono(int cvePersona, String telefono) throws ErrorGeneral {
        ArrayList<CustomHashMap> person = siest.ejecutarConsulta("SELECT cve_persona_comunicacion, dato "
                + "FROM persona_comunicacion "
                + "WHERE cve_persona=" + cvePersona + " AND cve_comunicacion=1");
        if (person.isEmpty()) {
            sql = "INSERT INTO persona_comunicacion(cve_persona, cve_comunicacion, dato, comentarios, activo) "
                    + "VALUES(" + cvePersona + ", 1, '" + telefono + "', 'Teléfono de la persona', 'True'); ";
        } else {
            int cvePersonaComunicacion = person.get(0).getInt("cve_persona_comunicacion");
            sql = "UPDATE persona_comunicacion SET dato='" + telefono + "' "
                    + "WHERE cve_persona_comunicacion=" + cvePersonaComunicacion + " AND cve_persona= " + cvePersona;
        }
        siest.iniciarTransaccion();
        siest.serializarSentencia(sql);
        siest.finalizarTransaccion();
    }

    public void personaEmail(int cvePersona, String email) throws ErrorGeneral {
        ArrayList<CustomHashMap> person = siest.ejecutarConsulta("SELECT cve_persona_comunicacion, dato "
                + "FROM persona_comunicacion "
                + "WHERE cve_persona=" + cvePersona + " AND cve_comunicacion=4");
        if (person.isEmpty()) {
            sql = "INSERT INTO persona_comunicacion(cve_persona, cve_comunicacion, dato, comentarios, activo) "
                    + "VALUES(" + cvePersona + ", 4, '" + email + "', 'Email de la empresa', 'True'); \n";
        } else {
            int cvePersonaComunicacion = person.get(0).getInt("cve_persona_comunicacion");
            sql = "UPDATE persona_comunicacion SET dato='" + email + "' "
                    + "WHERE cve_persona_comunicacion=" + cvePersonaComunicacion + " AND cve_persona= " + cvePersona;
        }

        siest.iniciarTransaccion();
        siest.serializarSentencia(sql);
        siest.finalizarTransaccion();
    }
    public String personaDocumento(int cveDocumento, boolean estadoDocumento, int anio, boolean legalizado) {
        String salida = "ok-update";
        try {
            ArrayList<CustomHashMap> cConvenio = siest.ejecutarConsulta("SELECT * "
                    + "FROM documento_persona "
                    + "WHERE cve_persona=" + this.cvePersona + " AND cve_documento =" + cveDocumento);

            if (!cConvenio.isEmpty()) {
                siest.iniciarTransaccion();
                siest.serializarSentencia("UPDATE documento_persona SET activo='" + estadoDocumento + "', "
                        + "anio_expedicion= " + anio + ", legalizado='" + legalizado + "' "
                        + "WHERE cve_documento=" + cveDocumento + " AND cve_persona=" + this.cvePersona);
                siest.finalizarTransaccion();
                
                if(cveDocumento==28 || cveDocumento==27 || cveDocumento==31 || cveDocumento==30){
                    if (estadoDocumento==false) {
                        Estadia estadia = new Estadia();
                        estadia.bajaEstadoDocumento(this.cvePersona, cveDocumento);
                        salida = "ok-save";
                    }
                }
            } else {
                siest.iniciarTransaccion();
                siest.serializarSentencia("INSERT INTO documento_persona(cve_persona, cve_documento, prestado, activo, anio_expedicion, legalizado) "
                        + "VALUES(" + this.cvePersona + "," + cveDocumento + ",0, 1, " + anio + ", '" + legalizado + "')");
                siest.finalizarTransaccion();
                salida = "ok-save";
            }
        } catch (ErrorGeneral ex) {
            Logger.getLogger(Alumno.class.getName()).log(Level.SEVERE, null, ex);
            salida = "fail-error-" + ex.getMessage();
        }
        return salida;
    }
    
    public void guardarDatoPersonal(int cvePersona, int cveTipoSexo, String fechaNacimiento, String curp, int cveConstitucionFamiliar, int cveConstitucionFisica, int cveTipoReligion, int cveEstadoCivil, int cveAsentamientoNacio){
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO dato_personal(cve_persona, cve_tipo_sexo, fecha_nacimiento, curp, cve_constitucion_familiar, cve_constitucion_fisica, cve_tipo_religion, "
                + "cve_estado_civil, cve_asentamiento_nacio) VALUES("+cvePersona+", "+cveTipoSexo+", '"+fechaNacimiento+"', '"+curp+"',"+
                cveConstitucionFamiliar+", "+cveConstitucionFisica+", "+cveTipoReligion+", "+cveEstadoCivil+", "+cveAsentamientoNacio+");");
        siest.finalizarTransaccion();
    }

    /*
     * Mutators ----------------------------------------------------------------
     */
    public void setFechaNac(String fechaNac) {
        this.fechaNac = fechaNac;
    }

    public void setApellidoMaterno(String apellidoMaterno) {
        this.apellidoMaterno = apellidoMaterno;
    }

    public void setApellidoPaterno(String apellidoPaterno) {
        this.apellidoPaterno = apellidoPaterno;
    }

    public void setCarrera(Carrera carrera) {
        this.carrera = carrera;
    }

    public void setCurp(String curp) {
        this.curp = curp;
    }

    public void setCvePersona(int cvePersona) {
        this.cvePersona = cvePersona;
    }

    public EstadoCivil getEstadoCivil() {
        return estadoCivil;
    }
    
    public void setFechaNacimiento(Date fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public void setSexo(String sexo) {
        this.sexo = sexo;
    }

    public void setTipoSangre(TipoSangre tipoSangre) {
        this.tipoSangre = tipoSangre;
    }

    public void setUnidadAcademica(UnidadAcademica unidadAcademica) {
        this.unidadAcademica = unidadAcademica;
    }

    public void setDatosMedicos(DatosMedicos datosMedicos) {
        this.datosMedicos = datosMedicos;
    }

    public void addMedioComunicacion(MedioComunicacion medioComunicacion) {
        this.mediosComunicacion.add(medioComunicacion);
    }

    /*
     * Accesors ----------------------------------------------------------------
     */
    public String getApellidoMaterno() {
        return apellidoMaterno;
    }

    public String getFechaNac() {
        return fechaNac;
    }

    public TipoSangre getTipoSangre() {
        return tipoSangre;
    }

    public String getApellidoPaterno() {
        return apellidoPaterno;
    }

    public String getCarrera() {
        return carrera.getNombre();
    }

    public String getCurp() {
        return curp;
    }

    public int getCvePersona() {
        return cvePersona;
    }

    public Double getEstatura() {
        return datosMedicos.getEstatura();
    }

    public Date getFechaNacimiento() {
        return fechaNacimiento;
    }

    public String getNombre() {
        return nombre;
    }

    public Double getPeso() {
        return datosMedicos.getPeso();
    }

    public String getSexo() {
        return sexo;
    }

    public String getUnidadAcademica() {
        return unidadAcademica.getNombre();
    }

    public String getNombreCompleto() {
        return getApellidoPaterno() + " " + getApellidoMaterno() + " " + getNombre();
    }

    public TipoSexo getTipoSexo() {
        return tipoSexo;
    }

    public void setTipoSexo(TipoSexo tipoSexo) {
        this.tipoSexo = tipoSexo;
    }

    public ArrayList<MedioComunicacion> getMediosComunicacion() {
        return mediosComunicacion;
    }

    public void setMediosComunicacion(ArrayList<MedioComunicacion> mediosComunicacion) {
        this.mediosComunicacion = mediosComunicacion;
    }

    public int getCveEstadoCivil() {
        return cveEstadoCivil;
    }

    public void setCveEstadoCivil(int cveEstadoCivil) {
        this.cveEstadoCivil = cveEstadoCivil;
    }

    public String getRfc() {
        return rfc;
    }

    public Asentamiento getAsentamientoNacio() {
        return asentamientoNacio;
    }    

    public void setRfc(String rfc) {
        this.rfc = rfc;
    }

    public void getPagos() {

    }

    @Override
    public String toString() {
        return "La Persona: " + getNombreCompleto();
    }

    public ArrayList<Concepto> getAdeudos() throws ErrorGeneral {
        return new ArrayList<>();
    }

    /*
     * Métodos de la interfaz Persistente --------------------------------------
     */
    public String getSQLInserts() throws ErrorGeneral {
        String sentencia = "";
        /* Verificamos que el alumno no exista en la BD */
        if (!existe()) {
            sentencia = "INSERT INTO persona("
                    + "cve_carrera, cve_unidad_academica, cve_estado_civil, cve_tipo_sangre, "
                    + " nombre, apellido_paterno, apellido_materno, fecha_nacimiento, "
                    + " curp, sexo, peso, estatura)"
                    + " VALUES("
                    + carrera.getCveCarrera() + ", "
                    + unidadAcademica.getCveUnidadAcademica() + ", 1, "
                    + tipoSangre.getCveTipoSangre() + ", "
                    + "'" + getNombre() + "', "
                    + "'" + getApellidoPaterno() + "', "
                    + "'" + getApellidoMaterno() + "', "
                    + "'" + getFechaNacimiento() + "', "
                    + "'" + getCurp() + "', "
                    + "'" + getSexo() + "', "
                    + getPeso() + ", "
                    + getEstatura() + ");";
            sentencia += "DECLARE @cvePersona AS INTEGER; "
                    + " SET @cvePersona = (SELECT TOP(1) cve_persona "
                    + " FROM persona WHERE nombre = '" + getNombre() + "' "
                    + " AND apellido_paterno = '" + getApellidoPaterno() + "'"
                    + " AND apellido_materno = '" + getApellidoMaterno() + "');";

            for (MedioComunicacion mC : mediosComunicacion) {
                sentencia += " INSERT INTO persona_comunicacion("
                        + "cve_comunicacion, cve_persona, dato,"
                        + "comentarios)"
                        + " VALUES("
                        + +mC.getCveMedioComunicacion() + ", "
                        + getCvePersona() + ", "
                        + "'" + mC.getDato() + "',"
                        + " '" + mC.getComentarios() + "'); ";
            }
        } else {
            throw new ErrorGeneral(0, this.toString());
        }
        /*  */
        return sentencia;
    }

    public boolean existe() throws ErrorGeneral {
        boolean existe = false;
        try {
            existe = siest.devuelveRegistros("SELECT cve_persona "
                    + " FROM persona WHERE "
                    + " nombre = '" + getNombre() + "'"
                    + " AND apellido_paterno = '" + getApellidoPaterno() + "'"
                    + " AND apellido_materno = '" + getApellidoMaterno() + "'");
        } catch (SQLException e) {
            throw new ErrorGeneral(1, this.toString());
        }
        return existe;
    }

}