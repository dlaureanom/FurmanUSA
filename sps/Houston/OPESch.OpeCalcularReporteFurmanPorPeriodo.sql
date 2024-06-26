USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeCalcularReporteFurmanPorPeriodo]    Script Date: 4/1/2024 3:35:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [OPESch].[OpeCalcularReporteFurmanPorPeriodo]
	 @pnAnioMesInicio		INT
	,@pnAnioMesFin			INT
	,@pnDpto                INT = NULL
	,@pnClaUbicacion		INT = 65
	,@pnEsDebug             INT = 0	
AS
BEGIN
	SET NOCOUNT ON

	--WOKRING IN PROGRESS [OPESch].[OpeCalcularReporteFurmanPorPeriodo]

	DECLARE  
	--@pnAnioMesInicio		 INT = @pnAnioMesInicio
	--,@pnAnioMesFin		 INT = @pnAnioMesInicio
	--,@pnDpto               INT = NULL
	--,@pnClaUbicacion		 INT = 65
	--,@pnEsDebug            INT = 1
	@nFactorConv			NUMERIC(22,2) = 1000.00
	,@sTiposGastoFurpack	VARCHAR(500)
	,@nFURGNA               NUMERIC(22,8)
	,@nFURINT               NUMERIC(22,8)
	,@nCRCEnRevison			INT --= 4033
	,@nFURMAT				NUMERIC(22,8) = 0
	,@nProductionScrapTotal DECIMAL(22,8) = 0
	,@nScrapRevenueTotal	DECIMAL(22,8) = 0
	-- 4208 OK
	-- 4133 OK
	-- 4033 OK


	SELECT @sTiposGastoFurpack = sValor1 --410,411,705,872
	FROM [OPESch].[OpeCatFurmanConfiguracion] 
	WHERE ClaConfiguracion = 4		

	SELECT ClaTipoGasto = Item
	INTO #tmpGastoFurpack
	FROM [OPESch].[OpeSplitString] (@sTiposGastoFurpack,',',1)
	
	
	--FURNGA
	DECLARE @pnAnioCalculoGNA INT

	SELECT @pnAnioCalculoGNA=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) 
	WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA OR AnioGNAPeriodoFurman=@pnAnioCalculoGNA-1)
	BEGIN
		

		IF EXISTS(SELECT 1 FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA)
		BEGIN
			SELECT @nFURGNA = ISNULL((FactorGNAPeriodoFurman),0) FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURGNA = ISNULL((FactorGNAPeriodoFurman),0) FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) ORDER BY AnioGNAPeriodoFurman DESC
		END
		--SET @nFURGNA=1
		PRINT @nFURGNA
	END
	ELSE
	BEGIN
		RAISERROR('GNA Missing configuration, please configure a GNA value for current P.O.R',16,1)
	END

	--FURINT
	DECLARE @pnAnioCalculoINT INT

	SELECT @pnAnioCalculoINT=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) 
	WHERE AnioINTPeriodoFurman=@pnAnioCalculoINT OR AnioINTPeriodoFurman=@pnAnioCalculoINT-1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) WHERE AnioINTPeriodoFurman=@pnAnioCalculoINT)
		BEGIN
			SELECT @nFURINT = ISNULL((FactorINTPeriodoFurman),0) FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) WHERE AnioINTPeriodoFurman=@pnAnioCalculoINT
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURINT = ISNULL((FactorINTPeriodoFurman),0) FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) ORDER BY AnioINTPeriodoFurman DESC
		END
		--SET @nFURINT=1
		PRINT @nFURINT
	END
	ELSE
	BEGIN
		RAISERROR('INT Missing configuration, please configure a INT value for current P.O.R',16,1)
	END


	/*Tomamos toda los costos y produccion de los CRC y sus respectivos Gastos dejando fuera los gastos de Packing (GastoFurpack)*/
	SELECT		
		P.ClaAnioMes
		,P.ClaUbicacion
		,P.ClaCrc
		,P.ClaElementoCosto		
		,ImpManufacturaDir = SUM(P.ImpManufacturaDir)
		,ImpManufacturaInd = SUM(P.ImpManufacturaInd)
		,ImpManufacturaNoDist = SUM(P.ImpManufacturaNoDist)
		,P.TonsProd
	INTO #tmpProdFurmanPorGastos
	FROM [OPESch].[OPETraFurmanGastos] P WITH(NOLOCK)		
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND P.ClaAnioMes >= @pnAnioMesInicio))
	AND  (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND  P.ClaAnioMes <= @pnAnioMesFin))	
	AND P.ClaUbicacion = @pnClaUbicacion
	AND P.ClaTipoGasto NOT IN (SELECT ClaTipoGasto FROM #tmpGastoFurpack)
	AND  (@nCRCEnRevison IS NULL OR (@nCRCEnRevison IS NOT NULL AND  P.ClaCrc = @nCRCEnRevison))	
	GROUP BY P.ClaAnioMes
		,P.ClaUbicacion
		,P.ClaCrc
		,P.ClaElementoCosto		
		,P.TonsProd

	/*Tomamos toda los costos y produccion de los CRC pero solo los gastos de Packing (GastoFurpack)*/
	SELECT		
		P.ClaAnioMes
		,P.ClaUbicacion
		,P.ClaCrc
		,P.ClaElementoCosto		
		,ImpManufacturaDir = SUM(P.ImpManufacturaDir)
		,ImpManufacturaInd = SUM(P.ImpManufacturaInd)
		,ImpManufacturaNoDist = SUM(P.ImpManufacturaNoDist)
		,P.TonsProd
	INTO #tmpProdFurmanPorGastosPacking
	FROM [OPESch].[OPETraFurmanGastos] P WITH(NOLOCK)		
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND P.ClaAnioMes >= @pnAnioMesInicio))
	AND  (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND  P.ClaAnioMes <= @pnAnioMesFin))	
	AND P.ClaUbicacion = @pnClaUbicacion
	AND P.ClaTipoGasto IN (SELECT ClaTipoGasto FROM #tmpGastoFurpack)
	AND  (@nCRCEnRevison IS NULL OR (@nCRCEnRevison IS NOT NULL AND  P.ClaCrc = @nCRCEnRevison))	
	GROUP BY P.ClaAnioMes
		,P.ClaUbicacion
		,P.ClaCrc
		,P.ClaElementoCosto		
		,P.TonsProd

	/*Tomamos toda la produccion de articulos por CRC*/
	SELECT
		P.IdFurmanProduccion
		,P.ClaAnioMes    
		,P.ClaUbicacion
		,P.ClaArticulo
		,P.ClaCrc
		,P.NomCrc
		--,F.ClaFurmanDepartment
		--,F.NomFurmanDepartment
		,P.ClaElementoCosto
		,P.NomElementoCosto
		,P.Importe
		,P.ProdTonsArticuloBase
		,P.CostoXTonelada
		,P.PorcComp      
	INTO #tmpProdFurman
	FROM [OPESch].[OPETraFurmanProduccion] P WITH(NOLOCK)
		--INNER JOIN [OPESch].[OPERelCRCFurmanDepartments] Rel WITH (NOLOCK) ON P.ClaCrc = Rel.ClaCrc
		--INNER JOIN [OPESch].[OPECatFurmanDepartments] F WITH (NOLOCK) ON Rel.ClaFurmanDepartment = F.ClaFurmanDepartment
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND P.ClaAnioMes >= @pnAnioMesInicio))
	AND  (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND  P.ClaAnioMes <= @pnAnioMesFin))	
	AND P.ClaUbicacion = @pnClaUbicacion 
	--AND  (@pnDpto IS NULL OR (@pnDpto IS NOT NULL AND F.ClaFurmanDepartment = @pnDpto))
	AND  (@nCRCEnRevison IS NULL OR (@nCRCEnRevison IS NOT NULL AND  P.ClaCrc = @nCRCEnRevison))	
	--AND P.ClaElementoCosto IN (1,3)
	
	/*Quitamos los Costos y nos quedamos unicamente con la Produccion CRC a nivel articulo*/
	SELECT DISTINCT ClaArticulo,ClaCrc,NomCrc,ProdTonsArticuloBase
	INTO #tmpProdArticuloCrc
	FROM #tmpProdFurman

	/*
		Agrupamos Total de Produccion por CRC por Aritculo.
		Tenemos cuanto se produjo por articulo en un CRC.
	*/
	SELECT ClaArticulo,ClaCrc, NomCrc, ProdTonsArticuloBase = SUM(ProdTonsArticuloBase)
	INTO #tmpProdArticulo
	FROM #tmpProdArticuloCrc
	GROUP BY ClaArticulo,ClaCrc, NomCrc
	
	/*
		Agrupamos Total de Produccion por CRC.
		Tenemos cuanto se produjo por CRC.
	*/
	SELECT ClaCrc,TonsProd = SUM(ProdTonsArticuloBase)
	INTO #tmpProdCrc
	FROM #tmpProdArticuloCrc
	GROUP BY ClaCrc

	IF @pnEsDebug = 1 SELECT 'Art Tons During POR',* FROM #tmpProdArticulo
	IF @pnEsDebug = 1 SELECT 'Crc Tons During POR',* FROM #tmpProdCrc


	SELECT 
		ClaCrc, ClaElementoCosto, GastoPropio = SUM(ImpManufacturaDir) , GastoAsignado = SUM(ImpManufacturaInd), GastoSinProd = SUM(ImpManufacturaNoDist)
	INTO #tmpGastosPropiosAsignados
	FROm #tmpProdFurmanPorGastos			
	GROUP BY ClaCrc, ClaElementoCosto

	SELECT 
		ClaCrc, ClaElementoCosto, GastoPropio = SUM(ImpManufacturaDir) , GastoAsignado = SUM(ImpManufacturaInd), GastoSinProd = SUM(ImpManufacturaNoDist)
	INTO #tmpGastosPropiosAsignadosPacking
	FROM #tmpProdFurmanPorGastosPacking
	GROUP BY ClaCrc, ClaElementoCosto

	IF @pnEsDebug = 1
		SELECT 'Production Cost By Crc & Cost Element (Without Packing Cost)',* 
		FROM #tmpGastosPropiosAsignados
		ORDER BY ClaCrc, ClaElementoCosto

	IF @pnEsDebug = 1
		SELECT 'Production Cost By Crc & Cost Element (Packing Costo Only)',* 
		FROM #tmpGastosPropiosAsignadosPacking
		ORDER BY ClaCrc, ClaElementoCosto


	/*
	SELECT 		 
		G.ClaCrc			
		,GastoAsignado = SUM(G.GastoAsignado)
		--,TonsProd = SUM(Pr.TonsProd) 
		,Pr.TonsProd
		--,FURMAT = SUM(G.GastoAsignado)/(SUM(Pr.TonsProd) * @nFactorConv)
		,FURMAT = SUM(G.GastoAsignado)/(Pr.TonsProd * @nFactorConv)
	INTO #tmpFURMAT
	FROM #tmpGastosPropiosAsignados G
	INNER JOIN #tmpProdCrc Pr ON G.ClaCrc = Pr.ClaCrc
	WHERE G.ClaElementoCosto IN (SELECT ClaElementoCosto --Elemento de Costo
								 FROM [OPESch].[OPERelConceptoFurmanCrc] Rel
								 WHERE IdConceptoFurman = 1 --FURMAT
								)
	GROUP BY G.ClaCrc,Pr.TonsProd
	

	IF @pnEsDebug = 1 SELECT 'FURMAT By CRC' ,* FROM #tmpFURMAT
	*/
	SELECT 
		@nFURMAT = SUM(ISNULL(T.ImportePagarFinal,0))/SUM(ISNULL(EC.TotPesoViaje,0))
	FROM	OPESCH.OpeTraMovEntSal E WITH(NOLOCK)
		INNER JOIN OPESCH.OpeTraMovEntSalDet D WITH(NOLOCK) ON E.ClaUbicacion = D.ClaUbicacion AND E.IdMovEntsal = D.IdMovEntsal
		OUTER APPLY (
			SELECT SUM(EC.PesoEmbarcado) AS TotPesoViaje 
			FROM	OPESCH.OpeTraMovEntSal EC WITH(NOLOCK)  
			WHERE E.ClaUbicacion= EC.ClaUbicacion AND E.IdViaje= EC.IdViaje
		) EC
		INNER JOIN OPESCH.ArtCatArticuloVW A WITH(NOLOCK)  ON D.ClaArticulo = A.ClaArticulo 
		INNER JOIN OPESCH.ArtCatFamiliaVW F WITH(NOLOCK)  ON  A.ClaFamilia =F.ClaFamilia AND A.ClaTipoInventario = F.ClaTipoInventario
		INNER JOIN OPESCH.OPETRAVIAJE V WITH(NOLOCK) ON  E.CLAUBICACION = V.CLAUBICACION AND E.IDVIAJE= V.IDVIAJE
		INNER JOIN FleSch.FleTraTabular T WITH(NOLOCK) ON  V.CLAUBICACION = T.CLAUBICACION AND V.IdNumTabular= T.IdTabular
		INNER JOIN  ManSch.ManRelArticuloComposicion S ON S.CLAPLANTA= 65 AND  D.ClaArticulo =  S.ClaArticuloComp AND S.BajaLogica=  0 AND S.ClaTipoComponente = 1
		INNER JOIN OPESCH.ArtCatArticuloVW AC WITH(NOLOCK)  ON S.ClaArticulo = AC.ClaArticulo 
	WHERE	
		E.ClaUbicacion = 65 AND
		E.ClaUbicacionOrigen = 345 AND
		E.ClaUbicacionDestino = 65 AND
		A.ClaTipoArticulo = 12 AND
		YEAR(E.FechaEntsal)= 2023 AND
		E.ClaMotivoentrada = 3		AND
		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND (YEAR(E.FechaEntsal) * 100 + MONTH(E.FechaEntsal)) >= @pnAnioMesInicio)) AND
		(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND  (YEAR(E.FechaEntsal) * 100 + MONTH(E.FechaEntsal)) <= @pnAnioMesFin))	


	SELECT 		 
		G.ClaCrc			
		,GastoPropio = (SUM(G.GastoPropio + G.GastoSinProd))
		--,TonsProd = SUM(Pr.TonsProd)
		,Pr.TonsProd
		--,FURLAB = SUM(G.GastoPropio)/(SUM(Pr.TonsProd) * @nFactorConv)
		,FURLAB = (SUM(G.GastoPropio + G.GastoSinProd))/(Pr.TonsProd * @nFactorConv)
		INTO #tmpFULAB
	FROM #tmpGastosPropiosAsignados G
	INNER JOIN #tmpProdCrc Pr ON G.ClaCrc = Pr.ClaCrc
	WHERE G.ClaElementoCosto IN (SELECT ClaElementoCosto --Elemento de Costo
								 FROM [OPESch].[OPERelConceptoFurmanCrc] Rel
								 WHERE IdConceptoFurman = 2 --FURLAB
								)
	GROUP BY G.ClaCrc,Pr.TonsProd

	IF @pnEsDebug = 1 SELECT 'FURLAB By CRC' ,* FROM #tmpFULAB

	SELECT 		 
		G.ClaCrc			
		,GastoPropio = (SUM(G.GastoPropio + G.GastoSinProd))
		--,TonsProd = SUM(Pr.TonsProd) 
		,Pr.TonsProd
		--,FUROH = SUM(G.GastoPropio)/(SUM(Pr.TonsProd) * @nFactorConv)
		,FUROH  = (SUM(G.GastoPropio + G.GastoSinProd))/(Pr.TonsProd * @nFactorConv)
	INTO #tmpFUROH
	FROM #tmpGastosPropiosAsignados G
	INNER JOIN #tmpProdCrc Pr ON G.ClaCrc = Pr.ClaCrc
	WHERE G.ClaElementoCosto IN (SELECT ClaElementoCosto --Elemento de Costo
								 FROM [OPESch].[OPERelConceptoFurmanCrc] Rel
								 WHERE IdConceptoFurman = 3 --FUROH

								)
	GROUP BY G.ClaCrc,Pr.TonsProd

	IF @pnEsDebug = 1 SELECT 'FUROH By CRC' ,* FROM #tmpFUROH

	SELECT 		 
		G.ClaCrc			
		,GastoPropio = (SUM(G.GastoPropio + G.GastoSinProd))
		--,TonsProd = SUM(Pr.TonsProd) 
		,Pr.TonsProd
		,FURPACK = (SUM(G.GastoPropio + G.GastoSinProd))/(SUM(Pr.TonsProd) * @nFactorConv)
		--,FURPACK = SUM(G.GastoPropio)/(SUM(Pr.TonsProd) * @nFactorConv)
	INTO #tmpFURPCK
	FROM #tmpGastosPropiosAsignadosPacking G
	INNER JOIN #tmpProdCrc Pr ON G.ClaCrc = Pr.ClaCrc
	WHERE G.ClaElementoCosto IN (SELECT ClaElementoCosto --Elemento de Costo
								 FROM [OPESch].[OPERelConceptoFurmanCrc] Rel
								 WHERE IdConceptoFurman = 4 --FURPACK

								)
	GROUP BY G.ClaCrc,Pr.TonsProd

	IF @pnEsDebug = 1 SELECT 'FURPACK By CRC' ,* FROM #tmpFURPCK

	SELECT 
		PRODCODU = Pd.ClaArticulo
		,PRODCODU2 = CArt.ClaveArticulo
		,DESCRIP = CArt.NomArticulo
		,CRC = Pd.ClaCrc
		,CRCN = Pd.NomCRc
		,DEPT = F.ClaFurmanDepartment
		,DEPTN = F.NomFurmanDepartment
		,CONNUMU = ISNULL(connumWire.ConnumConGuiones, '')
		,PRODQTY = (Pd.ProdTonsArticuloBase * @nFactorConv) * ISNULL(connumWire.PorcComposicion, 1.0)
		,FURMAT = ISNULL(@nFURMAT,0)
		,FURMANYLD = CAST (0 AS NUMERIC(22,8))		
		,ProcTeoricoScrap = ISNULL(C.nValor2, 0)
		,ProductionScrapKg = (ISNULL(C.nValor2, 0) / 100.00) * (Pd.ProdTonsArticuloBase * @nFactorConv) * ISNULL(connumWire.PorcComposicion, 1.0) -- >ProcTeoricoScrap = ISNULL(C.nValor2, 0)
		,SCRAPOFFSET = CAST (0 AS NUMERIC(22,8))
		,FURLAB = FLB.FURLAB
		,FUROH = FOH.FUROH
		,FURCOM = CAST(0 AS numeric(22,8))
		--ISNULL(@nFURMAT,0) + FLB.FURLAB + FOH.FUROH
		,FURPACK = FPK.FURPACK
		,FURGNA = @nFURGNA --* (ISNULL(@nFURMAT,0) + FLB.FURLAB + FOH.FUROH)
		,FURINT = @nFURINT --* (ISNULL(@nFURMAT,0) + FLB.FURLAB + FOH.FUROH)
		,TOTFMG = CAST (0 AS NUMERIC(22,8))
	INTO #tmpResultSet
	FROM #tmpProdArticulo Pd
	INNER JOIN #tmpFULAB FLB ON Pd.ClaCrc = FLB.ClaCrc
	INNER JOIN #tmpFUROH FOH ON Pd.ClaCrc = FOH.ClaCrc
	--INNER JOIN #tmpFURMAT FMT ON Pd.ClaCrc = FMT.ClaCrc
	INNER JOIN #tmpFURPCK FPK ON Pd.ClaCrc = FPK.ClaCrc
	LEFT JOIN [OPESch].[ArtCatArticuloVw] CArt ON Pd.ClaArticulo = CArt.ClaArticulo 
													AND CArt.ClaTipoInventario = 1
	INNER JOIN [OPESch].[OPERelCRCFurmanDepartments] Rel WITH (NOLOCK) ON Pd.ClaCrc = Rel.ClaCrc
	INNER JOIN [OPESch].[OPECatFurmanDepartments] F WITH (NOLOCK) ON Rel.ClaFurmanDepartment = F.ClaFurmanDepartment
	LEFT JOIN [OPESch].[OpeCatFurmanConfiguracion] C WITH(NOLOCK) ON Pd.ClaCrc = C.nValor1
	OUTER APPLY(
		SELECT 
			Are.ConnumConGuiones AS ConnumConGuiones,
			SUM (Cmp.PorcComposicion/100.0) AS PorcComposicion
		FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
		INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Are.ClaArticulo = Cmp.ClaArticuloComp
		WHERE Cmp.ClaArticulo = Pd.ClaArticulo
		GROUP BY Are.ConnumConGuiones		
	) as connumWire
	WHERE (@nCRCEnRevison IS NULL OR (@nCRCEnRevison IS NOT NULL AND  Pd.ClaCrc = @nCRCEnRevison))	
	AND  (@pnDpto IS NULL OR (@pnDpto IS NOT NULL AND F.ClaFurmanDepartment = @pnDpto))
	--AND Pd.ClaArticulo	= 270806
	ORDER BY Pd.ClaCrc

	--UPDATE #tmpResultSet SET TOTFMG = FURCOM + FURPACK + FURGNA + FURINT
	--FMT.FURMAT + FLB.FURLAB + FOH.FUROH) + FPK.FURPACK --+ (@nFURGNA * (FMT.FURMAT + FLB.FURLAB + FOH.FUROH)) --+ (@nFURINT * (FMT.FURMAT + FLB.FURLAB + FOH.FUROH))
	/*
	SELECT		
		R.CRC
		,R.CRCN
		,R.DEPT
		,R.DEPTN
		,PRODQTY = SUM(R.PRODQTY)
		,ProcTeoricoScrap = ISNULL(C.nValor2, 0)
	FROM #tmpResultSet R
	LEFT JOIN [OPESch].[OpeCatFurmanConfiguracion] C ON R.CRC = C.nValor1
	GROUP BY R.CRC
		,R.CRCN
		,R.DEPT
		,R.DEPTN
		,C.nValor2
	ORDER BY DEPT
	*/

	SELECT
		 V.ClaClienteUnico	
		,V.ClaClienteCuenta
		,V.ClaUbicacion	
		,V.IdFacturaAlfanumerico	
		,V.ImpFactura	
		,V.FechaFactura	
		,V.ClaArticulo
		,Art.ClaveArticulo
		,Art.NomArticulo
		,V.CantidadSurtida	
		,V.KilosSurtidos
	INTO #tmpVtaTraFacturasScrap
	FROM DEAOFINET05.VENTAS.VtaSch.VtaTraFacturasScrap V
	INNER JOIN OpeSch.ArtCatArticuloVw Art ON V.ClaArticulo = Art.ClaArticulo AND Art.ClaTipoInventario = 1
	WHERE V.ClaClienteunico = 21188 
	AND V.ClaClienteCuenta = 827482
	AND V.ClaUbicacion = 65
	AND V.ClaArticulo = 551164
	AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(V.FechaFactura	) * 100 + MONTH(V.FechaFactura) >= @pnAnioMesInicio))
	AND  (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND  YEAR(V.FechaFactura) * 100  + MONTH(V.FechaFactura) <= @pnAnioMesFin))

	IF @pnEsDebug  = 1 SELECT * FROM #tmpVtaTraFacturasScrap

	SELECT
		IdFacturaAlfanumerico
		,ImporteTotalFactura = ImpFactura
		,KilosFactura = KilosSurtidos	
	INTO #tmpVtaFacturas
	FROM #tmpVtaTraFacturasScrap
	GROUP BY IdFacturaAlfanumerico, ImpFactura, KilosSurtidos, CantidadSurtida
	
	IF @pnEsDebug  = 1 SELECT * FROM #tmpVtaFacturas
	
	SELECT @nProductionScrapTotal = SUM(ProductionScrapKg) 
	FROM #tmpResultSet

	SELECT @nScrapRevenueTotal = SUM(ImporteTotalFactura)
	FROM #tmpVtaFacturas

	IF @pnEsDebug = 1 
	BEGIN
		SELECT * FROM #tmpResultSet
		
		SELECT nScrapRevenueTotal = @nScrapRevenueTotal, nProductionScrapTotal = @nProductionScrapTotal
	END

	UPDATE t1
	SET
		--t1.OTHDISU = ISNULL(t2SumImpCreditoMonCargo/NULLIF(t1.QTYU2,0),0)
		t1.SCRAPOFFSET = ISNULL((((1.00 * t1.ProductionScrapKg) / t2.SumProductionScrapKg) * (@nScrapRevenueTotal * - 1)) / NULLIF(ProductionScrapKg, 0), 0)
	FROM #tmpResultSet t1	
	OUTER APPLY (
		SELECT SumPRODQTY = SUM(PRODQTY), SumProductionScrapKg = SUM(ProductionScrapKg)
		FROM #tmpResultSet
	) t2	
