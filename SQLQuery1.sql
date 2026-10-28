SELECT
    @@SERVERNAME AS ServerName,
    DB_NAME() AS DatabaseName;

SELECT name
FROM sys.tables
ORDER BY name;