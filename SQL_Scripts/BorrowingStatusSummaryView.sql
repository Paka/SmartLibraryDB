CREATE VIEW [dbo].[BorrowingStatusSummaryView]
AS 
SELECT 
    borrowing_status,
    COUNT(*) AS total_borrowwings
FROM dbo.Borrowing
GROUP BY borrowing_status ;
