use ISEL
SET NOCOUNT ON 
begin tran
print(' ')
print('*****************************TESTE L*****************************')
print('Listar os leil�es que n�o foram conclu�dos;')
-- OS QUE NAO TEM compra, nao houve licitacao 
	select * from dbo.leilaoNaoConcluido

GO
COMMIT