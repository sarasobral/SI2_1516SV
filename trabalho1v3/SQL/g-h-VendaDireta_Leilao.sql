use ISEL
set nocount on
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN

--(h) Realizar a compra de um artigo de venda directa
if OBJECT_ID('dbo.efetuarCompraDireta') is not null
	drop proc dbo.efetuarCompraDireta
--(g) Concluir a compra de um leilão;
if OBJECT_ID('dbo.efetuarLeilao') is not null
	drop proc dbo.efetuarLeilao

go
-- VERIFICAR SE JA FORAM LICITADOS -----------------------------------
create proc dbo.efetuarCompraDireta @data dateTime, @locDest varchar(2), @cc int, @artigoId int
as
	if((select unCheck from Artigo where id=@artigoId)=0) 
		RAISERROR (N'Atrigo indisponovel!',11,1)
	else if(not exists (select unCheck from dbo.Licitacao where artigoId=@artigoId and unCheck=1)) 
		RAISERROR (N'Atrigo sem licitacoes!',11,1)
	else if (0 = (select unCheck from Compra where artigoId=@artigoId))
		RAISERROR (N'Compra já efetuada!',11,1)
	else if (@locDest not in (select moradaDestino from dbo.Porte))
		RAISERROR (N'Local inexistente na aplicacao!',11,1)	
/*	else if (@email not in (select email from dbo.Venda WHERE artigoId=@artigoId))
			RAISERROR (N'Nao pode conluir a compra deste artigo, apenas o vendedor!',11,1)	*/	
	else
	begin
		declare @string varchar(5000), @msg VARCHAR(500)
		declare @valorArtigo int, @valorProposto int, @user varchar(100)
		select @valorArtigo=(select TOP 1 precoVenda FROM VendaDirecta where artigoId=@artigoId)
		select @string = concat('Valor do artigo selecionado: ',@valorArtigo)
		RAISERROR (@string,11,1)
		select @valorProposto = (select max(preco) from dbo.Licitacao where artigoId=@artigoId and uncheck=1)
		select @user = (select top 1 email from dbo.Licitacao where preco=@valorProposto )
		SET @msg = RTRIM(CAST(@valorProposto AS nvarchar(10))) + N' por ' + RTRIM(CAST(@user AS nvarchar(10)));
		select @string = concat('Valor do preço proposto: ',@msg)
		RAISERROR (@string,11,1)
		if(@valorProposto<@valorArtigo)
			RAISERROR (N'Impossivel concluir compra',11,1)
		else 
		begin
			declare @porte int
			select @porte = (select preco from Porte 
							where moradaOrigem=(select localOrigem from Venda Where artigoId=@artigoId) and 
								  moradaDestino=@locDest)
			select @string = concat('Valor do porte: ',@porte)
			RAISERROR (@string,11,1)
			select @string = concat('Valor total a pagar: ',@valorProposto+@porte)
			RAISERROR (@string,11,1)
			insert into dbo.Compra(dataCompra,localDestino,cartaoCredito,email,artigoId) values	(@data,@locDest,@cc,@user,@artigoId)
			delete dbo.Artigo where id=@artigoId	--colocar o artigo indisponivel corre um trigger feito no b.sql
			return 0
		end
	end
	return 1
go
COMMIT
go
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
go
--ver o local
create proc dbo.efetuarLeilao @data dateTime, @locDest varchar(2), @cc int, @artigoId int
as	
	--declare @newLine as char(2) = char(13)+char(10)
	declare @string varchar(5000), @string2 varchar(5000)
	if((select unCheck from Artigo where id=@artigoId)=0) 
		RAISERROR (N'Atrigo indisponovel!',11,1)
	else if(not exists (select top 1 unCheck from dbo.Licitacao where artigoId=@artigoId and unCheck=1)) 
		RAISERROR (N'Atrigo sem licitacoes!',11,1)
	else if (@locDest not in (select moradaDestino from dbo.Porte))
		RAISERROR (N'Local inexistente na aplicacao!',11,1)
/*	else if (@email not in (select email from dbo.Venda WHERE artigoId=@artigoId))
			RAISERROR (N'Nao pode conluir a compra deste artigo, apenas o vendedor!',11,1)		*/
	else
		begin
			declare @valorArtigo int, @valorProposto int, @user varchar(100), @msg varchar(500)
			select @valorArtigo=(select valorMin FROM Leilao where artigoId=@artigoId)
			select @string = concat('Valor do artigo selecionado: ',@valorArtigo)
			RAISERROR (@string,11,1)
			select @valorProposto = (select max(preco) from dbo.Licitacao where artigoId=@artigoId and uncheck=1)
			select @user = (select top 1 email from dbo.Licitacao where preco=@valorProposto )
			SET @msg = RTRIM(CAST(@valorProposto AS nvarchar(10))) + N' por ' + RTRIM(CAST(@user AS nvarchar(50)));
			select @string = concat('Valor do preço proposto: ',@msg);
			RAISERROR (@string,11,1)
			if(@valorProposto<@valorArtigo and @valorProposto>0.1*(select licitacaoMin from Leilao where artigoId=@artigoId))
				RAISERROR (N'Impossivel concluir compra!',11,1)	
			else 
			begin
				declare @porte int
				select @porte =(select preco from Porte 
								where moradaOrigem=(select localOrigem from Venda Where artigoId=@artigoId) and 
									  moradaDestino=@locDest)
				select @string = concat('Valor do porte: ',@porte)
				RAISERROR (@string,11,1)
				select @string = concat('Valor total a pagar: ',@valorProposto+@porte)
				RAISERROR (@string,11,1)
				insert into dbo.Compra(dataCompra,localDestino,cartaoCredito,email,artigoId) values	(@data,@locDest,@cc,@user,@artigoId)
				delete dbo.Artigo where id=@artigoId	--colocar o artigo indisponivel corre um trigger feito no b.sql
				return 0
			end
		end	
		return 1
go

COMMIT
