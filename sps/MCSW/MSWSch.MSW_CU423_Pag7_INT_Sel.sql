USE [MCSW_ERP]
GO
/****** Object:  StoredProcedure [MSWSch].[MSW_CU423_Pag7_INT_Sel]    Script Date: 5/9/2024 4:06:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 25/04/2022
-- Description:	Furman Report - INT FACTOR
-- =============================================
ALTER PROCEDURE [MSWSch].[MSW_CU423_Pag7_INT_Sel]
	-- Add the parameters for the stored procedure here
	@pnDepto					int = NULL
	,@pnAnioMesInicio			int = NULL
	,@pnAnioMesFin				int = NULL
	,@pnVendor					int = NULL           
	,@psIdioma					varchar(10)	= 'English'
	,@pnClaUsuarioMod			int	= 1
	,@pnEsPorPantallaReact      INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--IF @pnEsPorPantallaReact = 1
	--BEGIN
		SELECT 
			ClaInteresPeriodoFurman AS 'Id'
			,AnioInteresPeriodoFurman AS 'AnioINTPeriodoFurman'
			,FactorInteresPeriodoFurman AS 'FactorINTPeriodoFurman'
		FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK)
		ORDER BY AnioInteresPeriodoFurman DESC
	--END
	--ELSE 
	--BEGIN
		-- Insert statements for procedure here	
	--	SELECT 
	--		ClaInteresPeriodoFurman [Id;w=200;a=Center;v=false]
	--		,AnioInteresPeriodoFurman [AnioInteresPeriodoFurman;w=200;a=Center;c=Year;t=clave]
	--		,FactorInteresPeriodoFurman [FactorInteresPeriodoFurman;w=200;a=Center;c=% Factor;d=8;t=decimal]
	--	FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK)
	--	ORDER BY AnioInteresPeriodoFurman DESC
	--END
		
	SET NOCOUNT OFF;

END
