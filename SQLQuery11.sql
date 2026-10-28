USE SmartLibraryDB;
GO

SELECT
    borrowing_id,
    borrowing_status,
    renewal_count,
    due_date,
    return_date
FROM dbo.Borrowing
WHERE borrowing_id = 10;

SELECT
    copy_id,
    barcode,
    copy_status
FROM dbo.Book_copies
WHERE copy_id = 5;
GO