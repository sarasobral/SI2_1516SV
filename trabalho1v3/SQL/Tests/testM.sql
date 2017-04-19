use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE M*****************************')
	print'Para o utilizador vend1 com a palavra passe 123456'
	declare @res int
	print'Teste com a palavra passe ANTRIOR 123456 '
	exec @res= dbo.verificarPp 'vend1','123456'	
	print'Teste com a palavra passe zzzzzzz '
	exec @res=dbo.verificarPp 'vend1','zzzzzzz'
COMMIT