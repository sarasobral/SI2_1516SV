use ISEL

set nocount on

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 
--SE ALGUEM FICZER ALTERA��ES NA TABELA DE ICITA�OES
BEGIN TRAN

go
--(j) Obter as n �ltimas licita��es; 

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
