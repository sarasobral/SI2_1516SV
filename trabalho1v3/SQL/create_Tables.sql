use ISEL
begin tran

if OBJECT_ID('dbo.Compra') is not null
	drop table dbo.Compra
if OBJECT_ID('dbo.Licitacao') is not null
	drop table dbo.Licitacao
if OBJECT_ID('dbo.Venda') is not null
	drop table dbo.Venda
if OBJECT_ID('dbo.VendaDirecta') is not null
	drop table dbo.VendaDirecta
if OBJECT_ID('dbo.Leilao') is not null
	drop table dbo.Leilao
if OBJECT_ID('dbo.Artigo') is not null
	drop table dbo.Artigo
if OBJECT_ID('dbo.HistoricoUtilizador') is not null
	drop table dbo.HistoricoUtilizador
if OBJECT_ID('dbo.Utilizador') is not null
	drop table dbo.Utilizador
if OBJECT_ID('dbo.Porte') is not null
	drop table dbo.Porte
go
create table dbo.Porte(
	moradaOrigem varchar(2), 
	moradaDestino varchar(2),
	preco money not null,  
	primary key(moradaOrigem, moradaDestino),
	check (preco>0)
)

create table dbo.Utilizador(
	email varchar(30) primary key,
	nome varchar(50),
	morada varchar(2) not null,
	palavraPasse varchar(50) not null,
	unCheck bit default 1, 
	check(DATALENGTH(palavraPasse)>=6 and (unCheck=0 or unCheck=1)) 
)
go

create table dbo.HistoricoUtilizador(
	dataTempo dateTime, 
	email varchar(30),
	morada varchar(2) not null, 
	primary key(email, dataTempo),
	foreign key(email) references Utilizador(email),
)
go
create table dbo.Artigo(
	id int identity(1,1) primary key,
	dataTempo dateTime not null,
	unCheck bit default 1, 
	check(unCheck=0 or unCheck=1)
)
go
create table dbo.Leilao(
	artigoId int primary key , 
	licitacaoMin money not null, --incremento à última licit
	valorMin money not null,
	foreign key(artigoId) references Artigo(id),
	check (licitacaoMin>0 and valorMin>0)
)

create table dbo.VendaDirecta(
	artigoId int primary key, 
	precoVenda money not null,
	foreign key(artigoId) references Artigo(id),
	check (precoVenda>0)
)

create table dbo.Venda(
	artigoId int,
	email varchar(30), 
	dataInicio dateTime not null, 
	dataFim dateTime not null, 
	localOrigem varchar(2) not null, 
	condicao varchar(16) not null, 
	descricao varchar(20), 
	unCheck bit default 1, 	
	primary key(email, artigoId),
	constraint fk1_idArtigo foreign key(artigoId) references Artigo,
	constraint fk1_emailUtilizador foreign key(email) references Utilizador,
	check (condicao='Novo' or condicao='Usado' or condicao='Como novo' or condicao='Velharia vintage'),
	check (dataFim>dataInicio),
	check(unCheck=0 or unCheck=1)
)

create table dbo.Licitacao(
	artigoId int,
	email varchar(30),
	dataHora dateTime not null,
	preco money  not null,
	unCheck bit default 1, 
	primary key(email, artigoId, dataHora),
	constraint fk2_idArtigo foreign key(artigoId) references Artigo,
	constraint fk2_emailUtilizador foreign key(email) references Utilizador,
	check (preco>0 and (unCheck=0 or unCheck=1))
)

create table dbo.Compra(
	codigo int identity(1,1) primary key,
	artigoId int,
	email varchar(30),
	dataCompra dateTime not null,
	localDestino varchar(2) not null, 
	cartaoCredito int not null, 
	unCheck bit default 1, 
	constraint fk3_idArtigo foreign key(artigoId) references Artigo,
	constraint fk3_emailUtilizador foreign key(email) references Utilizador,
	check (unCheck=0 or unCheck=1)
)
go
commit

print('Finished creating tables on database ISEL.'); 

