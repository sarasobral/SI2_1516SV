use ISEL
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN

--(c) Inserir, remover e actualizar informação de um utilizador;
if OBJECT_ID('dbo.inserirUtilizador') is not null
	drop proc dbo.inserirUtilizador
if OBJECT_ID('dbo.atualizarUtilizador') is not null
	drop proc dbo.atualizarUtilizador
if OBJECT_ID('dbo.apagarUtilizador') is not null
	drop proc dbo.apagarUtilizador

go
create proc dbo.inserirUtilizador @email varchar(100), @pp varchar(50), @nome varchar(50), @morada varchar(100)
as
	insert into dbo.Utilizador(email,palavraPasse,nome,morada) values (@email,@pp,@nome,@morada);
	if(@@ROWCOUNT>0) return 0
	return 1

go
create proc dbo.atualizarUtilizador @email varchar(100), @pp varchar(50)=null, @nome varchar(50)=null, @morada varchar(100)=null
as
	if(DATALENGTH(@pp)>=6)
		update dbo.Utilizador set palavraPasse=(SELECT HashBytes('MD5',@pp)) where email=@email;
	if(DATALENGTH(@nome)>0) --if(UPDATE(NAME))
		update dbo.Utilizador set nome=@nome where email=@email;
	if(DATALENGTH(@morada)>0) --if(UPDATE(MORADA))
		update dbo.Utilizador set morada=@morada where email=@email;
		if(@@ROWCOUNT>0) return 0
	return 1

go
create proc dbo.apagarUtilizador @email varchar(100)
as
	delete dbo.Utilizador where email=@email
	if(@@ROWCOUNT>0) return 0
	return 1
go
COMMIT

