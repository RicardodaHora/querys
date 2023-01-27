SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_amanha]
as

select getdate()-1 as Amanha
GO
