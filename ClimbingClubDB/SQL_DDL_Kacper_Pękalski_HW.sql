-- Create the ClimbingClubDB database
CREATE DATABASE ClimbingClubDB;

--Create the schema
CREATE SCHEMA mountaineering;

-- Creating table Countries to store Country names
CREATE TABLE IF NOT EXISTS mountaineering.Countries (
    CountryID SERIAL PRIMARY KEY,
    Name VARCHAR(60) NOT NULL UNIQUE
);

-- Creating table Locations to store mountainous locations
CREATE TABLE IF NOT EXISTS mountaineering.Locations (
    LocationID SERIAL PRIMARY KEY,
    CountryID INT NOT NULL,
    Area VARCHAR(50) NOT NULL,
    Region VARCHAR(100) DEFAULT 'Unknown',
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID),
    CONSTRAINT unique_country_area UNIQUE (CountryID, Area)
);

-- Creating table Mountains to store mountain information
CREATE TABLE IF NOT EXISTS mountaineering.Mountains (
    MountainID SERIAL PRIMARY KEY,
    Name VARCHAR(60) NOT NULL,
    Height INT NOT NULL,
    LocationID INT NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    CONSTRAINT unique_mountain_location UNIQUE (LocationID, Name)
);

-- Creating table Cities to store city information
CREATE TABLE IF NOT EXISTS mountaineering.Cities (
    CityID SERIAL PRIMARY KEY,
    Name VARCHAR NOT NULL,
    LocationID INT NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    CONSTRAINT unique_city_location UNIQUE (LocationID, Name)
);

-- Creating table Addresses to store address information
CREATE TABLE IF NOT EXISTS mountaineering.Addresses (
    AddressID SERIAL PRIMARY KEY,
    CityID INT NOT NULL,
    Street VARCHAR(60) NOT NULL,
    PostalCode VARCHAR(20),
    CONSTRAINT chk_postal_code_format CHECK (PostalCode LIKE '%-%'),
    FOREIGN KEY (CityID) REFERENCES Cities(CityID)
);

-- Creating table Clubs to store information about climbing clubs
CREATE TABLE IF NOT EXISTS mountaineering.Clubs (
    ClubID SERIAL PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    LocationID INT NOT NULL,
    FoundedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP CHECK (FoundedDate >= '2000-01-01'), -- Assuming default is the current timestamp
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    CONSTRAINT unique_club_location UNIQUE (LocationID, Name)
);

-- Creating table Equipments to store information about climbing equipment
CREATE TABLE IF NOT EXISTS mountaineering.Equipments (
    EquipmentID SERIAL PRIMARY KEY,
    Name VARCHAR(40) NOT NULL,
    ClubID INT NOT NULL,
    Condition VARCHAR(20) DEFAULT 'New',
    EquipmentType VARCHAR(30),
    Availability VARCHAR(15) DEFAULT 'Available',
    DateAdded TIMESTAMP DEFAULT CURRENT_TIMESTAMP CHECK (DateAdded >= '2000-01-01'),
    CONSTRAINT chk_condition_values CHECK (Condition IN ('New', 'Used', 'Damaged', 'Under Repair')),
    CONSTRAINT chk_type_values CHECK (EquipmentType IN ('Climbing Gear', 'Tents', 'Ropes', 'Hiking Boots', 'Camping Stoves')),
    CONSTRAINT chk_avail_values CHECK (Availability IN ('Available', 'Unavailable')),
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID)
);

-- Creating table Climbers to store information about climbers
CREATE TABLE IF NOT EXISTS mountaineering.Climbers (
    ClimberID SERIAL PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Surname VARCHAR(30) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    AddressID INT NOT NULL,
    ClubID INT,
    CONSTRAINT chk_phone CHECK (Phone not like '%[^0-9]%'),
    FOREIGN KEY (AddressID) REFERENCES Addresses(AddressID),
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID)
);

-- Creating table EquipmentRentals to store information about equipment rentals
CREATE TABLE IF NOT EXISTS mountaineering.EquipmentRentals (
    RentalID SERIAL PRIMARY KEY,
    ClimberID INT NOT NULL,
    EquipmentID INT NOT NULL,
    StartDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (StartDate >= '2000-01-01'),
    PlannedEndDate TIMESTAMP CHECK (PlannedEndDate >= '2000-01-01'),
    ReturnDate TIMESTAMP,
    Fee DECIMAL CHECK (Fee >= 0),
    FOREIGN KEY (EquipmentID) REFERENCES Equipments(EquipmentID),
    FOREIGN KEY (ClimberID) REFERENCES Climbers(ClimberID),
    CONSTRAINT check_end_date CHECK (ReturnDate >= StartDate OR ReturnDate IS NULL)
);

