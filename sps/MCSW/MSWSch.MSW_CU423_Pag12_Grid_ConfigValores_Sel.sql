ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_ConfigValores_Sel]
 @psIdioma				VARCHAR(15)='Spanish'
,@pnEsDebug				TINYINT = 0  
AS
BEGIN

	SELECT 
		Year = Anio,
		--PorcInteres,
		IndirectSellingExpFactor = PorcGastoVentaIndirecta
		--ComisionAgenteVenta,
		--ComisionManagerVenta,
		--ComisionVPVenta,
		--ComisionAgIndVenta,
		--1 AS EditaAnio
	FROM MSWSch.MSWCfgFurmanVentaValoresUsar WITH(NOLOCK)
	ORDER BY Anio DESC
	
FINSP:


END
