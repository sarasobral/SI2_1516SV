use ISEL

set nocount on

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 
--SE ALGUEM FICZER ALTERAÇÕES NA TABELA DE ICITAÇOES
BEGIN TRAN

go
--(j) Obter as n últimas licitações; 

--function 
if OBJECT_ID('dbo.nLicitacao') is not null
	drop function dbo.nLicitacao
	
go
create function dbo.nLicitacao(@n int)
returns table
as
   return (select top (@n) * from dbo.Licitacao where unCheck = 1 order by dataHora desc)   
go 

COMMIT
