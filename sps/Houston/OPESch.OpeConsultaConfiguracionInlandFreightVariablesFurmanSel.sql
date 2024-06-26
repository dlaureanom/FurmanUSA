USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeConsultaConfiguracionInlandFreightVariablesFurmanSel]    Script Date: 4/4/2024 1:08:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [OPESch].[OpeConsultaConfiguracionInlandFreightVariablesFurmanSel]
	@pnClaUbicacion	  INT = 65
	
AS
BEGIN
	SET NOCOUNT ON
       
	SELECT 
		Anio AS 'Year'
		,DINLFTWU_MX
		,DWAREHU_MX
		,DINLFTPU_MXN
		,DBROKU_MX
		,USBROKU
		,INLFPWCU_L
		,USWAREHU_L
	FROM [OPESch].[OPECfgFurmanInlandFreightRates] WITH(NOLOCK)
	ORDER BY Anio DESC 


   	SET NOCOUNT OFF
END