CREATE TABLE IF NOT EXISTS mountaineering.Climbings (
	ClimbingID SERIAL PRIMARY KEY,
	ClimberID INT NOT NULL,
	MountainID INT NOT NULL,
	StartDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (StartDate >= '2000-01-01'),
	EndDate TIMESTAMP,
	CONSTRAINT check_end_date CHECK (EndDate >= StartDate OR EndDate IS NULL)
);


-- Inserting values into the Countries table
INSERT INTO mountaineering.Countries (Name) 
SELECT 'Germany'
WHERE NOT EXISTS (SELECT 1 FROM Countries WHERE Name = 'Germany')
RETURNING CountryID;

INSERT INTO mountaineering.Countries (Name) 
SELECT 'Spain'
WHERE NOT EXISTS (SELECT 1 FROM Countries WHERE Name = 'Spain')
RETURNING CountryID;

INSERT INTO mountaineering.Countries (Name) 
SELECT 'Nepal'
WHERE NOT EXISTS (SELECT 1 FROM Countries WHERE Name = 'Nepal')
RETURNING CountryID;

INSERT INTO mountaineering.Countries (Name) 
SELECT 'USA'
WHERE NOT EXISTS (SELECT 1 FROM Countries WHERE Name = 'USA')
RETURNING CountryID;

INSERT INTO mountaineering.Countries (Name) 
SELECT 'Switzerland'
WHERE NOT EXISTS (SELECT 1 FROM Countries WHERE Name = 'Switzerland')
RETURNING CountryID;

-- Inserting values into the Locations table
INSERT INTO mountaineering.Locations (CountryID, Area, Region)
SELECT 
    (SELECT CountryID FROM Countries WHERE Name = 'Nepal'),
    'Himalayas',
    'Asia'
WHERE NOT EXISTS (SELECT 1 FROM Locations WHERE CountryID = (SELECT CountryID FROM Countries WHERE Name = 'Nepal') AND Area = 'Himalayas' AND Region = 'Asia')
RETURNING LocationID;

INSERT INTO mountaineering.Locations (CountryID, Area, Region)
SELECT 
    (SELECT CountryID FROM Countries WHERE Name = 'USA'),
    'Yosemite Valley',
    'North America'
WHERE NOT EXISTS (SELECT 1 FROM Locations WHERE CountryID = (SELECT CountryID FROM Countries WHERE Name = 'USA') AND Area = 'Yosemite Valley' AND Region = 'North America')
RETURNING LocationID;

INSERT INTO mountaineering.Locations (CountryID, Area, Region)
SELECT 
    (SELECT CountryID FROM Countries WHERE Name = 'Switzerland'),
    'Swiss Alps',
    'Europe'
WHERE NOT EXISTS (SELECT 1 FROM Locations WHERE CountryID = (SELECT CountryID FROM Countries WHERE Name = 'Switzerland') AND Area = 'Swiss Alps' AND Region = 'Europe')
RETURNING LocationID;


-- Inserting values into the Mountains table
INSERT INTO mountaineering.Mountains (Name, Height, LocationID)
SELECT 
    'Mount Everest',
    8848,
    (SELECT LocationID FROM Locations WHERE Area = 'Himalayas' AND Region = 'Asia')
