use ISEL
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN

--(d) Inserir, remover e actualizar informação de um local;
if OBJECT_ID('dbo.inserirLocal') is not null
	drop proc dbo.inserirLocal
if OBJECT_ID('dbo.atualizarLocal') is not null
	drop proc dbo.atualizarLocal
if OBJECT_ID('dbo.apagarLocal') is not null
	drop proc dbo.apagarLocal

go
create proc dbo.inserirLocal @preco money, @locOrigem varchar(2), @locDestino varchar(2)
as
	--TER UMA TABELA COM A NORMA ISO 3166-1
	insert into dbo.Porte(preco,moradaOrigem,moradaDestino) values (@preco,@locOrigem,@locDestino)
	if(@@ROWCOUNT>0) return 0
	return 1

go
create proc dbo.atualizarLocal @preco money, @locOrigem varchar(2), @locDestino varchar(2)
AS
	update dbo.Porte SET preco=@preco where moradaOrigem=@locOrigem and moradaDestino=@locDestino
	if(@@ROWCOUNT>0) return 0
	return 1

go
create proc dbo.apagarLocal @local varchar(2)
as
	delete from dbo.Porte where moradaDestino=@local
	delete from dbo.Porte where moradaOrigem=@local
	if(@@ROWCOUNT>0) return 0
	return 1
go
COMMIT


