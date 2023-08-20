--- Create a database
CREATE DATABASE music_store_DB
GO

USE music_store_DB
GO

--- Create tables

CREATE TABLE Artist (
	ArtistId INT PRIMARY KEY,
	Name NVARCHAR(255)
)

CREATE TABLE Album (
	AlbumId INT PRIMARY KEY,
	Title NVARCHAR(100),
	ArtistId INT NOT NULL,
	CONSTRAINT FK_album_artist FOREIGN KEY (ArtistId) REFERENCES Artist (ArtistId) ON DELETE CASCADE
	)

CREATE TABLE Playlist (
	PlaylistId INT PRIMARY KEY,
	Name NVARCHAR(100)
)

CREATE TABLE MediaType (
	MediaTypeId INT PRIMARY KEY,
	Name VARCHAR(50)
)

CREATE TABLE Genre (
	GenreId INT PRIMARY KEY,
	Name VARCHAR(50)
)

CREATE TABLE Track (
	TrackId INT PRIMARY KEY,
	Name NVARCHAR(255),
	AlbumId INT NOT NULL,
	MediaTypeId INT NOT NULL,
	GenreId INT NOT NULL,
	Composer NVARCHAR(255),
	Miliseconds INT,
	Bytes BIGINT,
	UnitPrice DECIMAL(10,2),
	CONSTRAINT FK_track_album FOREIGN KEY (AlbumId) REFERENCES Album (AlbumId),
	CONSTRAINT FK_track_mediatype FOREIGN KEY (MediaTypeId) REFERENCES MediaType (MediaTypeId),
	CONSTRAINT FK_track_genre FOREIGN KEY (GenreId) REFERENCES Genre (GenreId)
)

CREATE TABLE PlaylistTrack (
	PlaylistId INT,
	TrackId INT NOT NULL,
	PRIMARY KEY (PlaylistId, TrackId),
	CONSTRAINT FK_playlisttrack_track FOREIGN KEY (TrackId) REFERENCES Track (TrackId),
	CONSTRAINT FK_playlisttrack_playlist FOREIGN KEY (PlaylistId) REFERENCES Playlist (PlaylistId)
)

CREATE TABLE Employee (
	EmployeeId INT PRIMARY KEY,
	LastName VARCHAR(50),
	FirstName VARCHAR(50),
	Title VARCHAR(100),
	ReportsTo INT,
	--- Because of data in CSV file is DD-MM-YYYY format, will change BirthDate and HireDate into DATE type after loading in data
	BirthDate VARCHAR(225) 
	HireDate VARCHAR(255),  
	Address VARCHAR(255),
	City VARCHAR(50),
	State VARCHAR(50),
	Country VARCHAR(50),
	PostalCode VARCHAR(25),
	Phone VARCHAR(25),
	Fax VARCHAR(255),
	Email VARCHAR(255) UNIQUE,
	Levels VARCHAR(10),
	CONSTRAINT FK_employee_employee FOREIGN KEY (ReportsTo) REFERENCES Employee (EmployeeId)
)

CREATE TABLE Customer (
	CustomerId INT PRIMARY KEY,
	FirstName NVARCHAR(100),
	LastName NVARCHAR(100),
	Company VARCHAR(100),
	Address VARCHAR(225),
	City VARCHAR(50),
	State VARCHAR(50),
	Country VARCHAR(50),
	PostalCode VARCHAR(25),
	Phone VARCHAR(25),
	Fax VARCHAR(255),
	Email VARCHAR(255) UNIQUE,
	SupportRepId INT NOT NULL,
	CONSTRAINT FK_customer_employee FOREIGN KEY (SupportRepId) REFERENCES Employee (EmployeeId)
)

CREATE TABLE Invoice (
	InvoiceId INT PRIMARY KEY,
	CustomerId INT NOT NULL,
	InvoiceDate DATE,
	BillingAddress VARCHAR(255),
	BillingCity VARCHAR(50),
	BillingState VARCHAR(50),
	BillingCountry VARCHAR(50),
	BillingPostalCode VARCHAR(25),
	Total DECIMAL(10,2),
	CONSTRAINT FK_invoice_customer FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId)
)

CREATE TABLE InvoiceLine (
	InvoiceLineId INT PRIMARY KEY,
	InvoiceId INT NOT NULL,
	TrackId INT NOT NULL,
	UnitPrice DECIMAL(10,2),
	Quantity SMALLINT,
	CONSTRAINT FK_invoiceline_invoice FOREIGN KEY (InvoiceId) REFERENCES Invoice (InvoiceId),
	CONSTRAINT FK_invoiceline_track FOREIGN KEY (TrackId) REFERENCES Track (TrackId)
)




