CREATE TABLE [dbo].[VW_PARTIDAS_RM](
CODFILIAL		[int] NOT NULL,				
CODCOLIGADA             [int] NOT NULL,
DATA                    [Datetime] NOT NULL,
INTEGRACHAVE            [char](20) NULL,
CODIGO_BFC              [char](20) NULL,
DESCRICAO               [char](100) NULL,
CONTA                   [char](20) NULL,
DESCRICAO_CONTA         [char](70) NULL,
CCUSTO                  [char](20) NULL,
DESCRICAO_CENTRO_CUSTO  [char](40) NULL,
VALOR                   [Numeric](17,2) NOT NULL,
VALOR_LANC              [Numeric](17,2) NOT NULL,
COD_CLI                 [INT] NULL,
RAZAO                   [char](50) NULL,
LCTREF                  [INT] NOT NULL,
DOCUMENTO               [char](20) NULL,
COMPLEMENTO             [char](250) NULL
) ON [PRIMARY]
GO

