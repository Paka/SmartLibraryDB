CREATE TABLE [dbo].[Staff]
(
	staff_id      VARCHAR(6) NOT NULL PRIMARY KEY,
	first_name    NVARCHAR(255) NOT NULL,
	last_name     NVARCHAR(255) NOT NULL,
	email         VARCHAR(255) NOT NULL,
	phon          VARCHAR(10) NULL,
	role          VARCHAR(50) NOT NULL,
	username      VARCHAR(255) NOT NULL UNIQUE,
	password_hash VARCHAR(255) NOT NULL,
	staff_status  VARCHAR(50) NOT NULL,
	created_at    DATETIME NOT NULL DEFAULT SYSDATETIME()
);
