CREATE VIEW [dbo].[MemberBorrowingSummaryView]
AS 
SELECT 
    m.member_id,
    COUNT(b.borrowing_id) AS total_borrowings
FROM dbo.Member AS m
LEFT JOIN dbo.Borrowing AS b
   ON m.member_id = b.member_id
GROUP BY m.member_id ;