WHERE NOT EXISTS (SELECT 1 FROM Mountains WHERE Name = 'Mount Everest' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Himalayas' AND Region = 'Asia'))
RETURNING MountainID;

INSERT INTO mountaineering.Mountains (Name, Height, LocationID)
SELECT 
    'El Capitan',
    2307,
    (SELECT LocationID FROM Locations WHERE Area = 'Yosemite Valley' AND Region = 'North America')
WHERE NOT EXISTS (SELECT 1 FROM Mountains WHERE Name = 'El Capitan' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Yosemite Valley' AND Region = 'North America'))
RETURNING MountainID;

INSERT INTO mountaineering.Mountains (Name, Height, LocationID)
SELECT 
    'Matterhorn',
    4478,
    (SELECT LocationID FROM Locations WHERE Area = 'Swiss Alps' AND Region = 'Europe')
WHERE NOT EXISTS (SELECT 1 FROM Mountains WHERE Name = 'Matterhorn' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Swiss Alps' AND Region = 'Europe'))
RETURNING MountainID;


-- Inserting values into the Cities table
INSERT INTO mountaineering.Cities (Name, LocationID)
SELECT 
    'Kathmandu',
    (SELECT LocationID FROM Locations WHERE Area = 'Himalayas' AND Region = 'Asia')
WHERE NOT EXISTS (SELECT 1 FROM Cities WHERE Name = 'Kathmandu' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Himalayas' AND Region = 'Asia'))
RETURNING CityID;

INSERT INTO mountaineering.Cities (Name, LocationID)
SELECT 
    'Yosemite Village',
    (SELECT LocationID FROM Locations WHERE Area = 'Yosemite Valley' AND Region = 'North America')
WHERE NOT EXISTS (SELECT 1 FROM Cities WHERE Name = 'Yosemite Village' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Yosemite Valley' AND Region = 'North America'))
RETURNING CityID;

INSERT INTO mountaineering.Cities (Name, LocationID)
SELECT 
    'Zermatt',
    (SELECT LocationID FROM Locations WHERE Area = 'Swiss Alps' AND Region = 'Europe')
WHERE NOT EXISTS (SELECT 1 FROM Cities WHERE Name = 'Zermatt' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Swiss Alps' AND Region = 'Europe'))
RETURNING CityID;


-- Inserting values into the Addresses table
INSERT INTO mountaineering.Addresses (CityID, Street, PostalCode)
SELECT 
    (SELECT CityID FROM Cities WHERE Name = 'Kathmandu'),
    'Thamel Road',
    '44-600'
WHERE NOT EXISTS (SELECT 1 FROM Addresses WHERE CityID = (SELECT CityID FROM Cities WHERE Name = 'Kathmandu') AND Street = 'Thamel Road' AND PostalCode = '44600')
RETURNING AddressID;

INSERT INTO mountaineering.Addresses (CityID, Street, PostalCode)
SELECT 
    (SELECT CityID FROM Cities WHERE Name = 'Yosemite Village'),
    'El Capitan Road',
    '95-389'
WHERE NOT EXISTS (SELECT 1 FROM Addresses WHERE CityID = (SELECT CityID FROM Cities WHERE Name = 'Yosemite Village') AND Street = 'El Capitan Road' AND PostalCode = '95389')
RETURNING AddressID;

INSERT INTO mountaineering.Addresses (CityID, Street, PostalCode)
SELECT 
    (SELECT CityID FROM Cities WHERE Name = 'Zermatt'),
    'Bahnhofstrasse',
    '39-20'
WHERE NOT EXISTS (SELECT 1 FROM Addresses WHERE CityID = (SELECT CityID FROM Cities WHERE Name = 'Zermatt') AND Street = 'Bahnhofstrasse' AND PostalCode = '3920')
RETURNING AddressID;


-- Inserting values into the Clubs table
INSERT INTO mountaineering.Clubs (Name, LocationID)
SELECT 
    'Himalayan Climbing Club',
    (SELECT LocationID FROM Locations WHERE Area = 'Himalayas' AND Region = 'Asia')
WHERE NOT EXISTS (SELECT 1 FROM Clubs WHERE Name = 'Himalayan Climbing Club' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Himalayas' AND Region = 'Asia'))
RETURNING ClubID;

INSERT INTO mountaineering.Clubs (Name, LocationID)
SELECT 
    'Yosemite Climbers Association',
    (SELECT LocationID FROM Locations WHERE Area = 'Yosemite Valley' AND Region = 'North America')
WHERE NOT EXISTS (SELECT 1 FROM Clubs WHERE Name = 'Yosemite Climbers Association' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Yosemite Valley' AND Region = 'North America'))
RETURNING ClubID;

INSERT INTO mountaineering.Clubs (Name, LocationID)
SELECT 
    'Swiss Alpine Club',
    (SELECT LocationID FROM Locations WHERE Area = 'Swiss Alps' AND Region = 'Europe')
WHERE NOT EXISTS (SELECT 1 FROM Clubs WHERE Name = 'Swiss Alpine Club' AND LocationID = (SELECT LocationID FROM Locations WHERE Area = 'Swiss Alps' AND Region = 'Europe'))
RETURNING ClubID;


-- Inserting values into the Equipments table
INSERT INTO mountaineering.Equipments (Name, ClubID, EquipmentType)
SELECT 
    'Climbing Rope',
    (SELECT ClubID FROM Clubs WHERE Name = 'Himalayan Climbing Club'),
    'Ropes'
WHERE NOT EXISTS (SELECT 1 FROM Equipments WHERE Name = 'Climbing Rope' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Himalayan Climbing Club'))
RETURNING EquipmentID;

INSERT INTO mountaineering.Equipments (Name, ClubID, EquipmentType)
SELECT 
    'Tent',
    (SELECT ClubID FROM Clubs WHERE Name = 'Yosemite Climbers Association'),
    'Tents'
WHERE NOT EXISTS (SELECT 1 FROM Equipments WHERE Name = 'Tent' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Yosemite Climbers Association'))
RETURNING EquipmentID;

INSERT INTO mountaineering.Equipments (Name, ClubID, EquipmentType)
SELECT 
    'Climbing Shoes',
    (SELECT ClubID FROM Clubs WHERE Name = 'Swiss Alpine Club'),
    'Hiking Boots'
WHERE NOT EXISTS (SELECT 1 FROM Equipments WHERE Name = 'Climbing Shoes' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Swiss Alpine Club'))
RETURNING EquipmentID;


-- Inserting values into the Climbers table
INSERT INTO mountaineering.Climbers (Name, Surname, Phone, AddressID, ClubID)
SELECT 
    'John',
    'Doe',
    '123456789',
    (SELECT AddressID FROM Addresses WHERE Street = 'Thamel Road' AND PostalCode = '44-600'),
    (SELECT ClubID FROM Clubs WHERE Name = 'Himalayan Climbing Club')
WHERE NOT EXISTS (SELECT 1 FROM Climbers WHERE Name = 'John' AND Surname = 'Doe' AND Phone = '123456789' AND AddressID = (SELECT AddressID FROM Addresses WHERE Street = 'Thamel Road' AND PostalCode = '44600') AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Himalayan Climbing Club'))
RETURNING ClimberID;

INSERT INTO mountaineering.Climbers (Name, Surname, Phone, AddressID, ClubID)
SELECT 
    'Alice',
    'Smith',
    '987654321',
    (SELECT AddressID FROM Addresses WHERE Street = 'El Capitan Road' AND PostalCode = '95-389'),
    (SELECT ClubID FROM Clubs WHERE Name = 'Yosemite Climbers Association')
WHERE NOT EXISTS (SELECT 1 FROM Climbers WHERE Name = 'Alice' AND Surname = 'Smith' AND Phone = '987654321' AND AddressID = (SELECT AddressID FROM Addresses WHERE Street = 'El Capitan Road' AND PostalCode = '95389') AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Yosemite Climbers Association'))
RETURNING ClimberID;

INSERT INTO mountaineering.Climbers (Name, Surname, Phone, AddressID, ClubID)
SELECT 
    'Bob',
    'Johnson',
    '555123456',
    (SELECT AddressID FROM Addresses WHERE Street = 'Bahnhofstrasse' AND PostalCode = '39-20'),
    (SELECT ClubID FROM Clubs WHERE Name = 'Swiss Alpine Club')
WHERE NOT EXISTS (SELECT 1 FROM Climbers WHERE Name = 'Bob' AND Surname = 'Johnson' AND Phone = '555123456' AND AddressID = (SELECT AddressID FROM Addresses WHERE Street = 'Bahnhofstrasse' AND PostalCode = '3920') AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Swiss Alpine Club'))
RETURNING ClimberID;


-- Inserting values into the EquipmentRentals table
INSERT INTO mountaineering.EquipmentRentals (ClimberID, EquipmentID, StartDate, PlannedEndDate, Fee)
SELECT 
    (SELECT ClimberID FROM Climbers WHERE Name = 'John' AND Surname = 'Doe'),
    (SELECT EquipmentID FROM Equipments WHERE Name = 'Climbing Rope' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Himalayan Climbing Club')),
    '2024-03-01',
    '2024-03-15',
    50.00
WHERE NOT EXISTS (SELECT 1 FROM EquipmentRentals WHERE ClimberID = (SELECT ClimberID FROM Climbers WHERE Name = 'John' AND Surname = 'Doe') AND EquipmentID = (SELECT EquipmentID FROM Equipments WHERE Name = 'Climbing Rope' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Himalayan Climbing Club')) AND StartDate = '2024-03-01')
RETURNING RentalID;

INSERT INTO mountaineering.EquipmentRentals (ClimberID, EquipmentID, StartDate, PlannedEndDate, Fee)
SELECT 
    (SELECT ClimberID FROM Climbers WHERE Name = 'Alice' AND Surname = 'Smith'),
    (SELECT EquipmentID FROM Equipments WHERE Name = 'Tent' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Yosemite Climbers Association')),
    '2024-03-05',
    '2024-03-10',
    30.00
WHERE NOT EXISTS (SELECT 1 FROM EquipmentRentals WHERE ClimberID = (SELECT ClimberID FROM Climbers WHERE Name = 'Alice' AND Surname = 'Smith') AND EquipmentID = (SELECT EquipmentID FROM Equipments WHERE Name = 'Tent' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Yosemite Climbers Association')) AND StartDate = '2024-03-05')
RETURNING RentalID;

INSERT INTO mountaineering.EquipmentRentals (ClimberID, EquipmentID, StartDate, PlannedEndDate, Fee)
SELECT 
    (SELECT ClimberID FROM Climbers WHERE Name = 'Bob' AND Surname = 'Johnson'),
    (SELECT EquipmentID FROM Equipments WHERE Name = 'Climbing Shoes' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Swiss Alpine Club')),
    '2024-03-10',
    '2024-03-20',
    40.00
WHERE NOT EXISTS (SELECT 1 FROM EquipmentRentals WHERE ClimberID = (SELECT ClimberID FROM Climbers WHERE Name = 'Bob' AND Surname = 'Johnson') AND EquipmentID = (SELECT EquipmentID FROM Equipments WHERE Name = 'Climbing Shoes' AND ClubID = (SELECT ClubID FROM Clubs WHERE Name = 'Swiss Alpine Club')) AND StartDate = '2024-03-10')
RETURNING RentalID;

-- Inserting values into the Climbings table
INSERT INTO mountaineering.Climbings (ClimberID, MountainID, StartDate, EndDate) VALUES
    ((SELECT ClimberID FROM Climbers WHERE Name = 'John' AND Surname = 'Doe'),
     (SELECT MountainID FROM Mountains WHERE Name = 'Mount Everest'),
     '2024-03-01', NULL), -- Assuming the EndDate is not specified initially
    ((SELECT ClimberID FROM Climbers WHERE Name = 'Alice' AND Surname = 'Smith'),
     (SELECT MountainID FROM Mountains WHERE Name = 'El Capitan'),
     '2024-03-05', '2024-03-10'),
    ((SELECT ClimberID FROM Climbers WHERE Name = 'Bob' AND Surname = 'Johnson'),
     (SELECT MountainID FROM Mountains WHERE Name = 'Matterhorn'),
     '2024-03-10', '2024-03-20');

-- Adding record_ts field with default value to the Countries table
ALTER TABLE mountaineering.Countries
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the Locations table
ALTER TABLE mountaineering.Locations
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the Mountains table
ALTER TABLE mountaineering.Mountains
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the Cities table
ALTER TABLE mountaineering.Cities
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the Addresses table
ALTER TABLE mountaineering.Addresses
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the Clubs table
ALTER TABLE mountaineering.Clubs
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the Equipments table
ALTER TABLE mountaineering.Equipments
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the Climbers table
ALTER TABLE mountaineering.Climbers
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the EquipmentRentals table
ALTER TABLE mountaineering.EquipmentRentals
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Adding record_ts field with default value to the Climbings table
ALTER TABLE mountaineering.Climbings
ADD COLUMN IF NOT EXISTS record_ts DATE DEFAULT CURRENT_DATE NOT NULL;

-- Changing schema for tables since I forgot to create schema at the begining and I had created tables before I created schema.
ALTER TABLE addresses  SET SCHEMA mountaineering;
ALTER TABLE cities  SET SCHEMA mountaineering;
ALTER TABLE climbers  SET SCHEMA mountaineering;
ALTER TABLE climbings  SET SCHEMA mountaineering;
ALTER TABLE clubs  SET SCHEMA mountaineering;
ALTER TABLE countries SET SCHEMA mountaineering;
ALTER TABLE equipmentrentals  SET SCHEMA mountaineering;
ALTER TABLE equipments  SET SCHEMA mountaineering;
ALTER TABLE locations  SET SCHEMA mountaineering;
ALTER TABLE mountains  SET SCHEMA mountaineering;