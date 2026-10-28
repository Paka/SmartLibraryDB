
USE SmartLibraryDB;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;


--------------------------------------------------
-- 0. Member_type
--------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM dbo.Member_type
    WHERE member_type_id = '001'
)
BEGIN
    INSERT INTO dbo.Member_type (
        member_type_id,
        type_name,
        max_borrow_limit,
        borrow_duration_limit,
        max_reservation_limit,
        fine_rate_per_day,
        description
    )
    VALUES (
        '001',
        N'Undergraduate',
        5,
        14,
        3,
        5.00,
        N'Undergraduate student'
    );
END;
GO

--------------------------------------------------
-- 1. Author: target 30 records
--------------------------------------------------
DECLARE @i INT = 1;

WHILE (SELECT COUNT(*) FROM dbo.Author) < 30
   AND @i <= 1000
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Author
        WHERE author_name = N'Mock Author ' + CAST(@i AS NVARCHAR(10))
    )
    BEGIN
        INSERT INTO dbo.Author (author_name, pen_name, biography)
        VALUES (
            N'Mock Author ' + CAST(@i AS NVARCHAR(10)),
            NULL,
            N'Generated test author.'
        );
    END;

    SET @i += 1;
END;
GO

--------------------------------------------------
-- 2. Categories: target 30 records
--------------------------------------------------
DECLARE @i INT = 1;

WHILE (SELECT COUNT(*) FROM dbo.Categories) < 30
   AND @i <= 1000
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Categories
        WHERE category_name =
            N'Mock Category ' + CAST(@i AS NVARCHAR(10))
    )
    BEGIN
        INSERT INTO dbo.Categories (
            category_name, description, parent_category_id
        )
        VALUES (
            N'Mock Category ' + CAST(@i AS NVARCHAR(10)),
            N'Generated test category.',
            NULL
        );
    END;

    SET @i += 1;
END;
GO

--------------------------------------------------
-- 3. Books: target 500 records
--------------------------------------------------
DECLARE @i INT = 1;
DECLARE @AuthorID INT;
DECLARE @CategoryID INT;
DECLARE @ISBN VARCHAR(13);

WHILE (SELECT COUNT(*) FROM dbo.Books) < 500
   AND @i <= 10000
BEGIN
    SET @ISBN = '978' + RIGHT(
        '0000000000' + CAST(@i AS VARCHAR(10)), 10
    );

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Books WHERE isbn = @ISBN
    )
    BEGIN
        SET @AuthorID = NULL;
        SET @CategoryID = NULL;

        SELECT TOP (1) @AuthorID = author_id
        FROM dbo.Author
        ORDER BY author_id;

        SELECT TOP (1) @CategoryID = category_id
        FROM dbo.Categories
        ORDER BY category_id;

        IF @AuthorID IS NULL OR @CategoryID IS NULL
            THROW 50001, 'Author or Category data is missing.', 1;

        INSERT INTO dbo.Books (
            isbn, title, author_id, publisher,
            publication_year, edition, language,
            description, category_id
        )
        VALUES (
            @ISBN,
            N'Mock Book ' + CAST(@i AS NVARCHAR(10)),
            @AuthorID,
            N'Mock Publisher',
            2020 + (@i % 7),
            1,
            'TH',
            N'Generated test book.',
            @CategoryID
        );
    END;

    SET @i += 1;
END;
GO

--------------------------------------------------
-- 4. Member: target 500 records
--------------------------------------------------
DECLARE @i INT = 1;
DECLARE @MemberTypeID VARCHAR(3);

SELECT TOP (1) @MemberTypeID = member_type_id
FROM dbo.Member_type
ORDER BY member_type_id;

IF @MemberTypeID IS NULL
    THROW 50002, 'Member_type data is missing.', 1;

WHILE (SELECT COUNT(*) FROM dbo.Member) < 500
   AND @i <= 10000
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Member
        WHERE member_id =
            'MB' + RIGHT('00000000' + CAST(@i AS VARCHAR(8)), 8)
    )
    BEGIN
        INSERT INTO dbo.Member (
            member_id, first_name, last_name, email, phone,
            member_type_id, register_date, expiry_date,
            member_status, username, password_hash
        )
        VALUES (
            'MB' + RIGHT('00000000' + CAST(@i AS VARCHAR(8)), 8),
            N'MockFirst' + CAST(@i AS NVARCHAR(10)),
            N'MockLast' + CAST(@i AS NVARCHAR(10)),
            'mockmember' + CAST(@i AS VARCHAR(10)) + '@example.com',
            NULL,
            @MemberTypeID,
            '2026-01-01',
            '2027-12-31',
            'Active',
            'mockuser' + CAST(@i AS VARCHAR(10)),
            'MOCK_ONLY_NOT_FOR_LOGIN'
        );
    END;

    SET @i += 1;
