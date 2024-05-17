ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_FactorInteres_Sel]
	@psNombrePcMod				VARCHAR(64) = ''
	,@pnClaUsuarioMod				INT = 1
AS
BEGIN

	SELECT 		
		YearMonth = AnioMes,
		InteresExpenseRate = PorcInteres
	FROM [MSWSch].[MSWCfgFurmanVentaInterestRate]
	ORDER BY AnioMes DESC
	
END
