 --NUEVO FURMAN
ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel]
--ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel_DFSS]

 @pnAnioMesInicio		INT = 202301
,@pnAnioMesFin			INT = 202312
,@pnVendor				INT = 275
,@pnDepto				INT = 0
,@psIdioma				VARCHAR(15)='Spanish'
,@pnEsDebug				TINYINT = 0
,@pnEsPorPantallaReact  INT = 0
AS
BEGIN

	DECLARE @nFactorLbsToKgs DECIMAL(10,6) = 0.453592

	CREATE TABLE #tmpProduccion	(
		 PRODCODU			VARCHAR(20)
		,FURCOM				NUMERIC(22,8)
		,FURGNA             NUMERIC(22,8)
		,FURINT             NUMERIC(22,8)
	)

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
	AND fac.IdFactura IN (1501775) --1501765)--,1501764
	--2401438 --2396834--2396680 
	/*2390174 | 2391437 | */
	AND fac.ClaTipoPedido = 1 
	AND ISNULL(fac.IdOrdenCarga,0) != 0
	AND fac.ClaEstatusFactura = 1 --Amarramos que la factura este autorizada/Emitida
	GROUP BY det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		IdOrdenCarga,
		det.PrecioUnitario	
	HAVING SUM(ISNULL(det.Subtotal,0)) > 0

	IF @pnEsDebug = 1 SELECT '#Factura7Vw',* FROm #Factura7Vw

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
		--CantTotalEmbarcada = SUM(ISNULL(oce.Cantidad,0)),
		CantTotalEmbarcada = ISNULL(oce.Cantidad,0),
		CantidadKilos = CAST(0 AS NUMERIC(22,4))
	INTO #Furman
	FROM #Factura7Vw						   fac WITH(NOLOCK)
	LEFT JOIN MSWSch.MSWTraOrdenCArgaEscaneo4  oce WITH(NOLOCK) ON  fac.IdOrdenCarga = oce.IdOrdenCarga	
																	AND fac.IdPedido = oce.IdPedido
																	AND fac.ClaArticulo = oce.ClaArticulo																	
	LEFT JOIN MSWSch.MSWTraFurmanProduccion	pro WITH(NOLOCK)	ON pro.IdProdClavo = oce.IdProduccionArticulo
	OUTER APPLY	(
		SELECT
			TOP 1 
			ConnumuAlambre = ISNULL(prox.ConnumuAlambre,'') 
			, ConnumuAlambron = ISNULL(prox.ConnumuAlambron,'')
			, WireSource = CASE WHEN prox.ClaProveedorResuelto = @pnVendor AND prox.ClaProvResueltoAlambre = @pnVendor AND prox.ConnumuAlambre IS NOT NULL 
								THEN 'MX' 
								ELSE 'US' 
						   END
			,ConnumuResuelto = prox.ConnumuResuelto
		FROM MSWSch.MSWTraFurmanProduccion	prox WITH(NOLOCK)	
		WHERE prox.IdProdClavo = oce.IdProduccionArticulo
		--AND prox.ClaArticuloClavo = oce.ClaArticulo
		--AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(prox.FechaProdClavo)*100+MONTH(prox.FechaProdClavo) >= @pnAnioMesInicio))
		--AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(prox.FechaProdClavo)*100+MONTH(prox.FechaProdClavo) <= @pnAnioMesFin))		
		--AND	prox.ClaProveedorResuelto IS NOT NULL
		--AND prox.ClaProveedorResuelto = @pnClaProveedor
		--AND	prox.ClaProvResueltoAlambre = @pnClaProveedor
		--AND prov.ClaProvResueltoAlambron = @pnVendor			
			
	) AS con	
	WHERE oce.Cantidad > 0
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
	/*
	UPDATE F			
		SET F.CantidadKilos = CASE WHEN F.CantTotalEmbarcada > 0 
								THEN F.CantTotalEmbarcada * (art.PesoTeoricoLbs * @nFactorLbsToKgs)
								ELSE F.CantTotalFactura * (art.PesoTeoricoLbs * @nFactorLbsToKgs)
							  END
	FROM #Furman F
	INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON  art.ClaArticulo		  = F.ClaArticulo 
																		AND art.ClaTipoInventario = 1	
	*/
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

	
	IF @pnEsDebug = 1 SELECT '#FurmanGp', * FROM #FurmanGp

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
			--,V.CantTotalFactura
			,V.CantTotalEmbarcada
			,V.CantidadKilos
			,UOM = facD.NomUnidadPendiente
			,PrecioUnitarioBruto = facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)
			,facD.PrecioUnitario
			,QtyXGRSUPRU = V.CantidadKilos * (facD.PrecioUnitario / (NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)))
			,BILLADJU = ISNULL(fac.ImporteTotalAjustado,0)
			,OTHDIS1U = ISNULL(fac.ImporteTotalDescuento,0) / NULLIF(V.CantidadKilos,0)
			,REBATEU = ISNULL(afConcilia.afcRebates,0) / NULLIF(V.CantidadKilos,0)
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
			,ImporteFlete = ISNULL(fac.ImpFleteSCargoCliente,0)/NULLIF(V.CantidadKilos,0)
			,ImporteFleteAhorrado = ISNULL(fac.ImpFleteCCargoCliente,0)/NULLIF(V.CantidadKilos,0)
			,emb.CodigoPostal
			,AcronimoEdo = LTRIM(REPLACE(edo.AcronimoEdo,',',''))			
			,Commision = ISNULL((ISNULL(CommSAg.ComisionPorCaja,0) * V.CantTotalEmbarcada) / NULLIF(V.CantidadKilos,0),0)
			,AgenteVta = ISNULL(age.ClaveAgente,0) + ' - ' + ISNULL(age.NomAgente,'') + ' ' + ISNULL(age.ApellidoPaterno,'')
			,CREDITU = ISNULL((CONVERT(NUMERIC,DATEDIFF(day, fac.FechaEmbarcado, fac.FechaUltimoPago))/365) * (facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)) * (Convert(NUMERIC,ISNULL(ConfigIntRate.PorcInteres,0))/100),0)
			,REPACKU = RPCK.CostoPackingPorKilo / NULLIF((facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0)),0)
			,INDIRECTS = (Config.PorcGastoVentaIndirecta/100) * (facD.PrecioUnitario / NULLIF((art.PesoTeoricoLbs*@nFactorLbsToKgs),0))
			,FURMANU = ISNULL(Fur.FURCOM+Fur.FURGNA+Fur.FURINT,0)
			,USP = 0			
		INTO #ResultSet																			                                                
		FROM #FurmanGp V
		INNER JOIN MSWSch.MSwTraFActura7				fac WITH(NOLOCK)    ON V.IdFactura = fac.IdFactura
		INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON art.ClaArticulo		  = V.ClaArticulo 
																			--AND art.ClaTipoInventario = 1
																			--AND art.ClaGrupoEstadistico2 IN (202,201)
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
		) facD
		OUTER APPLY(
			SELECT 
				Est.ClaArticulo	 
				,Est.IdFactura		 
				,Est.ConnumuArticulo
			FROM [MSWSch].[MSWEstVentasFurman]		Est WITH(NOLOCK)	WHERE  V.ClaArticulo	  = Est.ClaArticulo
																			AND	V.IdFactura		  = Est.IdFactura
																			AND V.ConnumuResuelto = Est.ConnumuArticulo
																		
		) EstV
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
				,val.PorcGastoVentaIndirecta
				,val.ComisionAgenteVenta
				,val.ComisionManagerVenta
				,val.ComisionVPVenta
				,val.ComisionAgIndVenta
			FROM MSWSch.MSWCfgFurmanVentaValoresUsar	val	WITH(NOLOCK)
			WHERE val.Anio = YEAR(fac.FechaFactura)
		)Config	
		OUTER APPLY (
			SELECT 
				PorcInteres = AVG(FInt.PorcInteres)
			FROM [MSWSch].[MSWCfgFurmanVentaInterestRate] FInt WITH(NOLOCK) 
			WHERE FInt.AnioMes >= @pnAnioMesInicio
			AND FInt.AnioMes <= @pnAnioMesFin
		)ConfigIntRate

		OUTER APPLY(
			SELECT 
				est.ClaArticuloClavo		
				,CostoPackingPorKilo = SUM(est.CostoPackingPorKilo)
			FROM [MSWSch].[MSWCfgFurmanRepackingCost] est 
			WHERE
				est.ClaArticuloClavo = V.ClaArticulo
				AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(est.FechaVenta)*100+MONTH(est.FechaVenta) >= @pnAnioMesInicio))
				AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(est.FechaVenta)*100+MONTH(est.FechaVenta) <= @pnAnioMesFin))	
			GROUP BY ClaArticuloClavo					
		)RPCK

		OUTER APPLY (
			SELECT TOP 1
				ClaArticulo
				,FURCOM
				,FURGNA
				,FURINT
			FROM [MSWSch].[MSWEstFURCOMFurman]
			WHERE ClaArticulo = V.ClaArticulo
			AND AnioMes >= @pnAnioMesInicio
			AND AnioMes <= @pnAnioMesFin
			ORDER BY AnioMes DESC
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
		
		/*
		UPDATE R
			SET R.QtyXGRSUPRU = ISNULL((R.CantidadKilos * R.PrecioUnitarioBruto)/(SumQtyXGRSUPRU.SumQtyGRSUPRUValue),0)
		FROM #ResultSet R 
		CROSS APPLY(
			SELECT 
				SumQtyGRSUPRUValue = ISNULL(SUM(F.CantidadKilos * F.PrecioUnitarioBruto),0)
			FROM #ResultSet F
			WHERE F.IdFactura = R.IdFactura
			
		) SumQtyXGRSUPRU
		*/	
		IF @pnEsDebug = 1 SELECT '#ResultSet',* FROM #ResultSet

		UPDATE R
			SET R.BILLADJU = 0--ISNULL((R.BILLADJU  *  R.QtyXGRSUPRU) / NULLIF(ISNULL(R.CantidadKilos,0),0),0)
		FROM #ResultSet R 

		UPDATE R
			SET USP = 0 --PrecioUnitarioBruto + (BILLADJU - OTHDIS1U - REBATEU) - (DINLFTWU_USD + DWAREHU_USD + DINLFTPU_USD + DBROKU_USD) - USBROKU - INLFPWU_L - USWAREHU_L - ImporteFlete + ImporteFleteAhorrado - Commision
		FROM #ResultSet R 		

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
			,V.IdFactura			AS [INVOICEID;w=100;a=Center;t=clave;c=INVOICEID]
			,V.ClaveFactura			AS [INVOICEU;w=100;a=Center;t=clave;c=INVOICEU]			
			,V.FechaEmbarcado		AS [SHIPDATU;w=100;a=Center;t=clave;c=SHIPDATU]
			,V.FechaUltimoPago		AS [PAYDATEU;w=100;a=Center;t=clave;c=PAYDATEU]			
			,V.CantidadKilos		AS [QTYU;w=80;a=Right;t=decimal;d=4;c=QTYU;s=Sum]
			,V.CantTotalEmbarcada	AS [QTY_AS_SOLDU;w=120;a=Right;t=decimal;d=4;c=QTY_AS_SOLDU;s=Sum]
			,V.UOM					AS [QTYUNIT_AS_SOLDU;w=120;a=Center;t=clave;c=QTYUNIT_AS_SOLDU]
			,V.PrecioUnitarioBruto	AS [GRSUPRU;w=80;a=Right;t=decimal;d=4;c=GRSUPRU]
			,V.PrecioUnitario		AS [GRSUPR_AS_SOLDU;w=120;a=Right;t=decimal;d=4;c=GRSUPR_AS_SOLDU]			
			,V.BILLADJU				AS [BILLADJU;w=100;a=Right;t=decimal;d=4;c=BILLADJU]			
			,V.OTHDIS1U				AS [OTHDIS1U;w=100;a=Right;t=decimal;d=4;c=OTHDIS1U & EARLPYU]
			,V.REBATEU				AS [REBATEU;w=100;a=Right;t=decimal;d=4;c=REBATEU]			
			,V.DINLFTWU_MXN			AS [DINLFTWU_MXN;w=100;a=Right;t=decimal;d=4;c=DINLFTWU_MXN]
			,V.DINLFTWU_USD			AS [DINLFTWU_USD;w=100;a=Right;t=decimal;d=4;c=DINLFTWU_USD]
			,V.DWAREHU_MXN			AS [DWAREHU_MXN;w=100;a=Right;t=decimal;d=4;c=DWAREHU_MXN]
			,V.DWAREHU_USD			AS [DWAREHU_USD;w=100;a=Right;t=decimal;d=4;c=DWAREHU_USD]
			,V.DINLFTPU_MXN			AS [DINLFTPU_MXN;w=100;a=Right;t=decimal;d=4;c=DINLFTPU_MXN]
			,V.DINLFTPU_USD			AS [DINLFTPU_USD;w=100;a=Right;t=decimal;d=4;c=DINLFTPU_USD]
			,V.DBROKU_MXN			AS [DBROKU_MXN;w=100;a=Right;t=decimal;d=4;c=DBROKU_MXN]
			,V.DBROKU_USD    		AS [DBROKU_USD;w=100;a=Right;t=decimal;d=4;c=DBROKU_USD]			
			,V.USBROKU				AS [USBROKU;w=100;a=Right;t=decimal;d=4;c=USBROKU]
			,V.INLFPWU_L			AS [INLFPWU_L;w=80;a=Right;t=decimal;d=4;c=INLFPWU_L]
			,V.USWAREHU_L			AS [USWAREHU_L;w=80;a=Right;t=decimal;d=4;c=USWAREHU_L]
			,V.ImporteFlete			AS [INLFCU;w=80;a=Right;t=decimal;d=4;c=INLFCU]
			,V.ImporteFleteAhorrado	AS [FGHTREV;w=80;a=Right;t=decimal;d=4;c=FGHTREV]
			,V.CodigoPostal			AS [DESTU;w=80;a=Center;t=clave;c=DESTU]
			,V.AcronimoEdo			AS [STATEU;w=60;a=Center;t=clave;c=STATEU]
			,V.Commision			AS [COMM;w=80;a=Right;t=decimal;d=4;c=COMM]
			,V.AgenteVta			AS [SELAGENU;w=300;a=Left;c=SELAGENU]
			,V.CREDITU				AS [CREDITU;w=80;a=Right;t=decimal;d=4;c=CREDITU]
			,V.REPACKU				AS [REPACKU;w=100;a=Right;t=decimal;d=4;c=REPACKU]
			,V.INDIRECTS			AS [INDIRECTS;w=100;a=Right;t=decimal;d=4;c=INDIRECTS]
			,V.FURMANU				AS [FURMANU;w=100;a=Right;t=decimal;d=4;c=FURMANU]
			,V.USP					AS [USP;w=100;a=Right;t=decimal;d=4;c=USP]
		FROM #ResultSet V
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

	DROP TABLE #Factura7Vw
	DROP TABLE #Furman
	DROP TABLE #FurmanGp
END
