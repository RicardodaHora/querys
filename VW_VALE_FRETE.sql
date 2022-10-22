
CREATE TABLE [dbo].[VW_VALE_FRETE](
	[CODIGO] [varchar](6) NULL,
	[MOSTORISTA] [varchar](40) NULL,
	[PLACA] [varchar](10) NULL,
	[TRANSP] [varchar](6) NULL,
	[NUM_CARGA] [varchar](15) NULL,
	[PEDAGIO] [NUMERIC](16,2) NULL,
	[DATA_GER] [datetime] NOT NULL,
	[NUMERO] [varchar](10) NULL,
	[PESO] [NUMERIC](12,3) NULL,
	[FRETE] [NUMERIC](12,2) NULL,
	[CLIENTE] [INT] NULL,
	[PED] [varchar](10) NULL,
	[EMPRESA] [INT] NULL
	
) ON [PRIMARY]
GO