use ISEL
BEGIN TRAN
--(b) Inserir, remover e actualizar informação de um artigo;
if OBJECT_ID('dbo.inserirArtigo') is not null
	drop proc dbo.inserirArtigo
if OBJECT_ID('dbo.atualizarArtigo') is not null
	drop proc dbo.atualizarArtigo
if OBJECT_ID('dbo.apagarArtigo') is not null
	drop proc dbo.apagarArtigo

go
create proc dbo.inserirArtigo @data datetime
as
	insert into dbo.Artigo(dataTempo) values (@data)
	if(@@ROWCOUNT>0) return 0
	return 1
go
create proc dbo.atualizarArtigo @update1 int, @artigoId int
AS
	declare @check int
	select @check = (select unCheck from dbo.Artigo where id=@artigoId)
	if(@check=1)
	begin
		if(@artigoId in (select artigoId from dbo.VendaDirecta))
			update dbo.VendaDirecta set precoVenda=@update1
		else
			update dbo.Leilao set valorMin=@update1
			return 0
	end
	else
		print('Artigo indesponivel para atualização.')
	return 1
go
create proc dbo.apagarArtigo @artigoId int
as
	delete from dbo.Artigo where id=@artigoId
	if(@@ROWCOUNT>0) return 0
	return 1
go
COMMIT
