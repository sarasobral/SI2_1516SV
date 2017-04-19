use ISEL
--(m) Verificar a password de um utilizador; 
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
if OBJECT_ID('dbo.verificarPp') is not null
	drop proc dbo.verificarPp

go
create proc dbo.verificarPp @email varchar(100), @pp varchar(50), @res int=1 output
as
	declare @ppAtual varchar(50)
	set @ppAtual = (select palavraPasse from Utilizador where email=@email)
	set @pp = (SELECT HashBytes('MD5', @pp))
	
	if (@ppAtual=@pp)
	begin
		print 'A password a verificar está correta!'
		set @res = 0
		return 0
	end
	else
	begin
		print('A password a verificar está incorreta!')
		set @res = 1
		return 1
	end
	
go
COMMIT
