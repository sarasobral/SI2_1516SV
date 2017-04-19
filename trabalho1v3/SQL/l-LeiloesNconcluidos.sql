use ISEL
set nocount on

--(l) Listar os leilões que não foram concluídos; 
if OBJECT_ID('dbo.leilaoNaoConcluido') is not null
	drop view dbo.leilaoNaoConcluido

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN

go
create view dbo.leilaoNaoConcluido
as
	-- nao vendido -- nao licitado --nao comprado
	(select Leilao.artigoId as lid from Leilao 
		where Leilao.artigoId NOT IN (select Venda.artigoId from Venda) 
		or Leilao.artigoId NOT IN(select Licitacao.artigoId from Licitacao) 
		or Leilao.artigoId NOT IN (select Compra.artigoId from Compra) 
	) union
	-- perdeu validade de data -- foi comprado passado 2 dias
	(select Venda.artigoId as vid from Venda join Compra on (Venda.artigoId=Compra.artigoId)
		where Venda.dataFim<GETDATE() and Venda.artigoId in (select Leilao.artigoId from Leilao) and dataCompra>dataFim+2
	) union
	-- preco nao atingido
	(select Licitacao.artigoId as lllid from Licitacao join Leilao on(Licitacao.artigoId=Leilao.artigoId) 
		where preco<(valorMin)
	) 
	
go

COMMIT
