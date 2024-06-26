-- =============================================
-- Author:		David Sanchez
-- Create date: 05-12-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeConfiguracionVariablesFurmanSel]
	@pnClaUbicacion	  INT = 65
	
AS
BEGIN
	SET NOCOUNT ON
       
     SELECT 
		[Year] = V.Anio			
		,IndirectSalesRatio = V.PorcGastoVentaIndirecta
		,COMM1 = V.ComisionAgenteVenta
		,COMM2 = V.ComisionManagerVenta
		,COMM3 = V.ComisionVPVenta
		,COMM4 = V.ComisionAgIndVenta
	 FROm [OPESch].[OPECfgFurmanVariables] V WITH(NOLOCK)
	 ORDER BY V.Anio DESC


   	SET NOCOUNT OFF
END

