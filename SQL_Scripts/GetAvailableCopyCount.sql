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