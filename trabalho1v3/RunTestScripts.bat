echo off
echo Running sql test scripts from group 

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

sqlcmd -i %cd%\SQL\Tests\testB.sql
sqlcmd -i %cd%\SQL\Tests\testC.sql
sqlcmd -i %cd%\SQL\Tests\testD.sql
sqlcmd -i %cd%\SQL\Tests\testE.sql
sqlcmd -i %cd%\SQL\Tests\testG.sql
sqlcmd -i %cd%\SQL\Tests\testH.sql
sqlcmd -i %cd%\SQL\Tests\testI.sql
sqlcmd -i %cd%\SQL\Tests\testJ.sql
sqlcmd -i %cd%\SQL\Tests\testK.sql
sqlcmd -i %cd%\SQL\Tests\testL.sql
sqlcmd -i %cd%\SQL\Tests\testM.sql

sqlcmd -i %cd%\SQL\create_Tables.sql
set /p delExit=Press the ENTER key to exit...: