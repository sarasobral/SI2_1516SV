use ISEL
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
go
--(i) Determinar o valor da licitação de um artigo;
--vista onde se faz where ou func onde se passa o artigoId
if OBJECT_ID('dbo.valorLicit') is not null
	drop function dbo.valorLicit
go

go
create function dbo.valorLicit(@id int) --a ultima
returns table
as
	return (select artigoId, email, preco, dataHora from Licitacao 
		where preco=(select max(preco) from Licitacao where artigoId=@id and unCheck=1) and artigoId=@id  )  
go 

COMMIT

