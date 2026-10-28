CREATE VIEW [dbo].[AvailableBookCopiesView]
AS 
SELECT 
    copy_id,
    book_id,
    barcode,
    copy_status
FROM dbo.Book_copies
WHERE copy_status = 'Availabble' ;