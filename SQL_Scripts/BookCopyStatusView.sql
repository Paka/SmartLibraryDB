CREATE VIEW [dbo].[BookCopyStatusView]
AS 
SELECT 
    copy_id,
    book_id,
    barcode,
    copy_status
FROM dbo.Book_copies ;
