USE SmartLibraryDB;
GO

DECLARE @BorrowingID INT = 7;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @CopyID INT;
    
    SELECT @CopyID = copy_id
    FROM dbo.Borrowing WITH (UPDLOCK, HOLDLOCK)
    WHERE borrowing_id = @BorrowingID
       AND borrowing_status = 'Borrowed'
       AND return_date IS NULL ;
    
    IF @CopyID IS NULL
        THROW 50001, 'Borrowing record not found or already returned.', 1;

    
    UPDATE dbo.Borrowing
    SET borrowing_status = 'Returned',
        return_date = GETDATE()
    WHERE borrowing_id = @BorrowingID
      AND borrowing_status = 'Borrowed'
      AND return_date IS NULL ;


    IF @@ROWCOUNT <> 1
        THROW 50002, 'Could not update borrowing record.', 1;

   
    UPDATE dbo.Book_copies
    SET copy_status = 'Available'
    WHERE copy_id = @CopyID 
        AND copy_status = 'Borrowed' ;

    IF @@ROWCOUNT <> 1
        THROW 50003, 'Could not update book copy status.', 1;

    COMMIT TRANSACTION;
    PRINT 'Return book successful.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
