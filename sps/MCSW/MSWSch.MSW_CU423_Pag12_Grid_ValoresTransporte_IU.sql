ALTER PROCEDURE [MSWSch].[MSW_CU423_Pag12_Grid_ValoresTransporte_IU]
		@pnAnio INT
		,@pnDINLFTWU_MX NUMERIC(22,6)
		,@pnDWAREHU_MX NUMERIC(22,6)
		,@pnDINLFTPU_MXN NUMERIC(22,6)
		,@pnDBROKU_MX NUMERIC(22,6)
		,@pnUSBROKU NUMERIC(22,6)
		,@pnINLFPWU_L NUMERIC(22,6)
		,@pnUSWAREHU_L NUMERIC(22,6)
		, @psNombrePcMod				VARCHAR(64)
		, @pnClaUsuarioMod				INT		
AS   
BEGIN  

	DECLARE 			
		@MSG				VARCHAR(255)

	IF NOT EXISTS (SELECT 1 FROM MSWSch.MSWCfgFurmanInlandFreightRates WHERE Anio = @pnAnio)
		BEGIN /* ES ALTA DE AÑO */
			INSERT INTO MSWSch.MSWCfgFurmanInlandFreightRates
				(
					Anio
					,DINLFTWU_MXN
					,DWAREHU_MXN
					,DINLFTPU_MXN
					,DBROKU_MXN
					,USBROKU
					,INLFPWU_L
					,USWAREHU_L
					,BajaLogica
					,FechaBajaLogica
					,FechaUltimaMod
					,ClaUsuarioMod
					,NombrePcMod
				)
			VALUES
				(
					@pnAnio
					,@pnDINLFTWU_MX
					,@pnDWAREHU_MX
					,@pnDINLFTPU_MXN
					,@pnDBROKU_MX
					,@pnUSBROKU
					,@pnINLFPWU_L
					,@pnUSWAREHU_L
					,0
					,NULL
					,GETDATE()
					,@pnClaUsuarioMod
					,@psNombrePcMod
				)
		END
	ELSE
		BEGIN /*SE ACTUALIZA AÑO*/
			UPDATE MSWSch.MSWCfgFurmanInlandFreightRates
			SET 				  
				DINLFTWU_MXN = @pnDINLFTWU_MX
				,DWAREHU_MXN  = @pnDWAREHU_MX
				,DINLFTPU_MXN = @pnDINLFTPU_MXN
				,DBROKU_MXN   = @pnDBROKU_MX
				,USBROKU      = @pnUSBROKU
				,INLFPWU_L    = @pnINLFPWU_L
				,USWAREHU_L   = @pnUSWAREHU_L
				,FechaUltimaMod = GETDATE()
				,ClaUsuarioMod = @pnClaUsuarioMod
				,NombrePcMod = @psNombrePcMod
			 WHERE Anio = @pnAnio
		END
END