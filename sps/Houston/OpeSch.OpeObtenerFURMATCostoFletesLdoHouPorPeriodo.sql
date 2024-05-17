CREATE PROCEDURE [OPESch].[OpeObtenerFURMATCostoFletesLdoHouPorPeriodo]	 
	@pnAnioMesInicio INT
	,@pnAnioMesFin	 INT
AS
BEGIN
	SET NOCOUNT ON
				AND (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND  (YEAR(E.FechaEntsal) * 100 + MONTH(E.FechaEntsal)) <= @pnAnioMesFin))	