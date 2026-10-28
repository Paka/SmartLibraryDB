CREATE TABLE [dbo].[Author]
(
	[author_id]   INT IDENTITY(1,1) NOT NULL,
	[author_name] NVARCHAR(255) NOT NULL,
	[pen_name]    NVARCHAR(255)  NULL,
	[biography]   NVARCHAR(MAX)  NULL,

	CONSTRAINT [PK_Author]
	    PRIMARY KEY ([author_id])
);
