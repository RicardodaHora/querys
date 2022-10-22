
CREATE TABLE [dbo].[TIPO_CAMINHAO_CARGA](
	[CAMINHAO] [char](20) NULL,
	[CODIGO] [numeric](2, 0) NULL,
	[NRECNO] [numeric](15, 0) IDENTITY(1,1) NOT NULL,
	[PESO_MIN] [numeric](17, 4) NULL,
	[PESO_MAX] [numeric](17, 4) NULL
) ON [PRIMARY]
GO


