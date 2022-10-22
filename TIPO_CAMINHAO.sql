
CREATE TABLE [dbo].[TIPO_CAMINHAO](
	[CAMINHAO] [char](30) NULL,
	[NRECNO] [numeric](15, 0) IDENTITY(1,1) NOT NULL,
	[TIP_RODADO] [char](2) NULL,
	[VAXLE] [char](50) NULL,
	[VCATEGORY] [char](50) NULL,
	[VCLASS] [char](50) NULL,
	[VTYPE] [char](50) NULL
) ON [PRIMARY]
GO


