SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create proc [dbo].[sp_hoje] 
as

SELECT GETDATE() as Hoje

GO