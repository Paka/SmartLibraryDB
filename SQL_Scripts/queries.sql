USE [SmartLibraryDB];
GO

-- Query 1: JOIN at least 3 tables
-- Show borrowing records with book and staff information.
SELECT
    br.borrowing_id,
    br.member_id,
    bk.title,
    s.first_name AS staff_first_name,
    s.last_name AS staff_last_name,
    br.borrow_date,
    br.borrowing_status
FROM dbo.Borrowing AS br
INNER JOIN dbo.Book_copies AS bc
    ON br.copy_id = bc.copy_id
INNER JOIN dbo.Books AS bk
    ON bc.book_id = bk.book_id
INNER JOIN dbo.Staff AS s
    ON br.staff_id = s.staff_id;
GO

-- Query 2: GROUP BY + HAVING
-- Find members with more than one borrowing record.
SELECT
    member_id,
    COUNT(*) AS total_borrowings
FROM dbo.Borrowing
GROUP BY member_id
HAVING COUNT(*) > 1;
GO

-- Query 3: GROUP BY + HAVING
-- Find books that have more than one physical copy.
SELECT
    bk.book_id,
    bk.title,
    COUNT(bc.copy_id) AS total_copies
FROM dbo.Books AS bk
INNER JOIN dbo.Book_copies AS bc
    ON bk.book_id = bc.book_id
GROUP BY bk.book_id, bk.title
HAVING COUNT(bc.copy_id) > 1;
GO

-- Query 4: GROUP BY + HAVING
-- Find staff members who processed more than one borrowing.
SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    COUNT(br.borrowing_id) AS total_borrowings
FROM dbo.Staff AS s
INNER JOIN dbo.Borrowing AS br
    ON s.staff_id = br.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name
HAVING COUNT(br.borrowing_id) > 1;
GO

-- Query 5: Subquery
-- Find book copies that have been borrowed.
SELECT *
FROM dbo.Book_copies
WHERE copy_id IN (
    SELECT copy_id
    FROM dbo.Borrowing
);
GO

-- Query 6: Correlated subquery
-- Find members who have at least one borrowing record.
SELECT
    m.member_id,
    m.first_name,
    m.last_name
FROM dbo.Member AS m
WHERE EXISTS (
    SELECT 1
    FROM dbo.Borrowing AS br
    WHERE br.member_id = m.member_id
);
GO

-- Query 7: Subquery with AVG
-- Find copies whose IDs are above the average copy ID.
SELECT
    copy_id,
    book_id,
    barcode,
    copy_status
FROM dbo.Book_copies
WHERE copy_id > (
    SELECT AVG(CAST(copy_id AS DECIMAL(10,2)))
    FROM dbo.Book_copies
);
GO

-- Query 8: Window function RANK
-- Rank members by number of borrowing records.
SELECT
    member_id,
    COUNT(*) AS total_borrowings,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS borrowing_rank
FROM dbo.Borrowing
GROUP BY member_id;
GO

-- Query 9: Window function ROW_NUMBER
-- Number each member's borrowing records from newest to oldest.
SELECT
    borrowing_id,
    member_id,
    borrow_date,
    borrowing_status,
    ROW_NUMBER() OVER (
        PARTITION BY member_id
        ORDER BY borrow_date DESC, borrowing_id DESC
    ) AS row_num
FROM dbo.Borrowing;
GO


-- Query 10: JOIN + Subquery
-- Find borrowing records whose scheduled borrowing duration
-- is longer than the average scheduled borrowing duration.
SELECT
    br.borrowing_id,
    br.member_id,
    bk.title,
    br.borrow_date,
    br.due_date,
    br.borrowing_status
FROM dbo.Borrowing AS br
INNER JOIN dbo.Book_copies AS bc
    ON br.copy_id = bc.copy_id
INNER JOIN dbo.Books AS bk
    ON bc.book_id = bk.book_id
WHERE DATEDIFF(DAY, br.borrow_date, br.due_date) > (
    SELECT AVG(
        CAST(
            DATEDIFF(DAY, borrow_date, due_date)
            AS DECIMAL(10,2)
        )
    )
    FROM dbo.Borrowing
    WHERE due_date IS NOT NULL
);
GO
