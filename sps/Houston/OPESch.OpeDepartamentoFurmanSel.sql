USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeDepartamentoFurmanSel]    Script Date: 4/1/2024 11:00:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 01-11-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeDepartamentoFurmanSel]
	@pnClaUbicacion		INT = 65
	
AS
BEGIN
	SET NOCOUNT ON
       
        SELECT 
			DISTINCT 
			ClaFurmanDepartment = ClaFurmanDepartment
			,NomFurmanDepartment = CAST(ClaFurmanDepartment AS VARCHAR) + ' - ' + NomFurmanDepartment
		FROM [OPESch].[OPECatFurmanCrcVw] P WITH(NOLOCK)        

   	SET NOCOUNT OFF
END