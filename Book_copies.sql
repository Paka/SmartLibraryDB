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
