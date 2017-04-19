use ISEL
SET NOCOUNT ON 
begin tran
go

IF EXISTS (SELECT * FROM sys.syslogins WHERE name = N'User1') 
	DROP LOGIN User1
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'User1')
	DROP USER User1
IF EXISTS (SELECT * FROM sys.syslogins WHERE name = N'User2') 
	DROP LOGIN User2
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'User2')
	DROP USER User2
go

CREATE LOGIN User1 
    WITH PASSWORD = 'user1pwd';
CREATE USER User1 FOR LOGIN User1 
    WITH DEFAULT_SCHEMA = dbo;
GO
EXEC sp_addrolemember 'db_owner', 'User1';

CREATE LOGIN User2
    WITH PASSWORD = 'user2pwd';
CREATE USER User2 FOR LOGIN User2 
    WITH DEFAULT_SCHEMA = dbo;
GO
EXEC sp_addrolemember 'db_owner', 'User2';

GO 
--UTILIZADOR
	exec dbo.inserirUtilizador @email='licit1', @pp='aaaaaa', @nome='Sara', @morada='PT'
	exec dbo.inserirUtilizador @email='licit2', @pp='bbbbbb', @nome='Rute', @morada='FR'
	exec dbo.inserirUtilizador @email='licit3', @pp='cccccc', @nome='Filipa', @morada='BR'
	exec dbo.inserirUtilizador @email='vend1', @pp='zzzzzzz', @nome='Chiquinho', @morada='PT'
GO
--ARTIGOS
	exec dbo.inserirArtigo @data='2015-11-26 08:12:12'
	exec dbo.inserirArtigo @data='2016-02-21 22:12:12'
	exec dbo.inserirArtigo @data='2016-02-25 10:12:12'
	exec dbo.inserirArtigo @data='2016-03-12 15:12:12'
	exec dbo.inserirArtigo @data='2016-04-03 17:12:12'
	exec dbo.inserirArtigo @data='2016-05-11 17:25:25'
	-------------------------------------------------
	insert into dbo.VendaDirecta(artigoId,precoVenda) values (1,10),(3,15),(5,20)
	insert into dbo.leilao(artigoId, licitacaoMin, valorMin) values (2,1,20),(4,2,30),(6,3,40)
GO
--VENDA
	insert into dbo.Venda(email,artigoId,condicao,localOrigem,dataInicio,dataFim,descricao) values ('vend1',1,'Novo','PT','2016-03-01','2016-08-01','venda direta')
	insert into dbo.Venda(email,artigoId,condicao,localOrigem,dataInicio,dataFim,descricao) values ('vend1',2,'Novo','BR','2016-03-01','2016-08-01','leilao')
	insert into dbo.Venda(email,artigoId,condicao,localOrigem,dataInicio,dataFim,descricao) values ('vend1',3,'Usado','FR','2016-03-01','2016-08-01','venda direta')
	insert into dbo.Venda(email,artigoId,condicao,localOrigem,dataInicio,dataFim,descricao) values ('vend1',4,'Como novo','PT','2016-03-01','2016-08-01','leilao')
	insert into dbo.Venda(email,artigoId,condicao,localOrigem,dataInicio,dataFim,descricao) values ('vend1',5,'Novo','FR','2016-03-01','2016-08-01','venda direta')
	insert into dbo.Venda(email,artigoId,condicao,localOrigem,dataInicio,dataFim,descricao) values ('vend1',6,'Velharia vintage','BR','2016-03-01','2016-08-01','leilao')
GO
--LOCAIS
	exec dbo.inserirLocal @preco=1, @locOrigem='PT', @locDestino='PT'
	exec dbo.inserirLocal @preco=2, @locOrigem='PT', @locDestino='FR'
	exec dbo.inserirLocal @preco=3, @locOrigem='PT', @locDestino='BR'
	exec dbo.inserirLocal @preco=4, @locOrigem='FR', @locDestino='BR'
	exec dbo.inserirLocal @preco=5, @locOrigem='FR', @locDestino='PT'
	exec dbo.inserirLocal @preco=6, @locOrigem='FR', @locDestino='FR'
	exec dbo.inserirLocal @preco=7, @locOrigem='BR', @locDestino='BR'
	exec dbo.inserirLocal @preco=8, @locOrigem='BR', @locDestino='PT'
	exec dbo.inserirLocal @preco=9, @locOrigem='BR', @locDestino='FR'
GO
/*
--LICITACOES
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:22', @preco=1, @email='licit1', @artigoId=1 --venda direta valor inferior ao esperado
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:23', @preco=10, @email='licit1', @artigoId=1 --venda direta aceita
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:23', @preco=10, @email='licit2', @artigoId=1 --venda direta nao aceita aceita
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:23', @preco=10, @email='licit2', @artigoId=1 --venda direta aceita
	exec dbo.inserirLicitacao @data='2016-03-03 10:10:00', @preco=15, @email='licit1', @artigoId=2
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:22', @preco=14, @email='vend1', @artigoId=2
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:22', @preco=15, @email='licit2', @artigoId=2 
	exec dbo.inserirLicitacao @data='2016-03-26 22:22:22', @preco=16, @email='licit2', @artigoId=2 
	exec dbo.inserirLicitacao @data='2016-04-02 10:10:22', @preco=10, @email='licit2', @artigoId=2
	exec dbo.inserirLicitacao @data='2016-04-02 15:10:00', @preco=17, @email='licit1', @artigoId=2
	exec dbo.inserirLicitacao @data='2016-05-04 15:10:00', @preco=0.05, @email='licit1', @artigoId=2 --venda direta valor inferior ao esperado
GO*/
--LEILAO
--COMPRA_DIRETA

commit

