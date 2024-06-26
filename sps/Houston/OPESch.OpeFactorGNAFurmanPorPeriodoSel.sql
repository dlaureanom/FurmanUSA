USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeFactorGNAFurmanPorPeriodo]    Script Date: 4/18/2024 2:39:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 01-11-2022
-- Description: 
-- =============================================
CREATE PROCEDURE [OPESch].[OpeFactorGNAFurmanPorPeriodoSel]
	@pnClaUbicacion		INT = 65
AS
BEGIN
	SET NOCOUNT ON
        SELECT 
            ClaGNAPeriodoFurman
            ,AnioGNAPeriodoFurman
            ,FactorGNAPeriodoFurman
        FROM [OPESch].[OPECfgGNAPeriodoFurman]
        ORDER BY AnioGNAPeriodoFurman ASC        
   	SET NOCOUNT OFF
END