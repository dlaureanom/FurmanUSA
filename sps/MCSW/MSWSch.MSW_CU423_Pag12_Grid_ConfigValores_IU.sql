ALTER PROCEDURE [MSWSch].[MSW_CU423_Pag12_Grid_ConfigValores_IU]
		  @pnAnio						INT
		, @pnPorcGastoVentaIndirecta	NUMERIC(22,6)	
		, @psNombrePcMod				VARCHAR(64)
		, @pnClaUsuarioMod				INT		
AS   
BEGIN  

	DECLARE 			
		@MSG				VARCHAR(255)

	IF NOT EXISTS (SELECT 1 FROM MSWSch.MSWCfgFurmanVentaValoresUsar WHERE Anio = @pnAnio)
		BEGIN /* ES ALTA DE AÑO */
			INSERT INTO MSWSch.MSWCfgFurmanVentaValoresUsar
				(
					 Anio
					,PorcInteres
					,PorcGastoVentaIndirecta
					,ComisionAgenteVenta
					,ComisionManagerVenta
					,ComisionVPVenta
					,ComisionAgIndVenta
					,BajaLogica
					,FechaBajaLogica
					,FechaUltimaMod
					,ClaUsuarioMod
					,NombrePcMod
				)
			VALUES
				(
					 @pnAnio
					,0
					,@pnPorcGastoVentaIndirecta
					,-1
					,-1
					,-1
					,-1
					,0
					,NULL
					,GETDATE()
					,@pnClaUsuarioMod
					,@psNombrePcMod
				)
		END
	ELSE
		BEGIN /*SE ACTUALIZA AÑO*/
			UPDATE MSWSch.MSWCfgFurmanVentaValoresUsar
			SET 				   
				  PorcGastoVentaIndirecta = @pnPorcGastoVentaIndirecta
				  ,FechaUltimaMod = GETDATE()
				  ,ClaUsuarioMod = @pnClaUsuarioMod
				  ,NombrePcMod = @psNombrePcMod
			 WHERE Anio = @pnAnio
		END
END
