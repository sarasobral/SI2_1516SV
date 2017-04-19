use ISEL

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN

--(e) Inserir uma licitação;
--(f) Retirar uma licitação;
if OBJECT_ID('dbo.inserirLicitacao') is not null
	drop proc dbo.inserirLicitacao
if OBJECT_ID('dbo.removerLicitacao') is not null
	drop proc dbo.removerLicitacao

go
create proc dbo.inserirLicitacao @data datetime, @preco money, @email varchar(100), @artigoId int
as
	if((select unCheck from Artigo where id=@artigoId)=0) 
		RAISERROR (N'Atrigo indisponivel!',11,1)
	begin
		--VERIFICAR A DATA
		if(@data>(select dataInicio from Venda where artigoId=@artigoId) and @data<(select dataFim from Venda where artigoId=@artigoId))
		begin
			--VERIFICAR VENDADIRETA
			if(EXISTS (select precoVenda from dbo.VendaDirecta where artigoId=@artigoId))
			begin
				if(@preco>=(select precoVenda from dbo.VendaDirecta where artigoId=@artigoId)) --preco aceitavel
					begin
						if (not exists (select artigoId from dbo.Licitacao where artigoId=@artigoId))
						begin --ainda nao foi licitado
							insert into dbo.Licitacao(dataHora,preco,email,artigoId) values (@data,@preco,@email,@artigoId)
							update venda set uncheck=0 where artigoId=@artigoId
							return 0
						end
						else if (exists (select unCheck from dbo.Licitacao where artigoId=@artigoId and unCheck=1)) 
							RAISERROR (N'Artigo já licitado!',11,1)
						else
						begin --já foi licitado mas a licitacao foi retirada
							insert into dbo.Licitacao(dataHora,preco,email,artigoId) values (@data,@preco,@email,@artigoId)
							--update Leilao set uncheck=0 where artigoId=@artigoId
							return 0
						end	
							
					end
				else 
					RAISERROR (N'Verifique o valor introduzido!',11,1)
			end
			--VERIFICAR LEILAO
			else 
			begin
				if(@preco >= 0.1*(select licitacaoMin from dbo.Leilao where artigoId=@artigoId) or @preco >= 1)
				begin
					insert into dbo.Licitacao(dataHora,preco,email,artigoId) values (@data,@preco,@email,@artigoId)
					return 0
				end
				else 
					RAISERROR (N'Verifique o valor introduzido!',11,1)
			end
		end
		else
			RAISERROR (N'Impossivel concluir licitação devido à data!',11,1)
	end
	return 1

go

create proc dbo.removerLicitacao @email varchar(100), @artigoId int
as
	--ainda existem licitaçoes para remover
	if (exists (select unCheck from dbo.Licitacao where artigoId=@artigoId and email =@email and unCheck=1))
	begin
		delete dbo.Licitacao where email=@email and artigoId=@artigoId and dataHora=(select max(dataHora) from Licitacao where email=@email and artigoId=@artigoId)
		return 0
	end
	else
		RAISERROR (N'Ja nao existem licitacoes a remover para este artigo!',11,1)
	return 1

go
COMMIT
