/*
	Revision de Documentos
	http://appnet05:2019/Pages/Vta_CU536_Pag1.aspx?wu=6


*/
ALTER PROC [OPESch].[OPECalcularReporteFurmanVentasPorPeriodo]
 @pnAnioMesInicio		INT = NULL
,@pnAnioMesFin			INT = NULL
,@pnEsDebug				TINYINT = 0  
AS
BEGIN

	DECLARE 
		@nEsError       INT,
		@sMensaje       VARCHAR(MAX),
		@AnioInicial    INT,
		@AnioFinal      INT,
		@nREPACKU		NUMERIC(22,8),
		@pnDpto         INT = NULL,
		@AnioSinConfig	VARCHAR(MAX),
		@FechaCompletaIni	DATE,
		@FechaCompletaFin	DATE,
		@sFamiliasAlambre VARCHAR(8000),
		@nINLFPW_P NUMERIC(22,6),
		@nUSAWAREHU_P NUMERIC(22,6),
		@nInterestExpRate NUMERIC(22,6)

    SELECT @sFamiliasAlambre = sValor1 
	FROM [OPESch].[OpeCatFurmanConfiguracion] WHERE ClaConfiguracion = 2


	SELECT * 
	INTO #FamiliasAlambre
	FROM [OPESch].[OpeSplitString](@sFamiliasAlambre,',',0)


	CREATE TABLE #tmpTonsProdPOR
	(
		PRODCODU INT
		,PRODCODU2 VARCHAR(100)
		,DESCRIP  VARCHAR(500)
		,CRC INT
		,CRCN VARCHAR(500)
		,DEPT INT
		,DEPTN VARCHAR(500)
		,CONNUMU VARCHAR(200)
		,PRODQTY NUMERIC(22,8)
		,FURMAT  NUMERIC(22,8)
		,FURMANYLD NUMERIC(22,8)
		,SCRAPOFFSET NUMERIC(22,8)
		,FURLAB  NUMERIC(22,8)
		,FUROH   NUMERIC(22,8)
		,FURPACK NUMERIC(22,8)
		,FURCOM  NUMERIC(22,8)
		,FURGNA  NUMERIC(22,8)
		,FURINT  NUMERIC(22,8)
		,TOTFGM  NUMERIC(22,8)
	)

	CREATE TABLE #tmpAnios(
		Anio		INT
	)

	CREATE TABLE #PackingCost(
		ClaArticulo INT 
		,ClaAnioMes INT
		,ProdTonsSUM NUMERIC (22,8)
		,ProdKGsSUM NUMERIC (22,8)
		,CostoPacking NUMERIC (22,8)
	)

	
	INSERT INTO #PackingCost
	SELECT
		--SUM(ProdTonsArticuloBase*1000) AS 'ProdKGsSUM', SUM(Importe) AS 'CostoPacking',SUM(Importe)/SUM(ProdTonsArticuloBase*1000) AS REPACK  
		ClaArticulo
		, ClaAnioMes
		, ProdTonsArticuloBase as 'ProdTonsSUM'
		, ProdTonsArticuloBase*1000 as 'ProdKGsSUM'
		, SUM(Importe) as 'CostoPacking'
	FROM [OPESch].[OPETraFurmanCostoEmbalaje]
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND ClaAnioMes >= @pnAnioMesInicio))
	AND (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND ClaAnioMes <= @pnAnioMesFin))
	AND ClaArticulo NOT IN(259087)
	GROUP BY ClaArticulo, ClaAnioMes, ProdTonsArticuloBase
	

	SELECT @nREPACKU = ISNULL(SUM(CostoPacking)/SUM(ProdKGsSUM),0)
	FROM #PackingCost	

	SELECT
		@AnioInicial = LEFT(@pnAnioMesInicio,4),
		@AnioFinal	 = LEFT(@pnAnioMesFin,4)

	WHILE	@AnioInicial <= @AnioFinal
	BEGIN
		INSERT INTO #tmpAnios (Anio) VALUES (@AnioInicial)
		SET @AnioInicial = @AnioInicial + 1
	END

	SELECT  
		@AnioSinConfig = CAST(STUFF((SELECT ', ' + CONVERT(VARCHAR(4),tmp.Anio)
	FROM #tmpAnios tmp
	WHERE tmp.Anio NOT IN (
		SELECT 
			Anio
		FROM [OPESch].[OPECfgFurmanVariables] con WITH(NOLOCK)
	)FOR XML PATH('')) ,1,1,'') AS VARCHAR(MAX))

	IF @AnioSinConfig IS NOT NULL
		BEGIN		
		--SELECT @sMensaje =  'Missing settings for following years: ' + @AnioSinConfig
					
		--RAISERROR(@sMensaje , 16, 1 )
		--RETURN

		SET @sMensaje = 'Missing settings for following years: ' + @AnioSinConfig
		SET @nEsError = 1
		--RAISERROR(@sMensaje , 16, 1 )
	END

	SET @FechaCompletaIni = CAST(@pnAnioMesInicio/100 AS VARCHAR) + '-' + CAST(@pnAnioMesInicio%100 AS VARCHAR) + '-1'

	SET @FechaCompletaFin = CAST(@pnAnioMesFin/100 AS VARCHAR) + '-' + CAST(@pnAnioMesFin%100 AS VARCHAR) + '-1'
	SET	@FechaCompletaFin = DATEADD(dd,-1,DATEADD(mm,1,@FechaCompletaFin))

	/*		
	INSERT INTO #tmpTonsProdPOR (PRODCODU, PRODCODU2, DESCRIP, CRC, CRCN, DEPT, DEPTN, CONNUMU, PRODQTY, FURMAT, FURMANYLD, SCRAPOFFSET, FURLAB, FUROH, FURPACK, FURCOM, FURGNA, FURINT,TOTFGM)
	EXEC [OpeSch].[OpeCalcularReporteFurmanPorPeriodo] @pnAnioMesInicio = @pnAnioMesInicio
													  ,@pnAnioMesFin = @pnAnioMesFin													  	
		
	IF @pnEsDebug = 1 SELECT '#tmpTonsProdPOR',* FROM #tmpTonsProdPOR WHERE PRODCODU2 = 716392


	SELECT 
		PRODCODU = PRODCODU
		,TOTFGM  = TOTFGM
		,CONNUMU = CONNUMU
		,CRC = CRC
		,CRCN = CRCN
		,DEPT = DEPT
		,DEPTN = DEPTN
	INTO #tmpFURMAN
	FROM #tmpTonsProdPOR	

	IF @pnEsDebug = 1 SELECT '#tmpFURMAN',* FROM #tmpFURMAN WHERE PRODCODU = 716392
	*/

	
		SELECT 
			@nInterestExpRate = AVG(ISNULL(PorcInteres,0))
		FROM [OpeSch].[OpeCfgFurmanVentasInterestRate]	FInt
		WHERE FInt.AnioMes >= @pnAnioMesInicio
		AND FInt.AnioMes <= @pnAnioMesFin
	

	SELECT @nINLFPW_P = ISNULL(SUM(HTL.ImportePagarFinalUSD)/NULLIF(SUM(HTL.Tons * 1000.00),0),0)
		--,Tons = SUM(Tons)
		--,Kgs = SUM(Tons) * 1000.00
		--,ImportePagarFinalUSD = SUM(ImportePagarFinalUSD)
	FROM [OpeSch].[OpeFreightFromHoustonToLocation] HTL WITH(NOLOCK) 
	WHERE ClaCiudadDestino = 24456 --Houston
	AND ClaCiudadDestino = 24456 --Pasadena
	AND ClaAgrupador1 = 2 
	AND ClaAgrupador2 = 1
	AND AnioMes >= @pnAnioMesInicio --@pnAnioMesInicio 
	AND AnioMes <= @pnAnioMesFin --@pnAnioMesInicio 

	DECLARE @pnAnioCalculoUSAWAREHU_P INT
	, @nWareHExp_P NUMERIC(22,4)

	SELECT @pnAnioCalculoUSAWAREHU_P = SUBSTRING(CONVERT(VARCHAR,@pnAnioMesInicio),1,4)

	--SELECT pnAnioCalculoUSAWAREHU_P = @pnAnioCalculoUSAWAREHU_P

	IF EXISTS 
	(
		SELECT 1 FROM [OPESch].[OPETraFurmanGastosPasadena] (NOLOCK)
		WHERE ClaAnio=@pnAnioCalculoUSAWAREHU_P OR ClaAnio = @pnAnioCalculoUSAWAREHU_P-1
	)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM [OPESch].[OPETraFurmanGastosPasadena] (NOLOCK) WHERE ClaAnio=@pnAnioCalculoUSAWAREHU_P)
		BEGIN
			SELECT
				@nWareHExp_P = ISNULL((SaldoFinal),0) 
			FROM [OPESch].[OPETraFurmanGastosPasadena](NOLOCK) 
			WHERE ClaAnio=@pnAnioCalculoUSAWAREHU_P
		END
		ELSE
		BEGIN
			SELECT TOP 1 
				@nWareHExp_P = ISNULL((SaldoFinal),0) 
			FROM [OPESch].[OPETraFurmanGastosPasadena](NOLOCK)  
			ORDER BY ClaAnio DESC
		END			
	END	

	SELECT @nUSAWAREHU_P = @nWareHExp_P/SUM(CAST ((PTL.Tons * 1000) AS numeric)) 
	FROM [OPESch].[OpeFreightFromPasadenaToLocation] PTL WITH(NOLOCK)	
	WHERE ClaCiudadDestino <> 24415 --Pasadena
	AND AnioMes >= @pnAnioMesInicio --@pnAnioMesInicio 
	AND AnioMes <= @pnAnioMesFin --@pnAnioMesInicio 

	--SELECT nUSAWAREHU_P = @nUSAWAREHU_P

	--SELECT *
	--FROM [OPESch].[OpeFreightFromPasadenaToLocation]
	--WHERE ClaCiudadDestino <> 24415 --Pasadena

	SELECT
		PRODCODU = VtFcD.ClaArticulo 
		,PRODDESCU = Cat.NomArticulo		
		,DEPT = FDpt.ClaFurmanDepartment
		,DEPTN = FDpt.NomFurmanDepartment
		,CRC = FDpt.ClaCrc
		,CRCN = FDpt.NomCrc
		,WireRodCONNUMU = '' -- NULL 
		--,WireRodClaArticulo = NULL 
		,WireCONNUMU = ISNULL(connumWire.ConnumConGuiones, '')
		--,WireClaArticulo = ISNULL(connumWire.ClaArticuloComp, NULL) 
		,CUSCODU = Cl.ClaCliente 
		,CUSTNAMEU = Cl.NombreCliente 
		,SALINDTU = VtFc.FechaFactura 
		,INVOICEU = VtFc.IdFactura
		,INVOICEUALF = VtFc.IdFacturaAlfanumerico		 
		,ImporteFactura = VtFc.ImpFactura 
		,ImporteSubTotal = Edt.CantEmbarcada --* ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) 
		,TipoCambio = VtFc.TipoCambio 
		,SHIPDATU = E.FechaEntSal 
		,PAYDATEU = ISNULL(Car.FechaUltimoPago, CarH.FechaUltimoPago) 
		,QTYU = Edt.PesoEmbarcado * ISNULL(connumWire.PorcComposicion,1)
		,QTYU2 = Invs.TotalQtyKilos
		--,QTYU = Edt.PesoEmbarcado
		,QTY_AS_SOLDU = Edt.CantEmbarcada --* ISNULL(connumWire.PorcComposicion,1)
		,QTYUNIT_AS_SOLDU = ISNULL(CatUV.NombreUnidadEdi, CatUV.NombreUnidadVenta) 
		,GRSUPRU = CAST ((ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/ Cat.PesoTeoricoKgs) AS numeric(22,4))
		,GRSUPR_AS_SOLDU = CAST(ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) AS numeric(22,4))
		,BILLADJU = CAST(NULL as numeric(22,8))
		,EARLPYU = CAST(NULL as numeric(22,8)) 
		,OTHDISU = CAST(NULL as numeric(22,8))
		,REBATEU = CAST(NULL as numeric(22,8))
		,DINLFTWU_MX = InFht.DINLFTWU_MX
		,DINLFTWU_USD = InFht.DINLFTWU_MX / NULLIF(ExRt.ParidadMonedaPeso,0)
		,DWAREHU_MX = InFht.DWAREHU_MX
		,DWAREHU_USD = InFht.DWAREHU_MX / NULLIF(ExRt.ParidadMonedaPeso,0)
		,DINLFTPU_MXN = InFht.DINLFTPU_MXN
		,DINLFTPU_USD = InFht.DINLFTPU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
		,DBROKU_MX = InFht.DBROKU_MX
		,DBROKU_USD = InFht.DBROKU_MX / NULLIF(ExRt.ParidadMonedaPeso,0)
		,USBROKU = InFht.USBROKU
		,INLFPWCU_L = InFht.INLFPWCU_L
		,USWAREHU_L = InFht.USWAREHU_L
		--,INLFCU = ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Tab.ImportePagarFinal,0))/Edt.PesoEmbarcado,0)
		--,INLFCU =  / NULLIF(CAST(Edt.PesoEmbarcado AS numeric(22,2)),0)
		,INLFCU = (Tab.ImportePagarFinal * (Edt.PesoEmbarcado/ViajesFact.TotalPesoEmbarcado))/ Invs.TotalQtyKilos--Sub.TotalPesoEmbarcado--Edt.PesoEmbarcado
		--,INLFCU = (Tab.ImportePagarFinal * ((Edt.PesoEmbarcado * ISNULL(connumWire.PorcComposicion,1))/ViajesFact.TotalPesoEmbarcado))/ Invs.TotalQtyKilos--Sub.TotalPesoEmbarcado--Edt.PesoEmbarcado
		--ISNULL(Tab.ImportePagarFinal,CAST(0 as numeric(22,8)))
		,INLFPW_P = ISNULL(@nINLFPW_P,0)
		,USWAREHU_P = ISNULL(@nUSAWAREHU_P,0)
		,DESTU = Cl.ZonaPostal
		,STATEU = LTRIM(REPLACE(Cd.NombreEstado,',',''))
		,COMM1U = (ISNULL(Val.ComisionAgenteVenta,0) * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)) / NULLIF(CAST(Edt.PesoEmbarcado AS numeric(22,2)),0)
		,COMM2U = (ISNULL(Val.ComisionManagerVenta,0) * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)) / NULLIF(CAST(Edt.PesoEmbarcado AS numeric(22,2)),0)
		,COMM3U = (ISNULL(Val.ComisionVPVenta,0) * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)) / NULLIF(CAST(Edt.PesoEmbarcado AS numeric(22,2)),0)
		,COMM4U = (ISNULL(Val.ComisionAgIndVenta,0) * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)) / NULLIF(CAST(Edt.PesoEmbarcado AS numeric(22,2)),0)
		,SELAGENU = SRep.NombreAgente
		,CREDITU = CAST(NULL as numeric(22,8))
		,REPACKU = @nREPACKU
		,INDIRECTS = ((ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) *Edt.CantEmbarcada) / Edt.PesoEmbarcado) * (CONVERT(numeric,Val.PorcGastoVentaIndirecta)/100)
		,FURMANU = CAST(0 as numeric(22,8))
		,USP = CAST(0 AS numeric(22,8))
		,PorcInteres = CAST(ISNULL(@nInterestExpRate,0) as numeric(22,6))
	INTO #tmpInfoVtas
	FROM OpeSch.OpeTraMovEntSal                E      WITH(NOLOCK)
	INNER JOIN OpeSch.[OPETraMovEntSalDet]     Edt    WITH(NOLOCK)  ON E.ClaUbicacion = Edt.ClaUbicacion 
																				AND E.IdMovEntSal = Edt.IdMovEntSal 
																				AND E.IdFabricacion = Edt.IdFabricacion	
																				AND Edt.ClaUbicacion = 65	
	INNER JOIN OpeSch.OpeTraFacturaVw                VtFc   WITH(NOLOCK)  ON VtFc.IdFactura = E.IdFactura AND VtFc.IdViaje = E.IdViaje
	INNER JOIN OpeSch.OpeTraFacturaDetVw             VtFcD  WITH(NOLOCK)  ON VtFcD.IdFactura = VtFc.IdFactura AND VtFcD.NumRenglonFab = Edt.IdFabricacionDet AND VtFcD.ClaArticulo = Edt.ClaArticulo 	
	LEFT JOIN  OpeSch.OPECfgFurmanVariables	         Val    WITH(NOLOCK)  ON Val.Anio = YEAR(VtFc.FechaFactura)
	INNER JOIN OpeArtCatArticuloVw				     Cat    WITH(NOLOCK)  ON Cat.ClaArticulo = Edt.ClaArticulo AND Cat.ClaTipoInventario = 1
	LEFT JOIN  OPESch.OPECarTraCargo                 Car    WITH(NOLOCK)  ON Car.IdCargo = VtFc.IdFactura
	LEFT JOIN  OPESch.OPECarHisCargo                 CarH   WITH(NOLOCK)  ON CarH.IdCargo = VtFc.IdFactura
	INNER JOIN OpeSch.OpeVtaCatClienteVw             Cl     WITH(NOLOCK)  ON Cl.ClaCliente = VtFc.ClaClienteCuenta 
	INNER JOIN OpeSch.OpeVtaCatCiudadVw  	         Cd     WITH(NOLOCK)  ON Cl.ClaCiudad = Cd.ClaCiudad AND Cd.ClaPais = 2
	INNER JOIN OpeSch.OpeTraViajevw		  			 Via    WITH(NOLOCK)  ON E.ClaUbicacion = Via.ClaUbicacion
																			  AND E.IdViaje = Via.IdViaje
																			  AND Via.IdNumTabular IS NOT NULL
																			  AND Via.ClaEstatus = 3
	LEFT JOIN OPESch.OPEFleTraTabularVw           Tab    WITH (NOLOCK) ON Via.ClaUbicacion = Tab.ClaUbicacion
																			  AND Via.IdNumTabular = Tab.IdTabular
																			  AND Tab.ClaTipoTabular IN (1,3) --(1) Nacional y (3) Ruta, (5) Es Rescogen y no genera costo de flete/tabular.
	INNER JOIN FleSch.FleVtaCfgArticuloFacturaVw  CfgVta WITH(NOLOCK)  ON CfgVta.ClaArticulo = VtFcD.ClaArticulo AND CfgVta.ClaPais = 2
	INNER JOIN FleSch.FleVtaCatUnidadVentaVw      CatUV  WITH(NOLOCK)  ON CfgVta.ClaUnidadVenta = CatUV.ClaUnidadVenta
	INNER JOIN OPESch.OpeVtaCatAgenteVw           SRep   WITH(NOLOCK)  ON SRep.ClaAgente = VtFc.ClaAgente
	--LEFT JOIN OpeSch.OPECfgFurmanInlandFreightValoresUsar InFht WITH(NOLOCK) ON InFht.Anio=YEAR(VtFc.FechaFactura)
	LEFT JOIN OPESch.OPECfgFurmanInlandFreightRates InFht WITH(NOLOCK) ON InFht.Anio=YEAR(VtFc.FechaFactura)
	OUTER APPLY(
		--SELECT 
		--	TotalQtyKilos = SUM(Edt.PesoEmbarcado)			
		--FROM [OPESch].[OpeTraFacturaDetVw] FD  WITH(NOLOCK)  
		--WHERE FD.IdFactura = VtFc.IdFactura 
		--AND FD.NumRenglonFab = Edt.IdFabricacionDet 
		--AND FD.ClaArticulo = Edt.ClaArticulo 	

		SELECT 
			TotalQtyKilos = SUM(Ed.PesoEmbarcado)	
		FROM OPERACION.OPESCH.OpeTraMovEntSal                En      WITH(NOLOCK)
		INNER JOIN OPERACION.OPESCH.[OPETraMovEntSalDet]     Ed    WITH(NOLOCK)  ON En.ClaUbicacion = Ed.ClaUbicacion 
																					AND En.IdMovEntSal = Ed.IdMovEntSal 
																					AND En.IdFabricacion = Ed.IdFabricacion	
																					AND En.ClaUbicacion = 65	
		INNER JOIN [OPESch].[OpeTraFacturaVw]                Inv   WITH(NOLOCK)  ON Inv.IdFactura = En.IdFactura AND Inv.IdViaje = En.IdViaje
		WHERE Inv.IdFactura = VtFc.IdFactura AND Inv.IdViaje = VtFc.IdViaje
		--INNER JOIN [OPESch].[OpeTraFacturaDetVw]             VtFcD  WITH(NOLOCK)  ON VtFcD.IdFactura = VtFc.IdFactura AND VtFcD.NumRenglonFab = Edt.IdFabricacionDet AND VtFcD.ClaArticulo = Edt.ClaArticulo 	

	) Invs
	CROSS APPLY(
		SELECT 
			TotalPesoEmbarcado = SUM(Edts.PesoEmbarcado)--, Edt.* 
		FROM OpeSch.OpeTraMovEntSal                Es      WITH(NOLOCK)
		INNER JOIN OpeSch.[OPETraMovEntSalDet]     Edts    WITH(NOLOCK)  ON Es.ClaUbicacion = Edts.ClaUbicacion
																		AND Es.IdMovEntSal = Edts.IdMovEntSal 
																		AND Es.IdFabricacion = Edts.IdFabricacion	
																		AND Edts.ClaUbicacion = 65	
		WHERE Es.IdViaje = E.IdViaje
	) ViajesFact
	
	OUTER APPLY(
		SELECT 
			Are.ConnumConGuiones AS ConnumConGuiones,
			SUM (Cmp.PorcComposicion/100.0) AS PorcComposicion
		FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
		INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Cmp.ClaArticuloComp = Are.ClaArticulo
		WHERE Cmp.ClaArticulo = VtFcD.ClaArticulo
		GROUP BY Are.ConnumConGuiones	
	) as connumWire
	
	OUTER APPLY (
		SELECT 
			ParidadMonedaPeso
		FROm
		OpeSch.OpeAreCatParidadVw P
		WHERE CAST(P.FechaParidad AS DATE) = CAST(VtFc.FechaFactura AS DATE)
	) ExRt
	OUTER APPLY(
		SELECT 
			ClaCrc
			,NomCrc
			,ClaFurmanDepartment
			,NomFurmanDepartment
		FROM [OPESch].[OPECatArticuloFurmanDepartmentVw] Dpt
		WHERE Dpt.ClaArticulo = VtFcD.ClaArticulo 
	) FDpt
	
	
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(VtFc.FechaFactura)*100+MONTH(VtFc.FechaFactura) >= @pnAnioMesInicio))
		AND (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(VtFc.FechaFactura)*100+MONTH(VtFc.FechaFactura) <= @pnAnioMesFin))
		AND E.ClaMotivoEntrada = 1 AND Cat.ClaArticulo NOT IN(259087)
		--AND VtFc.IdFactura IN (168011987) --244062328,168011961)

	--AND VtFcD.ClaArticulo = 522801
	--ORDER BY VtFcD.ClaArticulo, VtFc.FechaFactura

	SELECT DISTINCT Vta.INVOICEU, Vta.PRODCODU, Vta.QTYU 
	INTO #tmpInfoKilosTotalesPorFactura
	FROM #tmpInfoVtas Vta
	--WHERE Vta.CRCN IS NOT NULL

	IF @pnEsDebug = 1 SELECT '#tmpInfoKilosTotalesPorFactura', * FROM #tmpInfoKilosTotalesPorFactura

	--UPDATE 
	--	t1
	--SET		
	--	t1.INLFCU = t1.INLFCU / NULLIF(t1.QTYU2,0)	--NULLIF(t2.KilosPorFactura,0) 
	--	--t1.INLFCU = ISNULL(t2.KilosPorFactura,0)
	--FROM #tmpInfoVtas t1	
	--OUTER APPLY (
	--	SELECT 
	--		Vta.INVOICEU
	--		, KilosPorFactura = SUM(Vta.QTYU)
	--	FROM #tmpInfoKilosTotalesPorFactura Vta
	--	WHERE Vta.INVOICEU = t1.INVOICEU
	--	GROUP BY Vta.INVOICEU
	--) t2	
			
	/* DFSS
	UPDATE 
		t1
	SET		
		t1.FURMANU = ISNULL(FUR.TOTFGM, 0)
	FROM #tmpInfoVtas t1	
	LEFT JOIN  #tmpFURMAN FUR  WITH(NOLOCK) ON t1.ClaFurmanDepartment = FUR.DEPT 
											AND t1.ClaCrc = FUR.CRC
	*/
	--,FDpt.ClaFurmanDepartment
	--	,DEPTN = FDpt.NomFurmanDepartment
	--	,FDpt.ClaCrc

	/*
	UPDATE 
		t1
	SET				
		t1.CRCN = FUR.CRCN
		,t1.DEPTN = FUR.DEPTN
	FROM #tmpInfoVtas t1	
	LEFT JOIN  #tmpFURMAN FUR  WITH(NOLOCK) ON t1.PRODCODU = FUR.PRODCODU 
											AND t1.WireCONNUMU = FUR.CONNUMU
	
	*/


	/*  
		Vamos por todos los creditos que se le han emitido a la factura. [OPECarHisCredito] es una replica (Sincroniza) de CARTERA.
		
		"ClaMovCredito"

		Ajuste en precio: (Bonificacion):
			65 - AJUSTE EN PRECIO

		Descuentos por pronto pago:    
			61 - PP AUTOMATICO
			62 - PP MANUAL
			67 - COD AUTORIZADO
			101-COD IMPROCEDENTE

		Rebates:
			118-REBATE

		Otro Descuentos
			Descuentos confidenciales:        63 - DESCTOS. CONF. AUTOMATICOS
			64- DESCTOS. CONF. MANUALES
			163-DESCTOS. CONF. AUTOMATICOS.
			263-DICE DEBE DECIR.
			Descuentos por ajuste*:             66-AJUSTE EN DESCUENTO
			102-DESCUENTOS EXCEDIDOS
			110-DESCTO COEXPORTACION			 
	*/ 
	--SELECT NULL/1
	--SELECT NULL * 1
	--SELECT 1/NULL
	--UPDATE 
	--	t1
	--SET		
	--	t1.INLFWCU = ISNULL(((t1.ImporteSubTotal /t1.ImporteFactura)*t1.Impor) / t1.QTYU,0)
	--FROM #tmpInfoVtas t1	
	
	--INLFWCU

	UPDATE 
		t1
	SET		
		--t1.BILLADJU = ISNULL(t2.SumImpCreditoMonCargo/NULLIF(t1.QTYU,0),0)
		t1.BILLADJU = ISNULL(t2.SumImpCreditoMonCargo/NULLIF(t1.QTYU2,0),0)
	FROM #tmpInfoVtas t1	
	OUTER APPLY (
		SELECT SUM(Cred.ImpCreditoMonCargo) as SumImpCreditoMonCargo
		FROM [OPESch].[OPECarHisCredito] Cred
		WHERE Cred.ClaMovCredito = 65 AND IdCargo = t1.INVOICEU
		GROUP BY Cred.IdCargo
	) t2		

	UPDATE t1
	SET
		--t1.EARLPYU = ISNULL(t2.SumImpCreditoMonCargo/NULLIF(t1.QTYU,0),0)
		t1.EARLPYU = ISNULL(t2.SumImpCreditoMonCargo/NULLIF(t1.QTYU2,0),0)
	FROM #tmpInfoVtas t1	
	OUTER APPLY (
		SELECT SUM(Cred.ImpCreditoMonCargo) as SumImpCreditoMonCargo
		FROM [OPESch].[OPECarHisCredito] Cred
		WHERE Cred.ClaMovCredito IN (61,62,67, 101) AND IdCargo = t1.INVOICEU
		GROUP BY Cred.IdCargo
	) t2

	UPDATE t1
	SET
		--t1.OTHDISU = ISNULL(t2.SumImpCreditoMonCargo/NULLIF(t1.QTYU,0),0)
		t1.OTHDISU = ISNULL(t2.SumImpCreditoMonCargo/NULLIF(t1.QTYU2,0),0)
	FROM #tmpInfoVtas t1	
	OUTER APPLY (
		SELECT SUM(Cred.ImpCreditoMonCargo) as SumImpCreditoMonCargo
		FROM [OPESch].[OPECarHisCredito] Cred
		WHERE Cred.ClaMovCredito IN (64,66,102,110,163,263) AND IdCargo = t1.INVOICEU
		GROUP BY Cred.IdCargo
	) t2	

	UPDATE t1
	SET
		--t1.REBATEU = ISNULL(t2.SumImpCreditoMonCargo/NULLIF(t1.QTYU,0),0)
		t1.REBATEU = ISNULL(t2.SumImpCreditoMonCargo/NULLIF(t1.QTYU2,0),0)
	FROM #tmpInfoVtas t1	
	OUTER APPLY (
		SELECT SUM(Cred.ImpCreditoMonCargo) as SumImpCreditoMonCargo
		FROM [OPESch].[OPECarHisCredito] Cred
		WHERE Cred.ClaMovCredito IN (118) AND IdCargo = t1.INVOICEU
		GROUP BY Cred.IdCargo
	) t2

	--CALCULOS COMPLEMENTARIOS
	UPDATE t1
	SET 
		t1.CREDITU = (ISNULL(DATEDIFF(day, SHIPDATU, PAYDATEU),0) /365.00) * GRSUPRU * (PorcInteres / 100.00)
	FROM #tmpInfoVtas t1
	
	IF @pnEsDebug = 1  SELECT '#tmpInfoVtas',* FROm #tmpInfoVtas --WHERE INVOICEU = 244059922

	--UPDATE t1
	--SET 
	--	t1.CREDITU = t1.CREDITU * PorcInteres
		
	--FROM #tmpInfoVtas t1

	
	IF @pnEsDebug = 1 SELECT '#tmpInfoVtas',* FROm #tmpInfoVtas --WHERE INVOICEU = 244059922
	
	--UPDATE t1	
	--	SET t1.USP = ISNULL(t1.GRSUPRU,0) + ISNULL(t1.BILLADJU,0) - ISNULL(t1.EARLPYU,0) - ISNULL(t1.OTHDISU,0) - ISNULL(t1.REBATEU,0) - ((ISNULL(t1.DINLFTWU_USD,0) + ISNULL(t1.DWAREHU_USD,0) + ISNULL(t1.DINLFTPU_USD,0) + ISNULL(t1.DBROKU_USD,0)) * TipoCambio) - ISNULL(t1.USBROKU,0) - ISNULL(t1.INLFPWCU_L,0) - ISNULL(t1.USWAREHU_L,0) - ISNULL(t1.INLFCU,0) - ISNULL(t1.COMM1U,0) - ISNULL(t1.COMM2U,0) - ISNULL(t1.COMM3U,0) - ISNULL(t1.COMM4U,0) - ISNULL(t1.CREDITU,0) - ISNULL(t1.REPACKU,0) - ISNULL(t1.INDIRECTS,0) - ISNULL(t1.FURMANU,0)
	--FROM #tmpInfoVtas t1
	

	UPDATE t1	
	SET t1.USP  = t1.GRSUPRU
	+
	(
		t1.BILLADJU - t1.OTHDISU - t1.REBATEU
	)
	-
	(
		t1.DINLFTWU_USD 
		+ t1.DWAREHU_USD 
		+ t1.DINLFTPU_USD 
		+ t1.DBROKU_USD
	) 
	- t1.USBROKU 
	- t1.INLFPWCU_L 
	- t1.USWAREHU_L 
	- t1.USWAREHU_P
	- t1.INLFPW_P
	- t1.INLFCU 
	- ISNULL(t1.COMM1U,0) - ISNULL(t1.COMM2U,0) - ISNULL(t1.COMM3U,0) - ISNULL(t1.COMM4U,0)
	- t1.FURMANU
	FROM #tmpInfoVtas t1

	--SET USP = R.PrecioUnitarioBruto + (R.BILLADJU - R.OTHDIS1U - R.REBATEU) - (R.DINLFTWU_USD + R.DWAREHU_USD + R.DINLFTPU_USD + R.DBROKU_USD) - R.USBROKU - R.INLFPWU_L - R.USWAREHU_L - R.USWAREHU_O - INLFPW_O - (R.ImporteFlete + R.ImporteFleteAhorrado) - R.Commision - R.FURMANU
 

	IF @pnEsDebug = 1
	BEGIN
		SELECT * FROM #tmpInfoVtas
	END


		SELECT 
			PRODCODU
			,PRODDESCU
			,DEPT
			,DEPTN
			,CRC
			,CRCN
			,WireRodCONNUMU
			,WireCONNUMU
			,WSOURCE =  'MX'
			,CUSCODU
			,CUSTNAMEU
			,SALINDTU
			,INVOICEU = INVOICEUALF
			,SHIPDATU
			,PAYDATEU
			,QTYU
			,QTYU2
			,QTY_AS_SOLDU
			,QTYUNIT_AS_SOLDU
			,GRSUPRU
			,GRSUPR_AS_SOLDU
			,BILLADJU
			,EARLPYU
			,OTHDISU
			,REBATEU
			,DINLFTWU_MX
			,DINLFTWU_USD
			,DWAREHU_MX
			,DWAREHU_USD
			,DINLFTPU_MXN
			,DINLFTPU_USD
			,DBROKU_MX
			,DBROKU_USD
			,USBROKU
			,INLFPWCU_L
			,USWAREHU_L
			,INLFCU
			,INLFPW_P
			,USWAREHU_P
			,DESTU
			,STATEU
			,COMM1U
			,COMM2U
			,COMM3U
			,COMM4U
			,SELAGENU
			,CREDITU
			,REPACKU
			,INDIRECTS
			,FURMANU
			,USP
		FROM #tmpInfoVtas vtas
		WHERE CRCN IS NOT NULL
		--AND INVOICEU = 168011871
		ORDER BY INVOICEUALF, PRODCODU
	
		DROP TABLE #tmpInfoVtas
		DROP TABLE #tmpTonsProdPOR
		--DROP TABLE #tmpFURMAN
		DROP TABLE #FamiliasAlambre
		DROP TABLE #PackingCost
END