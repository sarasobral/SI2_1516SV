use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE I*****************************')
print('determinar o valor da licita��o de um artigo ')
	print('Para o artigo 2  ')
	select * from dbo.valorLicit(2)
GO
COMMIT