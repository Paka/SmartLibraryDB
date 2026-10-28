CREATE VIEW [dbo].[OverdueBorrowingView]
AS
SELECT
    borrowing_id,
    member_id,
    copy_id,
    borrow_date,
    due_date,
    borrowing_status
FROM dbo.Borrowing
WHERE due_date < GETDATE()
    AND return_date IS NULL
    AND borrowing_status = 'Borrowed';


