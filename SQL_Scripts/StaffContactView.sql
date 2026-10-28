CREATE VIEW [dbo].[StaffContactView]
AS
SELECT
    staff_id,
    first_name,
    last_name,
    email,
    phon,
    role,
    staff_status
FROM dbo.Staff;
