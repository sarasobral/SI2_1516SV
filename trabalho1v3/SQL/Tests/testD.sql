use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE D*****************************')
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
commit