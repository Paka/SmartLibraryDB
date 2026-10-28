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
