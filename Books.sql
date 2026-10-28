CREATE TABLE [dbo].[Books]
(
   book_id          INT IDENTITY(1,1) PRIMARY KEY,
   isbn             VARCHAR(13) UNIQUE NULL,
   title            NVARCHAR(255) NOT NULL,
   author_id        INT NOT NULL,
   publisher        NVARCHAR(255) NOT NULL,
   publication_year INT NOT NULL,
   edition          INT NOT NULL,
   language         VARCHAR(2) NOT NULL,
   description      NVARCHAR(MAX) NULL,
   category_id      INT NOT NULL,

   CONSTRAINT FK_Books_Author
      FOREIGN KEY (author_id)
      REFERENCES [dbo].[Author](author_id),

   CONSTRAINT FK_Boos_Category
      FOREIGN KEY (category_id)
      REFERENCES [dbo].[Categories](category_id)
);