/*
	SELECT
		PRODCODU
		,PRODCODU2
		,DESCRIP
		,CRC
		,CRCN
		,DEPT
		,DEPTN
		,CONNUMU
		,PRODQTY
		,ProcTeoricoScrap = ISNULL(C.nValor2, 0)
		,ProductionScrap = (ISNULL(C.nValor2, 0) / 100.00) * PRODQTY
	INTO #tmpResultSetScrapProducction
	FROM #tmpResultSet R
	LEFT JOIN [OPESch].[OpeCatFurmanConfiguracion] C ON R.CRC = C.nValor1
	GROUP BY 
		PRODCODU
		,PRODCODU2
		,DESCRIP
		,R.CRC
		,R.CRCN
		,R.DEPT
		,R.DEPTN
		,CONNUMU
		,PRODQTY
		,C.nValor2
	ORDER BY DEPT

	IF @pnEsDebug  = 1
		SELECT * FROM #tmpResultSetScrapProducction		
	
	IF @pnEsDebug  = 1 
		SELECT ProductionScrapTotal = SUM(ProductionScrap) FROM #tmpResultSetScrapProducction

	SELECT @nProductionScrapTotal = SUM(ProductionScrap)
	FROM #tmpResultSetScrapProducction

	SELECT ScrapOffsetTotal = @nScrapRevenueTotal / @nProductionScrapTotal

	--IF @pnEsDebug  = 1 
	SELECT 
		PRODCODU
		,PRODCODU2
		,DESCRIP
		,CRC
		,CRCN
		,DEPT
		,DEPTN
		,CONNUMU
		,PRODQTY
		,ProcTeoricoScrap
		,ProductionScrap
		,ProductionScrapTotal = @nProductionScrapTotal
		,ScrapRevenue = ((1.00 * ProductionScrap)/@nProductionScrapTotal ) * @nScrapRevenueTotal
		,ScrapRevenueTotal = @nScrapRevenueTotal
		,ScrapOffset = ISNULL((((1.00 * ProductionScrap)/@nProductionScrapTotal ) * @nScrapRevenueTotal) / NULLIF(ProductionScrap, 0),0)
	INTO #tmpResultSetScrapProducctionProc
	FROM #tmpResultSetScrapProducction

	IF @pnEsDebug  = 1 
		SELECT * FROM #tmpResultSetScrapProducctionProc
*/	
	SELECT
		PRODCODU
		,PRODCODU2
		,DESCRIP
		,CRC
		,CRCN
		,DEPT
		,DEPTN
		,CONNUMU
		,PRODQTY
		,FURMAT
		,FURMANYLD
		,SCRAPOFFSET
		,FURLAB
		,FUROH
		,FURCOM
		,FURPACK
		,FURGNA
		,FURINT
		,TOTFMG
	FROM #tmpResultSet
	

	DROP TABLE #tmpProdFurman
	DROP TABLE #tmpProdArticuloCrc
	DROP TABLE #tmpProdArticulo
	DROP TABLE #tmpProdCrc
	DROP TABLE #tmpProdFurmanPorGastos
	DROP TABLE #tmpGastosPropiosAsignados
	DROP TABLE #tmpFULAB
	DROP TABLE #tmpFUROH
	DROP TABLE #tmpFURPCK
	DROP TABLE #tmpGastoFurpack
	DROP TABLE #tmpGastosPropiosAsignadosPacking
	DROP TABLE #tmpProdFurmanPorGastosPacking
	DROP TABLE #tmpResultSet
	DROP TABLE #tmpVtaFacturas
	DROP TABLE #tmpVtaTraFacturasScrap
	
	/*
	SELECT 
		PRODCODU = Art.ClaveArticulo
		,PRODCODU2 = tP.ClaArticulo
		,DESCRIP = Art.NomArticulo
		,CRC = CRC.ClaCrc
		,CRCN = CRC.NomCRc
		,DEPT = CRC.ClaFurmanDepartment
		,DEPTN = CRC.NomFurmanDepartment
		,CONNUMU = ISNULL(connumWire.ConnumConGuiones, '')
		,PRODQTY = ISNULL(tP.ProdTonsArticuloBase* 1000, 0) * ISNULL(connumWire.PorcComposicion, 1.0)
		,FURMAT = ISNULL(fmat.FURMAT,0)
		,FURLAB = ISNULL(flab.FURLAB,0)
		,FUROH = ISNULL(foh.FUROH, 0)
		,FURPACK = ISNULL(fpk.FURPACK,0)
		,FURCOM = ISNULL(fmat.FURMAT,0) + ISNULL(flab.FURLAB,0) + ISNULL(foh.FUROH, 0) + ISNULL(fpk.FURPACK,0)
		,FURGNA = ISNULL(@nFURGNA, 0)
		,FURINT = ISNULL(@nFURINT, 0)
		,TOTFGM = ISNULL(fmat.FURMAT,0) + ISNULL(flab.FURLAB,0) + ISNULL(foh.FUROH, 0) + ISNULL(@nFURGNA, 0) + ISNULL(@nFURINT, 0) + ISNULL(fpk.FURPACK,0)
	INTO #tmpReporteFurmanProd
	FROM #tmpTonsProdPOR tP
		LEFT JOIN #tmpFURMAT fmat ON tP.ClaArticulo = fmat.ClaArticulo
		LEFT JOIN #tmpFURLAB flab ON tP.ClaArticulo = flab.ClaArticulo
		LEFT JOIN #tmpFUROH  foh  ON tP.ClaArticulo = foh.ClaArticulo
		LEFT JOIN #tmpFURPACK fpk ON tP.ClaArticulo = fpk.ClaArticulo
		LEFT JOIN [OPESch].[ArtCatArticuloVw] Art ON tp.ClaArticulo = Art.ClaArticulo 
													AND Art.ClaTipoInventario = 1
	
	OUTER APPLY(
		SELECT 
			Are.ConnumConGuiones AS ConnumConGuiones,
			SUM (Cmp.PorcComposicion/100.0) AS PorcComposicion
		FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
		INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Are.ClaArticulo = Cmp.ClaArticuloComp
		WHERE Cmp.ClaArticulo = tP.ClaArticulo
		GROUP BY Are.ConnumConGuiones		
	) as connumWire
	CROSS APPLY(
		SELECT 
			TOP 1 ClaArticulo, ClaCrc, NomCrc, ClaFurmanDepartment, NomFurmanDepartment
		FROM #ItemWithDepartments F
		WHERE F.ClaArticulo = tP.ClaArticulo
	) CRC
	
	ORDER BY tP.ClaArticulo
	*/
	
	SET NOCOUNT OFF
END
