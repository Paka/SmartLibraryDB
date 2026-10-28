CREATE TRIGGER [dbo].[ValidateBorrowingCopyTrigger]
ON [dbo].[Borrowing]
AFTER INSERT	
AS
BEGIN
		SET NOCOUNT ON ;

		IF EXISTS (
		    SELECT 1 
			FROM inserted AS i
			INNER JOIN dbo.Book_copies AS bc
			   ON i.copy_id = bc.copy_id 
			WHERE i.borrowing_status = 'Borrowed'
			  AND i.return_date IS NULL
			  AND ISNULL(bc.copy_status, '') <> 'Available'
		)
		BEGIN 
		    ;THROW 50041,
			    'Cannot borrow a book copy that is not available.', 1;
		END;
		
END;
