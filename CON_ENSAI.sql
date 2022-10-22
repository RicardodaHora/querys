
CREATE TABLE [dbo].[CON_ENSAI](
	[BAU] [char](1) NULL,
	[BAU_FRIG] [char](1) NULL,
	[BAU_NORM] [char](1) NULL,
	[CACAMBA] [char](1) NULL,
	[CAM_LIM] [char](1) NULL,
	[CAM_SUJ] [char](1) NULL,
	[CAR_OUT] [char](1) NULL,
	[CARGA] [char](15) NULL,
	[CARR_ALU] [char](1) NULL,
	[CARR_MAD] [char](1) NULL,
	[CARR_SIDE] [char](1) NULL,
	[CARROCERIA] [char](1) NULL,
	[COD_EMP] [numeric](6, 0) NULL,
	[CONTAINER] [char](1) NULL,
	[DATA_CHEG] [datetime] NULL,
	[DATA_ENT] [datetime] NULL,
	[DATA_SAI] [datetime] NULL,
	[DESCR_PARC] [char](50) NULL,
	[FORRO_NAO] [char](1) NULL,
	[FORRO_SIM] [char](1) NULL,
	[GRANELEIRO] [char](1) NULL,
	[GRAVA] [char](1) NULL,
	[HORA_CHEG] [char](10) NULL,
	[HORA_ENT] [char](10) NULL,
	[HORA_SAI] [char](10) NULL,
	[INF_NAO] [char](1) NULL,
	[INF_SIM] [char](1) NULL,
	[LIBERAR_EX] [char](1) NULL,
	[LONA_BOM] [char](1) NULL,
	[LONA_RUIM] [char](1) NULL,
	[MOTORISTA] [char](60) NULL,
	[NOME_COMPL] [char](40) NULL,
	[NOME_TRANSP] [char](100) NULL,
	[NR] [char](10) NULL,
	[OBS] [char](120) NULL,
	[OBS_PORT] [char](120) NULL,
	[OBS_REJE] [char](120) NULL,
	[OBS_VEI] [char](120) NULL,
	[OBSLIBPESO] [char](100) NULL,
	[ORDEM] [numeric](10, 0) NULL,
	[OUTROS] [char](1) NULL,
	[PES_BRUTO] [numeric](17, 3) NULL,
	[PES_CARGA] [numeric](17, 3) NULL,
	[PES_LIQ] [numeric](17, 3) NULL,
	[PES_TARA] [numeric](17, 3) NULL,
	[PLACA] [char](7) NULL,
	[TANQUE] [char](1) NULL,
	[TIPO] [char](1) NULL,
	[TRANSPOR] [char](8) NULL,
	[US_LIB] [char](10) NULL,
	[USUARIO] [char](10) NULL,
	[VARIACAO] [numeric](12, 4) NULL,
	[NRECNO] [numeric](15, 0) IDENTITY(1,1) NOT NULL,
	[DATA_LIB] [datetime] NULL,
	[HORA_LIB] [char](8) NULL,
	[PES_DIF] [numeric](17, 3) NULL,
	[BLOQ_FAT] [char](1) NULL,
	[DATA_PESO] [datetime] NULL,
	[DTPESOSAI] [datetime] NULL,
	[HORA_PESO] [char](8) NULL,
	[HRPESOSAI] [char](8) NULL,
	[US_ALT] [char](10) NULL,
	[BLOQ_SAI] [char](1) NULL,
	[EST_PLACA] [char](2) NULL,
	[BAL_A] [char](20) NULL,
	[BAL_B] [char](20) NULL,
	[NOME_BALA] [char](20) NULL,
	[NOME_BALB] [char](20) NULL,
	[CARGA_ANT] [char](50) NULL,
	[LOTACAO] [numeric](17, 2) NULL,
	[PESO_CAPE] [numeric](12, 3) NULL,
	[PESO_CAPS] [numeric](12, 2) NULL,
	[NOTAS] [char](500) NULL,
	[PEDIDOS] [char](500) NULL,
	[DATA_PROG] [datetime] NULL,
	[EPI_CAP] [char](1) NULL,
	[EPI_COL] [char](1) NULL
) ON [PRIMARY]
GO


