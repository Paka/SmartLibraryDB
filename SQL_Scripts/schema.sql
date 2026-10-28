CREATE TABLE [dbo].[Author]
(
	[author_id]   INT IDENTITY(1,1) NOT NULL,
	[author_name] NVARCHAR(255) NOT NULL,
	[pen_name]    NVARCHAR(255)  NULL,
	[biography]   NVARCHAR(MAX)  NULL,

	CONSTRAINT [PK_Author]
	    PRIMARY KEY ([author_id])
);


CREATE TABLE [dbo].[Categories]
(
	category_id         INT IDENTITY(1,1) PRIMARY KEY,
    category_name       NVARCHAR(255) NOT NULL,
    description         NVARCHAR(MAX) NULL,
    parent_category_id  INT NULL,

    CONSTRAINT FK_Categories_Parent
        FOREIGN KEY (parent_category_id)
        REFERENCES [dbo].[Categories](category_id)
        ON DELETE NO ACTION
);


CREATE TABLE [dbo].[Member_type]
(
	member_type_id        VARCHAR(3) PRIMARY KEY,
	type_name             NVARCHAR(50) NOT NULL,
	max_borrow_limit      INT NOT NULL,
	borrow_duration_limit INT NOT NULL,
	max_reservation_limit INT NOT NULL,
	fine_rate_per_day     DECIMAL(8,2) NOT NULL,
	description NVARCHAR(MAX) NULL
);


CREATE TABLE [dbo].[Staff]
(
	staff_id      VARCHAR(6) NOT NULL PRIMARY KEY,
	first_name    NVARCHAR(255) NOT NULL,
	last_name     NVARCHAR(255) NOT NULL,
	email         VARCHAR(255) NOT NULL,
	phon          VARCHAR(10) NULL,
	role          VARCHAR(50) NOT NULL,
	username      VARCHAR(255) NOT NULL UNIQUE,
	password_hash VARCHAR(255) NOT NULL,
	staff_status  VARCHAR(50) NOT NULL,
	created_at    DATETIME NOT NULL DEFAULT SYSDATETIME()
);


CREATE TABLE [dbo].[Books]
(
   book_id          INT IDENTITY(1,1) PRIMARY KEY,
   isbn             VARCHAR(13) UNIQUE NULL,
   title            NVARCHAR(255) NOT NULL,
   author_id        INT NOT NULL,
   publisher        NVARCHAR(255) NOT NULL,
   publication_year INT NOT NULL,
   edition          INT NOT NULL,
   language         VARCHAR(2) NOT NULL,
   description      NVARCHAR(MAX) NULL,
   category_id      INT NOT NULL,

   CONSTRAINT FK_Books_Author
      FOREIGN KEY (author_id)
      REFERENCES [dbo].[Author](author_id),

   CONSTRAINT FK_Boos_Category
      FOREIGN KEY (category_id)
      REFERENCES [dbo].[Categories](category_id)
);


CREATE TABLE [dbo].[Member]
(
	member_id      VARCHAR(10) NOT NULL PRIMARY KEY,
    first_name     NVARCHAR(255) NOT NULL,
    last_name      NVARCHAR(255) NOT NULL,
    email          VARCHAR(255) NOT NULL,
    phone          VARCHAR(10) NULL,
    member_type_id VARCHAR(3) NOT NULL,
    register_date  DATE NOT NULL,
    expiry_date    DATE NOT NULL,
    member_status  VARCHAR(50) NOT NULL,
    username       VARCHAR(255) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,

    CONSTRAINT FK_Member_MemberType
        FOREIGN KEY (member_type_id)
        REFERENCES [dbo].[Member_type](member_type_id)
);


CREATE TABLE [dbo].[Book_copies]
(
	copy_id          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	book_id          INT NOT NULL,
    barcode          VARCHAR(50) NOT NULL UNIQUE,
    acquisition_date DATE NOT NULL,
    shelf_location   NVARCHAR(255) NOT NULL,
    copy_status      VARCHAR(50) NOT NULL,
    condition_status VARCHAR(50) NOT NULL,
    is_active        BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_BookCopies_Books
        FOREIGN KEY (book_id)
        REFERENCES [dbo].[Books](book_id),

    CONSTRAINT CK_BookCopies_CopyStatus
        CHECK (copy_status IN (
            'Available', 'Borrowed', 'Reserved',
            'Repairing', 'Lost', 'Discarded'
        )),

    CONSTRAINT CK_BookCopies_ConditionStatus
        CHECK (condition_status IN (
            'New', 'Good', 'FAIR', 'Poor', 'Lost'
        ))
);


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


CREATE TABLE [dbo].[Reservation]
(
	reservation_id     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    member_id          VARCHAR(10) NOT NULL,
    book_id            INT NOT NULL,
    reservation_date   DATETIME2 NOT NULL,
    queue_number       INT NOT NULL,
    reservation_status VARCHAR(50) NOT NULL,
    ready_date         DATETIME2 NULL,
    pickup_deadline    DATETIME2 NULL,
    cancel_date        DATETIME2 NULL,

    CONSTRAINT FK_Reservation_Member
        FOREIGN KEY (member_id)
        REFERENCES [dbo].[Member](member_id),

    CONSTRAINT FK_Reservation_Books
        FOREIGN KEY (book_id)
        REFERENCES [dbo].[Books](book_id),

    CONSTRAINT CK_Reservation_Status
        CHECK (reservation_status IN (
            'Waiting', 'Ready', 'Completed',
            'Cancelled', 'Expired'
        )),

    CONSTRAINT CK_Reservation_QueueNumber
        CHECK (queue_number > 0)
);


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
