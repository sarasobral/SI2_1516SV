use ISEL
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN 
if OBJECT_ID('dbo.deleteLocal') is not null
	drop trigger dbo.deleteLocal
if OBJECT_ID('dbo.utilizadorU') is not null
	drop trigger dbo.utilizadorU
	if OBJECT_ID('dbo.utilizadorI') is not null
	drop trigger dbo.utilizadorI
if OBJECT_ID('dbo.deleteUtilizador') is not null
	drop trigger deleteUtilizador
if OBJECT_ID('dbo.deleteArtigo') is not null
	drop trigger dbo.deleteArtigo
if OBJECT_ID('dbo.deleteLicitacao') is not null
	drop trigger dbo.deleteLicitacao
if OBJECT_ID('dbo.deleteCompra') is not null
	drop trigger dbo.deleteCompra
if OBJECT_ID('dbo.deleteVenda') is not null
	drop trigger dbo.deleteVenda
go

--trigger que coloca a palavra passe em md5
create trigger dbo.utilizadorI on dbo.Utilizador
after insert
as	
	declare @pp varchar(50)
	select @pp=(select palavraPasse from inserted)
	if (DATALENGTH(@pp)>=6)
		update Utilizador set palavraPasse=(SELECT HashBytes('MD5',@pp)) where email=(select email from inserted)
	
go

create trigger dbo.utilizadorU on dbo.Utilizador
after update
as
	if update(email)
	BEGIN
			RAISERROR('Nao é permitido alterar o email',16,1)
			update Utilizador set email=(select email from deleted) where email=(select email from inserted)
	END
	if(update(morada))
			insert into dbo.HistoricoUtilizador(morada,dataTempo,email) values ((select morada from deleted),GETDATE(),(select email from inserted))
go

create trigger dbo.deleteUtilizador on dbo.Utilizador
instead of delete
as
	declare @email varchar(100)
	select @email = (select email from deleted)
	UPDATE dbo.Utilizador set unCheck=0 where email=@email
	UPDATE dbo.Compra set unCheck=0 where email=@email
	UPDATE dbo.Licitacao set unCheck=0 where email=@email
	UPDATE dbo.Venda set unCheck=0 where email=@email
go

--fazer o mesmo para Leilao e vendaDireta
create trigger dbo.deleteArtigo on dbo.Artigo
instead of delete
as
	declare @artigo int
	select @artigo = (select id from deleted)
	--UPDATE dbo.Leilao set unCheck=0 where artigoId=@artigo
	--UPDATE dbo.VendaDirecta set unCheck=0 where artigoId=@artigo
	UPDATE dbo.Artigo set unCheck=0 where id=@artigo
	UPDATE dbo.Compra set unCheck=0 where artigoId=@artigo
	UPDATE dbo.Licitacao set unCheck=0 where artigoId=@artigo
	UPDATE dbo.Venda set unCheck=0 where artigoId=@artigo
go

create trigger dbo.deleteLicitacao on dbo.Licitacao
instead of delete
as
	update dbo.Licitacao set unCheck=0 
	where email=(select email from deleted) 
	and artigoId=(select artigoId from deleted) 
	and dataHora=(select dataHora from deleted)
go

create trigger dbo.deleteCompra on dbo.Compra
instead of delete
as
	update dbo.Compra set unCheck=0 where codigo=(select codigo from deleted)
go

create trigger dbo.deleteVenda on dbo.Venda
instead of delete
as
	update dbo.Venda set unCheck=0 where email=(select email from deleted) and artigoId=(select artigoId from deleted)
go

COMMIT

print('Finished creating triggers on database ISEL.'); 



