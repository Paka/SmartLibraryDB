USE SmartLibraryDB;
GO

DECLARE @MemberID VARCHAR(20) = 'MB00000001';
DECLARE @CopyID INT = 4 ;
DECLARE @StaffID VARCHAR(20) = 'ST0001';

BEGIN TRY
    BEGIN TRANSACTION;

    
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Member
        WHERE member_id = @MemberID
          
    )
        THROW 50001, 'Member not found.' , 1;

    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.Staff
        WHERE staff_id = @StaffID
    )
        THROW 50002, 'Staff not found.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Book_copies WITH (UPDLOCK, HOLDLOCK)
        WHERE copy_id = @CopyID
          AND copy_status = 'Available'
    )
        THROW 50003, 'Book copy is not available.', 1;

    INSERT INTO dbo.Borrowing
    (
        member_id,
        copy_id,
        staff_id,
        borrow_date,
        due_date,
        return_date,
        borrowing_status,
        renewal_count,
        note
    )
    VALUES
    (
        @MemberID,
        @CopyID,
        @StaffID,
        GETDATE(),DATEADD(DAY, 14, GETDATE()),
        NULL,'Borrowed',0,NULL
    );


    UPDATE dbo.Book_copies
    SET copy_status = 'Borrowed'
    WHERE copy_id = @CopyID
      AND copy_status = 'Available';

    IF @@ROWCOUNT <> 1
        THROW 50004, 'Could not update book copy status.', 1;

    COMMIT TRANSACTION;
    PRINT 'Borrow book successful.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
