ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_ValoresTransporte_Sel]
	@psNombrePcMod				VARCHAR(64) = ''
	,@pnClaUsuarioMod				INT = 1
AS
BEGIN
	SELECT 
		Year = Anio
		,DINLFTWU_MX = DINLFTWU_MXN
		,DWAREHU_MX = DWAREHU_MXN
		,DINLFTPU_MXN
		,DBROKU_MX = DBROKU_MXN
		,USBROKU
		,INLFPWCU_L = INLFPWU_L
		,USWAREHU_L
	FROM MSWSch.MSWCfgFurmanInlandFreightRates WITH(NOLOCK)
	ORDER BY Anio DESC
END