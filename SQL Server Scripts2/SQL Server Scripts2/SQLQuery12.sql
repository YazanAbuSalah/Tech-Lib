-- 1
SELECT  b.Title
FROM BOOKS b JOIN Loans l ON b.BookID =l.BookID 
JOIN Borrowers bo ON l.BorrowerID = bo.BorrowerID
WHERE bo.FirstName = 'FirstName1' and bo.LastName = 'LastName1';


