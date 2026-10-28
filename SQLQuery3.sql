
USE SmartLibraryDB;
GO

SELECT
    borrowing_id,
    member_id,
    copy_id,
    staff_id,
    borrow_date,
    due_date,
    return_date,
    borrowing_status,
    renewal_count,
    note
FROM dbo.Borrowing
ORDER BY borrowing_id;
GO

