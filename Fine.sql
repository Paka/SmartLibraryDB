CREATE TABLE [dbo].[Fine]
(
	fine_id        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    borrowing_id   INT NOT NULL,
    fine_type      VARCHAR(50) NOT NULL,
    fine_amount    DECIMAL(10,2) NOT NULL,
    fine_date      DATETIME2 NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    paid_amount    DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_date   DATETIME2 NULL,
    staff_id       VARCHAR(6) NOT NULL,
    note           NVARCHAR(MAX) NULL,

    CONSTRAINT FK_Fine_Borrowing
        FOREIGN KEY (borrowing_id)
        REFERENCES [dbo].[Borrowing](borrowing_id),

    CONSTRAINT FK_Fine_Staff
        FOREIGN KEY (staff_id)
        REFERENCES [dbo].[Staff](staff_id),

    CONSTRAINT CK_Fine_Type
        CHECK (fine_type IN ('Overdue', 'Damaged', 'Lost')),

    CONSTRAINT CK_Fine_PaymentStatus
        CHECK (payment_status IN ('Unpaid', 'Paid', 'Partially Paid')),

    CONSTRAINT CK_Fine_Amounts
        CHECK (fine_amount >= 0 AND paid_amount >= 0)
);
