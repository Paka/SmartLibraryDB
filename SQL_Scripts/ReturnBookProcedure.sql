USE SmartLibraryDB;
GO

CREATE PROCEDURE [dbo].[ReturnBookProcedure]
    @BorrowingID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CopyID INT;

        SELECT @CopyID = copy_id
        FROM dbo.Borrowing WITH (UPDLOCK, HOLDLOCK)
        WHERE borrowing_id = @BorrowingID
          AND borrowing_status = 'Borrowed'
          AND return_date IS NULL;

        IF @CopyID IS NULL
        BEGIN
            THROW 50011, 'Borrowing record not found or already returned.', 1;
        END;

        UPDATE dbo.Borrowing
        SET return_date = GETDATE(),
            borrowing_status = 'Returned'
        WHERE borrowing_id = @BorrowingID
          AND borrowing_status = 'Borrowed'
          AND return_date IS NULL;

        IF @@ROWCOUNT <> 1
        BEGIN
            THROW 50012, 'Could not update borrowing record.', 1;
        END;

        UPDATE dbo.Book_copies
        SET copy_status = 'Available'
        WHERE copy_id = @CopyID
          AND copy_status = 'Borrowed';

        IF @@ROWCOUNT <> 1
        BEGIN
            THROW 50013, 'Could not update book copy status.', 1;
        END;

        COMMIT TRANSACTION;
        PRINT 'Return book successful.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
