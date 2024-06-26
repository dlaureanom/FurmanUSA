ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel]

 @pnAnioMesInicio		INT = 202301
,@pnAnioMesFin			INT = 202312
,@pnVendor				INT = 275
,@pnDepto				INT = 0
,@psIdioma				VARCHAR(15)='Spanish'
,@pnEsDebug				TINYINT = 0
,@pnEsPorPantallaReact  INT = 0
,@pnSoloAlamabreMx		INT = 0
AS
BEGIN

	DECLARE @nFactorLbsToKgs     DECIMAL(10,6) = 0.453592
	,@nKilosFacturadosOntario    DECIMAL(22,4) = 0
	,@nOnWarehouseExp		     DECIMAL(22,4) = 0
	,@nOnWarehouseFreightExp     DECIMAL(22,4) = 0
	,@nKilosEmbarcadosDePopToOnt DECIMAL(22,4) = 0
	,@nUSWAREHU_O			     DECIMAL(22,4) = 0
	,@nINLFPW_O				     DECIMAL(22,4) = 0

	CREATE TABLE #tmpProduccion	(
		 PRODCODU			VARCHAR(20)
		,FURCOM				NUMERIC(22,8)
		,FURGNA             NUMERIC(22,8)
		,FURINT             NUMERIC(22,8)
	)

	
	CREATE TABLE #ResultSet(
		ClaArticulo			    INT
		,NomArticulo		    VARCHAR(500)
		,IdFactura  		    INT
		,ClaveFactura           VARCHAR(50)
		,ConnumuAlambre 	    VARCHAR(250)	
		,ConnumuAlambron	    VARCHAR(250)
		,WireSource			    VARCHAR(50)
		,ClaveConsignado	    VARCHAR(50)	
		,NomConsignado		    VARCHAR(250)
		,FechaFactura		    DATETIME
		,FechaEmbarcado			DATETIME
		,FechaUltimoPago		DATETIME
		,CantTotalEmbarcada	    NUMERIC(22,4)
		,CantidadKilos		    NUMERIC(22,4)
		,UOM				    VARCHAR(20)
		,PrecioUnitarioBruto    NUMERIC(22,4)
		,PrecioUnitario		    NUMERIC(22,4)
		,QtyXGRSUPRU            NUMERIC(22,4)
		,BILLADJU			    NUMERIC(22,8)
		,OTHDIS1U			    NUMERIC(22,8)
		,REBATEU			    NUMERIC(22,8)	
		,DINLFTWU_MXN		    NUMERIC(22,8)
		,DINLFTWU_USD		    NUMERIC(22,8)
		,DWAREHU_MXN		    NUMERIC(22,8)	
		,DWAREHU_USD		    NUMERIC(22,8)	
		,DINLFTPU_MXN		    NUMERIC(22,8)
		,DINLFTPU_USD		    NUMERIC(22,8)
		,DBROKU_MXN			    NUMERIC(22,8)
		,DBROKU_USD    		    NUMERIC(22,8)
		,USBROKU			    NUMERIC(22,8)	
		,INLFPWU_L			    NUMERIC(22,8)
		,USWAREHU_L			    NUMERIC(22,8)
		,USWAREHU_O				NUMERIC(22,8)
		,INLFPW_O				NUMERIC(22,8)
		,ImporteFlete		    NUMERIC(22,8)
		,ImporteFleteAhorrado   NUMERIC(22,8)
		,CodigoPostal		    VARCHAR(20)
		,AcronimoEdo			VARCHAR(20)
		,Commision			    NUMERIC(22,8)
		,AgenteVta			    VARCHAR(200)
		,CREDITU				NUMERIC(22,8)
		,REPACKU				NUMERIC(22,8)
		,INDIRECTS			    NUMERIC(22,8)
		,FURMANU				NUMERIC(22,8)
		,USP					NUMERIC(22,8)
	)

	CREATE TABLE #MovAlmacen (	
		IdMovAlmacen INT
		,ClaLocalidad INT
		,NomLocalidad VARCHAR(200)
		,NomAlmacen VARCHAR(200)
		,ClaTipoMovAlmacen INT
		,NomTipoMovAlmacen VARCHAR(200)
		,NomEstatus VARCHAR(200)
		,AnioMes DATETIME
		,ClaArticuloCompra INT
		,NomArticuloCompra VARCHAR(200)
		,EntradaSalida INT
		,Cantidad NUMERIC(22,4)
		,TransactionAmount NUMERIC(22,4)
		,NomUnidad VARCHAR(100)
		,Comentario VARCHAR(250)
		,CuentaContable VARCHAR(250)
		,ClaveCategoria VARCHAR(100)
		,NomCategoria VARCHAR(200)
		,FechaAplicacion DATETIME
		,NumCel INT
		,NumMaquina VARCHAR(200)
	)
	DECLARE
	@nAnioInicio INT = 0
	,@nMesInicio INT = 0
	,@nDiaInicio INT = 0
	,@nAnioFin INT = 0
	,@nMesFin INT = 0
	,@nDiaFin INT = 0
	,@sFehaAnioMesInicio VARCHAR (100)
	,@sFehaAnioMesFin VARCHAR (100)
	,@nEsBisiestoAnioInicio BIT 
	,@nEsBisiestoAnioFin BIT 
	,@dFechaIni DATETIME
	,@dFechaFin DATETIME

	SELECT @sFehaAnioMesInicio = CAST((@pnAnioMesFin / 100) AS VARCHAR)+'-01-01'
	SELECT @sFehaAnioMesFin = CAST((@pnAnioMesFin / 100) AS VARCHAR)+'-01-01'

	SELECT @nEsBisiestoAnioInicio = MSWSch.MSWGetLeapYear(CAST(@sFehaAnioMesInicio AS datetime2))
	SELECT @nEsBisiestoAnioFin = MSWSch.MSWGetLeapYear(CAST(@sFehaAnioMesFin AS datetime2))

	SELECT @nAnioInicio = @pnAnioMesInicio / 100
		,@nAnioFin = @pnAnioMesFin / 100
		,@nMesInicio = @pnAnioMesInicio % 100
		,@nMesFin = @pnAnioMesFin % 100
		,@nDiaInicio = CASE WHEN @pnAnioMesInicio % 100 = 1 THEN 31
							WHEN @pnAnioMesInicio % 100 = 2 AND  @nEsBisiestoAnioInicio = 1 THEN 29
							WHEN @pnAnioMesInicio % 100 = 2 AND @nEsBisiestoAnioInicio = 0 THEN 28
							WHEN @pnAnioMesInicio % 100 = 3 THEN 31
							WHEN @pnAnioMesInicio % 100 = 4 THEN 30
							WHEN @pnAnioMesInicio % 100 = 5 THEN 31
							WHEN @pnAnioMesInicio % 100 = 6 THEN 30
							WHEN @pnAnioMesInicio % 100 = 7 THEN 31
							WHEN @pnAnioMesInicio % 100 = 8 THEN 31
							WHEN @pnAnioMesInicio % 100 = 9 THEN 30
							WHEN @pnAnioMesInicio % 100 = 10 THEN 31
							WHEN @pnAnioMesInicio % 100 = 11 THEN 30
							WHEN @pnAnioMesInicio % 100 = 12 THEN 31	
						END
		,@nDiaFin = CASE WHEN @pnAnioMesFin % 100 = 1 THEN 31
							WHEN @pnAnioMesFin % 100 = 2 AND @nEsBisiestoAnioFin = 1 THEN 29
							WHEN @pnAnioMesFin % 100 = 2 AND @nEsBisiestoAnioFin = 0 THEN 28
							WHEN @pnAnioMesFin % 100 = 3 THEN 31
							WHEN @pnAnioMesFin % 100 = 4 THEN 30
							WHEN @pnAnioMesFin % 100 = 5 THEN 31
							WHEN @pnAnioMesFin % 100 = 6 THEN 30
							WHEN @pnAnioMesFin % 100 = 7 THEN 31
							WHEN @pnAnioMesFin % 100 = 8 THEN 31
							WHEN @pnAnioMesFin % 100 = 9 THEN 30
							WHEN @pnAnioMesFin % 100 = 10 THEN 31
							WHEN @pnAnioMesFin % 100 = 11 THEN 30
							WHEN @pnAnioMesFin % 100 = 12 THEN 31
						END
	SELECT @dFechaIni = CAST(CAST(@nAnioInicio AS VARCHAR)+'-'+CAST(@nMesInicio AS VARCHAR)+'-'+CAST(@nDiaInicio AS VARCHAR) AS DATE),
		@dFechaFin = CAST(CAST(@nAnioFin AS VARCHAR)+'-'+CAST(@nMesFin AS VARCHAR)+'-'+CAST(@nDiaFin AS VARCHAR) AS DATE)
		
	--SELECT CAST(CAST(2023 AS VARCHAR)+'-'+CAST(1 AS VARCHAR)+'-'+CAST(2 AS VARCHAR) AS DATE)	   
	INSERT INTO #MovAlmacen
	exec MSWSch.MSW_CU503_Pag12_Grid_GrdMovAlmacen_Sel 
	@pnClaArticuloCompra5 = NULL
	,@pnIdMovimiento = NULL
	,@pdFechaIni = @dFechaIni
	,@pdFechaFin = @dFechaFin
	,@psComentario=''
	,@pnChkVerAplicados=1
	,@pnClaLocalidadOrig=20 --TRANSFER DE POPLAR to ONTARIO
	,@pnClaAlmacenOrig=20 --TRANSFER DE POPLAR to ONTARIO
	,@pnClaLocalidadDest=NULL
	,@pnClaAlmacenDest=NULL
	,@psNombrePcMod='FURMAN - USA'
	,@pnClaUsuarioMod=1
	,@psIdioma='English'
	,@pnClaTipoMovAlmacen=2 --Mov de Tipo Transfer
	,@psCategorias=''
	,@psIdMovAlmacen=''
	,@pnEsMuestraOnWaters=0

	IF @pnEsDebug = 1 SELECT  * FROM #MovAlmacen

	SELECT 
		Mv.ClaArticuloCompra
		,Mv.Cantidad
		,Mv.NomUnidad
		,CantidadKilos = SUM(Mv.Cantidad * (art.PesoTeoricoLbs * @nFactorLbsToKgs))
	INTO #MovAlmacenKilo
	FROM #MovAlmacen Mv
	INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON  art.ClaArticulo		  = Mv.ClaArticuloCompra 
																		AND art.ClaTipoInventario = 1
	GROUP BY Mv.ClaArticuloCompra
		,Mv.Cantidad
		,Mv.NomUnidad
	
	SELECT @nKilosEmbarcadosDePopToOnt = SUM(CantidadKilos) FROM #MovAlmacenKilo
	


	SELECT 	
			est.ClaLocalidad,
			est.AnioMes,
			est.ClaArticulo,
			est.IdFactura,			
			est.ClaveFactura,			
			SUM (est.Cantidad)		AS Cantidad,	
			SUM (est.Tons * 0.90718474)	* 1000 AS KilosTotales
	INTO #EstVta				
	FROM  MSWSch.MswEstVentaArticuloGpoEst est 
		LEFT JOIN MSWSch.MSWObtenerZonasOrgaSel(0,0) ZON ON (ZON.ClaOrganizacion = EST.ClaZona)				
		LEFT JOIN mswsch.MSWCatAgenteVw	GteVta			   ON GteVta.ClaAgenteVentas = est.ClaAgenteGerente
		LEFT JOIN mswsch.MSWCatClienteCuentaEmbarque cte   ON cte.ClaClienteCuentaEmbarque = est.ClaClienteCuentaEmbarque	 					
		INNER JOIN mswsch.MSWCatEstado			 	edo	   ON cte.ClaEstadoUnico  = edo.ClaEstadoUnico 
		INNER JOIN [MSWSch].[MSWCatRegionEstadistica] red  ON red.claRegionEstadistica = edo.ClaRegionEstadistica
	WHERE 
		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND Est.AnioMes >= @pnAnioMesInicio))
		AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND Est.AnioMes <= @pnAnioMesFin))	
		AND ISNULL(est.ClaGrupoEstadistico2,206) not in ( 206 ,-999 )  and est.AnioMes  /100 >= 2019
		AND	 ( 0=0 Or  ISNULL(est.ClaGrupoEstadistico1,101 ) = 0)		
		AND	 ( 272=0 Or  ISNULL(est.ClaSistemaOrigen,272 ) = 272)
	GROUP BY 
			est.ClaLocalidad
			,est.AnioMes
			,est.ClaArticulo
			,est.IdFactura
			,est.ClaveFactura			
	HAVING MAX(abs(ISNULL(Cantidad,0))) != 0


	SELECT 
		DISTINCT IdFactura
	INTO #EstVtaFac
	FROM #EstVta

	SELECT 
		@nKilosFacturadosOntario = SUM(ISNULL(KilosTotales,0))
	FROM #EstVta 
	WHERE CLaLocalidad = 20
	
	SELECT
		@nOnWarehouseExp = SUM(Cargos - Creditos)		
	FROM [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] FO
	INNER JOIN [MSWSch].[MswTraCuentaContable9] CC ON FO.IdCuentaContable = CC.IdCuentaContable
	LEFT JOIN [MSWSch].[MswTraSaldosEng9] S ON FO.IdCuentaContable = S.ClaCuenta
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND S.AnioMes >= @pnAnioMesInicio))
		AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND S.AnioMes <= @pnAnioMesFin))

	SELECT
		@nOnWarehouseFreightExp = SUM(Cargos - Creditos)		
	FROM [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] FO
	INNER JOIN [MSWSch].[MswTraCuentaContable9] CC ON FO.IdCuentaContable = CC.IdCuentaContable
	LEFT JOIN [MSWSch].[MswTraSaldosEng9] S ON FO.IdCuentaContable = S.ClaCuenta
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND S.AnioMes >= @pnAnioMesInicio))
		AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND S.AnioMes <= @pnAnioMesFin))
		AND FO.IdCuentaContable = 775 /* 6015-20 --> INBOUND MAT FREIGHT CAL */
		
	SELECT @nUSWAREHU_O = @nOnWarehouseExp / @nKilosFacturadosOntario
	SELECT @nINLFPW_O = @nOnWarehouseFreightExp / @nKilosEmbarcadosDePopToOnt

	IF @pnEsDebug = 1
		SELECT nKilosEmbarcadosDePopToOnt = @nKilosEmbarcadosDePopToOnt, nOnWarehouseFreightExp = @nOnWarehouseFreightExp


	--SELECT 
	--	IdFactura, USWAREHU_O = @nUSWAREHU_O
	--INTO #EstVtaOntario
	--FROM #EstVta 
	--WHERE CLaLocalidad = 20

			   		 	  
	IF @pnEsDebug = 1 SELECT '#EstVtaFac', * FROM #EstVtaFac WHERE IdFactura = 2401489
	
	SELECT 
		det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		IdOrdenCarga,
		det.PrecioUnitario,
		SUM(det.CantidadEmbarcada) AS CantidadEmbarcada
	INTO #Factura7Vw
	FROM MSWSch.MSwTraFActura7Vw					fac WITH(NOLOCK)
	INNER JOIN MSWSch.MSwTraFActuraDet7				det WITH(NOLOCK)	ON  det.IdFactura = fac.IdFactura AND det.ClaTipoCargo=1	
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(fac.FechaFactura)*100+MONTH(fac.FechaFactura) >= @pnAnioMesInicio))
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(fac.FechaFactura)*100+MONTH(fac.FechaFactura) <= @pnAnioMesFin))	
	--AND fac.IdFactura = 2402072
	AND fac.ClaTipoPedido IN(1,4,5)
	AND fac.ClaEstatusFactura = 1 --Amarramos que la factura este autorizada/Emitida

	GROUP BY det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		IdOrdenCarga,
		det.PrecioUnitario	
	HAVING SUM(ISNULL(det.Subtotal,0)) > 0

	IF @pnEsDebug = 1 
		SELECT '#Factura7Vw',* 
		FROm #Factura7Vw F
		INNER JOIN MSWSch.MSwTraFActura7Vw fac WITH(NOLOCK) ON F.IdFactura = fac.IdFactura
		WHERE fac.ClaLocalidad = 20


	SELECT 
		fac.ClaArticulo,
		ConnumuAlambre = ISNULL(con.ConnumuAlambre,''),
		ConnumuAlambron = ISNULL(con.ConnumuAlambron,''),
		oce.IdProduccionArticulo,
		con.ConnumuResuelto,
		WireSource = ISNULL(con.WireSource,'US'),
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.PrecioUnitario,
		CantTotalFactura = fac.CantidadEmbarcada,
		CantTotalEmbarcada = ISNULL(oce.Cantidad,fac.CantidadEmbarcada),
		CantidadKilos = CAST(0 AS NUMERIC(22,4))
	INTO #Furman
	FROM #Factura7Vw						   fac WITH(NOLOCK)
	LEFT JOIN MSWSch.MSWTraOrdenCArgaEscaneo4  oce WITH(NOLOCK) ON  fac.IdOrdenCarga = oce.IdOrdenCarga	
																	AND fac.IdPedido = oce.IdPedido
																	AND fac.ClaArticulo = oce.ClaArticulo																	
	LEFT JOIN MSWSch.MSWTraFurmanProduccion	pro WITH(NOLOCK)	ON pro.IdProdClavo = oce.IdProduccionArticulo
																	AND pro.ClaProveedorResuelto IS NOT NULL																	
	OUTER APPLY	(
		SELECT
			TOP 1 
			ConnumuAlambre = ISNULL(prox.ConnumuAlambre,'') 
			, ConnumuAlambron = ISNULL(prox.ConnumuAlambron,'')
			, WireSource = CASE WHEN prox.ClaProveedorResuelto = @pnVendor AND prox.ClaProvResueltoAlambre = @pnVendor AND prox.IdProdAlambre IS NOT NULL 
								THEN 'MX' 
								ELSE 'US' 
						   END
			,ConnumuResuelto = prox.ConnumuResuelto
		FROM MSWSch.MSWTraFurmanProduccion	prox WITH(NOLOCK)	
		WHERE prox.IdProdClavo = oce.IdProduccionArticulo
		AND	prox.ClaProveedorResuelto IS NOT NULL
		AND prox.ClaProveedorResuelto = @pnVendor
		AND	prox.ClaProvResueltoAlambre = @pnVendor
		AND prox.ClaProveedorResuelto = prox.ClaProvResueltoAlambre 
			
	) AS con	
	GROUP BY fac.ClaArticulo,
		con.ConnumuAlambre,
		con.ConnumuAlambron,
		oce.IdProduccionArticulo,
		con.ConnumuResuelto,
		con.WireSource,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.PrecioUnitario,
		fac.CantidadEmbarcada,
		oce.Cantidad

	UPDATE F
		SET F.CantidadKilos = CAST(CantTotalEmbarcada AS NUMERIC(22,4)) * (art.PesoTeoricoLbs * @nFactorLbsToKgs) 
	FROM #Furman F
	INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON  art.ClaArticulo		  = F.ClaArticulo 
																		AND art.ClaTipoInventario = 1	

	IF @pnEsDebug = 1 SELECT '#Furman', * FROM #Furman

	SELECT
		F.ClaArticulo	
		,F.ConnumuAlambre	
		,F.ConnumuAlambron		
		,F.ConnumuResuelto	
		,F.WireSource	
		,F.FechaFactura	
		,F.IdFactura	
		,F.ClaveFactura	
		,F.PrecioUnitario	
		,F.CantTotalFactura
		,CantTotalEmbarcada = SUM(F.CantTotalEmbarcada)
		,CantidadKilos		= SUM(F.CantidadKilos)
	INTO #FurmanGp
	FROM #Furman F
	GROUP BY F.ClaArticulo
		,F.ConnumuAlambre
		,F.ConnumuAlambron
		,F.ConnumuResuelto
		,F.WireSource
		,F.FechaFactura
		,F.IdFactura
		,F.ClaveFactura
		,F.PrecioUnitario
		,CantTotalFactura

		CREATE TABLE #tmpFurmanCosts(
			--TYPEID			INT
			TYPE			VARCHAR(50),
			QTYKG			NUMERIC(22,8),
			FURMAT			NUMERIC(22,8),
			FURMAT_COLLATED	NUMERIC(22,8),
			FURMANYLD		NUMERIC(22,8),
			SCRAPOFFSET		NUMERIC(22,8),
			FURLAB			NUMERIC(22,8),
			FURFOH			NUMERIC(22,8),
			FURCOM			NUMERIC(22,8),
			FURGNA			NUMERIC(22,8),
			FURINT			NUMERIC(22,8),
			FURPACK			NUMERIC(22,8),
			TOTFGM			NUMERIC(22,8),
		)

		CREATE TABLE #tmpFURCOM(
			SubType			INT,
			SubsubType		INT,
			TYPE			VARCHAR(50),
			QTYKG			NUMERIC(22,8),
			FURMAT			NUMERIC(22,8),
			FURMAT_COLLATED	NUMERIC(22,8),
			FURMANYLD		NUMERIC(22,8),
			SCRAPOFFSET		NUMERIC(22,8),
			FURLAB			NUMERIC(22,8),
			FURFOH			NUMERIC(22,8),
			FURCOM			NUMERIC(22,8),
			FURGNA			NUMERIC(22,8),
			FURINT			NUMERIC(22,8),
			FURPACK			NUMERIC(22,8),
			TOTFGM			NUMERIC(22,8),
		)

		INSERT INTO #tmpFurmanCosts
		EXEC [MSWSch].[MSW_CU423_Pag8_Grid_GridGenerico_Sel]
			@pnAnioMesInicio		= @pnAnioMesInicio
			,@pnAnioMesFin		= @pnAnioMesFin

		INSERT INTO #tmpFURCOM
		SELECT SubType = 202 ,SubSubType = 292 , * FROM #tmpFurmanCosts WHERE Type = 'Bulk'
		UNION
		SELECT SubType = 202 ,SubSubType = 293 , * FROM #tmpFurmanCosts WHERE Type = 'Bulk'
		UNION
		SELECT SubType = 202 ,SubSubType = 453 , * FROM #tmpFurmanCosts WHERE Type = 'Bulk'
		UNION
		SELECT SubType = 201 ,SubSubType = 289 , * FROM #tmpFurmanCosts WHERE Type = 'Wire Coil'
		UNION
		SELECT SubType = 201 ,SubSubType = 291 , * FROM #tmpFurmanCosts WHERE Type = 'Paper Tape'
		UNION
		SELECT SubType = 201 ,SubSubType = 290 , * FROM #tmpFurmanCosts WHERE Type = 'Plastic Strip'
		UNION
		SELECT SubType = 201 ,SubSubType = 454 , * FROM #tmpFurmanCosts WHERE Type = 'Wire Coil'

		IF @pnEsDebug = 1 SELECT '#tmpFURCOM',* FROm #tmpFURCOM

	
	IF @pnEsDebug = 1 SELECT '#FurmanGp', * FROM #FurmanGp

	IF @pnSoloAlamabreMx = 1 
	BEGIN
		INSERT INTO #ResultSet
		SELECT
			 V.ClaArticulo
			,art.NomArticulo
			,V.IdFactura
			,V.ClaveFactura
			,V.ConnumuAlambre
			,V.ConnumuAlambron
			,V.WireSource
			,fac.ClaveConsignado
			,fac.NomConsignado
			,V.FechaFactura
			,fac.FechaEmbarcado
			,fac.FechaUltimoPago
			,V.CantTotalEmbarcada
			,V.CantidadKilos
			,UOM = facD.NomUnidadPendiente
			,PrecioUnitarioBruto = facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)
			,facD.PrecioUnitario
			,QtyXGRSUPRU = CAST(0 AS numeric)--V.CantidadKilos * (facD.PrecioUnitario / (NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)))
			,BILLADJU = ISNULL(fac.ImporteTotalAjustado,0)
			,OTHDIS1U = ISNULL(fac.ImporteTotalDescuento,0)
			,REBATEU = ISNULL(afConcilia.afcRebates,0)
			,DINLFTWU_MXN = InFhtV.DINLFTWU_MXN
			,DINLFTWU_USD = InFhtV.DINLFTWU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
			,DWAREHU_MXN = InFhtV.DWAREHU_MXN
			,DWAREHU_USD = InFhtV.DWAREHU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
			,DINLFTPU_MXN = InFhtV.DINLFTPU_MXN
			,DINLFTPU_USD = InFhtV.DINLFTPU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
			,DBROKU_MXN = InFhtV.DBROKU_MXN
			,DBROKU_USD = InFhtV.DBROKU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
			,USBROKU = InFhtV.USBROKU
			,INLFPWU_L = InFhtV.INLFPWU_L
			,USWAREHU_L = InFhtV.USWAREHU_L
			,USWAREHU_O = ISNULL(@nUSWAREHU_O,0)
			,INLFPW_O = ISNULL(@nINLFPW_O,0)
			,ImporteFlete = ISNULL(fac.ImpFleteSCargoCliente,0)
			,ImporteFleteAhorrado = ISNULL(fac.ImpFleteCCargoCliente,0)
			,emb.CodigoPostal
			,AcronimoEdo = LTRIM(REPLACE(edo.AcronimoEdo,',',''))			
			,Commision = ISNULL((ISNULL(CommSAg.ComisionPorCaja,0) * V.CantTotalEmbarcada) / NULLIF(V.CantidadKilos,0),0)
			,AgenteVta = ISNULL(age.ClaveAgente,0) + ' - ' + ISNULL(age.NomAgente,'') + ' ' + ISNULL(age.ApellidoPaterno,'')
			,CREDITU = ISNULL((CONVERT(NUMERIC,DATEDIFF(day, fac.FechaEmbarcado, fac.FechaUltimoPago))/365.00) * (facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)) * (ISNULL(ConfigIntRate.InterestExpFactor,0)/100.00),0)
			--,REPACKU = RPCK.CostoPackingPorKilo / NULLIF((facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)),0)
			,REPACKU = 0
			,INDIRECTS = (Config.IndirectExpRate/100.00) * (facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0))
			,FURMANU = ISNULL(Fur.TOTFGM,0.0)
			,USP = 0					
		FROM #FurmanGp V
		INNER JOIN MSWSch.MSWTraFactura7Vw				fac WITH(NOLOCK)    ON V.IdFactura = fac.IdFactura
		INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON art.ClaArticulo		  = V.ClaArticulo 
																			AND art.ClaTipoInventario = 1
																			AND art.ClaGrupoEstadistico2 IN (202,201)
		INNER JOIN MSWSch.MSWCatAgente					age WITH(NOLOCK)	ON	age.ClaAgente = fac.ClaAgenteVta
		INNER JOIN MSWSch.MSwCatClienteCuentaEmbarque	emb WITH(NOLOCK)	ON  emb.ClaveClienteCuentaEmbarque = fac.ClaveConsignado
		INNER JOIN MSWSch.MswCatEstado					edo WITH(NOLOCK)	ON  edo.ClaEstadoUnico = fac.ClaEstadoConsignado
		CROSS APPLY(
			SELECT DISTINCT
				det.IdFactura
				,det.ClaArticulo
				,det.NomUnidadPendiente
				,det.PrecioUnitario				
			FROM MSWSch.MSwTraFActuraDet7				det WITH(NOLOCK)
			WHERE det.IdFactura = V.IdFactura
			AND det.ClaArticulo = V.ClaArticulo
			AND det.PrecioUnitario	> 0
		) facD
		OUTER APPLY(
			SELECT TOP 1
				DINLFTWU_MXN
				,DWAREHU_MXN
				,DINLFTPU_MXN
				,DBROKU_MXN
				,USBROKU
				,INLFPWU_L
				,USWAREHU_L	
			FROM [MSWSch].[MSWCfgFurmanInlandFreightRates] InFht WITH(NOLOCK)	
			WHERE Anio >= CAST(SUBSTRING(CAST(@pnAnioMesFin AS VARCHAR(10)),1,4) AS INT)
				AND Anio <= CAST(SUBSTRING(CAST(@pnAnioMesFin AS VARCHAR(10)),1,4) AS INT)
			ORDER BY Anio
		) InFhtV
		
		OUTER APPLY (
			SELECT 
				ParidadMonedaPeso
			FROm
			MSWSch.MSWAreCatParidadVw P
			WHERE CAST(P.FechaParidad AS DATE) = CAST(fac.FechaFactura AS DATE)
		) ExRt

		OUTER APPLY (
			SELECT Comm.ComisionPorCaja
			FROM MSWCfgFurmanComisionesPorCaja	Comm WITH(NOLOCK)	
			WHERE age.ClaUsuario = Comm.ClaUsuario 
				AND Comm.Anio= YEAR(fac.FechaFactura)
		) CommSAg

		OUTER APPLY (
			SELECT 
				val.PorcInteres
				,IndirectExpRate = val.PorcGastoVentaIndirecta
				,val.ComisionAgenteVenta
				,val.ComisionManagerVenta
				,val.ComisionVPVenta
				,val.ComisionAgIndVenta
			FROM MSWSch.MSWCfgFurmanVentaValoresUsar	val	WITH(NOLOCK)
			WHERE val.Anio = YEAR(fac.FechaFactura)
		)Config	
		OUTER APPLY (
			SELECT 
				InterestExpFactor = AVG(FInt.PorcInteres)
			FROM [MSWSch].[MSWCfgFurmanVentaInterestRate] FInt WITH(NOLOCK) 
			WHERE FInt.AnioMes >= @pnAnioMesInicio
			AND FInt.AnioMes <= @pnAnioMesFin
		)ConfigIntRate

		--OUTER APPLY(
		--	SELECT 
		--		est.ClaArticuloClavo		
		--		,CostoPackingPorKilo = SUM(est.CostoPackingPorKilo)
		--	FROM [MSWSch].[MSWCfgFurmanRepackingCost] est 
		--	WHERE
		--		est.ClaArticuloClavo = V.ClaArticulo
		--		AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(est.FechaVenta)*100+MONTH(est.FechaVenta) >= @pnAnioMesInicio))
		--		AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(est.FechaVenta)*100+MONTH(est.FechaVenta) <= @pnAnioMesFin))	
		--	GROUP BY ClaArticuloClavo					
		--)RPCK

		OUTER APPLY (	
			SELECT SubType, SubSubType, [Type], TOTFGM  
			FROM #tmpFURCOM Fc
			WHERE Art.ClaGrupoEstadistico3 = Fc.Subsubtype
		) as Fur

		OUTER APPLY (
			SELECT 			
				SUM(afc.ImporteAnticipoAplicar) AS afcRebates
				FROM MSWSch.MswRelAnticipoFacturaConcilia7 afc WITH(NOLOCK)
				INNER JOIN MSWSch.MSwTraFActura7 FNg  WITH(NOLOCK) ON afc.IdFacturaAnticipo = FNg.IdFactura
				INNER JOIN MSWSch.MSWTraPreOrdenVenta pov WITH(NOLOCK) ON pov.IdPreORdenVenta = FNg.IdPedido
				WHERE afc.IdFactura = V.IdFactura
				AND pov.ClaTipoPreOrdenVenta = 5 --Rebate & Other
		) AS afConcilia					
		
		UPDATE R
			SET R.QtyXGRSUPRU = ISNULL((R.CantidadKilos * R.PrecioUnitarioBruto)/(SumQtyXGRSUPRU.SumQtyGRSUPRUValue),0)
		FROM #ResultSet R 
		CROSS APPLY(
			SELECT 
				SumQtyGRSUPRUValue = ISNULL(SUM(F.CantidadKilos * F.PrecioUnitarioBruto),0)
			FROM #ResultSet F
			WHERE F.IdFactura = R.IdFactura
			
		) SumQtyXGRSUPRU		
		
		
		IF @pnEsDebug = 1 SELECT '#ResultSet',* FROM #ResultSet

		UPDATE R
			SET R.BILLADJU = ISNULL((R.BILLADJU  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
			,R.OTHDIS1U = ISNULL((R.OTHDIS1U  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
			,R.REBATEU = ISNULL((R.REBATEU  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
			,R.ImporteFlete = ISNULL((R.ImporteFlete  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
			,R.ImporteFleteAhorrado = ISNULL((R.ImporteFleteAhorrado  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
		FROM #ResultSet R 

		UPDATE R
			SET USP = R.PrecioUnitarioBruto + (R.BILLADJU - R.OTHDIS1U - R.REBATEU) - (R.DINLFTWU_USD + R.DWAREHU_USD + R.DINLFTPU_USD + R.DBROKU_USD) - R.USBROKU - R.INLFPWU_L - R.USWAREHU_L - R.USWAREHU_O - INLFPW_O - (R.ImporteFlete + R.ImporteFleteAhorrado) - R.Commision - R.FURMANU
		FROM #ResultSet R		
	END
	ELSE
	BEGIN
		INSERT INTO #ResultSet
		SELECT
			 V.ClaArticulo
			,art.NomArticulo
			,V.IdFactura
			,V.ClaveFactura
			,V.ConnumuAlambre
			,V.ConnumuAlambron
			,V.WireSource
			,fac.ClaveConsignado
			,fac.NomConsignado
			,V.FechaFactura
			,fac.FechaEmbarcado
			,fac.FechaUltimoPago
			,V.CantTotalEmbarcada
			,V.CantidadKilos
			,UOM = facD.NomUnidadPendiente
			,PrecioUnitarioBruto = facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)
			,facD.PrecioUnitario
			,QtyXGRSUPRU = CAST(0 AS numeric)--V.CantidadKilos * (facD.PrecioUnitario / (NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)))
			,BILLADJU = ISNULL(fac.ImporteTotalAjustado,0)
			,OTHDIS1U = ISNULL(fac.ImporteTotalDescuento,0)
			,REBATEU = CAST(ISNULL(afConcilia.afcRebates,0) as numeric)
			,DINLFTWU_MXN = InFhtV.DINLFTWU_MXN
			,DINLFTWU_USD = InFhtV.DINLFTWU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
			,DWAREHU_MXN = InFhtV.DWAREHU_MXN
			,DWAREHU_USD = InFhtV.DWAREHU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
			,DINLFTPU_MXN = InFhtV.DINLFTPU_MXN
			,DINLFTPU_USD = InFhtV.DINLFTPU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
			,DBROKU_MXN = InFhtV.DBROKU_MXN
			,DBROKU_USD = InFhtV.DBROKU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
			,USBROKU = InFhtV.USBROKU
			,INLFPWU_L = InFhtV.INLFPWU_L
			,USWAREHU_L = InFhtV.USWAREHU_L
			,USWAREHU_O = ISNULL(@nUSWAREHU_O,0)
			,INLFPW_O = ISNULL(@nINLFPW_O,0)
			,ImporteFlete = ISNULL(fac.ImpFleteSCargoCliente,0)
			,ImporteFleteAhorrado = ISNULL(fac.ImpFleteCCargoCliente,0)
			,emb.CodigoPostal
			,AcronimoEdo = LTRIM(REPLACE(edo.AcronimoEdo,',',''))			
			,Commision = ISNULL((ISNULL(CommSAg.ComisionPorCaja,0) * V.CantTotalEmbarcada) / NULLIF(V.CantidadKilos,0),0)
			,AgenteVta = ISNULL(age.ClaveAgente,0) + ' - ' + ISNULL(age.NomAgente,'') + ' ' + ISNULL(age.ApellidoPaterno,'')
			,CREDITU = ISNULL((CONVERT(NUMERIC,DATEDIFF(day, fac.FechaEmbarcado, fac.FechaUltimoPago))/365.00) * (facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)) * (ISNULL(ConfigIntRate.InterestExpFactor,0)/100.00),0)
			--,REPACKU = RPCK.CostoPackingPorKilo / NULLIF((facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)),0)
			,REPACKU = 0
			,INDIRECTS = (Config.IndirectExpRate/100.00) * (facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0))
			,FURMANU = ISNULL(Fur.TOTFGM,0.0)
			,USP = 0			
		FROM #FurmanGp V
		INNER JOIN MSWSch.MSwTraFActura7				fac WITH(NOLOCK)    ON V.IdFactura			= fac.IdFactura
		INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON art.ClaArticulo		= V.ClaArticulo 
		INNER JOIN MSWSch.MSWCatAgente					age WITH(NOLOCK)	ON	age.ClaAgente = fac.ClaAgenteVta
		INNER JOIN MSWSch.MSwCatClienteCuentaEmbarque	emb WITH(NOLOCK)	ON  emb.ClaveClienteCuentaEmbarque = fac.ClaveConsignado
		INNER JOIN MSWSch.MswCatEstado					edo WITH(NOLOCK)	ON  edo.ClaEstadoUnico = fac.ClaEstadoConsignado
		CROSS APPLY(
			SELECT DISTINCT
				det.IdFactura
				,det.ClaArticulo
				,det.NomUnidadPendiente
				,det.PrecioUnitario				
			FROM MSWSch.MSWTraFacturaDet7Vw				det WITH(NOLOCK)
			WHERE det.IdFactura = V.IdFactura
			AND det.ClaArticulo = V.ClaArticulo
			AND det.PrecioUnitario	> 0
		) facD		
		OUTER APPLY(
			SELECT TOP 1
				DINLFTWU_MXN
				,DWAREHU_MXN
				,DINLFTPU_MXN
				,DBROKU_MXN
				,USBROKU
				,INLFPWU_L
				,USWAREHU_L	
			FROM [MSWSch].[MSWCfgFurmanInlandFreightRates] InFht WITH(NOLOCK)	
			WHERE Anio >= CAST(SUBSTRING(CAST(@pnAnioMesFin AS VARCHAR(10)),1,4) AS INT)
				AND Anio <= CAST(SUBSTRING(CAST(@pnAnioMesFin AS VARCHAR(10)),1,4) AS INT)
			ORDER BY Anio
		) InFhtV
		
		OUTER APPLY (
			SELECT 
				ParidadMonedaPeso
			FROm
			MSWSch.MSWAreCatParidadVw P
			WHERE CAST(P.FechaParidad AS DATE) = CAST(fac.FechaFactura AS DATE)
		) ExRt

		OUTER APPLY (
			SELECT Comm.ComisionPorCaja
			FROM MSWCfgFurmanComisionesPorCaja	Comm WITH(NOLOCK)	
			WHERE age.ClaUsuario = Comm.ClaUsuario 
				AND Comm.Anio= YEAR(fac.FechaFactura)
		) CommSAg

		OUTER APPLY (
			SELECT 
				val.PorcInteres
				,IndirectExpRate = val.PorcGastoVentaIndirecta
				,val.ComisionAgenteVenta
				,val.ComisionManagerVenta
				,val.ComisionVPVenta
				,val.ComisionAgIndVenta
			FROM MSWSch.MSWCfgFurmanVentaValoresUsar	val	WITH(NOLOCK)
			WHERE val.Anio = YEAR(fac.FechaFactura)
		)Config	
		OUTER APPLY (
			SELECT 
				InterestExpFactor = AVG(FInt.PorcInteres)
			FROM [MSWSch].[MSWCfgFurmanVentaInterestRate] FInt WITH(NOLOCK) 
			WHERE FInt.AnioMes >= @pnAnioMesInicio
			AND FInt.AnioMes <= @pnAnioMesFin
		)ConfigIntRate

		--OUTER APPLY(
		--	SELECT 
		--		est.ClaArticuloClavo		
		--		,CostoPackingPorKilo = SUM(est.CostoPackingPorKilo)
		--	FROM [MSWSch].[MSWCfgFurmanRepackingCost] est 
		--	WHERE
		--		est.ClaArticuloClavo = V.ClaArticulo
		--		AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(est.FechaVenta)*100+MONTH(est.FechaVenta) >= @pnAnioMesInicio))
		--		AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(est.FechaVenta)*100+MONTH(est.FechaVenta) <= @pnAnioMesFin))				
		--)RPCK

		OUTER APPLY (
			SELECT SubType, SubSubType, [Type], TOTFGM  
			FROM #tmpFURCOM Fc
			WHERE Art.ClaGrupoEstadistico3 = Fc.Subsubtype
		) as Fur

		OUTER APPLY (
			SELECT 			
				SUM(afc.ImporteAnticipoAplicar) AS afcRebates
				FROM MSWSch.MswRelAnticipoFacturaConcilia7 afc WITH(NOLOCK)
				INNER JOIN MSWSch.MSwTraFActura7 FNg  WITH(NOLOCK) ON afc.IdFacturaAnticipo = FNg.IdFactura
				INNER JOIN MSWSch.MSWTraPreOrdenVenta pov WITH(NOLOCK) ON pov.IdPreORdenVenta = FNg.IdPedido
				WHERE afc.IdFactura = V.IdFactura
				AND pov.ClaTipoPreOrdenVenta = 5 --Rebate & Other
		) AS afConcilia	
		
		UPDATE R
			SET R.QtyXGRSUPRU = ISNULL((R.CantidadKilos * R.PrecioUnitarioBruto)/(SumQtyXGRSUPRU.SumQtyGRSUPRUValue),0)
		FROM #ResultSet R 
		CROSS APPLY(
			SELECT 
				SumQtyGRSUPRUValue = ISNULL(SUM(F.CantidadKilos * F.PrecioUnitarioBruto),0)
			FROM #ResultSet F
			WHERE F.IdFactura = R.IdFactura
			
		) SumQtyXGRSUPRU
		

		IF @pnEsDebug = 1 SELECT '#ResultSet',* FROM #ResultSet


		SELECT
			IdFactura
			,ClaArticulo
			,Cajas = SUM(CantTotalEmbarcada)
			,Kilos = SUM(CantidadKilos)		
		INTO #ResultSetUsaOnly
		FROM #ResultSet
		GROUP BY IdFactura
			,ClaArticulo

		SELECT 
			US.IdFactura
			,US.ClaArticulo
			,CajasUs   = US.Cajas
			,KilosUs   = US.Kilos
			,CajasVta  = Vta.Cantidad
			,KilosVta  = Vta.KilosTotales
			,DiffCajas = US.Cajas - Vta.Cantidad 
			,DiffKilos = US.Kilos - Vta.KilosTotales
		INTO #ResultSetUsaOnlyWithDiff
		FROM #ResultSetUsaOnly US
		INNER JOIN #EstVta Vta ON US.IdFactura = Vta.IdFactura
								AND US.ClaArticulo = Vta.ClaArticulo
		
		ORDER BY US.IdFactura
		
		IF @pnEsDebug = 1		
			SELECT '#ResultSetUsaOnlyWithDiff',* FROM #ResultSetUsaOnlyWithDiff
			WHERE DiffCajas <> 0
		
		
		UPDATE R
			SET R.CantTotalEmbarcada = Df.CajasVta
			,R.CantidadKilos = Df.CajasVta * (Cat.PesoTeoricoLbs * @nFactorLbsToKgs)
		FROM #ResultSet R
		INNER JOIN #ResultSetUsaOnlyWithDiff Df  ON R.IdFactura = Df.IdFactura
												AND R.ClaArticulo = Df.ClaArticulo
												AND R.WireSource = 'US'
		INNER JOIN MSWSch.MSWCatArticulo Cat WITH(NOLOCK) ON R.ClaArticulo = Cat.ClaArticulo
		WHERE Df.DiffCajas <> 0
		

		UPDATE R
			SET R.BILLADJU = ISNULL((R.BILLADJU  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
			,R.OTHDIS1U = ISNULL((R.OTHDIS1U  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
			,R.REBATEU = ISNULL((R.REBATEU  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
			,R.ImporteFlete = ISNULL((R.ImporteFlete  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
			,R.ImporteFleteAhorrado = ISNULL((R.ImporteFleteAhorrado  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
		FROM #ResultSet R



		UPDATE R
			SET USP = R.PrecioUnitarioBruto + (R.BILLADJU - R.OTHDIS1U - R.REBATEU) - (R.DINLFTWU_USD + R.DWAREHU_USD + R.DINLFTPU_USD + R.DBROKU_USD) - R.USBROKU - R.INLFPWU_L - R.USWAREHU_L - R.USWAREHU_O - INLFPW_O - (R.ImporteFlete + R.ImporteFleteAhorrado) - R.Commision - R.FURMANU
		FROM #ResultSet R	
	END

	IF @pnEsDebug = 2
	BEGIN
		SELECT
			V.ClaArticulo			
			,Cat.ClaveArticulo		
			,V.NomArticulo			
			,TipoClavo = ISNULL(GpoEst2.NomGpoEst +' - '+ GpoEst3.NomGpoEst, 'ND')
			,V.ConnumuAlambre 	
			,V.ConnumuAlambron	 
			,V.WireSource		
			,V.ClaveConsignado	
			,V.NomConsignado	
			,V.FechaFactura		
			,Est.IdFactura
			,V.ClaveFactura		
			,V.FechaEmbarcado	
			,V.FechaUltimoPago	
			,V.CantidadKilos	
			,V.CantTotalEmbarcada
			,V.UOM				
			,V.PrecioUnitarioBruto
			,V.PrecioUnitario				
		FROM #EstVtaFac Est 
		LEFT JOIN #ResultSet V ON V.IdFactura = Est.IdFactura
		INNER JOIN MSWSch.MSWCatArticulo Cat WITH(NOLOCK) ON V.ClaArticulo = Cat.ClaArticulo
		OUTER APPLY(
			SELECT TOP 1
				ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
				NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
			FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
			WHERE GpoEstCat.ClaGrupoEstadistico = Cat.ClaGrupoEstadistico2
			ORDER BY NivelActual ASC
		) AS GpoEst2
		OUTER APPLY(
			SELECT TOP 1
				ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
				NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
			FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
			WHERE GpoEstCat.ClaGrupoEstadistico = Cat.ClaGrupoEstadistico3
			ORDER BY NivelActual ASC
		) AS GpoEst3

		ORDER BY V.FechaFactura ASC
	END
	ELSE
	BEGIN
		
		IF @pnSoloAlamabreMx = 1 
			SELECT
				V.ClaArticulo			AS [PRODCODU;w=90;a=Center;t=clave;c=PRODCODU]
				,Cat.ClaveArticulo		AS [PRODCODU2;w=110;a=Left;t=clave;c=PRODCODU2]
				,V.NomArticulo			AS [PRODDESCU;w=350;a=Left;c=PRODDESCU]
				,ISNULL(GpoEst2.NomGpoEst +' - '+ GpoEst3.NomGpoEst, 'ND') AS [NAILTYPE;w=280;a=left;t=clave;c=NAILTYPE]
				,V.ConnumuAlambre 		AS [CONNUMU;w=150;a=Left;t=clave;c=Wire CONNUMU]
				,V.ConnumuAlambron	 	AS [CONNUMU2;w=150;a=Left;t=clave;c=Wire Rod CONNUMU]
				,V.WireSource			AS [WSOURCE;w=80;a=Center;t=clave;c=WSOURCE]
				,V.ClaveConsignado		AS [CUSCODU;w=100;a=Center;t=clave;c=CUSCODU]
				,V.NomConsignado		AS [CUSTNAMEU;w=350;a=Left;c=CUSTNAMEU]
				,V.FechaFactura			AS [SALINDTU;w=100;a=Center;t=clave;c=SALINDTU]
				,Est.IdFactura			AS [INVOICEID;w=100;a=Center;t=clave;c=INVOICEID]
				,V.ClaveFactura			AS [INVOICEU;w=100;a=Center;t=clave;c=INVOICEU]			
				,V.FechaEmbarcado		AS [SHIPDATU;w=100;a=Center;t=clave;c=SHIPDATU]
				,V.FechaUltimoPago		AS [PAYDATEU;w=100;a=Center;t=clave;c=PAYDATEU]			
				,V.CantidadKilos		AS [QTYU;w=80;a=Right;t=decimal;d=2;c=QTYU;s=Sum]
				,V.CantTotalEmbarcada	AS [QTY_AS_SOLDU;w=120;a=Right;t=decimal;d=2;c=QTY_AS_SOLDU;s=Sum]
				,V.UOM					AS [QTYUNIT_AS_SOLDU;w=120;a=Center;t=clave;c=QTYUNIT_AS_SOLDU]
				,V.PrecioUnitarioBruto	AS [GRSUPRU;w=80;a=Right;t=decimal;d=4;c=GRSUPRU]
				,V.PrecioUnitario		AS [GRSUPR_AS_SOLDU;w=120;a=Right;t=decimal;d=4;c=GRSUPR_AS_SOLDU]			
				,V.BILLADJU				AS [BILLADJU;w=100;a=Right;t=decimal;d=8;c=BILLADJU]			
				,V.OTHDIS1U				AS [OTHDIS1U;w=100;a=Right;t=decimal;d=8;c=OTHDIS1U & EARLPYU]
				,V.REBATEU				AS [REBATEU;w=100;a=Right;t=decimal;d=8;c=REBATEU]			
				,V.DINLFTWU_MXN			AS [DINLFTWU_MXN;w=100;a=Right;t=decimal;d=8;c=DINLFTWU_MXN]
				,V.DINLFTWU_USD			AS [DINLFTWU_USD;w=100;a=Right;t=decimal;d=8;c=DINLFTWU_USD]
				,V.DWAREHU_MXN			AS [DWAREHU_MXN;w=100;a=Right;t=decimal;d=8;c=DWAREHU_MXN]
				,V.DWAREHU_USD			AS [DWAREHU_USD;w=100;a=Right;t=decimal;d=8;c=DWAREHU_USD]
				,V.DINLFTPU_MXN			AS [DINLFTPU_MXN;w=100;a=Right;t=decimal;d=8;c=DINLFTPU_MXN]
				,V.DINLFTPU_USD			AS [DINLFTPU_USD;w=100;a=Right;t=decimal;d=8;c=DINLFTPU_USD]
				,V.DBROKU_MXN			AS [DBROKU_MXN;w=100;a=Right;t=decimal;d=8;c=DBROKU_MXN]
				,V.DBROKU_USD    		AS [DBROKU_USD;w=100;a=Right;t=decimal;d=8;c=DBROKU_USD]			
				,V.USBROKU				AS [USBROKU;w=100;a=Right;t=decimal;d=8;c=USBROKU]
				,V.INLFPWU_L			AS [INLFPWU_L;w=80;a=Right;t=decimal;d=8;c=INLFPWU_L]
				,V.USWAREHU_L			AS [USWAREHU_L;w=80;a=Right;t=decimal;d=8;c=USWAREHU_L]
				,V.USWAREHU_O			AS [USWAREHU_O;w=80;a=Right;t=decimal;d=8;c=USWAREHU_O]
				,V.INLFPW_O             AS [INLFPW_O;w=80;a=Right;t=decimal;d=8;c=INLFPW_O]				
				,V.ImporteFlete			AS [INLFCU;w=80;a=Right;t=decimal;d=8;c=INLFCU]
				,V.ImporteFleteAhorrado	AS [FGHTREV;w=80;a=Right;t=decimal;d=8;c=FGHTREV]
				,V.CodigoPostal			AS [DESTU;w=80;a=Center;t=clave;c=DESTU]
				,V.AcronimoEdo			AS [STATEU;w=60;a=Center;t=clave;c=STATEU]
				,V.Commision			AS [COMM;w=80;a=Right;t=decimal;d=8;c=COMM]
				,V.AgenteVta			AS [SELAGENU;w=300;a=Left;c=SELAGENU]
				,V.CREDITU				AS [CREDITU;w=80;a=Right;t=decimal;d=8;c=CREDITU]
				,ISNULL(RRatio.REPACKURatio,0)	AS [REPACKU;w=100;a=Right;t=decimal;d=8;c=REPACKU]
				,V.INDIRECTS			AS [INDIRECTS;w=100;a=Right;t=decimal;d=8;c=INDIRECTS]
				,V.FURMANU				AS [FURMANU;w=100;a=Right;t=decimal;d=8;c=FURMANU]
				,V.USP					AS [USP;w=100;a=Right;t=decimal;d=8;c=USP]
			FROM #EstVtaFac Est 
			LEFT JOIN #ResultSet V ON V.IdFactura = Est.IdFactura
			INNER JOIN MSWSch.MSWCatArticulo Cat WITH(NOLOCK) ON V.ClaArticulo = Cat.ClaArticulo
			OUTER APPLY(
				SELECT TOP 1
					ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
					NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
				FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
				WHERE GpoEstCat.ClaGrupoEstadistico = Cat.ClaGrupoEstadistico2
				ORDER BY NivelActual ASC
			) AS GpoEst2
			OUTER APPLY(
				SELECT TOP 1
					ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
					NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
				FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
				WHERE GpoEstCat.ClaGrupoEstadistico = Cat.ClaGrupoEstadistico3
				ORDER BY NivelActual ASC
			) AS GpoEst3
			OUTER APPLY (
					SELECT 
						TOP 1 REPACKURatio = REPACKURatio 
					FROM [MSWSch].[MSWCfgFurmanREPACKURatio] R
					WHERE R.Anio >= (@pnAnioMesInicio / 100)
					AND R.Anio <= (@pnAnioMesFin / 100)
					AND R.ClaGpoEst2 = GpoEst2.ClaGpoEst
					AND R.ClaGpoEst3 = GpoEst3.ClaGpoEst
				) RRatio				
			WHERE V.WireSource = 'MX'
			ORDER BY V.IdFactura ASC
		ELSE
			SELECT	
				PRODCODU = V.ClaArticulo					
				,PRODCODU2 = Cat.ClaveArticulo				
				,PRODDESCU = V.NomArticulo									
				,TYPE = CASE WHEN GpoEst3.ClaGpoEst = 292 OR GpoEst3.ClaGpoEst = 293 OR GpoEst3.ClaGpoEst = 453 THEN 'Bulk'
							WHEN GpoEst3.ClaGpoEst = 289 OR GpoEst3.ClaGpoEst = 454 THEN 'Wire Coil'
							WHEN GpoEst3.ClaGpoEst = 291 THEN 'Paper Tape'
							WHEN GpoEst3.ClaGpoEst = 290 THEN 'Plastic Strip'
							ELSE 'ND'
						END
				--,NAILTYPE = ISNULL(GpoEst3.NomGpoEst, 'ND') 	
				--,NAILTYPE2 = ISNULL(F.NomFamiliaIngles, 'ND')
				,CONNUMU = V.ConnumuAlambre 					
				,CONNUMU2 = V.ConnumuAlambron	 			
				,WSOURCE = V.WireSource
				,CUSCODU = V.ClaveConsignado					
				,CUSTNAMEU = V.NomConsignado					
				,SALINDTU = V.FechaFactura					
				,INVOICEID = Est.IdFactura					
				,INVOICEU = V.ClaveFactura					
				,SHIPDATU = V.FechaEmbarcado					
				,PAYDATEU = V.FechaUltimoPago				
				,QTYU = V.CantidadKilos						
				,QTY_AS_SOLDU = V.CantTotalEmbarcada			
				,QTYUNIT_AS_SOLDU = V.UOM					
				,GRSUPRU = V.PrecioUnitarioBruto				
				,GRSUPR_AS_SOLDU = V.PrecioUnitario			
				,BILLADJU = V.BILLADJU						
				,OTHDIS1U = V.OTHDIS1U						
				,REBATEU = V.REBATEU											
				,DINLFTWU_MXN = V.DINLFTWU_MXN				
				,DINLFTWU_USD = V.DINLFTWU_USD				
				,DWAREHU_MXN = V.DWAREHU_MXN					
				,DWAREHU_USD = V.DWAREHU_USD					
				,DINLFTPU_MXN = V.DINLFTPU_MXN				
				,DINLFTPU_USD = V.DINLFTPU_USD				
				,DBROKU_MXN = V.DBROKU_MXN					
				,DBROKU_USD = V.DBROKU_USD    				
				,USBROKU = V.USBROKU							
				,INLFPWU_L = V.INLFPWU_L						
				,USWAREHU_L = V.USWAREHU_L					
				,USWAREHU_O = V.USWAREHU_O					
				,INLFPW_O = V.INLFPW_O             			
				,INLFCU = V.ImporteFlete						
				,FGHTREV = V.ImporteFleteAhorrado			
				,DESTU = V.CodigoPostal						
				,STATEU = V.AcronimoEdo						
				,COMM = V.Commision							
				,SELAGENU = V.AgenteVta						
				,CREDITU = V.CREDITU							
				,REPACKU = ISNULL(RRatio.REPACKURatio,0)		
				,INDIRECTS = V.INDIRECTS						
				,FURMANU = V.FURMANU							
				,USP = V.USP									
					--V.ClaArticulo			AS [PRODCODU;w=90;a=Center;t=clave;c=PRODCODU]
					--,Cat.ClaveArticulo		AS [PRODCODU2;w=110;a=Left;t=clave;c=PRODCODU2]
					--,V.NomArticulo			AS [PRODDESCU;w=350;a=Left;c=PRODDESCU]
					--,GpoEst2.ClaGpoEst
					--,ISNULL(GpoEst2.NomGpoEst, 'ND') AS [TYPE;w=280;a=left;t=clave;c=TYPE]
					--,GpoEst3.ClaGpoEst
					--,ISNULL(GpoEst3.NomGpoEst, 'ND') AS [NAILTYPE;w=280;a=left;t=clave;c=NAILTYPE]
					--,ISNULL(F.NomFamiliaIngles, 'ND') AS [NAILTYPE2;w=280;a=left;t=clave;c=NAILTYPE2]
					--,V.ConnumuAlambre 		AS [CONNUMU;w=150;a=Left;t=clave;c=Wire CONNUMU]
					--,V.ConnumuAlambron	 	AS [CONNUMU2;w=150;a=Left;t=clave;c=Wire Rod CONNUMU]
					--,V.WireSource			AS [WSOURCE;w=80;a=Center;t=clave;c=WSOURCE]
					--,V.ClaveConsignado		AS [CUSCODU;w=100;a=Center;t=clave;c=CUSCODU]
					--,V.NomConsignado		AS [CUSTNAMEU;w=350;a=Left;c=CUSTNAMEU]
					--,V.FechaFactura			AS [SALINDTU;w=100;a=Center;t=clave;c=SALINDTU]
					--,Est.IdFactura			AS [INVOICEID;w=100;a=Center;t=clave;c=INVOICEID]
					--,V.ClaveFactura			AS [INVOICEU;w=100;a=Center;t=clave;c=INVOICEU]			
					--,V.FechaEmbarcado		AS [SHIPDATU;w=100;a=Center;t=clave;c=SHIPDATU]
					--,V.FechaUltimoPago		AS [PAYDATEU;w=100;a=Center;t=clave;c=PAYDATEU]			
					--,V.CantidadKilos		AS [QTYU;w=80;a=Right;t=decimal;d=2;c=QTYU;s=Sum]
					--,V.CantTotalEmbarcada	AS [QTY_AS_SOLDU;w=120;a=Right;t=decimal;d=2;c=QTY_AS_SOLDU;s=Sum]
					--,V.UOM					AS [QTYUNIT_AS_SOLDU;w=120;a=Center;t=clave;c=QTYUNIT_AS_SOLDU]
					--,V.PrecioUnitarioBruto	AS [GRSUPRU;w=80;a=Right;t=decimal;d=4;c=GRSUPRU]
					--,V.PrecioUnitario		AS [GRSUPR_AS_SOLDU;w=120;a=Right;t=decimal;d=4;c=GRSUPR_AS_SOLDU]			
					--,V.BILLADJU				AS [BILLADJU;w=100;a=Right;t=decimal;d=8;c=BILLADJU]			
					--,V.OTHDIS1U				AS [OTHDIS1U;w=100;a=Right;t=decimal;d=8;c=OTHDIS1U & EARLPYU]
					--,V.REBATEU				AS [REBATEU;w=100;a=Right;t=decimal;d=8;c=REBATEU]			
					--,V.DINLFTWU_MXN			AS [DINLFTWU_MXN;w=100;a=Right;t=decimal;d=8;c=DINLFTWU_MXN]
					--,V.DINLFTWU_USD			AS [DINLFTWU_USD;w=100;a=Right;t=decimal;d=8;c=DINLFTWU_USD]
					--,V.DWAREHU_MXN			AS [DWAREHU_MXN;w=100;a=Right;t=decimal;d=8;c=DWAREHU_MXN]
					--,V.DWAREHU_USD			AS [DWAREHU_USD;w=100;a=Right;t=decimal;d=8;c=DWAREHU_USD]
					--,V.DINLFTPU_MXN			AS [DINLFTPU_MXN;w=100;a=Right;t=decimal;d=8;c=DINLFTPU_MXN]
					--,V.DINLFTPU_USD			AS [DINLFTPU_USD;w=100;a=Right;t=decimal;d=8;c=DINLFTPU_USD]
					--,V.DBROKU_MXN			AS [DBROKU_MXN;w=100;a=Right;t=decimal;d=8;c=DBROKU_MXN]
					--,V.DBROKU_USD    		AS [DBROKU_USD;w=100;a=Right;t=decimal;d=8;c=DBROKU_USD]			
					--,V.USBROKU				AS [USBROKU;w=100;a=Right;t=decimal;d=8;c=USBROKU]
					--,V.INLFPWU_L			AS [INLFPWU_L;w=80;a=Right;t=decimal;d=8;c=INLFPWU_L]
					--,V.USWAREHU_L			AS [USWAREHU_L;w=80;a=Right;t=decimal;d=8;c=USWAREHU_L]
					--,V.USWAREHU_O			AS [USWAREHU_O;w=80;a=Right;t=decimal;d=8;c=USWAREHU_O]
					--,V.INLFPW_O             AS [INLFPW_O;w=80;a=Right;t=decimal;d=8;c=INLFPW_O]
					--,V.ImporteFlete			AS [INLFCU;w=80;a=Right;t=decimal;d=8;c=INLFCU]
					--,V.ImporteFleteAhorrado	AS [FGHTREV;w=80;a=Right;t=decimal;d=8;c=FGHTREV]
					--,V.CodigoPostal			AS [DESTU;w=80;a=Center;t=clave;c=DESTU]
					--,V.AcronimoEdo			AS [STATEU;w=60;a=Center;t=clave;c=STATEU]
					--,V.Commision			AS [COMM;w=80;a=Right;t=decimal;d=8;c=COMM]
					--,V.AgenteVta			AS [SELAGENU;w=300;a=Left;c=SELAGENU]
					--,V.CREDITU				AS [CREDITU;w=80;a=Right;t=decimal;d=8;c=CREDITU]
					--,ISNULL(RRatio.REPACKURatio,0)	AS [REPACKU;w=100;a=Right;t=decimal;d=8;c=REPACKU]
					--,V.INDIRECTS			AS [INDIRECTS;w=100;a=Right;t=decimal;d=8;c=INDIRECTS]
					--,V.FURMANU				AS [FURMANU;w=100;a=Right;t=decimal;d=8;c=FURMANU]
					--,V.USP					AS [USP;w=100;a=Right;t=decimal;d=8;c=USP]
				FROM #EstVtaFac Est 
				LEFT JOIN #ResultSet V ON V.IdFactura = Est.IdFactura
				INNER JOIN MSWSch.MSWCatArticulo Cat WITH(NOLOCK) ON V.ClaArticulo = Cat.ClaArticulo
				LEFT JOIN MSWSch.MSWCatFamilia F WITH(NOLOCK) ON Cat.ClaFamilia = F.ClaFamilia
				OUTER APPLY(
					SELECT TOP 1
						ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
						NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
					FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
					WHERE GpoEstCat.ClaGrupoEstadistico = Cat.ClaGrupoEstadistico2
					ORDER BY NivelActual ASC
				) AS GpoEst2
				OUTER APPLY(
					SELECT TOP 1
						ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
						NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
					FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
					WHERE GpoEstCat.ClaGrupoEstadistico = Cat.ClaGrupoEstadistico3
					ORDER BY NivelActual ASC
				) AS GpoEst3				
				OUTER APPLY (
					SELECT 
						TOP 1 REPACKURatio = REPACKURatio 
					FROM [MSWSch].[MSWCfgFurmanREPACKURatio] R
					WHERE R.Anio >= (@pnAnioMesInicio / 100)
					AND R.Anio <= (@pnAnioMesFin / 100)
					AND R.ClaGpoEst2 = GpoEst2.ClaGpoEst
					AND R.ClaGpoEst3 = GpoEst3.ClaGpoEst
				) RRatio
				WHERE GpoEst2.ClaGpoEst  IN (201,202)
				ORDER BY V.IdFactura
			
	END

	DROP TABLE #MovAlmacen
	DROP TABLE #Factura7Vw
	DROP TABLE #Furman
	DROP TABLE #FurmanGp
	DROP TABLE #EstVta
	DROP TABLE #EstVtaFac
	DROP TABLE #ResultSetUsaOnly
	DROP TABLE #ResultSetUsaOnlyWithDiff
END
