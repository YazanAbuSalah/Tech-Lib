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






--6
DROP FUNCTION  IF EXISTS fn_CalculateOverdueFees ;

CREATE FUNCTION fn_CalculateOverdueFees( @LoanID INT)
RETURNS INT 
AS BEGIN 
	DECLARE @return_value INT ;
	DECLARE @DateReturned DATE
	DECLARE @DueDate DATE ;
	DECLARE @DaysDiff INT;

	SELECT @DateReturned =DateReturned , @DueDate= DueDate FROM Loans WHERE LoanID =@LoanID;

	SET @DaysDiff = DATEDIFF(day, @DueDate, @DateReturned);
	IF ( @DaysDiff <= 0 ) SET @return_value =0;
	ELSE IF ( @DaysDiff <= 30 ) SET @return_value = @DaysDiff;
	ELSE  SET @return_value = (@DaysDiff-30)*2 + 30;

	RETURN @return_value
END;





--7
DROP FUNCTION  IF EXISTS fn_BookBorrowingFrequency ;

CREATE FUNCTION fn_BookBorrowingFrequency(@bookID INT)
RETURNS INT 
AS
BEGIN
	DECLARE @return_value INT ;
	SELECT  @return_value =  Count(*) 
	FROM Loans 
	GROUP BY BookID 
	RETURN @return_value ;
	

END;




SELECT dbo.fn_BookBorrowingFrequency(3001) AS BorrowCount;






--8
SELECT FirstName, LastName, Title ,l.LoanID, l.DueDate, l.DateReturned, 
DATEDIFF(day, DueDate, ISNULL(DateReturned, GETDATE())) AS DaysOverdue
FROM Loans l JOIN Borrowers b ON l.BorrowerID = b.BorrowerID
JOIN Books bo ON l.BookID =bo.BookID

WHERE DATEDIFF(day, DueDate, ISNULL(DateReturned, GETDATE())) > 30
ORDER BY DaysOverdue DESC;




--9

WITH AuthorRank AS (
SELECT Author , COUNT(*) AuthorRank
FROM Loans l JOIN Books b ON l.BookID = b.BookID 
GROUP BY Author
)
SELECT Author ,  RANK() OVER(ORDER BY AuthorRank DESC ) AS Rank
FROM AuthorRank 
ORDER BY  Rank ;



--10

WITH BorrowerAgeGroups AS (
    SELECT 
        b.BorrowerID,
        CASE 
            WHEN Age BETWEEN 0 AND 10 THEN '0-10'
            WHEN Age BETWEEN 11 AND 20 THEN '11-20'
            WHEN Age BETWEEN 21 AND 30 THEN '21-30'
            WHEN Age BETWEEN 31 AND 40 THEN '31-40'
            WHEN Age BETWEEN 41 AND 50 THEN '41-50'
            ELSE '51+'
        END AS AgeGroup,
        bk.Genre
    FROM Borrowers b
    JOIN Loans l ON b.BorrowerID = l.BorrowerID
    JOIN Books bk ON l.BookID = bk.BookID
    CROSS APPLY (
        SELECT DATEDIFF(YEAR, b.DateOfBirth, GETDATE()) AS Age
    ) AS AgeCalc
)
, GenreCounts AS (
    SELECT 
        AgeGroup,
        Genre,
        COUNT(*) AS BorrowCount
    FROM BorrowerAgeGroups
    GROUP BY AgeGroup, Genre
)
, RankedGenres AS (
    SELECT 
        AgeGroup,
        Genre,
        BorrowCount,
        RANK() OVER (PARTITION BY AgeGroup ORDER BY BorrowCount DESC) AS GenreRank
    FROM GenreCounts
)
SELECT 
    AgeGroup,
    Genre,
    BorrowCount
FROM RankedGenres
WHERE GenreRank = 1
ORDER BY AgeGroup;



--11

CREATE PROCEDURE sp_BorrowedBooksReport(@StartDate DATE , @EndDate DATE)
AS BEGIN
	SELECT b.FirstName ,b.LastName ,l.DateBorrowed , bk.Title
	FROM Borrowers b
    JOIN Loans l ON b.BorrowerID = l.BorrowerID
    JOIN Books bk ON l.BookID = bk.BookID
	where DateBorrowed BETWEEN @StartDate AND @EndDate
	ORDER BY DateBorrowed
END ;












	

	




