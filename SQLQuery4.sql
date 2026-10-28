
SELECT borrowing_id, copy_id, borrowing_status, return_date
FROM dbo.Borrowing
WHERE borrowing_id = 7;

SELECT copy_id, barcode, copy_status
FROM dbo.Book_copies
WHERE copy_id = 4;
