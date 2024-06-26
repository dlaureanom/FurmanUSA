USE [MCSW_ERP]
GO
/****** Object:  StoredProcedure [MSWSch].[MSW_CU99_Pag50_GetFreightMXAndUS_sel]    Script Date: 4/12/2024 8:24:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

ALTER PROCEDURE [MSWSch].[MSW_CU99_Pag50_GetFreightMXAndUS_sel]
	@pnAnioMes			INT, 
	@pnEsAgruparMensual	VARCHAR(1) ='' 
AS
BEGIN
	SET NOCOUNT ON 
	
	/*
		
	select MillasViaje, PesoCubicado = NULL, PesoReal = Tons, ClaTransporte, NomTransporte = NomTransporte, ClaTransportista, NomTransportista = NomTranportista 
	from MSWSch.MSWSSTViajesTruckingDivisionMCN

	select NumViaje		= IdViaje,
		   PesoCubicado = NULL,
		   MillasViaje  = Kms*0.621371
		   ClaTransporte= null,
		   NomTransporte= NULL,
		   ClaTransportista=ClaFerroviaria,
		   NomTransportista = NombreCortoFerroviaria,

	from MSWSch.MSWSSTFFCCViajesExportacion
	select top 10 
			NumViaje	= NumViaje,
		   PesoCubicado = TonsCubicadas,
		   MillasViaje  = MillasRecorridas,
		   ClaTransporte= ClaTransporte,
		   NomTransporte= NomTransporte,
		   ClaTransportista=ClaTransportista,
		   NomTransportista = NomTransportista 
	from MSWSch.MSWSSTFleTraTabularViajeUSAVw

	*/
	IF @pnEsAgruparMensual = 'N'
	BEGIN 
	
				SELECT [AnioMes;c=Year Month;d=0;t=clave]						= AnioMes,		
					   [ClaAgrupador1;c=Goup ID 1;d=0;t=clave;v=false]			= ClaAgrupador1,
					   [NomAgrupador1;c=Group 1;]								= NomAgrupador1,
					   [ClaAgrupador2;c=Goup ID 2;d=0;t=clave;v=false]			= ClaAgrupador2,
					   [NomAgrupador2;c=Group 2;]								= NomAgrupador2,
					   [ClaUbicacion;c=Location ID;d=0;t=clave]					= ClaUbicacion,
					   [NomUbicacion;c=Location;]								= NomUbicacion,
					   [Tons;c=Tons;d=2;t=decimal]								= SUM(Tons),
					   [ImportePagarFinalUSD;c=Amount (US Dlls);d=2;t=decimal]  =  SUM(ImportePagarFinalUSD) 
				FROM   USADATALake.MCSW_SST.MSWSch.MSWSSTFreightMXAndUSVw  WITH(NOLOCK)
				WHERE ANIOMES = @pnAnioMes
				GROUP BY  AnioMes,		
					   NomAgrupador1,
					   NomAgrupador2,
					   ClaUbicacion,
					   NomUbicacion,
					   ClaAgrupador1,
					   ClaAgrupador2 
				ORDER BY AnioMes ASC, ClaAgrupador1 ASC, ClaAgrupador2 ASC  
	
	END
	ELSE
	BEGIN 
	
			SELECT	   [AnioMes;c=Year Month;d=0;t=clave]						= AnioMes,
					   [Fecha;c=Date;a=center]									= CONVERT(date,  convert(datetime,  FechaTabular )),					
					   ClaSemana												= ClaSemana,
					   NomSemana												= NomSemana,
					   [ClaAgrupador1;c=Goup ID 1;d=0;t=clave;v=false]			= ClaAgrupador1,
					   [NomAgrupador1;c=Group 1;]								= NomAgrupador1,
					   [ClaAgrupador2;c=Goup ID 2;d=0;t=clave;v=false]			= ClaAgrupador2,
					   [NomAgrupador2;c=Group 2;]								= NomAgrupador2,
					   [ClaUbicacion;c=Location ID;d=0;t=clave]					= ClaUbicacion,
					   [NomUbicacion;c=Location;]								= NomUbicacion,
					   [Tons;c=Tons;d=2;t=decimal]								= (Tons),
					   [ImportePagarFinalUSD;c=Amount (US Dlls);d=2;t=decimal] =  (ImportePagarFinalUSD),
					   [NumViaje;c=No. Viaje;d=0;t=clave]						= NumViaje,
					   [PesoCubicado;c=Tons Cub;d=2;t=decimal]	 				= TonsCubicadas,
					   [MillasViaje;c=Miles;d=2;t=decimal]	 					= MillasViaje,
					   [ClaTransporte;c=ClaTransporte;d=0;t=clave;v=false]	 	= ClaTransporte,
					   [NomTransporte;c=Truck Type;] 							= NomTransporte,
					   [ClaTransportista;c=ClaTransportista;d=0;t=clave;v=false] 				= ClaTransportista,
					   [NomTransportista;c=Carrier Name;]										= NomTransportista,
					   [ClaCiudadDestino;c=ClaCiudadDestino;d=0;t=clave;v=false]  			=   ClaCiudadDestino,
					   [NomCiudadDestino;c=Destionation - City Name;] 		=  NomCiudadDestino,
						[ClaEstadoDestino;c=ClaEstadoDestino;d=0;t=clave;v=false] 		=  ClaEstadoDestino,
						[NomEstadoDestino;c=Destionation - State Name;]  		=  NomEstadoDestino 
				FROM   USADATALake.MCSW_SST.MSWSch.MSWSSTFreightMXAndUSVw WITH(NOLOCK) 
				WHERE ANIOMES = @pnAnioMes  
				ORDER BY AnioMes ASC, ClaAgrupador1 ASC, ClaAgrupador2 ASC  
	END    
	SET NOCOUNT OFF
END




