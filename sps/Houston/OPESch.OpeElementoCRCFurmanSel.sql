USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeElementoCRCFurmanSel]    Script Date: 4/16/2024 4:14:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 01-11-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeElementoCRCFurmanSel]
	@pnClaUbicacion		INT = 65	
AS
BEGIN
	SET NOCOUNT ON
       
        SELECT 
          P.ClaElementoCosto
		  ,NomElementoCosto = CAST(P.ClaElementoCosto as varchar) + ' - ' + P.NomElementoCosto
		FROM [OPESch].[OPECatFurmanElementoCrcVw] P WITH(NOLOCK)
        ORDER BY P.ClaElementoCosto 

   	SET NOCOUNT OFF
END