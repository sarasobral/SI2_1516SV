use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE H*****************************')
print('Concluir a venda direta do artigo 1 com o vendedor errado')
	exec dbo.efetuarCompraDireta @data='2016-03-13 22:22:22', @locDest='PT', @cc=123, @artigoId=1, @email='licit1'

print('Concluir a venda direta do artigo 1 com o vendedor certo')
	exec dbo.efetuarCompraDireta @data='2016-03-13 22:22:22', @locDest='PT', @cc=123, @artigoId=1, @email='vend1'
PRINT('Verificar a alteracao na BD na tabela compra')
	SELECT c.artigoId,c.email,c.codigo,c.cartaoCredito,c.dataCompra,c.localDestino from compra c where artigoId=2
PRINT('Verificar que o artigo fico indesponivel')
	SELECT * from artigo where id=1
GO
COMMIT
	