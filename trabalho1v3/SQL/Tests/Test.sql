use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE B*****************************')
print('Inserir artigos 1, 2 e 3')
	exec dbo.inserirArtigo @data='2015';
	exec dbo.inserirArtigo @data='2016-02-21 22:12:12'
	exec dbo.inserirArtigo @data='2016-05-11 10:12:12'
--inserir os artigos em venda direta e leilao
	insert into dbo.VendaDirecta(artigoId,precoVenda) values (1,20),(3,10)
	insert into dbo.leilao(artigoId, licitacaoMin, valorMin) values (2,1,20)
print('Verificar se foram colocados na BD')
	select * from dbo.Artigo
print('Remover o artigo null')
	exec dbo.apagarArtigo null	
print('Remover o artigo 3')
	exec dbo.apagarArtigo 3
print('Verificar se o artigo 3 foi removido da BD')
	select * from dbo.Artigo
print('Atualizar o artigo 3')
	exec dbo.atualizarArtigo @update1 = 15, @artigoId = 3
print('Atualizar o artigo 1')
	exec dbo.atualizarArtigo @update1 = 10, @artigoId = 1
print('Verificar a atualizacao na BD')
	select * from dbo.Artigo
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
GO
print('-----------------------TESTE C-----------------------')
print('Inserir um utilizador')
	exec dbo.inserirUtilizador @email='licit1', @pp='aaaaaa', @nome='Amadeus', @morada='PT'
	exec dbo.inserirUtilizador @email='licit2', @pp='bbbbbb', @nome='Fernando', @morada='FR'
	exec dbo.inserirUtilizador @email='licit3', @pp='cccccc', @nome='Bianca', @morada='PT'
	exec dbo.inserirUtilizador @email='vend1', @pp='zzzzzzz', @nome='Jose', @morada='PT'
print('Verificar se foram colocados na BD')
	select * from dbo.Utilizador
print('Atualizar nome do licit1 Amadeus->Joaquim') 
	exec dbo.atualizarUtilizador @email='licit1', @nome='Joaquim'
print('Verificar a atualizacao na BD')
	select * from dbo.Utilizador where email='licit1'
print('Atualizar morada do licit2 FR->PT') 
	exec dbo.atualizarUtilizador @email='licit2', @pp=null, @nome='Alfredo', @morada='PT'
print('Verificar a atualizacao na BD')
	select * from dbo.Utilizador where email='licit2'
print('Verificar a atualizacao na BD Historico de utilizador')
	select*  from dbo.HistoricoUtilizador
print('Atualizar palavra-passe do vend1 zzzzzz->123456') 
	exec dbo.atualizarUtilizador @email='vend1', @pp='123456', @nome=null, @morada=null
print('Verificar a atualizacao na BD')
	select * from dbo.Utilizador where email='vend1'
print('Remover utilizador licit3')
	exec dbo.apagarUtilizador @email='licit3'
print('Verificar a atualizacao na BD')
	select * from dbo.Utilizador
GO
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
GO
print('-----------------------TESTE D-----------------------')
print('Inserir local')
	exec dbo.inserirLocal @preco=1, @locOrigem='PT', @locDestino='PT'
	exec dbo.inserirLocal @preco=2, @locOrigem='PT', @locDestino='FR'
	exec dbo.inserirLocal @preco=5, @locOrigem='FR', @locDestino='BR'
print('Verificar a atualizacao na BD')
	select * from dbo.Porte
print('Atualizar local PT-FR: 2->3')
	exec dbo.atualizarLocal @preco=3, @locOrigem='PT', @locDestino='FR'
print('Verificar a atualizacao na BD')
	select * from dbo.Porte where moradaOrigem='PT' and moradaDestino='FR'
print('Remover local FR')
	exec dbo.apagarLocal @local='FR'
print('Verificar a atualizacao na BD')
	select * from dbo.Porte
GO
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
GO
print('-----------------------TESTE E F---------------------')
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
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
GO
print('-----------------------TESTE ------------------------')
print('--test (g) Concluir a compra de um leilão; (h) Realizar a compra de um artigo de venda directa; ')
	exec dbo.efetuarCompraDireta @data='2016-03-13 22:22:22', @locDest='PT', @cc=123, @artigoId=1
	exec dbo.efetuarLeilao @data='2016-03-13 22:22:22', @locDest='PT', @cc=234, @artigoId=2
	
	--select * from Compra	

print('--test (i) Determinar o valor da licitação de um artigo; ')
	print('Para o artigo 2  ')
	select * from dbo.valorLicit(2)

print('--test (j) Obter as n últimas licitações;  ')
	print('Com n = 2  ')
	select * from dbo.nLicitacao(2);

print('--test (k) Obter os portes, dadas duas localizações; ')
	print('Portes entre PT e PT')
	declare @valorPorte int 
	exec dbo.valuePorte	'PT', 'PT', @valorPorte output 
	select @valorPorte as valorDoPorte

print('--test (l) Listar os leilões que não foram concluídos;')
-- OS QUE NAO TEM compra, nao houve licitacao 
	select * from dbo.leilaoNaoConcluido

print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
print('')	
GO
print('-----------------------TESTE M-----------------------')
	print'Para o utilizador vend1 com a palavra passe 123456'
	declare @res int
	print'Teste com a palavra passe anterior zzzzzz'
	exec dbo.verificarPp 'vend1','zzzzzz', @res output	
	print'Teste com a palavra passe 123456'
	exec dbo.verificarPp 'vend1','123456', @res output	

commit

