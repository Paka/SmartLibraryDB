CREATE TABLE [dbo].[Borrowing]
(
    borrowing_id   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    member_id      VARCHAR(10) NOT NULL,
    copy_id        INT NOT NULL,
    staff_id       VARCHAR(6) NOT NULL,
    borrow_date    DATETIME2 NOT NULL,
    due_date       DATETIME2 NOT NULL,
    return_date    DATETIME2 NULL,
    borrowing_status VARCHAR(50) NOT NULL,
    renewal_count  INT NOT NULL DEFAULT 0,
    note           NVARCHAR(MAX) NULL,

    CONSTRAINT FK_Borrowing_Member
        FOREIGN KEY (member_id)
        REFERENCES [dbo].[Member](member_id),

    CONSTRAINT FK_Borrowing_BookCopies
        FOREIGN KEY (copy_id)
        REFERENCES [dbo].[Book_copies](copy_id),

    CONSTRAINT FK_Borrowing_Staff
        FOREIGN KEY (staff_id)
        REFERENCES [dbo].[Staff](staff_id),

    CONSTRAINT CK_Borrowing_Status
        CHECK (borrowing_status IN (
            'Borrowed', 'Returned', 'Overdue', 'Lost'
        )),

    CONSTRAINT CK_Borrowing_RenewalCount
        CHECK (renewal_count >= 0)
);
