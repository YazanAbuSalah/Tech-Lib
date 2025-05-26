-- 1
SELECT  b.Title
FROM BOOKS b JOIN Loans l ON b.BookID =l.BookID 
JOIN Borrowers bo ON l.BorrowerID = bo.BorrowerID
WHERE bo.FirstName = 'FirstName1' and bo.LastName = 'LastName1';


--2

WITH ActiveBorrowers AS (
    SELECT 
        b.BorrowerID,
        b.FirstName,
        b.LastName
    FROM Borrowers b
    JOIN Loans l ON b.BorrowerID = l.BorrowerID
	WHERE DateReturned IS NULL
      AND b.BorrowerID NOT IN (
          SELECT BorrowerID 
          FROM Loans 
          WHERE DateReturned IS NOT NULL
      )
    GROUP BY b.BorrowerID, FirstName, LastName
    HAVING COUNT(*) >= 2
)
SELECT FirstName, LastName
FROM ActiveBorrowers;



