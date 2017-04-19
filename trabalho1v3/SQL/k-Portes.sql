use ISEL
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
set nocount on
go
--(k) Obter os portes, dadas duas localizações;
if object_id('dbo.valuePorte') is not null
	drop proc dbo.valuePorte
	
go
create proc dbo.valuePorte (@locOrigem varchar(2), @locDestino varchar(2), @valorPorte int output)
as
begin
	select @valorPorte = (select preco from Porte where moradaDestino=@locDestino and moradaOrigem=@locOrigem)
	print(':'+@@ROWCOUNT)
	return 0
end
go

COMMIT

