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
FROM dbo.Reservation ;
