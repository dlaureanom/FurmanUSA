ALTER PROC [MSWSch].[MSW_CU423_Pag8_Grid_GridGenerico_Sel]
	@pnAnioMesInicio		INT = NULL
	,@pnAnioMesFin			INT = NULL
	,@pnVendor				INT = NULL
	,@pnDepto				INT = NULL
	,@pnEsDebug				TINYINT = 0  
	,@pnEsPorPantallaReact	INT = 0
AS
BEGIN
	
	DECLARE  
		@nFURINT						NUMERIC(22,9)
		,@nFURGNA						NUMERIC(22,9)
		,@nFURMAT						NUMERIC(22,9)
		,@nScrapRevenueBulk				NUMERIC(22,9)
		,@nScrapRevenueCollated			NUMERIC(22,9)
		,@nScrapRevenuePaperTape		NUMERIC(22,9)
		,@nScrapProcBulk				NUMERIC(22,9)
		,@nScrapProcWireCoil			NUMERIC(22,9)
		,@nScrapProcPaperTape			NUMERIC(22,9)
		,@nScrapProcPlasticStrip		NUMERIC(22,9)
		,@pnAnioCalculoGNA				INT
		,@pnAnioCalculoINT				INT		
		,@nScrapProduccionBulk			NUMERIC(22,9)
		,@nScrapProduccionWireCoil		NUMERIC(22,9)
		,@nScrapProduccionPaperTape		NUMERIC(22,9)
		,@nScrapProduccionPlasticStrip	NUMERIC(22,9)
		,@nScrapOffSetBulk				NUMERIC(22,9)
		,@nScrapOffSetWireCoil			NUMERIC(22,9)
		,@nScrapOffSetPaperTape			NUMERIC(22,9)
		,@nScrapOffSetPlasticStrip		NUMERIC(22,9)
		,@nClaUnidadKgs					INT
		,@nClaUnidadLbs					INT
		,@nClaUnidadCajas				INT
		,@nTipoClavosBulk				INT
		,@sSubTipoClavosBulk			VARCHAR(100)
		,@nTipoClavosWireCoil			INT
		,@sSubTipoClavosWireCoil		VARCHAR(100)
		,@nTipoClavosPaperTape			INT
		,@sSubTipoClavosPaperTape		VARCHAR(100)
		,@nTipoClavosPlasticStrip		INT
		,@sSubTipoClavosPlasticStrip	VARCHAR(100)

		,@pdFechaBalanceInicio DATETIME
		,@pdFechaBalanceFin DATETIME

	IF @pnEsDebug = 1 SELECT FURMANAnioMesInicio = @pnAnioMesInicio, FURMANAnioMesFin = @pnAnioMesFin

	SELECT @pdFechaBalanceInicio = SUBSTRING(CAST(@pnAnioMesInicio AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@pnAnioMesInicio AS VARCHAR(10)), 5,6)+'-01'		
	SELECT @pdFechaBalanceFin = SUBSTRING(CAST(@pnAnioMesFin AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@pnAnioMesFin AS VARCHAR(10)), 5,6)+'-01'		
	
	SELECT @pdFechaBalanceInicio = DATEADD(MONTH, 1 ,@pdFechaBalanceInicio)	
	SELECT @pdFechaBalanceFin = DATEADD(MONTH, 1 ,@pdFechaBalanceFin)	
	
	IF @pnEsDebug = 1 SELECT dFechaBalanceInicio = (YEAR(@pdFechaBalanceInicio) *100) + MONTH(@pdFechaBalanceInicio) , dFechaBalanceFin = (YEAR(@pdFechaBalanceFin) *100) + MONTH(@pdFechaBalanceFin)
	
	SELECT 
		@nScrapRevenueBulk = SUM(Cargos - Creditos) 
	FROM MSWSch.MswTraSaldosEng9 
	WHERE ClaCuenta = 10911 
	AND AnioMes >= (YEAR(@pdFechaBalanceInicio) *100) + MONTH(@pdFechaBalanceInicio) 
	AND AnioMes <= (YEAR(@pdFechaBalanceFin) *100) + MONTH(@pdFechaBalanceFin)
	
	IF @pnEsDebug = 1 SELECT nScrapRevenueBulk = @nScrapRevenueBulk

	SELECT 
		@nScrapRevenueCollated = SUM(Cargos - Creditos) 
	FROM MSWSch.MswTraSaldosEng9 
	WHERE ClaCuenta = 10912 
	AND AnioMes >= (YEAR(@pdFechaBalanceInicio) *100) + MONTH(@pdFechaBalanceInicio) 
	AND AnioMes <= (YEAR(@pdFechaBalanceFin) *100) + MONTH(@pdFechaBalanceFin)

	IF @pnEsDebug = 1 SELECT nScrapRevenueCollated = @nScrapRevenueCollated

	SELECT 
		@nScrapRevenuePaperTape = SUM(Cargos - Creditos) 
	FROM MSWSch.MswTraSaldosEng9 
	WHERE ClaCuenta = 10918 
	AND AnioMes >= (YEAR(@pdFechaBalanceInicio) *100) + MONTH(@pdFechaBalanceInicio) 
	AND AnioMes <= (YEAR(@pdFechaBalanceFin) *100) + MONTH(@pdFechaBalanceFin)

	IF @pnEsDebug = 1 SELECT nScrapRevenuePaperTape = @nScrapRevenuePaperTape
	
	SELECT @nClaUnidadKgs = ClaUnidad FROM MSWSch.MSWCatUnidad WHERE ClaUnidad = 1
	SELECT @nClaUnidadLbs = ClaUnidad FROM MSWSch.MSWCatUnidad WHERE ClaUnidad = 15
	SELECT @nClaUnidadCajas = ClaUnidad FROM MSWSch.MSWCatUnidad WHERE ClaUnidad = 11

	SELECT 
		@nTipoClavosBulk = nValor1
		,@sSubTipoClavosBulk = sValor1
	FROM [MSWSch].[MSWCatConfiguracion] 
	WHERE ClaConfiguracion = 604

	SELECT 
		@nTipoClavosWireCoil = nValor1
		,@sSubTipoClavosWireCoil = sValor1
	FROM [MSWSch].[MSWCatConfiguracion] 
	WHERE ClaConfiguracion = 605

	SELECT 
		@nTipoClavosPaperTape = nValor1
		,@sSubTipoClavosPaperTape = sValor1
	FROM [MSWSch].[MSWCatConfiguracion] 
	WHERE ClaConfiguracion = 606

	SELECT 
		@nTipoClavosPlasticStrip = nValor1
		,@sSubTipoClavosPlasticStrip = sValor1
	FROM [MSWSch].[MSWCatConfiguracion] 
	WHERE ClaConfiguracion = 607

	SELECT * 
	INTO  #tmpSubTipoClavosBulk
	FROM [MSWSch].[MSWSplitString](@sSubTipoClavosBulk, ',',0)

	SELECT * 
	INTO  #tmpSubTipoClavosWireCoil
	FROM [MSWSch].[MSWSplitString](@sSubTipoClavosWireCoil, ',',0)

	SELECT * 
	INTO  #tmpSubTipoClavosPaperTape
	FROM [MSWSch].[MSWSplitString](@sSubTipoClavosPaperTape, ',',0)

	SELECT * 
	INTO  #tmpSubTipoClavosPlasticStrip
	FROM [MSWSch].[MSWSplitString](@sSubTipoClavosPlasticStrip, ',',0)

	SELECT 		
		OT.ClaArticulo
		,Cm.PorcCostoMaterial
		,UnidadOTs = OT.ClaUnidad
		,BxsOTs = OT.Cantidad
		,LbsOTs = [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs)
		,KgsOTs = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs)
		,KgsScrap = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs) * ISNULL(Cm.PorcCostoMaterial/100.00,0)
	INTO #tmpKgsScrapBulk
	FROM MSWSch.MSWTraOrdenTrabajo4 OT WITH(NOLOCK)
	INNER JOIN MSWSch.MswCatArticulo C WITH(NOLOCK) ON OT.ClaArticulo = C.ClaArticulo
										AND C.ClaTipoInventario = 1
	INNER JOIN MSWSch.MSWTraComposicionArticulo4Vw Cm WITH(NOLOCK) ON C.ClaArticulo = Cm.ClaArticulo
	WHERE C.ClaGrupoEstadistico2 = @nTipoClavosBulk
	AND C.ClaGrupoEstadistico3 IN (SELECT Item FROM #tmpSubTipoClavosBulk)
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) <= @pnAnioMesFin))
	AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) >= @pnAnioMesInicio))

	SELECT 		
		OT.ClaArticulo
		,Cm.PorcCostoMaterial
		,UnidadOTs = OT.ClaUnidad
		,BxsOTs = OT.Cantidad
		,LbsOTs = [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs)
		,KgsOTs = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs)
		,KgsScrap = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs) * ISNULL(Cm.PorcCostoMaterial/100.00,0)
	INTO #tmpKgsScrapWireCoil
	FROM MSWSch.MSWTraOrdenTrabajo4 OT WITH(NOLOCK)
	INNER JOIN MSWSch.MswCatArticulo C WITH(NOLOCK) ON OT.ClaArticulo = C.ClaArticulo
										AND C.ClaTipoInventario = 1
	INNER JOIN MSWSCh.MSWTraArticuloInfo I WITH(NOLOCK) ON Ot.ClaArticulo = I.ClaArticulo
	INNER JOIN MSWSch.MSWTraComposicionArticulo4Vw Cm ON C.ClaArticulo = Cm.ClaArticulo
	WHERE C.ClaGrupoEstadistico2 = @nTipoClavosWireCoil
	AND C.ClaGrupoEstadistico3 IN (SELECT Item FROM #tmpSubTipoClavosWireCoil)
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) <= @pnAnioMesFin))
	AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) >= @pnAnioMesInicio))


	SELECT 	
		OT.ClaArticulo
		,Cm.PorcCostoMaterial
		,UnidadOTs = OT.ClaUnidad
		,BxsOTs = OT.Cantidad
		,LbsOTs = [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs)
		,KgsOTs = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs)
		,KgsScrap = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs) * ISNULL(Cm.PorcCostoMaterial/100.00,0)	
	INTO #tmpKgsScrapPaperTape
	FROM MSWSch.MSWTraOrdenTrabajo4 OT WITH(NOLOCK)
	INNER JOIN MSWSch.MswCatArticulo C WITH(NOLOCK) ON OT.ClaArticulo = C.ClaArticulo
										AND C.ClaTipoInventario = 1
	INNER JOIN MSWSCh.MSWTraArticuloInfo I WITH(NOLOCK) ON Ot.ClaArticulo = I.ClaArticulo
	INNER JOIN MSWSch.MSWTraComposicionArticulo4Vw Cm ON C.ClaArticulo = Cm.ClaArticulo
	WHERE C.ClaGrupoEstadistico2 = @nTipoClavosPaperTape
	AND C.ClaGrupoEstadistico3 IN (SELECT Item FROM #tmpSubTipoClavosPaperTape)
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) <= @pnAnioMesFin))
	AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) >= @pnAnioMesInicio))

	SELECT 		
		OT.ClaArticulo
		,Cm.PorcCostoMaterial
		,UnidadOTs = OT.ClaUnidad
		,BxsOTs = OT.Cantidad
		,LbsOTs = [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs)
		,KgsOTs = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs)
		,KgsScrap = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs) * ISNULL(Cm.PorcCostoMaterial/100.00,0)
	INTO #tmpKgsScrapPlasticStrip
	FROM MSWSch.MSWTraOrdenTrabajo4 OT WITH(NOLOCK)
	INNER JOIN MSWSch.MswCatArticulo C WITH(NOLOCK) ON OT.ClaArticulo = C.ClaArticulo
										AND C.ClaTipoInventario = 1
	INNER JOIN MSWSCh.MSWTraArticuloInfo I WITH(NOLOCK) ON Ot.ClaArticulo = I.ClaArticulo
	INNER JOIN MSWSch.MSWTraComposicionArticulo4Vw Cm ON C.ClaArticulo = Cm.ClaArticulo
	WHERE C.ClaGrupoEstadistico2 = @nTipoClavosPlasticStrip
	AND C.ClaGrupoEstadistico3 IN (SELECT Item FROM #tmpSubTipoClavosPlasticStrip)
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) <= @pnAnioMesFin))
	AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) >= @pnAnioMesInicio))

	
	IF @pnEsDebug = 1 
	BEGIN
		SELECT 
			Type = 'Bulk'
			,UnidadOTs
			,ClaArticulo
			,PorcCostoMaterial
			,BxsOTs
			,LbsOTs
			,KgsOTs
			,KgsScrap
		FROm #tmpKgsScrapBulk
		
		SELECT 
			Type = 'PaperTape'
			,UnidadOTs
			,ClaArticulo
			,PorcCostoMaterial
			,BxsOTs
			,LbsOTs
			,KgsOTs
			,KgsScrap
		FROm #tmpKgsScrapPaperTape
		
		SELECT 
			Type = 'PlasticStrip'
			,UnidadOTs
			,ClaArticulo
			,PorcCostoMaterial
			,BxsOTs
			,LbsOTs
			,KgsOTs
			,KgsScrap
		FROm #tmpKgsScrapPlasticStrip
		
		SELECT 
			Type = 'WireCoil'
			,UnidadOTs
			,ClaArticulo
			,PorcCostoMaterial
			,BxsOTs
			,LbsOTs
			,KgsOTs
			,KgsScrap
		FROm #tmpKgsScrapWireCoil
	END

	

	IF @pnEsDebug = 1
	SELECT '#tmpKgsScrapBulk',
		KgsOTs = SUM(KgsOTs),
		KgsScrap = SUM(KgsScrap),
		ProcScrap = SUM(KgsScrap)/SUM(KgsOTs)	
	FROM #tmpKgsScrapBulk

	SELECT @nScrapProduccionBulk = SUM(KgsScrap) FROM #tmpKgsScrapBulk

	IF @pnEsDebug = 1
	SELECT '#tmpKgsScrapWireCoil', 
		KgsOTs = SUM(KgsOTs),
		KgsScrap = SUM(KgsScrap),
		ProcScrap = SUM(KgsScrap)/SUM(KgsOTs)
	FROM #tmpKgsScrapWireCoil

	SELECT @nScrapProduccionWireCoil = SUM(KgsScrap) FROM #tmpKgsScrapWireCoil

	IF @pnEsDebug = 1
	SELECT '#tmpKgsScrapPaperTape', 
		KgsOTs = SUM(KgsOTs),
		KgsScrap = SUM(KgsScrap),
		ProcScrap = SUM(KgsScrap)/SUM(KgsOTs)
	FROM #tmpKgsScrapPaperTape

	SELECT @nScrapProduccionPaperTape = SUM(KgsScrap) FROM #tmpKgsScrapPaperTape

	IF @pnEsDebug = 1
	SELECT '#tmpKgsScrapPlasticStrip', 
		KgsOTs = SUM(KgsOTs),
		KgsScrap = SUM(KgsScrap),
		ProcScrap = SUM(KgsScrap)/SUM(KgsOTs)	
	FROM #tmpKgsScrapPlasticStrip

	SELECT @nScrapProduccionPlasticStrip = SUM(KgsScrap) FROM #tmpKgsScrapPlasticStrip

	SELECT @nScrapOffSetBulk = @nScrapRevenueBulk / @nScrapProduccionBulk
	
	IF @pnEsDebug = 1 SELECT nScrapOffSetBulk = @nScrapOffSetBulk

	SELECT @nScrapOffSetPaperTape = @nScrapRevenuePaperTape / @nScrapProduccionPaperTape
	IF @pnEsDebug = 1 SELECT nScrapOffSetPaperTape = @nScrapOffSetPaperTape

	/*
	SELECT WireCoilRevenueProc = (@nScrapProduccionWireCoil) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip) 
	SELECT WireCoilRevenue = (((@nScrapProduccionWireCoil) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip)) * @nScrapRevenueCollated) 
	SELECT WreCoilScrapoffset = (((@nScrapProduccionWireCoil) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip)) * @nScrapRevenueCollated)  / @nScrapProduccionWireCoil
	*/

	SELECT @nScrapOffSetWireCoil = (((@nScrapProduccionWireCoil) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip)) * @nScrapRevenueCollated)  / @nScrapProduccionWireCoil
	IF @pnEsDebug = 1 SELECT nScrapOffSetWireCoil = @nScrapOffSetWireCoil

	SELECT @nScrapOffSetPlasticStrip = (((@nScrapProduccionPlasticStrip) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip)) * @nScrapRevenueCollated)  / @nScrapProduccionPlasticStrip
	IF @pnEsDebug = 1 SELECT nScrapOffSetWireCoil = @nScrapOffSetPlasticStrip



	SELECT @pnAnioCalculoINT=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [MSWSch].MSWCfgInteresPeriodoFurman (NOLOCK) 
	WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT OR AnioInteresPeriodoFurman=@pnAnioCalculoINT-1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT)
		BEGIN
			SELECT @nFURINT = ISNULL((FactorInteresPeriodoFurman),0) FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURINT = ISNULL((FactorInteresPeriodoFurman),0) FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) ORDER BY AnioInteresPeriodoFurman DESC
		END
		--SET @nFURINT=1
		PRINT @nFURINT
	END
	ELSE
	BEGIN
		RAISERROR('INT Missing configuration, please configure a INT value for current P.O.R',16,1)
	END
	
	SELECT @pnAnioCalculoGNA=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [MSWSch].MSWCfgGNAPeriodoFurman (NOLOCK) 
	WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA OR AnioGNAPeriodoFurman=@pnAnioCalculoGNA-1)
	BEGIN
		

		IF EXISTS(SELECT 1 FROM MswSch.MSWCfgGNAPeriodoFurman (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA)
		BEGIN
			SELECT @nFURGNA = ISNULL((FactorGNAPeriodoFurman),0) FROM MswSch.MSWCfgGNAPeriodoFurman (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURGNA = ISNULL((FactorGNAPeriodoFurman),0) FROM MswSch.MSWCfgGNAPeriodoFurman (NOLOCK) ORDER BY AnioGNAPeriodoFurman DESC
		END
		--SET @nFURGNA=1
		PRINT @nFURGNA
	END
	ELSE
	BEGIN
		RAISERROR('GNA Missing configuration, please configure a GNA value for current P.O.R',16,1)
	END

	SELECT		NumFacturaProv	= fftm.NumFacturaDEA
				,CantidadKgs	= fftm.CantidadKgs
				,ImporteFlete	= fftm.ImporteFlete
	INTO #tmpFlete
	FROM 		MSWSch.MSWTraFurmanFreightToMCSWAnioMes	fftm
	WHERE		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(fftm.FechaFacturaDEA)*100+MONTH(fftm.FechaFacturaDEA) >= @pnAnioMesInicio))
		AND		(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(fftm.FechaFacturaDEA)*100+MONTH(fftm.FechaFacturaDEA) <= @pnAnioMesFin))

	SELECT	@nFURMAT = SUM(ImporteFlete)/NULLIF(SUM(CantidadKgs),0)
	FROM	#tmpFlete

	SELECT
		ClaAnioMes = [YearMonth]
		,ClaveArticulo = [Item]
		,NomFamilia = [Family]
		,NomCategoria = [Category]
		,NomTipo = [Type]
		,CantCajas = [Boxes]
		,CantKilos = [Kg]
		,TotalDL = [TOTAL DL]
		,TotalVarExp = [TOTAL VAR EXP]
		,TotalIL	 = [TOTAL IL]
		,TotalFixed	 = [TOTAL FIXED EXP]
		,Collated	 = [Tot Collated]
		,NailCoating = [Tot Nail Coating]
		,Packing	 = [Tot Packaging]
		,Pallets	 = [Tot Pallets]
		,WireMarkup	 = [Tot Wire MarkUp]
	INTO #tmpResultSetCostos
	FROM [DEAMIDCON02].[MCSW_Integra].[MSWSch].[MSWTraBSCLecturaFurmanCostByItemDet] RD
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND RD.[YearMonth] >= @pnAnioMesInicio))
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND RD.[YearMonth] <= @pnAnioMesFin))

	SELECT
		NomTipo
		,CantCajas = CAST(SUM(CantCajas) AS NUMERIC(22,8)) 
		,A = CAST(SUM(CantKilos)   AS NUMERIC(22,8)) 
		,B = CAST(SUM(TotalDL)	   AS NUMERIC(22,8)) 
		,C = CAST(SUM(TotalVarExp) AS NUMERIC(22,8)) 
		,D = CAST(SUM(TotalIL)	   AS NUMERIC(22,8)) 
		,E = CAST(SUM(TotalFixed)  AS NUMERIC(22,8)) 
		,F = CAST(SUM(Collated)	   AS NUMERIC(22,8)) 
		,G = CAST(SUM(NailCoating) AS NUMERIC(22,8)) 
		,H = CAST(SUM(Packing)	   AS NUMERIC(22,8)) 
		,I = CAST(SUM(Pallets)	   AS NUMERIC(22,8)) 
		,J = CAST(SUM(WireMarkup)  AS NUMERIC(22,8)) 
	INTO #tmpVariablesFurman
	FROM #tmpResultSetCostos
	GROUP BY NomTipo

	IF @pnEsDebug = 1 
	SELECT '#tmpResultSetCostos',* FROm #tmpResultSetCostos
	
	IF @pnEsDebug = 1 
	SELECT '#tmpVariablesFurman', * FROM #tmpVariablesFurman

	SELECT 
		[TYPE] = NomTipo
		,QTYKG = A
		,FURMAT = @nFURMAT
		,FURMAT_COLLATED = (F + G)/A
		,FURMANYLD = J/A
		,SCRAPOFFSET  = CAST(0 AS NUMERIC(22,8)) 
		,FURLAB = B / A
		,FURFOH = (C + D + E) / A
		,FURCOM = CAST(0 AS NUMERIC(22,8)) 
		,FURGNA = CAST(0 AS NUMERIC(22,8)) 
		,FURINT = CAST(0 AS NUMERIC(22,8)) 
		,FURPACK = (H + I) / A
		,TOTFGM = CAST(0 AS NUMERIC(22,8)) 
	INTO #tmpFurmanCosts
	FROm #tmpVariablesFurman
	--GROUP BY NomTipo


	UPDATE #tmpFurmanCosts
		SET SCRAPOFFSET = @nScrapOffSetBulk
	WHERE [TYPE] = 'Bulk'

	UPDATE #tmpFurmanCosts
		SET SCRAPOFFSET = @nScrapOffSetPaperTape
	WHERE [TYPE] = 'Paper Tape'

	UPDATE #tmpFurmanCosts
		SET SCRAPOFFSET = @nScrapOffSetPlasticStrip
	WHERE [TYPE] = 'Plastic Strip'

	UPDATE #tmpFurmanCosts
		SET SCRAPOFFSET = @nScrapOffSetWireCoil
	WHERE [TYPE] = 'Wire Coil'

	UPDATE #tmpFurmanCosts
		SET FURCOM = FURMAT + FURMAT_COLLATED + FURMANYLD + SCRAPOFFSET +FURLAB + FURFOH

	UPDATE #tmpFurmanCosts
		SET FURGNA = FURCOM * @nFURGNA   
		,FURINT = FURCOM * @nFURINT

	UPDATE #tmpFurmanCosts
		SET TOTFGM = FURCOM + FURPACK + FURGNA + FURINT
	
	
	SELECT 
		[TYPE]
		,QTYKG
		,FURMAT
		,FURMAT_COLLATED
		,FURMANYLD
		,SCRAPOFFSET
		,FURLAB
		,FURFOH
		,FURCOM
		,FURGNA
		,FURINT
		,FURPACK
		,TOTFGM
	FROM #tmpFurmanCosts

	DROP TABLE #tmpSubTipoClavosBulk
	DROP TABLE #tmpSubTipoClavosWireCoil
	DROP TABLE #tmpSubTipoClavosPaperTape
	DROP TABLE #tmpSubTipoClavosPlasticStrip
	DROP TABLE #tmpKgsScrapBulk
	DROP TABLE #tmpKgsScrapWireCoil
	DROP TABLE #tmpKgsScrapPaperTape
	DROP TABLE #tmpKgsScrapPlasticStrip
	DROP TABLE #tmpResultSetCostos
	DROP TABLE #tmpVariablesFurman
	DROP TABLE #tmpFurmanCosts
	DROP TABLE #tmpFlete
	
END
