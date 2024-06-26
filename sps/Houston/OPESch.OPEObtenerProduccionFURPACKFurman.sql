USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OPEObtenerProduccionFURPACKFurman]    Script Date: 5/3/2024 11:15:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [OPESch].[OPEObtenerProduccionFURPACKFurman]
   @pnClaUsuarioMod	 INT		 = 1
    ,@psNombrePcMod		 VARCHAR(64) = 'JOB- FURMAN'
	,@pnClaUbicacion     INT         = 65
	,@psIdioma           VARCHAR(50) = 'ENGLISH'

AS
BEGIN
    SET NOCOUNT ON
    
  	DECLARE @AnioMesMaxRegistrado INT --= 2020--2024--2024
		,@dFechaActual DATETIME = GETDATE() --'2023-12-31'
		,@nDiasExtendidosCierreMes INT = 6
		,@dFechaEjecucionDesde DATETIME
		,@dFechaEjecucionHasta DATETIME
		,@nContador             INT           = 1
		,@nNumEjecuciones       INT           = NULL
        ,@nEsAbrirTransaccion   INT
        ,@sMensajeError 	    VARCHAR(2000) = NULL
		,@nIdFurmanProduccion   INT
		,@nIdFurmanGastos       INT
		,@sTiposGastoFurpack	VARCHAR(MAX) = ''


		CREATE TABLE #tmpFurmanProd
		(
			[ClaAnioMes]           INT
			,[ClaUbicacion]         INT
			,[ClaArticulo]	        INT
			,[NomArticulo]	        VARCHAR(200)
			,[ClaCrc]	            INT
			,[NomCrc]	            VARCHAR(100)
			,[ClaElementoCosto]	    INT
			,[NomElementoCosto]     VARCHAR(200)	
			,[Importe]	            NUMERIC(22,8)
			,[ProdTonsArticuloBase]	NUMERIC(22,8)
			,[CostoXTonelada]	    NUMERIC(22,8)
			,[PorcComp]             NUMERIC(22,8)
		)

		SELECT @sTiposGastoFurpack = sValor1 
		FROM [OPESch].[OpeCatFurmanConfiguracion] WHERE ClaConfiguracion = 4

		SELECT @dFechaEjecucionHasta = DATEADD(DAY, -@nDiasExtendidosCierreMes, @dFechaActual)

		--FECHA INICIAL POR DEFAULT 2020
		SELECT 
			@AnioMesMaxRegistrado = ISNULL(MAX(ClaAnioMes),202301)
		FROM [OPESch].[OPETraFurmanProduccionFURPACK] WITH(NOLOCK)

		SELECT @dFechaEjecucionDesde = SUBSTRING(CAST(@AnioMesMaxRegistrado AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@AnioMesMaxRegistrado AS VARCHAR(10)), 5,6)+'-01'
	

		SELECT 
			dFechaEjecucionDesde = @dFechaEjecucionDesde
			,dFechaEjecucionHasta = @dFechaEjecucionHasta

		SELECT @nNumEjecuciones = DATEDIFF(Month,@dFechaEjecucionDesde, @dFechaEjecucionHasta) + 1

		SELECT nNumEjecuciones = @nNumEjecuciones
		
		DECLARE @nFechaEnProceso DATETIME = @dFechaEjecucionDesde
		,@nAnioMesEnProceso INT = YEAR(@dFechaEjecucionDesde)*100 + MONTH(@dFechaEjecucionDesde)

		WHILE (@nContador <= @nNumEjecuciones)
		BEGIN			
				SELECT @nAnioMesEnProceso = YEAR(@nFechaEnProceso)*100 + MONTH(@nFechaEnProceso)
			
				SELECT 
					Contador = @nContador
					,nAnioMesEnProceso = @nAnioMesEnProceso

				INSERT INTO #tmpFurmanProd
				EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] @nAnioMesEnProceso , 65 ,'ENGLISH', @psClaTipoGastos = @sTiposGastoFurpack
				
				SELECT @nFechaEnProceso = DATEADD(Month, @nContador, @dFechaEjecucionDesde)
				SELECT @nContador = @nContador + 1
		END
	

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN 
            SET @nEsAbrirTransaccion = 1
            BEGIN TRAN INSERTAPRODFURMAN
        END
       
		DELETE FROM [OPESch].[OPETraFurmanProduccionFURPACK] WHERE ClaAnioMes = (YEAR(@dFechaEjecucionDesde) * 100) + MONTH(@dFechaEjecucionDesde)
		
		SELECT	@nIdFurmanProduccion = ISNULL(MAX(IdFurmanProduccionFURPACK),0)
		FROM	[OPESch].[OPETraFurmanProduccionFURPACK]

		INSERT INTO [OPESch].[OPETraFurmanProduccionFURPACK](
			[IdFurmanProduccionFURPACK]
			,[ClaAnioMes]
			,[ClaUbicacion]
			,[ClaArticulo]
			,[NomArticulo]
			,[ClaCrc]
			,[NomCrc]
			,[ClaElementoCosto]
			,[NomElementoCosto]
			,[Importe]
			,[ProdTonsArticuloBase]
			,[CostoXTonelada]
			,[PorcComp]
			,[FechaUltimaMod]
			,[NombrePcMod]
			,[ClaUsuarioMod]
		)
		SELECT 
			[IdFurmanProduccionFURPACK] = ROW_NUMBER() OVER(ORDER BY [ClaAnioMes],[ClaUbicacion],[ClaArticulo]) + @nIdFurmanProduccion
			,[ClaAnioMes]
			,[ClaUbicacion]
			,[ClaArticulo]
			,[NomArticulo]
			,[ClaCrc]
			,[NomCrc]
			,[ClaElementoCosto]
			,[NomElementoCosto]
			,[Importe]
			,[ProdTonsArticuloBase]
			,[CostoXTonelada]
			,[PorcComp]
			,GETDATE()
			,@psNombrePcMod
			,HOST_ID()
		FROM #tmpFurmanProd


        IF @@TRANCOUNT > 0 AND @nEsAbrirTransaccion = 1
        BEGIN
            COMMIT TRAN INSERTAPRODFURMAN
        END	
    END TRY
    BEGIN CATCH
        SET @sMensajeError = ERROR_MESSAGE()
		
        IF @@TRANCOUNT > 0 AND @nEsAbrirTransaccion = 1
        BEGIN
            ROLLBACK TRAN INSERTAPRODFURMAN
        END	
            
        RAISERROR(@sMensajeError,16,1)
    END CATCH

    FIN:
		DROP TABLE #tmpFurmanProd

    SET NOCOUNT OFF
END
