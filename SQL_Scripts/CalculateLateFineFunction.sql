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
    JOIN dbo.Member AS m
        ON b.member_id = m.member_id
    JOIN dbo.Member_type AS mt
        ON m.member_type_id = mt.member_type_id
    WHERE b.borrowing_id = @BorrowingID;

    IF @DaysLate > 0
        SET @Fine = @DaysLate * @Rate;

    RETURN ISNULL(@Fine, 0);
END;
