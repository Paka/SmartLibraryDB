CREATE VIEW [dbo].[MemberContactView]
AS 
SELECT 
    member_id,
    first_name,
    last_name,
    email,
    phone,
    member_type_id,
    member_status
FROM dbo.Member ;