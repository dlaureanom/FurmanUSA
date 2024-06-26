USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeConfiguracionConceptoFurmanSel]    Script Date: 4/16/2024 12:33:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 07-11-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeConfiguracionConceptoFurmanSel]
	@pnIdConceptoFurman   INT = NULL
	,@pnClaUbicacion	  INT = 65
	
AS
BEGIN
	SET NOCOUNT ON
       
        SELECT DISTINCT
			R.IdConceptoFurman
			,NomConceptoFurman = CAST(R.IdConceptoFurman as varchar) + ' - ' +CF.NomConceptoFurman 
			,R.ClaElementoCosto
			,NomElementoCosto = CAST(R.ClaElementoCosto as varchar) + ' - ' + eCrc.NomElementoCosto
        FROM [OPESch].[OPERelConceptoFurmanCrc] R WITH(NOLOCK)
		INNER JOIN [OPESch].[OPECatConceptoFurman] CF ON R.IdConceptoFurman = CF.IdConceptoFurman		
		INNER JOIN [OPESch].[OPECatFurmanElementoCrcVw] eCrc ON R.ClaElementoCosto = eCrc.ClaElementoCosto       
		ORDER BY R.IdConceptoFurman

   	SET NOCOUNT OFF
END