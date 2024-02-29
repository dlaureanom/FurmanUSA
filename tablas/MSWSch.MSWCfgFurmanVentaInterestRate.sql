CREATE TABLE [MSWSch].[MSWCfgFurmanVentaInterestRate](
	[AnioMes] [int] NOT NULL,
	[PorcInteres] [numeric](22, 6) NULL,
	[BajaLogica] [tinyint] NULL,
	[FechaBajaLogica] [datetime] NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
 CONSTRAINT [PK_MSWCfgFurmanVentaInterestRate] PRIMARY KEY CLUSTERED 
(
	[AnioMes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [MSWSch].[MSWCfgFurmanVentaInterestRate] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [MSWSch].[MSWCfgFurmanVentaInterestRate] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO