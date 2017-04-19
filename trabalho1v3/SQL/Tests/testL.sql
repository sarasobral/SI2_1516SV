use ISEL
SET NOCOUNT ON 
begin tran
print(' ')
print('*****************************TESTE L*****************************')
print('Listar os leilões que não foram concluídos;')
-- OS QUE NAO TEM compra, nao houve licitacao 
	select * from dbo.leilaoNaoConcluido

GO
COMMIT