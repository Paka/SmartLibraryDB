CREATE TABLE [dbo].[Categories]
(
	category_id         INT IDENTITY(1,1) PRIMARY KEY,
    category_name       NVARCHAR(255) NOT NULL,
    description         NVARCHAR(MAX) NULL,
    parent_category_id  INT NULL,

    CONSTRAINT FK_Categories_Parent
        FOREIGN KEY (parent_category_id)
        REFERENCES [dbo].[Categories](category_id)
        ON DELETE NO ACTION
);