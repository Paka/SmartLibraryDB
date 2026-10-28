
USE [SmartLibraryDB];
GO

/* =========================================
   1. FUNCTION: Calculate Late Fine
   ========================================= */
CREATE FUNCTION [dbo].[CalculateLateFineFunction]
(
    @BorrowingID INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Fine DECIMAL(10,2) = 0;
    DECLARE @DaysLate INT;
    DECLARE @Rate DECIMAL(10,2);

    SELECT
        @DaysLate = DATEDIFF(
            DAY,
            CAST(b.due_date AS DATE),
            CAST(COALESCE(b.return_date, GETDATE()) AS DATE)
        ),
        @Rate = mt.fine_rate_per_day
    FROM dbo.Borrowing AS b
    INNER JOIN dbo.Member AS m
        ON b.member_id = m.member_id
    INNER JOIN dbo.Member_type AS mt
        ON m.member_type_id = mt.member_type_id
    WHERE b.borrowing_id = @BorrowingID;

    IF @DaysLate > 0
        SET @Fine = @DaysLate * @Rate;

    RETURN ISNULL(@Fine, 0);
END;
GO


/* =========================================
   2. PROCEDURE: Borrow Book
   ========================================= */
CREATE PROCEDURE [dbo].[BorrowBookProcedure]
    @MemberID VARCHAR(20),
    @CopyID INT,
    @StaffID VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Member
            WHERE member_id = @MemberID
        )
            THROW 50001, 'Member not found.', 1;

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

        INSERT INTO dbo.Borrowing (
            member_id, copy_id, staff_id,
            borrow_date, due_date, return_date,
            borrowing_status, renewal_count, note
        )
        VALUES (
            @MemberID, @CopyID, @StaffID,
            GETDATE(), DATEADD(DAY, 14, GETDATE()),
            NULL, 'Borrowed', 0, NULL
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
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


/* =========================================
   3. PROCEDURE: Renew Book
   ========================================= */
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
            THROW 50021, 'Invalid renewal settings.', 1;

        UPDATE dbo.Borrowing WITH (UPDLOCK, HOLDLOCK)
        SET due_date = DATEADD(DAY, @ExtraDays, due_date),
            renewal_count = renewal_count + 1
        WHERE borrowing_id = @BorrowingID
          AND borrowing_status = 'Borrowed'
          AND return_date IS NULL
          AND renewal_count < @MaxRenewals;

        IF @@ROWCOUNT <> 1
            THROW 50022, 'Cannot renew this borrowing record.', 1;

        COMMIT TRANSACTION;
        PRINT 'Renew book successful.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


/* =========================================
   4. PROCEDURE: Return Book
   ========================================= */
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
            THROW 50011, 'Borrowing record not found or already returned.', 1;

        UPDATE dbo.Borrowing
        SET return_date = GETDATE(),
            borrowing_status = 'Returned'
        WHERE borrowing_id = @BorrowingID
          AND borrowing_status = 'Borrowed'
          AND return_date IS NULL;

        IF @@ROWCOUNT <> 1
            THROW 50012, 'Could not update borrowing record.', 1;

        UPDATE dbo.Book_copies
        SET copy_status = 'Available'
        WHERE copy_id = @CopyID
          AND copy_status = 'Borrowed';

        IF @@ROWCOUNT <> 1
            THROW 50013, 'Could not update book copy status.', 1;

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


/* =========================================
   5. TRIGGER: Prevent Delete Borrowed Copy
   ========================================= */
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
GO


/* =========================================
   6. TRIGGER: Validate Borrowing Copy
   ========================================= */
CREATE TRIGGER [dbo].[ValidateBorrowingCopyTrigger]
ON [dbo].[Borrowing]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.Book_copies AS bc
            ON i.copy_id = bc.copy_id
        WHERE i.borrowing_status = 'Borrowed'
          AND i.return_date IS NULL
          AND ISNULL(bc.copy_status, '') <> 'Available'
    )
    BEGIN
        ;THROW 50041,
            'Cannot borrow a book copy that is not available.',
            1;
    END;
END;
GO


/* =========================================
   7. VIEW: Available Book Copies
   ========================================= */
CREATE VIEW [dbo].[AvailableBookCopiesView]
AS
SELECT
    copy_id,
    book_id,
    barcode,
    copy_status
FROM dbo.Book_copies
WHERE copy_status = 'Available';
GO


/* =========================================
   8. VIEW: Book Copy Status
   ========================================= */
CREATE VIEW [dbo].[BookCopyStatusView]
AS
SELECT
    copy_id,
    book_id,
    barcode,
    copy_status
FROM dbo.Book_copies;
GO


/* =========================================
   9. VIEW: Borrowing Report
   ========================================= */
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
GO


/* =========================================
   10. VIEW: Borrowing Status Summary
   ========================================= */
CREATE VIEW [dbo].[BorrowingStatusSummaryView]
AS
SELECT
    borrowing_status,
    COUNT(*) AS total_borrowings
FROM dbo.Borrowing
GROUP BY borrowing_status;
GO


/* =========================================
   11. VIEW: Fine Summary
   ========================================= */
CREATE VIEW [dbo].[FineSummaryView]
AS
SELECT
    fine_id,
    borrowing_id,
    fine_type,
    fine_amount,
    fine_date,
    payment_status,
    paid_amount,
    payment_date,
    staff_id,
    note
FROM dbo.Fine;
GO


/* =========================================
   12. VIEW: Member Contact
   ========================================= */
CREATE VIEW [dbo].[MemberContactView]
AS
SELECT
    member_id,
    first_name,
    last_name,
    email,
    phone,
    member_type_id,
    member_status
FROM dbo.Member;
GO


/* =========================================
   13. VIEW: Overdue Borrowing
   ========================================= */
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
GO


/* =========================================
   14. VIEW: Reservation Summary
   ========================================= */
CREATE VIEW [dbo].[ReservationSummaryView]
AS
SELECT
    reservation_id,
    member_id,
    book_id,
    reservation_date,
    queue_number,
    reservation_status,
    ready_date,
    pickup_deadline,
    cancel_date
FROM dbo.Reservation;
GO


/* =========================================
   15. VIEW: Staff Contact
   ========================================= */
CREATE VIEW [dbo].[StaffContactView]
AS
SELECT
    staff_id,
    first_name,
    last_name,
    email,
    phon,
    role,
    staff_status
FROM dbo.Staff;
GO

/* =========================================
   ========================================= */
CREATE FUNCTION dbo.GetAvailableCopyCount
(
    @BookID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @AvailableCount INT;

    SELECT @AvailableCount = COUNT(*)
    FROM dbo.Book_copies
    WHERE book_id = @BookID
      AND copy_status = 'Available'
      AND is_active = 1;

    RETURN ISNULL(@AvailableCount, 0);
END;
GO

/* =========================================
   ========================================= */
CREATE VIEW [dbo].[MemberBorrowingSummaryView]
AS 
SELECT 
    m.member_id,
    COUNT(b.borrowing_id) AS total_borrowings
FROM dbo.Member AS m
LEFT JOIN dbo.Borrowing AS b
   ON m.member_id = b.member_id
GROUP BY m.member_id ;
GO