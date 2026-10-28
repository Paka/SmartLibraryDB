CREATE TRIGGER [dbo].[PreventDeleteBorrowedCopyTrigger]
ON [dbo].[Book_copies]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted AS d
        INNER JOIN dbo.Borrowing AS b
            ON b.copy_id = d.copy_id
        WHERE b.borrowing_status = 'Borrowed'
          AND b.return_date IS NULL
    )
    BEGIN
        THROW 50031,
            'Cannot delete a book copy that is currently borrowed.',
            1;
    END;
END;
