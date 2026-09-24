/*

Initially, this script creates a new database called "WareHouse". 
Additionally, the script builds three schemas within the database : "bronz", "silver", "gold".


============================


P.S : An extra case can be added to check whether the database has already created and if yes,it drops the previous database to prevent possible conflicts.  

*/


USE master;

-- CREATE DATABASE

CREATE DATABASE WareHouse;
GO
USE WareHouse;

-- CREATE SCHEMAS

CREATE SCHEMA bronze;
GO


CREATE SCHEMA silver;
GO

  
CREATE SCHEMA gold;
GO

