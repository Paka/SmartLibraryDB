
USE SmartLibraryDB;
GO

DECLARE @Search NVARCHAR(100) = N'คอมพิวเตอร์';

SELECT
    b.book_id,
    b.isbn,
    b.title,
    a.author_name,
    c.category_name,
    bc.copy_id,
    bc.barcode,
    bc.copy_status
FROM dbo.Books AS b
LEFT JOIN dbo.Author AS a
    ON b.author_id = a.author_id
LEFT JOIN dbo.Categories AS c
    ON b.category_id = c.category_id
LEFT JOIN dbo.Book_copies AS bc
    ON b.book_id = bc.book_id
WHERE b.title LIKE N'%' + @Search + N'%'
   OR a.author_name LIKE N'%' + @Search + N'%'
   OR c.category_name LIKE N'%' + @Search + N'%'
ORDER BY b.title, bc.copy_id;
GO
