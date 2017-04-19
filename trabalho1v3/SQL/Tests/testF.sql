use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE E F*****************************')
	insert into dbo.Venda(email,artigoId,condicao,localOrigem,dataInicio,dataFim,descricao) values ('vend1',1,'Novo','PT','2016-03-01','2016-07-01','venda direta')
	insert into dbo.Venda(email,artigoId,condicao,localOrigem,dataInicio,dataFim,descricao) values ('vend1',2,'Novo','PT','2016-03-01','2016-07-01','leilao')
print('Inserir licitaçoes artigo 1')
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:22', @preco=1, @email='licit1', @artigoId=1 --venda direta valor inferior ao esperado
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:23', @preco=10, @email='licit1', @artigoId=1 --venda direta aceita
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:23', @preco=10, @email='licit2', @artigoId=1 --venda direta nao aceita aceita
print('Verificar a atualizacao na BD')
	select * from dbo.Licitacao
print('Remover licitaçoes')	
	exec dbo.removerLicitacao @email='licit1', @artigoId=1
print('Verificar a atualizacao na BD')
	select * from dbo.Licitacao
print('Inserir licitaçoes artigo 2')
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:23', @preco=10, @email='licit2', @artigoId=1 --venda direta aceita
	exec dbo.inserirLicitacao @data='2016-03-03 10:10:00', @preco=15, @email='licit1', @artigoId=2
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:22', @preco=14, @email='vend1', @artigoId=2
	exec dbo.inserirLicitacao @data='2016-03-24 22:22:22', @preco=15, @email='licit2', @artigoId=2 
	exec dbo.inserirLicitacao @data='2016-03-26 22:22:22', @preco=16, @email='licit2', @artigoId=2 
print('Remover licitaçoes')	
	exec dbo.removerLicitacao @email='vend1', @artigoId=2
print('Inserir licitaçoes artigo 2')
	exec dbo.inserirLicitacao @data='2016-04-02 10:10:22', @preco=10, @email='licit2', @artigoId=2
	exec dbo.inserirLicitacao @data='2016-04-02 15:10:00', @preco=17, @email='licit1', @artigoId=2
print('Remover licitaçoes')	
	exec dbo.removerLicitacao @email='licit1', @artigoId=2
print('Inserir licitaçoes artigo 2')
	exec dbo.inserirLicitacao @data='2016-05-04 15:10:00', @preco=0.05, @email='licit1', @artigoId=2 --venda direta valor inferior ao esperado		
GO

COMMIT