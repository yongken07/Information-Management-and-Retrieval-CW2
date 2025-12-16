# TrailService Microservice - Spring Boot

[![Java](https://img.shields.io/badge/Java-17-orange)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen)](https://spring.io/projects/spring-boot)
[![Maven](https://img.shields.io/badge/Maven-3.8+-blue)](https://maven.apache.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> A RESTful microservice for managing hiking trails built with Spring Boot, featuring comprehensive security, privacy, integrity, and data preservation.

**Course**: Database Systems and Web Technologies  
**Assessment**: CW2 - Microservice Implementation  
**Student**: Yong Ken
**GitHub**: yongken07 
**Technology**: Java 17 + Spring Boot 3.2.0

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [LSEP Implementation](#lsep-implementation)
- [Project Structure](#project-structure)
- [Deployment](#deployment)
- [License](#license)

---

## Overview

TrailService is a microservice application that provides a RESTful API for managing hiking trails. Built upon the CW1 database design, it implements a complete backend system with user authentication, trail management, and comprehensive LSEP (Legal, Social, Ethical, Professional) considerations.

**Key Capabilities:**
- User registration and JWT-based authentication
- CRUD operations for hiking trails
- Trail search with multiple criteria
- User ownership and authorization
- Soft delete for data preservation
- Comprehensive audit logging

---

## Features

### Security (Legal & Professional)
- **Password Hashing**: BCrypt with configurable strength
- **JWT Authentication**: Stateless token-based security
- **Input Validation**: Jakarta Validation (Bean Validation 3.0)
- **CORS Configuration**: Controlled cross-origin access
- **SQL Injection Prevention**: Parameterized queries via JDBC
- **Spring Security**: Comprehensive security framework

### Privacy (Ethical)
- **User Ownership**: Trails linked to creators
- **Public/Private Control**: IsPublic flag
- **Authorization Checks**: Users can only modify own content
- ✅ **Password Protection**: Passwords never returned in responses

### Integrity (Professional)
- **Database Constraints**: CHECK constraints, Foreign Keys
- **Input Validation**: Both API and database layers
- **Transaction Management**: ACID compliance via Spring @Transactional
- ✅ **Type Safety**: Strong typing with Java

### Preservation (Legal & Professional)
- **Soft Deletes**: IsDeleted flag preserves data
- **Audit Logs**: Track all changes with timestamps
- **Modification Tracking**: LastModifiedBy and LastModifiedDate
- ✅ **Database Triggers**: Automatic logging

---

## Technology Stack

### Backend Framework
- **Language**: Java 17 (LTS)
- **Framework**: Spring Boot 3.2.0
- **Build Tool**: Maven 3.8+
- **Database**: Microsoft SQL Server

### Spring Boot Modules
- **Spring Web**: RESTful API
- **Spring Security**: Authentication & Authorization
- **Spring JDBC**: Database access
- **Spring Validation**: Input validation

### Security & Authentication
- **Password Hashing**: BCrypt (Spring Security)
- **JWT**: JJWT 0.12.3
- **Security**: Spring Security 6

### Database
- **Driver**: Microsoft SQL Server JDBC Driver
- **Connection Pooling**: HikariCP (default in Spring Boot)

### Development Tools
- **Lombok**: Reduce boilerplate code
- **Spring Boot DevTools**: Hot reload
- **SLF4J + Logback**: Logging

---

## Architecture

The microservice follows **Layered Architecture** pattern:

```
┌─────────────────────────────────────┐
│         Client Layer                │
│  (Browser, Mobile App, Postman)     │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      Controller Layer               │
│  - REST endpoints                   │
│  - Request validation               │
│  - Response formatting              │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      Service Layer                  │
│  - Business logic                   │
│  - Authorization                    │
│  - Transaction management           │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      Repository Layer               │
│  - Data access                      │
│  - SQL queries                      │
│  - Stored procedures                │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      Database Layer                 │
│  - MS SQL Server                    │
│  - CW2 Schema                       │
└─────────────────────────────────────┘
```

**Security Layer (Cross-cutting):**
- JWT Authentication Filter
- Spring Security Configuration
- Password Encoder

---

## Prerequisites

Before installing, ensure you have:

1. **Java Development Kit (JDK) 17 or higher**
   ```bash
   java -version
   ```

2. **Apache Maven 3.8+**
   ```bash
   mvn -version
   ```

3. **Microsoft SQL Server** (localhost or remote)
   - SQL Server 2019 or higher recommended
   - Running on default port 1433

4. **Git** (for version control)
   ```bash
   git --version
   ```

5. **IDE (Optional but recommended)**
   - IntelliJ IDEA (recommended)
   - Eclipse with Spring Tools
   - VS Code with Java extensions

---

## Installation

### Step 1: Clone Repository

```bash
cd "/Volumes/SSD 980 PRO/trailservice"
# Or if cloning from GitHub:
# git clone https://github.com/[your-username]/trailservice.git
# cd trailservice
```

### Step 2: Install Dependencies

```bash
mvn clean install
```

This will:
- Download all dependencies from Maven Central
- Compile the source code
- Run tests (if any)
- Package the application

---

## Configuration

### Step 1: Create Environment File

Copy the example environment file:

```bash
cp .env.example .env
```

### Step 2: Configure Database Connection

Edit `.env` file:

```env
DB_USERNAME=your_sql_server_username
DB_PASSWORD=your_sql_server_password
JWT_SECRET=change-this-to-a-very-long-random-string-at-least-256-bits
SERVER_PORT=8080
```

### Step 3: Update `application.properties` (if needed)

The main configuration is in `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=TrailServiceDB;encrypt=true;trustServerCertificate=true
spring.datasource.username=${DB_USERNAME:sa}
spring.datasource.password=${DB_PASSWORD:YourPassword123}
```

**Important Configuration Options:**

| Property | Description | Default |
|----------|-------------|---------|
| `server.port` | Application port | 8080 |
| `spring.datasource.url` | Database connection string | localhost:1433 |
| `jwt.secret` | JWT signing key | (must change!) |
| `jwt.expiration` | Token expiration (ms) | 86400000 (24h) |
| `bcrypt.strength` | BCrypt rounds | 10 |

---

## Database Setup

### Step 1: Create Database

Connect to SQL Server and create the database:

```sql
CREATE DATABASE TrailServiceDB;
GO

USE TrailServiceDB;
GO
```

### Step 2: Deploy CW2 Schema

Execute the CW2 SQL script:

```bash
# Using sqlcmd
sqlcmd -S localhost -U sa -P YourPassword123 -i TrailService_CW2_SQL.sql

# Or using SQL Server Management Studio (SSMS):
# 1. Open TrailService_CW2_SQL.sql
# 2. Execute (F5)
```

### Step 3: Verify Schema

```sql
-- Check tables
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'CW2'
ORDER BY TABLE_NAME;

-- Should see 12 tables:
-- User, Trail, Location, TrailRoute, Feature, TrailFeature,
-- Transport, TrailTransport, Review, Photo, Weather, AuditLog, TrailLog
```

---

## Running the Application

### Method 1: Using Maven (Development)

```bash
mvn spring-boot:run
```

### Method 2: Using Java JAR (Production)

```bash
# Build JAR
mvn clean package

# Run JAR
java -jar target/trailservice-1.0.0.jar
```

### Method 3: Using IDE

**IntelliJ IDEA:**
1. Open project
2. Right-click `TrailServiceApplication.java`
3. Select "Run 'TrailServiceApplication'"

**Eclipse:**
1. Right-click project → Run As → Spring Boot App

### Verify Running

Check the startup banner:

```
TrailService API is running on http://localhost:8080
Database: SQL Server
Security: JWT Authentication enabled
```

Test health endpoint:

```bash
curl http://localhost:8080/api/health
```

Expected response:
```json
{
  "status": "UP",
  "service": "TrailService Microservice",
  "version": "1.0.0",
  "timestamp": "2024-12-14T10:30:00"
}
```

---

## API Documentation

Base URL: `http://localhost:8080/api`

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "token": "eyJhbGciOiJIUzUxMiJ9...",
    "type": "Bearer",
    "userId": 1,
    "username": "johndoe",
    "email": "john@example.com"
  },
  "timestamp": "2024-12-14T10:30:00"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "johndoe",
  "password": "SecurePass123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzUxMiJ9...",
    "type": "Bearer",
    "userId": 1,
    "username": "johndoe",
    "email": "john@example.com"
  }
}
```

### Trail Endpoints

#### Get All Trails
```http
GET /api/trails
```

**Response:**
```json
{
  "success": true,
  "message": "Trails retrieved successfully",
  "data": [
    {
      "trailId": 1,
      "userId": 1,
      "trailName": "Lake District Hike",
      "summary": "Beautiful mountain scenery",
      "difficulty": "Moderate",
      "lengthMiles": 5.2,
      "isPublic": true
    }
  ]
}
```

#### Get Trail by ID
```http
GET /api/trails/{id}
```

#### Create Trail (Requires Auth)
```http
POST /api/trails
Authorization: Bearer {your-jwt-token}
Content-Type: application/json

{
  "trailName": "Peak District Walk",
  "summary": "Scenic countryside trail",
  "trailDescription": "A moderate walk through rolling hills",
  "lengthMiles": 3.5,
  "lengthKm": 5.6,
  "difficulty": "Moderate",
  "nearestTown": "Bakewell",
  "isPublic": true
}
```

#### Update Trail (Requires Auth + Ownership)
```http
PUT /api/trails/{id}
Authorization: Bearer {your-jwt-token}
Content-Type: application/json

{
  "trailName": "Updated Trail Name",
  "difficulty": "Hard",
  ...
}
```

#### Delete Trail (Requires Auth + Ownership)
```http
DELETE /api/trails/{id}
Authorization: Bearer {your-jwt-token}
```

#### Search Trails
```http
GET /api/trails/search?q=lake&difficulty=Moderate
```

---

## Testing

### Manual Testing with curl

```bash
# Health check
curl http://localhost:8080/api/health

# Register
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"Test123456"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123456"}'

# Get trails
curl http://localhost:8080/api/trails

# Create trail (replace {token})
curl -X POST http://localhost:8080/api/trails \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"trailName":"Test Trail","difficulty":"Easy","isPublic":true}'
```

### Using Postman

1. Import collection from `docs/postman_collection.json` (if provided)
2. Set `baseUrl` variable to `http://localhost:8080/api`
3. Run requests in order:
   - Register
   - Login (save token)
   - Create Trail
   - Get Trails
   - Update Trail
   - Delete Trail

---

## LSEP Implementation

### Security (Legal & Professional)

#### 1. Password Hashing
**Location:** `AuthService.java`
```java
String passwordHash = passwordEncoder.encode(request.getPassword());
```
**Implementation:** BCrypt with 10 rounds (configurable in `application.properties`)

#### 2. JWT Authentication
**Location:** `JwtTokenProvider.java`
```java
return Jwts.builder()
    .setSubject(userId.toString())
    .signWith(getSigningKey(), SignatureAlgorithm.HS512)
    .compact();
```
**Features:**
- HS512 algorithm
- 24-hour expiration
- Stateless authentication

#### 3. Input Validation
**Location:** `TrailRequest.java`
```java
@NotBlank(message = "Trail name is required")
@Size(max = 200)
private String trailName;
```
**Validation:** Jakarta Bean Validation annotations

### Privacy (Ethical)

#### 1. User Ownership
**Location:** `Trail.java`
```java
private Integer userId; // FK to User table
```
**Enforcement:** All trails linked to creator

#### 2. Authorization
**Location:** `TrailService.java`
```java
if (!existingTrail.getUserId().equals(userId)) {
    throw new RuntimeException("Unauthorized");
}
```
**Protection:** Users can only modify own trails

#### 3. Public/Private Control
**Location:** `Trail.java`
```java
private Boolean isPublic; // Controls visibility
```

### Integrity (Professional)

#### 1. Database Constraints
**Location:** `TrailService_CW2_SQL.sql`
```sql
CHECK (Difficulty IN ('Easy', 'Moderate', 'Hard', 'Challenging'))
CHECK (Latitude BETWEEN -90 AND 90)
```

#### 2. Type Safety
**Implementation:** Java strong typing + Lombok
```java
private BigDecimal lengthMiles; // Precise decimal handling
```

### Preservation (Legal & Professional)

#### 1. Soft Deletes
**Location:** `TrailRepository.java`
```java
public boolean deleteTrail(Integer trailId, Integer userId) {
    return jdbcTemplate.update("{CALL CW2.sp_DeleteTrail(?, ?)}", trailId, userId) > 0;
}
```
**Implementation:** Sets `IsDeleted = 1` instead of physical delete

#### 2. Audit Logging
**Location:** Database triggers in `TrailService_CW2_SQL.sql`
```sql
CREATE TRIGGER trg_AuditTrail ON CW2.Trail
AFTER UPDATE
AS
BEGIN
    INSERT INTO CW2.AuditLog (TableName, RecordID, Action, ...)
    ...
END
```

---

## Project Structure

```
trailservice/
├── pom.xml                                    # Maven configuration
├── .env.example                               # Environment template
├── .gitignore                                 # Git ignore rules
├── TrailService_CW2_SQL.sql                   # Database schema
│
├── src/main/java/com/university/trailservice/
│   ├── TrailServiceApplication.java           # Main entry point
│   │
│   ├── config/
│   │   └── SecurityConfig.java                # Spring Security config
│   │
│   ├── controller/
│   │   ├── AuthController.java                # Auth endpoints
│   │   ├── TrailController.java               # Trail endpoints
│   │   └── HealthController.java              # Health check
│   │
│   ├── service/
│   │   ├── AuthService.java                   # Auth business logic
│   │   └── TrailService.java                  # Trail business logic
│   │
│   ├── repository/
│   │   ├── UserRepository.java                # User data access
│   │   └── TrailRepository.java               # Trail data access
│   │
│   ├── model/
│   │   ├── User.java                          # User entity
│   │   └── Trail.java                         # Trail entity
│   │
│   ├── dto/
│   │   ├── LoginRequest.java                  # Login DTO
│   │   ├── RegisterRequest.java               # Register DTO
│   │   ├── TrailRequest.java                  # Trail DTO
│   │   ├── AuthResponse.java                  # Auth response
│   │   └── ApiResponse.java                   # Generic response
│   │
│   └── security/
│       ├── JwtTokenProvider.java              # JWT utilities
│       ├── JwtAuthenticationFilter.java       # JWT filter
│       └── UserPrincipal.java                 # Security principal
│
├── src/main/resources/
│   ├── application.properties                 # App configuration
│   └── logback-spring.xml                     # Logging config (optional)
│
└── docs/
    ├── UML_DIAGRAMS.md                        # Design diagrams
    ├── DEPLOYMENT.md                          # Deployment guide
    └── CW2_REPORT_TEMPLATE.md                 # Report template
```

---

## Deployment

### Localhost Deployment (for Assessment)

The application runs on `http://localhost:8080` by default.

**Requirements:**
1. SQL Server running on localhost:1433
2. Database `TrailServiceDB` created with CW2 schema
3. `.env` configured with credentials
4. Maven dependencies installed

**Start Command:**
```bash
mvn spring-boot:run
```

### Production Deployment (Optional)

For production (beyond assessment scope):

1. **Build production JAR:**
   ```bash
   mvn clean package -DskipTests
   ```

2. **Configure production properties:**
   - Use `application-prod.properties`
   - Set strong JWT secret
   - Use environment variables for credentials

3. **Run with production profile:**
   ```bash
   java -jar -Dspring.profiles.active=prod target/trailservice-1.0.0.jar
   ```

4. **Considerations:**
   - Use reverse proxy (Nginx)
   - Enable HTTPS/TLS
   - Configure proper CORS
   - Set up monitoring
   - Regular backups

---

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2025 [Yong Ken]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## Contact

**Student**: Yong Ken
**Email**: ken.yong@students.plymouth.ac.uk
**GitHub**: https://github.com/[your-username]/trailservice

---

## Acknowledgments

- Spring Boot team for excellent framework
- Microsoft for SQL Server
- Course instructors for guidance
- JJWT library for JWT support

---

**Last Updated:** December 2024  
**Version:** 1.0.0  
**Status:** Complete and ready for submission
