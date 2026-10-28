
USE SmartLibraryDB;
GO

-- 1. รายงานการยืมและคืนหนังสือ
SELECT
    b.borrowing_id,
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    bk.title,
    b.borrow_date,
    b.due_date,
    b.return_date,
    b.borrowing_status
FROM dbo.Borrowing AS b
JOIN dbo.Member AS m
    ON b.member_id = m.member_id
JOIN dbo.Book_copies AS bc
    ON b.copy_id = bc.copy_id
JOIN dbo.Books AS bk
    ON bc.book_id = bk.book_id
ORDER BY b.borrow_date DESC;

-- 2. รายงานค่าปรับ
SELECT
    f.fine_id,
    f.borrowing_id,
    f.fine_type,
    f.fine_amount,
    f.payment_status,
    f.paid_amount,
    f.fine_date,
    f.payment_date
FROM dbo.Fine AS f
ORDER BY f.fine_id;

-- 3. รายงานการจองหนังสือ
SELECT
    r.reservation_id,
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    bk.title,
    r.reservation_date,
    r.reservation_status,
    r.queue_number,
    r.ready_date,
    r.pickup_deadline
FROM dbo.Reservation AS r
JOIN dbo.Member AS m
    ON r.member_id = m.member_id
JOIN dbo.Books AS bk
    ON r.book_id = bk.book_id
ORDER BY r.reservation_date DESC;
GO
