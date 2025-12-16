-- =============================================
-- TrailService Microservice - CW2 Implementation
-- Schema: CW2
-- Enhanced with Security, Privacy, Integrity & Preservation
-- Deploy to: localhost SQL Server
-- =============================================

-- Create Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CW2')
    EXEC('CREATE SCHEMA CW2');
GO

-- =============================================
-- DROP EXISTING OBJECTS (Clean Deployment)
-- =============================================
IF OBJECT_ID('CW2.trg_AuditTrailChanges', 'TR') IS NOT NULL
    DROP TRIGGER CW2.trg_AuditTrailChanges;
GO
IF OBJECT_ID('CW2.trg_LogNewTrail', 'TR') IS NOT NULL
    DROP TRIGGER CW2.trg_LogNewTrail;
GO
IF OBJECT_ID('CW2.trg_PreventUnauthorizedDelete', 'TR') IS NOT NULL
    DROP TRIGGER CW2.trg_PreventUnauthorizedDelete;
GO
IF OBJECT_ID('CW2.vw_TrailDetails', 'V') IS NOT NULL
    DROP VIEW CW2.vw_TrailDetails;
GO
IF OBJECT_ID('CW2.vw_PublicTrails', 'V') IS NOT NULL
    DROP VIEW CW2.vw_PublicTrails;
