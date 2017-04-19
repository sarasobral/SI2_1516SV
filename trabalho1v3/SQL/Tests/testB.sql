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
print('Verificar a BD para o artigo 1')
	select * from dbo.VendaDirecta where artigoId=1
print('Atualizar o artigo 1')
	exec dbo.atualizarArtigo @update1 = 10, @artigoId = 1
print('Verificar a atualizacao na BD')
	select * from dbo.VendaDirecta where artigoId=1
GO
COMMIT