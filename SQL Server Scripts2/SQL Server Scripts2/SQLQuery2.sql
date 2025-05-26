CREATE TABLE Books (
    BookID INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(255) NOT NULL,
    Author NVARCHAR(255),
    ISBN NVARCHAR(13),
    PublishedDate DATE,
    Genre NVARCHAR(100),
    ShelfLocation NVARCHAR(100),
    CurrentStatus NVARCHAR(20)
);

CREATE TABLE Borrowers (
    BorrowerID INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255),
    DateOfBirth DATE,
    MembershipDate DATE NOT NULL
);

CREATE TABLE Loans (
    LoanID INT PRIMARY KEY IDENTITY,
    BookID INT NOT NULL FOREIGN KEY REFERENCES Books(BookID),
    BorrowerID INT NOT NULL FOREIGN KEY REFERENCES Borrowers(BorrowerID),
    DateBorrowed DATE NOT NULL,
    DueDate DATE NOT NULL,
    DateReturned DATE NULL
);