GO
IF OBJECT_ID('CW2.sp_InsertTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW2.sp_InsertTrail;
GO
IF OBJECT_ID('CW2.sp_GetTrailByID', 'P') IS NOT NULL
    DROP PROCEDURE CW2.sp_GetTrailByID;
GO
IF OBJECT_ID('CW2.sp_GetAllTrails', 'P') IS NOT NULL
    DROP PROCEDURE CW2.sp_GetAllTrails;
GO
IF OBJECT_ID('CW2.sp_UpdateTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW2.sp_UpdateTrail;
GO
IF OBJECT_ID('CW2.sp_DeleteTrail', 'P') IS NOT NULL
    DROP PROCEDURE CW2.sp_DeleteTrail;
GO
IF OBJECT_ID('CW2.sp_SearchTrails', 'P') IS NOT NULL
    DROP PROCEDURE CW2.sp_SearchTrails;
GO
IF OBJECT_ID('CW2.Photo', 'U') IS NOT NULL
    DROP TABLE CW2.Photo;
GO
IF OBJECT_ID('CW2.Feature', 'U') IS NOT NULL
    DROP TABLE CW2.Feature;
GO
IF OBJECT_ID('CW2.TrailFeature', 'U') IS NOT NULL
    DROP TABLE CW2.TrailFeature;
GO
IF OBJECT_ID('CW2.Transport', 'U') IS NOT NULL
    DROP TABLE CW2.Transport;
GO
IF OBJECT_ID('CW2.TrailTransport', 'U') IS NOT NULL
    DROP TABLE CW2.TrailTransport;
GO
IF OBJECT_ID('CW2.Review', 'U') IS NOT NULL
    DROP TABLE CW2.Review;
GO
IF OBJECT_ID('CW2.Weather', 'U') IS NOT NULL
    DROP TABLE CW2.Weather;
GO
IF OBJECT_ID('CW2.TrailRoute', 'U') IS NOT NULL
    DROP TABLE CW2.TrailRoute;
GO
IF OBJECT_ID('CW2.Location', 'U') IS NOT NULL
    DROP TABLE CW2.Location;
GO
IF OBJECT_ID('CW2.TrailLog', 'U') IS NOT NULL
    DROP TABLE CW2.TrailLog;
GO
IF OBJECT_ID('CW2.AuditLog', 'U') IS NOT NULL
    DROP TABLE CW2.AuditLog;
GO
IF OBJECT_ID('CW2.Trail', 'U') IS NOT NULL
    DROP TABLE CW2.Trail;
GO
IF OBJECT_ID('CW2.User', 'U') IS NOT NULL
    DROP TABLE CW2.[User];
GO

-- =============================================
-- CORE TABLES WITH ENHANCED SECURITY
-- =============================================

-- Table: User (with privacy and security features)
-- Privacy: Stores password hash (not plaintext), email validation
-- Security: Tracks creation date for audit purposes
CREATE TABLE CW2.[User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(200) NOT NULL UNIQUE 
        CHECK (Email LIKE '%_@__%.__%'),  -- Basic email validation for integrity
    PasswordHash NVARCHAR(256) NOT NULL,  -- Stored as hash for security
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastLoginDate DATETIME NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT CHK_Username_Length CHECK (LEN(Username) >= 3)
);
GO

-- Table: Location
-- Integrity: Latitude/Longitude validation
CREATE TABLE CW2.Location (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    LocationName NVARCHAR(200) NOT NULL,
    Postcode NVARCHAR(20) NULL,
    Country NVARCHAR(100) NULL DEFAULT 'UK',
    Latitude DECIMAL(9,6) NULL 
        CHECK (Latitude BETWEEN -90 AND 90),  -- Data integrity
    Longitude DECIMAL(9,6) NULL 
        CHECK (Longitude BETWEEN -180 AND 180),  -- Data integrity
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- Table: Trail (core entity with ownership tracking)
-- Security: Tracks who created/modified trail
-- Privacy: Created by links to user for accountability
-- Integrity: Check constraints for valid data
CREATE TABLE CW2.Trail (
    TrailID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,  -- Owner/creator of trail
    TrailName NVARCHAR(200) NOT NULL,
    Summary NVARCHAR(1000) NULL,
    TrailDescription NVARCHAR(MAX) NULL,
    Length_Miles DECIMAL(5,2) NULL 
        CHECK (Length_Miles >= 0),  -- Data integrity
    Length_Km DECIMAL(5,2) NULL 
        CHECK (Length_Km >= 0),  -- Data integrity
    Difficulty NVARCHAR(50) NULL 
        CHECK (Difficulty IN ('Easy','Moderate','Hard','Challenging')),
    AccessibilityNotes NVARCHAR(500) NULL,
    RouteType NVARCHAR(50) NULL,
    NearestTown NVARCHAR(100) NULL,
    StartPostcode NVARCHAR(20) NULL,
    FinishLocation NVARCHAR(200) NULL,
    FinishPostcode NVARCHAR(20) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastModifiedDate DATETIME NULL,
    LastModifiedBy INT NULL,  -- Tracks who last modified
    IsPublic BIT NOT NULL DEFAULT 1,  -- Privacy: controls visibility
    IsDeleted BIT NOT NULL DEFAULT 0,  -- Soft delete for preservation
    CONSTRAINT FK_Trail_User 
        FOREIGN KEY (UserID) REFERENCES CW2.[User](UserID),
    CONSTRAINT FK_Trail_LastModifiedBy 
        FOREIGN KEY (LastModifiedBy) REFERENCES CW2.[User](UserID)
);
GO

-- Table: TrailRoute (Enhanced with full ERD schema)
CREATE TABLE CW2.TrailRoute (
    TrailID INT NOT NULL,
    StartLocationID INT NOT NULL,
    FinishLocationID INT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_TrailRoute PRIMARY KEY (TrailID, StartLocationID),
    CONSTRAINT FK_TrailRoute_Trail 
        FOREIGN KEY (TrailID) REFERENCES CW2.Trail(TrailID) ON DELETE CASCADE,
    CONSTRAINT FK_TrailRoute_StartLoc 
        FOREIGN KEY (StartLocationID) REFERENCES CW2.Location(LocationID),
    CONSTRAINT FK_TrailRoute_FinishLoc 
        FOREIGN KEY (FinishLocationID) REFERENCES CW2.Location(LocationID)
);
GO

-- Table: Feature
CREATE TABLE CW2.Feature (
    FeatureID INT IDENTITY(1,1) PRIMARY KEY,
    FeatureName NVARCHAR(200) NOT NULL UNIQUE,
    Description NVARCHAR(500) NULL
);
GO

-- Table: TrailFeature (Many-to-Many relationship)
CREATE TABLE CW2.TrailFeature (
    TrailID INT NOT NULL,
    FeatureID INT NOT NULL,
    CONSTRAINT PK_TrailFeature PRIMARY KEY (TrailID, FeatureID),
    CONSTRAINT FK_TrailFeature_Trail 
        FOREIGN KEY (TrailID) REFERENCES CW2.Trail(TrailID) ON DELETE CASCADE,
    CONSTRAINT FK_TrailFeature_Feature 
        FOREIGN KEY (FeatureID) REFERENCES CW2.Feature(FeatureID)
);
GO

-- Table: Transport
CREATE TABLE CW2.Transport (
    TransportID INT IDENTITY(1,1) PRIMARY KEY,
    TransportType NVARCHAR(50) NOT NULL,
    Details NVARCHAR(300) NULL
);
GO

-- Table: TrailTransport (Many-to-Many relationship)
CREATE TABLE CW2.TrailTransport (
    TrailID INT NOT NULL,
    TransportID INT NOT NULL,
    CONSTRAINT PK_TrailTransport PRIMARY KEY (TrailID, TransportID),
    CONSTRAINT FK_TrailTransport_Trail 
        FOREIGN KEY (TrailID) REFERENCES CW2.Trail(TrailID) ON DELETE CASCADE,
    CONSTRAINT FK_TrailTransport_Transport 
        FOREIGN KEY (TransportID) REFERENCES CW2.Transport(TransportID)
);
GO

-- Table: Review (User-generated content)
-- Privacy: Links to user, can be moderated
-- Integrity: Rating validation
CREATE TABLE CW2.Review (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT NOT NULL,
    UserID INT NOT NULL,
    Rating INT NOT NULL 
        CHECK (Rating BETWEEN 1 AND 5),  -- Data integrity
    Title NVARCHAR(200) NULL,
    ReviewText NVARCHAR(MAX) NULL,
    HikingDate DATE NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastModifiedDate DATETIME NULL,
    IsApproved BIT NOT NULL DEFAULT 0,  -- Moderation for security
    CONSTRAINT FK_Review_Trail 
        FOREIGN KEY (TrailID) REFERENCES CW2.Trail(TrailID),
    CONSTRAINT FK_Review_User 
        FOREIGN KEY (UserID) REFERENCES CW2.[User](UserID)
);
GO

-- Table: Photo
-- Security: Tracks uploader, can be moderated
CREATE TABLE CW2.Photo (
    PhotoID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT NOT NULL,
    UserID INT NOT NULL,
    PhotoURL NVARCHAR(500) NOT NULL,
    Caption NVARCHAR(500) NULL,
    UploadDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsApproved BIT NOT NULL DEFAULT 0,  -- Moderation
    CONSTRAINT FK_Photo_Trail 
        FOREIGN KEY (TrailID) REFERENCES CW2.Trail(TrailID),
    CONSTRAINT FK_Photo_User 
        FOREIGN KEY (UserID) REFERENCES CW2.[User](UserID)
);
GO

-- Table: Weather (Historical weather data)
CREATE TABLE CW2.Weather (
    WeatherID INT IDENTITY(1,1) PRIMARY KEY,
    LocationID INT NOT NULL,
    RecordDate DATE NOT NULL,
    Temperature_C DECIMAL(4,1) NULL,
    Temperature_F DECIMAL(4,1) NULL,
    Conditions NVARCHAR(100) NULL,
    Precipitation_MM DECIMAL(5,2) NULL,
    WindSpeed_KMH DECIMAL(5,2) NULL,
    Humidity_Percent INT NULL 
        CHECK (Humidity_Percent BETWEEN 0 AND 100),
    CONSTRAINT FK_Weather_Location 
        FOREIGN KEY (LocationID) REFERENCES CW2.Location(LocationID)
);
GO

-- =============================================
-- AUDIT & LOGGING TABLES (Data Preservation & Security)
-- =============================================

-- Table: TrailLog (Operational logging)
-- Preservation: Maintains history of trail creation
CREATE TABLE CW2.TrailLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT NOT NULL,
    TrailName NVARCHAR(200) NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    ActionBy NVARCHAR(100) NULL,
    ActionDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- Table: AuditLog (Comprehensive audit trail)
-- Security: Tracks all modifications for compliance
-- Preservation: Maintains complete history
CREATE TABLE CW2.AuditLog (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128) NOT NULL,
    RecordID INT NOT NULL,
    Action NVARCHAR(50) NOT NULL,  -- INSERT, UPDATE, DELETE
    FieldChanged NVARCHAR(128) NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    ChangedBy NVARCHAR(100) NOT NULL,
    ChangedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IPAddress NVARCHAR(50) NULL  -- Can track source of changes
);
GO

-- =============================================
-- DEMO DATA
-- =============================================

-- Insert Users (passwords are hashed - in production use bcrypt)
INSERT INTO CW2.[User] (Username, Email, PasswordHash, IsActive)
VALUES 
('admin', 'admin@trailservice.com', 
 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 1),
('john_hiker', 'john@example.com',
 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 1),
('sarah_explorer', 'sarah@example.com',
 'b3a8e0e1f9ab1bfe3a36f231f676f78bb30a519d2b21e6c530c0eee8ebb4a5d0', 1);
GO

-- Insert Locations
INSERT INTO CW2.Location (LocationName, Postcode, Country, Latitude, Longitude)
VALUES 
('Admirals Hard, Stonehouse', 'PL1 3RJ', 'UK', 50.3682, -4.1567),
('Jennycliff', 'PL9 9SW', 'UK', 50.3421, -4.1234),
('The Hoe', 'PL1 2PA', 'UK', 50.3654, -4.1432),
('Plymbridge Woods Car Park', 'PL7 4SU', 'UK', 50.4123, -4.0876),
('Shaugh Bridge', 'PL7 5HD', 'UK', 50.4456, -4.0321);
GO

-- Insert Trails
INSERT INTO CW2.Trail (UserID, TrailName, Summary, TrailDescription, Length_Miles,
    Length_Km, Difficulty, AccessibilityNotes, RouteType, NearestTown, IsPublic)
VALUES 
(1, 'Plymouth Waterfront Walkway', 
 'Gentle coastal walk along Plymouth''s historic waterfront',
 'A scenic walk taking in naval history, the Hoe, and stunning coastal views. The route passes historic sites including the Royal Citadel, Smeaton''s Tower, and offers panoramic views of Plymouth Sound.',
 9.3, 14.9, 'Moderate', 'Mostly flat, some steps near Hoe', 'Linear', 
 'Plymouth', 1),

(2, 'Plymbridge Circular', 
 'Woodland walk through Plymbridge Woods',
 'Beautiful circular route through ancient woodland and along the river Plym. Features include the old railway viaduct, the National Trust woodland, and abundant wildlife.',
 3.5, 5.6, 'Easy', 'Some uneven paths, suitable for families', 'Circular', 
 'Plymouth', 1),

(2, 'Shaugh Prior Loop', 
 'Moorland and valley walk with river views',
 'A challenging route combining moorland terrain with river valley scenery. The walk takes you through Shaugh Prior village and along the River Plym with dramatic granite tors.',
 6.2, 10.0, 'Challenging', 'Steep sections, not suitable for wheelchairs',
 'Circular', 'Shaugh Prior', 1);
GO

-- Insert Trail Routes
INSERT INTO CW2.TrailRoute (TrailID, StartLocationID, FinishLocationID)
VALUES 
(1, 1, 2),  -- Plymouth Waterfront: Admirals Hard to Jennycliff
(2, 4, 4),  -- Plymbridge Circular: starts and ends at car park
(3, 5, 5);  -- Shaugh Prior Loop: starts and ends at Shaugh Bridge
GO

-- Insert Features
INSERT INTO CW2.Feature (FeatureName, Description)
VALUES 
('Historic Sites', 'Contains historical landmarks or monuments'),
('Wildlife', 'Good opportunities for wildlife spotting'),
('Scenic Views', 'Panoramic or notable scenic viewpoints'),
('Waterfall', 'Features one or more waterfalls'),
('Ancient Woodland', 'Passes through ancient woodland');
GO

-- Insert TrailFeatures
INSERT INTO CW2.TrailFeature (TrailID, FeatureID)
VALUES 
(1, 1),  -- Plymouth Waterfront - Historic Sites
(1, 3),  -- Plymouth Waterfront - Scenic Views
(2, 2),  -- Plymbridge - Wildlife
(2, 5),  -- Plymbridge - Ancient Woodland
(3, 2),  -- Shaugh Prior - Wildlife
(3, 3);  -- Shaugh Prior - Scenic Views
GO

-- Insert Transport Options
INSERT INTO CW2.Transport (TransportType, Details)
VALUES 
('Bus', 'Regular bus service available'),
('Train', 'Train station nearby'),
('Car Park', 'Free parking available'),
('Bike Friendly', 'Suitable for cycling access');
GO

-- Insert Reviews
INSERT INTO CW2.Review (TrailID, UserID, Rating, Title, ReviewText, HikingDate, IsApproved)
VALUES 
(1, 2, 5, 'Fantastic coastal walk!', 
 'Absolutely loved this trail. The views of Plymouth Sound are breathtaking and there''s so much history along the way.',
 '2024-09-15', 1),
(2, 3, 4, 'Great family walk', 
 'Perfect for families with young children. The woodland is beautiful and we saw lots of birds.',
 '2024-10-20', 1);
GO

-- Insert Weather Records
INSERT INTO CW2.Weather (LocationID, RecordDate, Temperature_C, Temperature_F, 
    Conditions, Precipitation_MM, WindSpeed_KMH, Humidity_Percent)
VALUES 
(1, '2024-11-01', 12.5, 54.5, 'Partly Cloudy', 0.0, 15.0, 75),
(4, '2024-11-01', 11.0, 51.8, 'Light Rain', 2.5, 10.0, 85);
GO

-- =============================================
-- VIEWS
-- =============================================

-- View: Public Trails Only (Privacy - hides private trails)
CREATE VIEW CW2.vw_PublicTrails AS
SELECT 
    t.TrailID,
    t.TrailName,
    t.Summary,
    t.Length_Miles,
    t.Length_Km,
    t.Difficulty,
    t.RouteType,
    t.NearestTown,
    u.Username AS CreatedBy,
    t.CreatedDate
FROM CW2.Trail t
INNER JOIN CW2.[User] u ON t.UserID = u.UserID
WHERE t.IsPublic = 1 AND t.IsDeleted = 0;  -- Privacy & preservation controls
GO

-- View: Trail Details (Enhanced)
CREATE VIEW CW2.vw_TrailDetails AS
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
    u.Username AS CreatedBy,
    sl.LocationName AS StartLocation,
    sl.Postcode AS StartPostcode,
    fl.LocationName AS FinishLocation,
    fl.Postcode AS FinishPostcode,
    t.CreatedDate,
    t.LastModifiedDate,
    AVG(CAST(r.Rating AS FLOAT)) AS AverageRating,
    COUNT(DISTINCT r.ReviewID) AS ReviewCount
FROM CW2.Trail t
INNER JOIN CW2.[User] u ON t.UserID = u.UserID
INNER JOIN CW2.TrailRoute tr ON t.TrailID = tr.TrailID
INNER JOIN CW2.Location sl ON tr.StartLocationID = sl.LocationID
LEFT JOIN CW2.Location fl ON tr.FinishLocationID = fl.LocationID
LEFT JOIN CW2.Review r ON t.TrailID = r.TrailID AND r.IsApproved = 1
WHERE t.IsDeleted = 0  -- Excludes soft-deleted trails
GROUP BY 
    t.TrailID, t.TrailName, t.Summary, t.TrailDescription,
    t.Length_Miles, t.Length_Km, t.Difficulty, t.AccessibilityNotes,
    t.RouteType, t.NearestTown, u.Username,
    sl.LocationName, sl.Postcode, fl.LocationName, fl.Postcode,
    t.CreatedDate, t.LastModifiedDate;
GO

-- =============================================
-- STORED PROCEDURES (Enhanced with Security)
-- =============================================

-- CREATE - Insert New Trail (Enhanced)
CREATE PROCEDURE CW2.sp_InsertTrail
    @UserID INT,
    @TrailName NVARCHAR(200),
    @Summary NVARCHAR(1000) = NULL,
    @TrailDescription NVARCHAR(MAX) = NULL,
    @Length_Miles DECIMAL(5,2) = NULL,
    @Length_Km DECIMAL(5,2) = NULL,
    @Difficulty NVARCHAR(50) = NULL,
    @AccessibilityNotes NVARCHAR(500) = NULL,
    @RouteType NVARCHAR(50) = NULL,
    @NearestTown NVARCHAR(100) = NULL,
    @IsPublic BIT = 1,
    @NewTrailID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate user exists
    IF NOT EXISTS (SELECT 1 FROM CW2.[User] WHERE UserID = @UserID AND IsActive = 1)
    BEGIN
        RAISERROR('Invalid or inactive user', 16, 1);
        RETURN;
    END
    
    INSERT INTO CW2.Trail (UserID, TrailName, Summary, TrailDescription,
        Length_Miles, Length_Km, Difficulty, AccessibilityNotes,
        RouteType, NearestTown, IsPublic)
    VALUES (@UserID, @TrailName, @Summary, @TrailDescription,
        @Length_Miles, @Length_Km, @Difficulty, @AccessibilityNotes,
        @RouteType, @NearestTown, @IsPublic);
    
    SET @NewTrailID = SCOPE_IDENTITY();
END;
GO

-- READ - Get Single Trail by ID (respects privacy)
CREATE PROCEDURE CW2.sp_GetTrailByID
    @TrailID INT,
    @RequestingUserID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM CW2.Trail 
    WHERE TrailID = @TrailID 
      AND IsDeleted = 0
      AND (IsPublic = 1 OR UserID = @RequestingUserID);  -- Privacy check
END;
GO

-- READ - Get All Trails (with privacy filter)
CREATE PROCEDURE CW2.sp_GetAllTrails
    @IncludePrivate BIT = 0,
    @RequestingUserID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM CW2.Trail 
    WHERE IsDeleted = 0
      AND (
          (@IncludePrivate = 0 AND IsPublic = 1) OR
          (@IncludePrivate = 1 AND UserID = @RequestingUserID)
      )
    ORDER BY TrailName;
END;
GO

-- UPDATE - Modify Existing Trail (with authorization)
CREATE PROCEDURE CW2.sp_UpdateTrail
    @TrailID INT,
    @UserID INT,  -- For authorization
    @TrailName NVARCHAR(200),
    @Summary NVARCHAR(1000) = NULL,
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
    
    -- Security: Check if user owns the trail
    IF NOT EXISTS (SELECT 1 FROM CW2.Trail WHERE TrailID = @TrailID AND UserID = @UserID)
    BEGIN
        RAISERROR('Unauthorized: You can only update your own trails', 16, 1);
        RETURN;
    END
    
    UPDATE CW2.Trail SET
        TrailName = @TrailName,
        Summary = @Summary,
        TrailDescription = @TrailDescription,
        Length_Miles = @Length_Miles,
        Length_Km = @Length_Km,
        Difficulty = @Difficulty,
        AccessibilityNotes = @AccessibilityNotes,
        RouteType = @RouteType,
        NearestTown = @NearestTown,
        LastModifiedDate = GETDATE(),
        LastModifiedBy = @UserID
    WHERE TrailID = @TrailID;
END;
GO

-- DELETE - Soft Delete Trail (Preservation)
CREATE PROCEDURE CW2.sp_DeleteTrail
    @TrailID INT,
    @UserID INT  -- For authorization
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Security: Check if user owns the trail
    IF NOT EXISTS (SELECT 1 FROM CW2.Trail WHERE TrailID = @TrailID AND UserID = @UserID)
    BEGIN
        RAISERROR('Unauthorized: You can only delete your own trails', 16, 1);
        RETURN;
    END
    
    -- Soft delete for preservation
    UPDATE CW2.Trail 
    SET IsDeleted = 1,
        LastModifiedDate = GETDATE(),
        LastModifiedBy = @UserID
    WHERE TrailID = @TrailID;
    
    -- Log the deletion
    INSERT INTO CW2.AuditLog (TableName, RecordID, Action, ChangedBy, ChangedDate)
    VALUES ('Trail', @TrailID, 'SOFT_DELETE', 
            (SELECT Username FROM CW2.[User] WHERE UserID = @UserID), 
            GETDATE());
END;
GO

-- SEARCH - Search Trails by Criteria
CREATE PROCEDURE CW2.sp_SearchTrails
    @Difficulty NVARCHAR(50) = NULL,
    @MaxLength DECIMAL(5,2) = NULL,
    @SearchTerm NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM CW2.vw_PublicTrails
    WHERE 
        (@Difficulty IS NULL OR Difficulty = @Difficulty) AND
        (@MaxLength IS NULL OR Length_Miles <= @MaxLength) AND
        (@SearchTerm IS NULL OR 
         TrailName LIKE '%' + @SearchTerm + '%' OR
         Summary LIKE '%' + @SearchTerm + '%')
    ORDER BY TrailName;
END;
GO

-- =============================================
-- TRIGGERS (Security & Auditing)
-- =============================================

-- Trigger: Log New Trail Creation
CREATE TRIGGER CW2.trg_LogNewTrail
ON CW2.Trail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO CW2.TrailLog (TrailID, TrailName, Action, ActionBy, ActionDate)
    SELECT 
        i.TrailID,
        i.TrailName,
        'INSERT',
        u.Username,
        GETDATE()
    FROM inserted i
    INNER JOIN CW2.[User] u ON i.UserID = u.UserID;
END;
GO

-- Trigger: Comprehensive Audit Trail
CREATE TRIGGER CW2.trg_AuditTrailChanges
ON CW2.Trail
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Log each field change
    INSERT INTO CW2.AuditLog (TableName, RecordID, Action, FieldChanged, 
                               OldValue, NewValue, ChangedBy, ChangedDate)
    SELECT 
        'Trail',
        i.TrailID,
        'UPDATE',
        'TrailName',
        d.TrailName,
        i.TrailName,
        u.Username,
        GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON i.TrailID = d.TrailID
    INNER JOIN CW2.[User] u ON i.LastModifiedBy = u.UserID
    WHERE i.TrailName <> d.TrailName;
    
    -- Additional fields can be logged similarly
END;
GO

-- Trigger: Prevent Unauthorized Hard Deletes
CREATE TRIGGER CW2.trg_PreventUnauthorizedDelete
ON CW2.Trail
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Prevent hard deletes, enforce soft delete
    RAISERROR('Hard deletes are not allowed. Use sp_DeleteTrail for soft delete.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

PRINT '=== CW2.User ===' 
SELECT UserID, Username, Email, CreatedDate, IsActive FROM CW2.[User];
GO

PRINT '=== CW2.Location ===' 
SELECT * FROM CW2.Location;
GO

PRINT '=== CW2.Trail ===' 
SELECT TrailID, UserID, TrailName, Difficulty, Length_Miles, IsPublic, IsDeleted 
FROM CW2.Trail;
GO

PRINT '=== CW2.vw_PublicTrails ===' 
SELECT * FROM CW2.vw_PublicTrails;
GO

PRINT '=== CW2.vw_TrailDetails ===' 
SELECT * FROM CW2.vw_TrailDetails;
GO

PRINT '=== CW2.Review ===' 
SELECT * FROM CW2.Review;
GO

PRINT '=== CW2.TrailLog ===' 
SELECT * FROM CW2.TrailLog;
GO

-- =============================================
-- TEST STORED PROCEDURES
-- =============================================

PRINT '=== Testing sp_InsertTrail ==='
DECLARE @NewID INT;
EXEC CW2.sp_InsertTrail 
    @UserID = 3,
    @TrailName = 'Dartmoor Discovery Trail',
    @Summary = 'Explore the wilds of Dartmoor National Park',
    @Length_Miles = 8.5,
    @Length_Km = 13.7,
    @Difficulty = 'Hard',
    @RouteType = 'Circular',
    @NearestTown = 'Princetown',
    @IsPublic = 1,
    @NewTrailID = @NewID OUTPUT;
SELECT @NewID AS InsertedTrailID;
GO

PRINT '=== Testing sp_SearchTrails ==='
EXEC CW2.sp_SearchTrails 
    @Difficulty = 'Easy',
    @MaxLength = 5.0;
GO

PRINT '=== Testing Soft Delete ==='
EXEC CW2.sp_DeleteTrail 
    @TrailID = 4,
    @UserID = 3;
GO

SELECT * FROM CW2.Trail WHERE TrailID = 4;  -- Should show IsDeleted = 1
SELECT * FROM CW2.AuditLog WHERE TableName = 'Trail';
GO

PRINT '=== CW2 DEPLOYMENT COMPLETE ==='
PRINT 'Security Features: Password hashing, authorization checks, moderation'
PRINT 'Privacy Features: Public/private trails, soft deletes, user ownership'
PRINT 'Integrity Features: Data validation, foreign keys, check constraints'
PRINT 'Preservation Features: Audit logs, soft deletes, modification tracking'
