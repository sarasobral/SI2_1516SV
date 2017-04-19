use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE G*****************************')
print('Concluir a compra do artigo 2com o vendedor errado')
	exec dbo.efetuarLeilao @data='2016-03-13 22:22:22', @locDest='PT', @cc=234, @artigoId=2, @email='licit2'
print('Concluir a compra do artigo 2com o vendedor verto')
	exec dbo.efetuarLeilao @data='2016-03-13 22:22:22', @locDest='PT', @cc=234, @artigoId=2, @email='vend1'
PRINT('Verificar a alteracao na BD na tabela compra')
	SELECT c.artigoId,c.email,c.codigo,c.cartaoCredito,c.dataCompra,c.localDestino from compra c where artigoId=2
PRINT('Verificar que o artigo fico ainda esta desponivel')
	SELECT * from artigo where id=2
GO
COMMIT