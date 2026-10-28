CREATE VIEW [dbo].[BorrowingReportView]
AS
SELECT
    b.borrowing_id,
    b.member_id,
    b.copy_id,
    bc.book_id,
    bc.barcode,
    b.staff_id,
    b.borrow_date,
    b.due_date,
    b.return_date,
    b.borrowing_status,
    b.renewal_count
FROM dbo.Borrowing AS b
INNER JOIN dbo.Book_copies AS bc
    ON b.copy_id = bc.copy_id;
