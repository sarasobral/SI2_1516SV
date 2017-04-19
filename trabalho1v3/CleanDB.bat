echo off
echo Running sql scripts from group 1
sqlcmd -i %cd%\SQL\create_DB.sql
sqlcmd -i %cd%\SQL\create_Tables.sql
sqlcmd -i %cd%\SQL\create_Triggers.sql
sqlcmd -i %cd%\SQL\b-Artigo.sql
sqlcmd -i %cd%\SQL\c-Utilizador.sql
sqlcmd -i %cd%\SQL\d-Local.sql
sqlcmd -i %cd%\SQL\e-f-Licitacao.sql
sqlcmd -i %cd%\SQL\g-h-VendaDireta_Leilao.sql
sqlcmd -i %cd%\SQL\i-ValorLicitacao.sql
sqlcmd -i %cd%\SQL\j-nLisitacoes.sql
sqlcmd -i %cd%\SQL\k-Portes.sql
sqlcmd -i %cd%\SQL\l-LeiloesNconcluidos.sql
sqlcmd -i %cd%\SQL\m-verificarPP.sql
set /p delExit=Press the ENTER key to exit...: