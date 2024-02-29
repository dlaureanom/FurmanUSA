ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_FactorInteres_Sel]
		 @psNombrePcMod				VARCHAR(64)
		, @pnClaUsuarioMod				INT	
AS
BEGIN

	SELECT 
		1 AS EditaAnio,
		AnioMes AS AnioMes,
		PorcInteres AS FactorInteresProc
	FROM [MSWSch].[MSWCfgFurmanVentaInterestRate]
	
END