END;
GO

--------------------------------------------------
-- 5. Staff, Book_copies, Borrowing,
--    Reservation and Fine
--------------------------------------------------
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @i INT = 1;
    DECLARE @StaffID VARCHAR(6);
    DECLARE @StaffName NVARCHAR(50);
    DECLARE @BookID INT;
    DECLARE @CopyID INT;
    DECLARE @MemberID VARCHAR(20);
    DECLARE @BorrowingID INT;

    --------------------------------------------------
    -- 5.1 Staff: target 20
    --------------------------------------------------
    SET @i = 1;

    WHILE (SELECT COUNT(*) FROM dbo.Staff) < 20
       AND @i <= 9999
    BEGIN
        SET @StaffID =
            'ST' + RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4);

        SET @StaffName =
            N'MockStaff' + CAST(@i AS NVARCHAR(10));

        IF NOT EXISTS (
            SELECT 1 FROM dbo.Staff
            WHERE staff_id = @StaffID
               OR username = 'mockstaff' + CAST(@i AS VARCHAR(10))
        )
        BEGIN
            INSERT INTO dbo.Staff (
                staff_id, first_name, last_name, email, phon,
                role, username, password_hash, staff_status, created_at
            )
            VALUES (
                @StaffID,
                @StaffName,
                N'Test',
                'mockstaff' + CAST(@i AS VARCHAR(10)) + '@example.com',
                NULL,
                'Librarian',
                'mockstaff' + CAST(@i AS VARCHAR(10)),
                'MOCK_ONLY_NOT_FOR_LOGIN',
                'Active',
                GETDATE()
            );
        END;

        SET @i += 1;
    END;

    IF (SELECT COUNT(*) FROM dbo.Staff) < 20
        THROW 50003, 'Could not create 20 Staff records.', 1;

    --------------------------------------------------
    -- 5.2 Book_copies: target 30
    --------------------------------------------------
    SET @i = 1;

    WHILE (SELECT COUNT(*) FROM dbo.Book_copies) < 30
       AND @i <= 99999
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM dbo.Book_copies
            WHERE barcode =
                'BC' + RIGHT('000000' + CAST(@i AS VARCHAR(6)), 6)
        )
        BEGIN
            SET @BookID = NULL;

            SELECT TOP (1) @BookID = book_id
            FROM dbo.Books
            ORDER BY book_id;

            IF @BookID IS NULL
                THROW 50004, 'Books data is missing.', 1;

            INSERT INTO dbo.Book_copies (
                book_id, barcode, acquisition_date, shelf_location,
                copy_status, condition_status, is_active
            )
            VALUES (
                @BookID,
                'BC' + RIGHT('000000' + CAST(@i AS VARCHAR(6)), 6),
                CAST(GETDATE() AS DATE),
                N'M-' + CAST(@i AS NVARCHAR(10)),
                'Available',
                'Good',
                1
            );
        END;

        SET @i += 1;
    END;

    IF (SELECT COUNT(*) FROM dbo.Book_copies) < 30
        THROW 50005, 'Could not create 30 Book_copies records.', 1;

    --------------------------------------------------
    -- 5.3 Borrowing: target 30
    -- Each new record uses a copy with no borrowing history.
    --------------------------------------------------
    SET @i = 1;

    WHILE (SELECT COUNT(*) FROM dbo.Borrowing) < 30
       AND @i <= 1000
    BEGIN
        SET @CopyID = NULL;
        SET @MemberID = NULL;
        SET @StaffID = NULL;

        SELECT TOP (1) @CopyID = bc.copy_id
        FROM dbo.Book_copies AS bc
        WHERE bc.copy_status = 'Available'
          AND bc.is_active = 1
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.Borrowing AS br
              WHERE br.copy_id = bc.copy_id
          )
        ORDER BY bc.copy_id;

        SELECT TOP (1) @MemberID = member_id
        FROM dbo.Member
        WHERE member_status = 'Active'
        ORDER BY member_id;

        SELECT TOP (1) @StaffID = staff_id
        FROM dbo.Staff
        WHERE staff_status = 'Active'
        ORDER BY staff_id;

        IF @CopyID IS NULL OR @MemberID IS NULL OR @StaffID IS NULL
            BREAK;

        INSERT INTO dbo.Borrowing (
            member_id, copy_id, staff_id,
            borrow_date, due_date, return_date,
            borrowing_status, renewal_count, note
        )
        VALUES (
            @MemberID,
            @CopyID,
            @StaffID,
            DATEADD(DAY, -30 - @i, SYSDATETIME()),
            DATEADD(DAY, -16 - @i, SYSDATETIME()),
            DATEADD(DAY, -15 - @i, SYSDATETIME()),
            'Returned',
            0,
            N'Generated mock record'
        );

        SET @i += 1;
    END;

    --------------------------------------------------
    -- 5.4 Reservation: target 20
    -- Avoid duplicate member-book pairs.
    --------------------------------------------------
    SET @i = 1;

    WHILE (SELECT COUNT(*) FROM dbo.Reservation) < 20
       AND @i <= 1000
    BEGIN
        SET @MemberID = NULL;
        SET @BookID = NULL;

        SELECT TOP (1)
            @MemberID = m.member_id,
            @BookID = b.book_id
        FROM dbo.Member AS m
        CROSS JOIN dbo.Books AS b
        WHERE m.member_status = 'Active'
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.Reservation AS r
              WHERE r.member_id = m.member_id
                AND r.book_id = b.book_id
                AND r.reservation_status = 'Waiting'
          )
        ORDER BY m.member_id, b.book_id;

        IF @MemberID IS NULL OR @BookID IS NULL
            BREAK;

        INSERT INTO dbo.Reservation (
            member_id, book_id, reservation_date, queue_number,
            reservation_status, ready_date, pickup_deadline, cancel_date
        )
        VALUES (
            @MemberID,
            @BookID,
            DATEADD(DAY, -@i, SYSDATETIME()),
            @i,
            'Waiting',
            NULL,
            NULL,
            NULL
        );

        SET @i += 1;
    END;

    --------------------------------------------------
    -- 5.5 Fine: target 20
    -- One fine per returned borrowing.
    --------------------------------------------------
    SET @i = 1;

    WHILE (SELECT COUNT(*) FROM dbo.Fine) < 20
       AND @i <= 1000
    BEGIN
        SET @BorrowingID = NULL;
        SET @StaffID = NULL;

        SELECT TOP (1)
            @BorrowingID = br.borrowing_id
        FROM dbo.Borrowing AS br
        WHERE br.borrowing_status = 'Returned'
          AND br.return_date IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.Fine AS f
              WHERE f.borrowing_id = br.borrowing_id
          )
        ORDER BY br.borrowing_id;

        SELECT TOP (1) @StaffID = staff_id
        FROM dbo.Staff
        WHERE staff_status = 'Active'
        ORDER BY staff_id;

        IF @BorrowingID IS NULL OR @StaffID IS NULL
            BREAK;

        INSERT INTO dbo.Fine (
            borrowing_id, fine_type, fine_amount, fine_date,
            payment_status, paid_amount, payment_date, staff_id, note
        )
        VALUES (
            @BorrowingID,
            'Overdue',
            5.00,
            SYSDATETIME(),
            'Unpaid',
            0.00,
            NULL,
            @StaffID,
            N'Generated mock fine'
        );

        SET @i += 1;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

--------------------------------------------------
-- 6. Verify record counts
--------------------------------------------------
SELECT 'Member_type' AS TableName, COUNT(*) AS TotalRecords
FROM dbo.Member_type
UNION ALL
SELECT 'Author', COUNT(*) FROM dbo.Author
UNION ALL
SELECT 'Categories', COUNT(*) FROM dbo.Categories
UNION ALL
SELECT 'Books', COUNT(*) FROM dbo.Books
UNION ALL
SELECT 'Member', COUNT(*) FROM dbo.Member
UNION ALL
SELECT 'Staff', COUNT(*) FROM dbo.Staff
UNION ALL
SELECT 'Book_copies', COUNT(*) FROM dbo.Book_copies
UNION ALL
SELECT 'Borrowing', COUNT(*) FROM dbo.Borrowing
UNION ALL
SELECT 'Reservation', COUNT(*) FROM dbo.Reservation
UNION ALL
SELECT 'Fine', COUNT(*) FROM dbo.Fine;
GO
