DECLARE @i INT = 1;

WHILE @i <= 1000
BEGIN
    INSERT INTO Books (Title, Author, ISBN, PublishedDate, Genre, ShelfLocation, CurrentStatus)
    VALUES (
        CONCAT('Book Title ', @i),
        CONCAT('Author ', ((@i - 1) % 100) + 1), -- 100 مؤلف مختلفين
        CONCAT('978-0-', FORMAT(@i, '0000000000')),
        DATEADD(YEAR, -(@i % 30), GETDATE()), -- كتب من 30 سنة الماضية
        CASE (@i % 5)
            WHEN 0 THEN 'Fiction'
            WHEN 1 THEN 'Science'
            WHEN 2 THEN 'History'
            WHEN 3 THEN 'Children'
            ELSE 'Technology'
        END,
        CONCAT('Shelf ', ((@i - 1) % 50) + 1),
        'Available'
    );
    SET @i = @i + 1;
END;



SET @i = 1;

WHILE @i <= 1000
BEGIN
    INSERT INTO Borrowers (FirstName, LastName, Email, DateOfBirth, MembershipDate)
    VALUES (
        CONCAT('FirstName', @i),
        CONCAT('LastName', @i),
        CONCAT('user', @i, '@library.com'),
        DATEADD(DAY, -((@i * 100) % 15000), GETDATE()), -- تاريخ ميلاد بين 0 و 40 سنة تقريبا
        DATEADD(DAY, -(@i % 2000), GETDATE()) -- تاريخ عضوية خلال آخر 2000 يوم
    );
    SET @i = @i + 1;
END;



DECLARE @i INT = 1;

SET @i = 1;

WHILE @i <= 1000
BEGIN
    DECLARE @loanDate DATE = DATEADD(DAY, -(@i % 365), GETDATE());
    DECLARE @dueDate DATE = DATEADD(DAY, 14, @loanDate);
    DECLARE @returnDate DATE = NULL;

    -- 75% من الكتب تم إرجاعها (بعكس 25% مازالوا مستعيرين)
    IF (@i % 4 != 0)
    BEGIN
        -- إرجاع في تاريخ بين تاريخ الإعارة و 10 أيام بعد موعد الإرجاع
        SET @returnDate = DATEADD(DAY, (@i % 25) - 5, @dueDate);
        -- نتأكد ان تاريخ الإرجاع ليس قبل تاريخ الإعارة
        IF (@returnDate < @loanDate)
            SET @returnDate = @loanDate;
    END

    INSERT INTO Loans (BookID, BorrowerID, DateBorrowed, DueDate, DateReturned)
    VALUES (
        @i + 3000, -- BookID 1-1000
        @i + 2000, -- BorrowerID 1-1000
        @loanDate,
        @dueDate,
        @returnDate
    );

    SET @i = @i + 1;
END;
