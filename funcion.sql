CREATE FUNCTION generafolioestadia
(
	@cveAlumnoGrupo INT
)
RETURNS VARCHAR(10)
AS
BEGIN

DECLARE @anio INTEGER, @consecutivo INTEGER, @num_cuatrimestre INTEGER;

	SET @num_cuatrimestre = (SELECT c.numero_cuatrimestre 
		 FROM alumno_grupo ag 
		 INNER JOIN grupo g ON g.cve_grupo=ag.cve_grupo 
		 INNER JOIN cuatrimestre c ON c.cve_cuatrimestre=g.cve_cuatrimestre 
		 WHERE ag.cve_alumno_grupo=@cveAlumnoGrupo);

	SET @anio = (SELECT CAST(YEAR(GETDATE()) as varchar(4)));

	SET @consecutivo = (SELECT COUNT(ec.cve_carta_estadia)+1 AS consecutivo 
		FROM estadia_carta ec 
		INNER JOIN estadia_alumno ea ON ec.cve_estadia_alumno=ea.cve_estadia_alumno
		INNER JOIN alumno_grupo ag ON ea.cve_alumno_grupo=ag.cve_alumno_grupo
		INNER JOIN grupo g ON g.cve_grupo=ag.cve_grupo 
		INNER JOIN cuatrimestre cu ON cu.cve_cuatrimestre=g.cve_cuatrimestre 
		WHERE cu.numero_cuatrimestre=@num_cuatrimestre);
	
	RETURN ('E'+'-'+CONVERT(VARCHAR(10), @anio)+'-'+CONVERT(VARCHAR(10),@consecutivo));	

END