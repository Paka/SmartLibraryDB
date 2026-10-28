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
