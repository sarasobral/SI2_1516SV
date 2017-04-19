USE master;
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'ISEL')
BEGIN
  print('Removing database named ISEL'); 
    ALTER DATABASE ISEL SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE ISEL;
END

GO
CREATE DATABASE ISEL;
print('Database named ISEL is created'); 



