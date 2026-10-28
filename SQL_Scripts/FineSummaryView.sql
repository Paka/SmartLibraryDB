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
FROM dbo.Fine ;
