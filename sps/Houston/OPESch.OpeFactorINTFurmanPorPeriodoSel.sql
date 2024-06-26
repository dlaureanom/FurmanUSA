USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeFactorINTFurmanPorPeriodo]    Script Date: 4/18/2024 2:39:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 01-11-2022
-- Description: 
-- =============================================
CREATE PROCEDURE [OPESch].[OpeFactorINTFurmanPorPeriodoSel]
	@pnClaUbicacion		INT = 65	
AS
BEGIN
SET NOCOUNT ON
        SELECT 
            ClaINTPeriodoFurman
            ,AnioINTPeriodoFurman
            ,FactorINTPeriodoFurman
        FROM [OPESch].[OPECfgINTPeriodoFurman]
        ORDER BY AnioINTPeriodoFurman ASC        

   	SET NOCOUNT OFF
END
