use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE K*****************************')
print('Obter os portes, dadas duas localizações; ')
	print('Portes entre PT e PT')
	declare @valorPorte int 
	exec dbo.valuePorte	'PT', 'PT', @valorPorte output 
	select @valorPorte as valorDoPorte
GO
COMMIT