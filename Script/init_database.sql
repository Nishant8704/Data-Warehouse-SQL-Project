-- Create Database 'DataWarehouse'

USE master;
Go
-- Check the database
IF exists (select 1 FROM sys.databases Where name ='DataWarehouse') 
BEGIN
	ALTER Database DataWarehouse SET SINGLE_USER WITH Rollback immediate;
	DROP Database DataWarehouse;
END;
GO
Create Database DataWarehouse;
GO
USE DataWarehouse;

GO
-- Create Schema
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
