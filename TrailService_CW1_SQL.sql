-- =============================================
-- TrailService Microservice - Complete SQL Script
-- Schema: CW1
-- Deploy to: localhost SQL Server
-- =============================================

-- Create Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CW1')
    EXEC('CREATE SCHEMA CW1');
GO

-- =============================================
-- DROP EXISTING OBJECTS (Clean Deployment)
-- =============================================
IF OBJECT_ID('CW1.trg_LogNewTrail', 'TR') IS NOT NULL
    DROP TRIGGER CW1.trg_LogNewTrail;
GO
IF OBJECT_ID('CW1.vw_TrailDetails', 'V') IS NOT NULL
    DROP VIEW CW1.vw_TrailDetails;
GO
IF OBJECT_ID('CW1.sp_InsertTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW1.sp_InsertTrail;
GO
IF OBJECT_ID('CW1.sp_GetTrailByID', 'P') IS NOT NULL
    DROP PROCEDURE CW1.sp_GetTrailByID;
GO
IF OBJECT_ID('CW1.sp_GetAllTrails', 'P') IS NOT NULL
    DROP PROCEDURE CW1.sp_GetAllTrails;
GO
IF OBJECT_ID('CW1.sp_UpdateTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW1.sp_UpdateTrail;
GO
IF OBJECT_ID('CW1.sp_DeleteTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW1.sp_DeleteTrail;
GO
IF OBJECT_ID('CW1.TrailRoute', 'U') IS NOT NULL
    DROP TABLE CW1.TrailRoute;
GO
IF OBJECT_ID('CW1.TrailLog', 'U') IS NOT NULL
    DROP TABLE CW1.TrailLog;
GO
IF OBJECT_ID('CW1.Trail', 'U') IS NOT NULL
    DROP TABLE CW1.Trail;
GO
IF OBJECT_ID('CW1.Location', 'U') IS NOT NULL
    DROP TABLE CW1.Location;
GO

-- =============================================
-- EXERCISE 4: CREATE TABLES
-- =============================================

-- Table 1: Location
CREATE TABLE CW1.Location (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    LocationName NVARCHAR(200) NOT NULL,
    Postcode NVARCHAR(20) NULL,
    Town NVARCHAR(100) NULL,
    Latitude DECIMAL(9,6) NULL,
    Longitude DECIMAL(9,6) NULL
);
GO

-- Table 2: Trail
CREATE TABLE CW1.Trail (
    TrailID INT IDENTITY(1,1) PRIMARY KEY,
    TrailName NVARCHAR(200) NOT NULL,
    Summary NVARCHAR(500) NULL,
    TrailDescription NVARCHAR(MAX) NULL,
    Length_Miles DECIMAL(5,2) NULL CHECK (Length_Miles >= 0),
    Length_Km DECIMAL(5,2) NULL CHECK (Length_Km >= 0),
    Difficulty NVARCHAR(50) NULL 
        CHECK (Difficulty IN ('Easy','Moderate','Hard','Challenging')),
    AccessibilityNotes NVARCHAR(500) NULL,
    RouteType NVARCHAR(50) NULL,
    NearestTown NVARCHAR(100) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100) NULL
);
GO

-- Table 3: TrailRoute (Link Entity)
CREATE TABLE CW1.TrailRoute (
    TrailID INT PRIMARY KEY,
    StartLocationID INT NOT NULL,
    FinishLocationID INT NOT NULL,
    CONSTRAINT FK_TrailRoute_Trail 
        FOREIGN KEY (TrailID) REFERENCES CW1.Trail(TrailID),
    CONSTRAINT FK_TrailRoute_StartLoc 
        FOREIGN KEY (StartLocationID) REFERENCES CW1.Location(LocationID),
    CONSTRAINT FK_TrailRoute_FinishLoc 
        FOREIGN KEY (FinishLocationID) REFERENCES CW1.Location(LocationID)
);
GO

-- Log Table (for Exercise 7 Trigger)
CREATE TABLE CW1.TrailLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT NOT NULL,
    TrailName NVARCHAR(200) NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    ActionBy NVARCHAR(100) NULL,
    ActionDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- =============================================
-- DEMO DATA
-- =============================================

-- Insert Locations
INSERT INTO CW1.Location (LocationName, Postcode, Town, Latitude, Longitude)
VALUES 
('Admirals Hard, Stonehouse', 'PL1 3RJ', 'Plymouth', 50.3682, -4.1567),
('Jennycliff', 'PL9 9SW', 'Plymouth', 50.3421, -4.1234),
('The Hoe', 'PL1 2PA', 'Plymouth', 50.3654, -4.1432),
('Plymbridge Woods Car Park', 'PL7 4SU', 'Plymouth', 50.4123, -4.0876),
('Shaugh Bridge', 'PL7 5HD', 'Shaugh Prior', 50.4456, -4.0321);
GO

-- Insert Trails
INSERT INTO CW1.Trail (TrailName, Summary, TrailDescription, Length_Miles,
    Length_Km, Difficulty, AccessibilityNotes, RouteType, NearestTown, CreatedBy)
VALUES 
('Plymouth Waterfront Walkway', 
 'Gentle coastal walk along Plymouth''s historic waterfront',
 'A scenic walk taking in naval history, the Hoe, and stunning coastal views. The route passes historic sites including the Royal Citadel, Smeaton''s Tower, and offers panoramic views of Plymouth Sound.',
 9.3, 14.9, 'Moderate', 'Mostly flat, some steps near Hoe', 'Linear', 
 'Plymouth', 'admin'),

('Plymbridge Circular', 
 'Woodland walk through Plymbridge Woods',
 'Beautiful circular route through ancient woodland and along the river Plym. Features include the old railway viaduct, the National Trust woodland, and abundant wildlife.',
 3.5, 5.6, 'Easy', 'Some uneven paths, suitable for families', 'Circular', 
 'Plymouth', 'admin'),

('Shaugh Prior Loop', 
 'Moorland and valley walk with river views',
 'A challenging route combining moorland terrain with river valley scenery. The walk takes you through Shaugh Prior village and along the River Plym with dramatic granite tors.',
 6.2, 10.0, 'Challenging', 'Steep sections, not suitable for wheelchairs',
 'Circular', 'Shaugh Prior', 'admin');
GO

-- Insert Trail Routes
INSERT INTO CW1.TrailRoute (TrailID, StartLocationID, FinishLocationID)
VALUES 
(1, 1, 2),  -- Plymouth Waterfront: Admirals Hard to Jennycliff
(2, 4, 4),  -- Plymbridge Circular: starts and ends at car park
(3, 5, 5);  -- Shaugh Prior Loop: starts and ends at Shaugh Bridge
GO

-- =============================================
-- EXERCISE 5: VIEW
-- =============================================

CREATE VIEW CW1.vw_TrailDetails AS
SELECT 
    t.TrailID,
    t.TrailName,
    t.Summary,
    t.TrailDescription,
    t.Length_Miles,
    t.Length_Km,
    t.Difficulty,
    t.AccessibilityNotes,
    t.RouteType,
    t.NearestTown,
    sl.LocationName AS StartLocation,
    sl.Postcode AS StartPostcode,
    sl.Town AS StartTown,
    fl.LocationName AS FinishLocation,
    fl.Postcode AS FinishPostcode,
    fl.Town AS FinishTown,
    t.CreatedDate,
    t.CreatedBy
FROM CW1.Trail t
INNER JOIN CW1.TrailRoute tr ON t.TrailID = tr.TrailID
INNER JOIN CW1.Location sl ON tr.StartLocationID = sl.LocationID
INNER JOIN CW1.Location fl ON tr.FinishLocationID = fl.LocationID;
GO

-- =============================================
-- EXERCISE 6: STORED PROCEDURES (CRUD)
-- =============================================

-- CREATE - Insert New Trail
CREATE PROCEDURE CW1.sp_InsertTrail
    @TrailName NVARCHAR(200),
    @Summary NVARCHAR(500) = NULL,
    @TrailDescription NVARCHAR(MAX) = NULL,
    @Length_Miles DECIMAL(5,2) = NULL,
    @Length_Km DECIMAL(5,2) = NULL,
    @Difficulty NVARCHAR(50) = NULL,
    @AccessibilityNotes NVARCHAR(500) = NULL,
    @RouteType NVARCHAR(50) = NULL,
    @NearestTown NVARCHAR(100) = NULL,
    @CreatedBy NVARCHAR(100) = NULL,
    @NewTrailID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO CW1.Trail (TrailName, Summary, TrailDescription,
        Length_Miles, Length_Km, Difficulty, AccessibilityNotes,
        RouteType, NearestTown, CreatedBy)
    VALUES (@TrailName, @Summary, @TrailDescription,
        @Length_Miles, @Length_Km, @Difficulty, @AccessibilityNotes,
        @RouteType, @NearestTown, @CreatedBy);
    SET @NewTrailID = SCOPE_IDENTITY();
END;
GO

-- READ - Get Single Trail by ID
CREATE PROCEDURE CW1.sp_GetTrailByID
    @TrailID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM CW1.Trail WHERE TrailID = @TrailID;
END;
GO

-- READ - Get All Trails
CREATE PROCEDURE CW1.sp_GetAllTrails
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM CW1.Trail ORDER BY TrailName;
END;
GO

-- UPDATE - Modify Existing Trail
CREATE PROCEDURE CW1.sp_UpdateTrail
    @TrailID INT,
    @TrailName NVARCHAR(200),
    @Summary NVARCHAR(500) = NULL,
    @TrailDescription NVARCHAR(MAX) = NULL,
    @Length_Miles DECIMAL(5,2) = NULL,
    @Length_Km DECIMAL(5,2) = NULL,
    @Difficulty NVARCHAR(50) = NULL,
    @AccessibilityNotes NVARCHAR(500) = NULL,
    @RouteType NVARCHAR(50) = NULL,
    @NearestTown NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE CW1.Trail SET
        TrailName = @TrailName,
        Summary = @Summary,
        TrailDescription = @TrailDescription,
        Length_Miles = @Length_Miles,
        Length_Km = @Length_Km,
        Difficulty = @Difficulty,
        AccessibilityNotes = @AccessibilityNotes,
        RouteType = @RouteType,
        NearestTown = @NearestTown
    WHERE TrailID = @TrailID;
END;
GO

-- DELETE - Remove Trail
CREATE PROCEDURE CW1.sp_DeleteTrail
    @TrailID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- First delete from TrailRoute (child table)
    DELETE FROM CW1.TrailRoute WHERE TrailID = @TrailID;
    -- Then delete from Trail
    DELETE FROM CW1.Trail WHERE TrailID = @TrailID;
END;
GO

-- =============================================
-- EXERCISE 7: TRIGGER
-- =============================================

CREATE TRIGGER CW1.trg_LogNewTrail
ON CW1.Trail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO CW1.TrailLog (TrailID, TrailName, Action, ActionBy, ActionDate)
    SELECT 
        i.TrailID,
        i.TrailName,
        'INSERT',
        COALESCE(i.CreatedBy, SYSTEM_USER),
        GETDATE()
    FROM inserted i;
END;
GO

-- =============================================
-- VERIFICATION QUERIES (for Screenshots)
-- =============================================

-- Verify Location data
PRINT '=== CW1.Location ===' 
SELECT * FROM CW1.Location;
GO

-- Verify Trail data
PRINT '=== CW1.Trail ===' 
SELECT * FROM CW1.Trail;
GO

-- Verify TrailRoute data
PRINT '=== CW1.TrailRoute ===' 
SELECT * FROM CW1.TrailRoute;
GO

-- Verify View
PRINT '=== CW1.vw_TrailDetails ===' 
SELECT * FROM CW1.vw_TrailDetails;
GO

-- Verify Log (should have entries from initial inserts due to trigger)
PRINT '=== CW1.TrailLog ===' 
SELECT * FROM CW1.TrailLog;
GO

-- =============================================
-- TEST STORED PROCEDURES
-- =============================================

-- Test INSERT
PRINT '=== Testing sp_InsertTrail ==='
DECLARE @NewID INT;
EXEC CW1.sp_InsertTrail 
    @TrailName = 'Dartmoor Discovery Trail',
    @Summary = 'Explore the wilds of Dartmoor',
    @Length_Miles = 8.5,
    @Length_Km = 13.7,
    @Difficulty = 'Hard',
    @RouteType = 'Circular',
    @NearestTown = 'Princetown',
    @CreatedBy = 'test_user',
    @NewTrailID = @NewID OUTPUT;
SELECT @NewID AS InsertedTrailID;
GO

-- Test READ
PRINT '=== Testing sp_GetAllTrails ==='
EXEC CW1.sp_GetAllTrails;
GO

-- Test UPDATE
PRINT '=== Testing sp_UpdateTrail ==='
EXEC CW1.sp_UpdateTrail 
    @TrailID = 4,
    @TrailName = 'Dartmoor Discovery Trail - Updated',
    @Summary = 'Updated: Explore the wilds of Dartmoor',
    @Length_Miles = 9.0,
    @Length_Km = 14.5,
    @Difficulty = 'Challenging';
EXEC CW1.sp_GetTrailByID @TrailID = 4;
GO

-- Check log after tests
PRINT '=== TrailLog After Tests ==='
SELECT * FROM CW1.TrailLog ORDER BY ActionDate;
GO

PRINT '=== DEPLOYMENT COMPLETE ==='
