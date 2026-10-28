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
)
