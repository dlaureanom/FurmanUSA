USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeConceptoFurmanSel]    Script Date: 4/16/2024 2:30:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 07-11-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeConceptoFurmanSel]
	@pnClaUbicacion		INT = 65
	
AS
BEGIN
	SET NOCOUNT ON
       
        SELECT 
			IdConceptoFurman
			,NomConceptoFurman = CAST(IdConceptoFurman as varchar) + ' - ' + NomConceptoFurman
        FROM [OPESch].[OPECatConceptoFurman] WITH(NOLOCK)
		WHERE BajaLogica = 0
        ORDER BY IdConceptoFurman

   	SET NOCOUNT OFF
END