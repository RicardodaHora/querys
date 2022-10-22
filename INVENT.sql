

CREATE TABLE [dbo].[INVENT](
	[NRECNO] [numeric](15, 0) NULL,
	[CHAVE] [numeric](10, 0) NULL,
	[CODIGO] [char](18) NULL,
	[LOCAL] [char](15) NULL,
	[LOC_FIS] [char](20) NULL,
	[LOTE_PROD] [char](25) NULL,
	[NOMEUSR1] [char](10) NULL,
	[NOMEUSR2] [char](10) NULL,
	[NOMEUSR3] [char](10) NULL,
	[QUANT1] [numeric](14, 4) NULL,
	[QUANT2] [numeric](14, 4) NULL,
	[QUANT3] [numeric](14, 4) NULL,
	[COD_BARRAS] [char](15) NULL,
	[CONT] [numeric](1, 0) NULL,
	[DISPONIVEL] [numeric](15, 4) NULL,
	[SEQ] [numeric](18, 0) NULL,
	[A_C] [char](1) NULL,
	[A_S] [char](1) NULL,
	[LOTE] [char](25) NULL,
	[AUTORIZ] [char](1) NULL,
	[QUAN_WMS] [numeric](14, 4) NULL,
	[ALCADA] [char](10) NULL,
	[ALCADA2] [char](10) NULL,
	[NIVEL] [char](1) NULL,
	[VARIACAO] [numeric](13, 2) NULL,
 CONSTRAINT [UQ__INVENT__71C95D1E] UNIQUE NONCLUSTERED 
(
	[NRECNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO


