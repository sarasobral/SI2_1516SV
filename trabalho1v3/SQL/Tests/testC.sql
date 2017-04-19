use ISEL
SET NOCOUNT ON 
begin tran
GO
print(' ')
print('*****************************TESTE C*****************************')
print('Inserir 4 utilizadores')
	exec dbo.inserirUtilizador @email='licit1', @pp='aaaaaa', @nome='Amadeus', @morada='PT'
	exec dbo.inserirUtilizador @email='licit2', @pp='bbbbbb', @nome='Fernando', @morada='FR'
	exec dbo.inserirUtilizador @email='licit3', @pp='cccccc', @nome='Bianca', @morada='PT'
	exec dbo.inserirUtilizador @email='vend1', @pp='zzzzzzz', @nome='Jose', @morada='PT'
print('Verificar se foram colocados na BD')
	select * from dbo.Utilizador
print('Atualizar email do licit1 -> licit4') 
	update Utilizador set email='licit4' where email='licit1'
print('Verificar as alteraçoes na BD')
	select * from dbo.Utilizador
print('Atualizar nome do licit1 Amadeus->Joaquim') 
	exec dbo.atualizarUtilizador @email='licit1', @nome='Joaquim'
print('Verificar a atualizacao na BD')
	select * from dbo.Utilizador where email='licit1'
print('Atualizar morada do licit2 FR->PT') 
	exec dbo.atualizarUtilizador @email='licit2', @pp=null, @nome='Alfredo', @morada='PT'
print('Verificar a atualizacao na BD')
	select * from dbo.Utilizador where email='licit2'
print('Verificar a atualizacao na BD Historico de utilizador')
	select*  from dbo.HistoricoUtilizador
print('Atualizar palavra-passe do vend1 zzzzzz->123456') 
	exec dbo.atualizarUtilizador @email='vend1', @pp='123456', @nome=null, @morada=null
print('Verificar a atualizacao na BD')
	select * from dbo.Utilizador where email='vend1'
print('Remover utilizador licit3')
	exec dbo.apagarUtilizador @email='licit3'
print('Verificar a atualizacao na BD')
	select * from dbo.Utilizador
GO
COMMIT