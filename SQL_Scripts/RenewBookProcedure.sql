CREATE PROCEDURE [dbo].[RenewBookProcedure]
    @BorrowingID INT,
    @ExtraDays INT = 7,
    @MaxRenewals INT = 2
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;


    BEGIN TRY
        BEGIN TRANSACTION;

        IF @ExtraDays <= 0 OR @MaxRenewals < 0
        BEGIN
            ;THROW 50021, 'Invalid renewal settings.', 1;
        END

        UPDATE dbo.Borrowing WITH (UPDLOCK, HOLDLOCK)
        SET due_date = DATEADD(DAY, @ExtraDays, due_date),
            renewal_count = renewal_count + 1
        WHERE borrowing_id = @BorrowingID
          AND borrowing_status = 'Borrowed'
          AND return_date IS NULL
          AND renewal_count < @MaxRenewals;

        IF @@ROWCOUNT <> 1
        BEGIN
            ;THROW 50022, 'Cannot renew this borrowing record.', 1;
        END

        COMMIT TRANSACTION;
        PRINT 'Renew book successful.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
