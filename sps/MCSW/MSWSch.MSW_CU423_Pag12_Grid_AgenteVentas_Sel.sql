ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_AgenteVentas_Sel]
 @psIdioma				VARCHAR(15)='Spanish'
,@pnEsDebug				TINYINT = 0  
AS
BEGIN
	SELECT 
		Year = Anio,
		UserId = Commision.ClaUsuario,
		UserName = Users.NombreUsuario+' '+Users.ApellidoPaterno,
		CommissionPerBoxRate = ComisionPorCaja
	FROM MSWSch.MSWCfgFurmanComisionesPorCaja  Commision WITH(NOLOCK)
	INNER JOIN [TiSeguridad].[dbo].[TiTraUsuario] Users  WITH(NOLOCK) ON Commision.ClaUsuario=Users.IdUsuario
	ORDER BY Anio DESC 
END