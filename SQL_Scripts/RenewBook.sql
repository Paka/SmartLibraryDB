USE SmartLibraryDB;
GO

DECLARE @BorrowingID INT = 8;
DECLARE @ExtraDays INT = 7;
DECLARE @MaxRenewals INT = 2;

UPDATE dbo.Borrowing
SET
    due_date = DATEADD(DAY, @ExtraDays, due_date),
    renewal_count = renewal_count + 1
WHERE borrowing_id = @BorrowingID
  AND borrowing_status = 'Borrowed'
  AND return_date IS NULL
  AND renewal_count < @MaxRenewals;

IF @@ROWCOUNT = 1
BEGIN
    PRINT 'ต่ออายุหนังสือสำเร็จ';

    SELECT
        borrowing_id,
        member_id,
        due_date,
        borrowing_status,
        renewal_count
    FROM dbo.Borrowing
    WHERE borrowing_id = @BorrowingID;
END
ELSE
BEGIN
    PRINT 'ต่ออายุไม่สำเร็จ กรุณาตรวจสอบสถานะการยืมและจำนวนครั้งที่ต่ออายุ';
END;
GO
