use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE J*****************************')
print('Obter as n últimas licitacoes')
	print('Com n = 2  ')
	select * from dbo.nLicitacao(2);
GO
COMMIT