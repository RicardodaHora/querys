CREATE TABLE [dbo].[cliente] (
  [ID] [int] NULL,
  [NOME] [varchar](50) NULL,
  [CIDADE] [varchar](50) NULL,
  [ENDERECO] [varchar](50) NULL
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tabela de Clientes', 'SCHEMA', N'dbo', 'TABLE', N'cliente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Identity', 'SCHEMA', N'dbo', 'TABLE', N'cliente', 'COLUMN', N'ID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nome', 'SCHEMA', N'dbo', 'TABLE', N'cliente', 'COLUMN', N'NOME'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Cidade', 'SCHEMA', N'dbo', 'TABLE', N'cliente', 'COLUMN', N'CIDADE'
GO