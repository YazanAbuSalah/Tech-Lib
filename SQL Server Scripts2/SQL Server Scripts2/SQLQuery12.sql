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



--3

WITH BorrowCounts AS (
	SELECT 
		b.BorrowerID,
		b.FirstName,
		b.LastName,
		COUNT(*) AS LoanCount
	FROM Borrowers b
    JOIN Loans l ON b.BorrowerID = l.BorrowerID	
	GROUP BY b.BorrowerID, b.FirstName, b.LastName
)
SELECT  BorrowerID, FirstName, LastName, LoanCount,
RANK() OVER(ORDER BY LoanCount DESC ) AS BorrowRank
FROM BorrowCounts 
ORDER BY BorrowRank;



--4

WITH PopularGenre AS(
	SELECT Genre , COUNT(*) AS GenreCount
	FROM Books b JOIN Loans l ON b.BookID = l.BookID
	where  DateBorrowed >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
  AND DateBorrowed <= EOMONTH(GETDATE(), -1) 
	GROUP BY Genre 
)

SELECT Genre , GenreCount ,GenreRank
FROM( SELECT Genre , GenreCount ,
RANK() OVER(ORDER BY GenreCount DESC) AS GenreRank 
From PopularGenre
)ranked
WHERE GenreRank = 1
ORDER BY GenreRank ;


--5

DROP PROCEDURE IF EXISTS sp_AddNewBorrower ;
GO
CREATE PROCEDURE sp_AddNewBorrower (@FirstName NVARCHAR(100) ,@LastName NVARCHAR(100) ,@Email NVARCHAR(255),@DateOfBirth DATE ,@MembershipDate DATE )
AS BEGIN
	IF EXISTS(SELECT 1 FROM Borrowers WHERE Email = @Email)
	BEGIN
		RAISERROR('Email already exists.', 16, 1);
		RETURN ;
	END
	INSERT INTO Borrowers(FirstName , LastName , Email , DateOfBirth  , MembershipDate  )
	VALUES( @FirstName  ,@LastName  ,@Email ,@DateOfBirth  ,@MembershipDate  )
	DECLARE @NewBorrowerID INT ;
	SET @NewBorrowerID = SCOPE_IDENTITY();
	SELECT 'Success' AS Status, 'Borrower added successfully.' AS Message, @NewBorrowerID AS BorrowerID;

END;



EXEC sp_AddNewBorrower
    @FirstName = 'yazan',
    @LastName = 'Hasan',
    @Email = 'yazanhassan@email.com',
    @DateOfBirth = '2000-02-27',
    @MembershipDate ='2000-02-27';


