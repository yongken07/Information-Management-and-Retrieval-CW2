package com.university.trailservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * TrailService Microservice Application
 * 
 * Main entry point for the Spring Boot application.
 * Provides RESTful API for managing hiking trails with:
 * - Security: JWT authentication, password hashing
 * - Privacy: User ownership, public/private trails
 * - Integrity: Input validation, database constraints
 * - Preservation: Soft deletes, audit logging
 * 
 * @author [Your Name]
 * @version 1.0.0
 */
@SpringBootApplication
public class TrailServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(TrailServiceApplication.class, args);
        
        System.out.println("\n" +
            "████████╗██████╗  █████╗ ██╗██╗     ███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗\n" +
            "╚══██╔══╝██╔══██╗██╔══██╗██║██║     ██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝\n" +
            "   ██║   ██████╔╝███████║██║██║     ███████╗█████╗  ██████╔╝██║   ██║██║██║     ███████╗\n" +
            "   ██║   ██╔══██╗██╔══██║██║██║     ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ╚════██║\n" +
            "   ██║   ██║  ██║██║  ██║██║███████╗███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████║\n" +
            "   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝\n");
        System.out.println("✅ TrailService API is running on http://localhost:8080");
        System.out.println("✅ Database: SQL Server");
        System.out.println("✅ Security: JWT Authentication enabled");
        System.out.println("✅ API Documentation: http://localhost:8080/api/health");
        System.out.println("\n📚 Endpoints:");
        System.out.println("   POST   /api/auth/register    - Register new user");
        System.out.println("   POST   /api/auth/login       - Login and get JWT token");
        System.out.println("   GET    /api/trails           - Get all public trails");
        System.out.println("   GET    /api/trails/{id}      - Get trail by ID");
        System.out.println("   POST   /api/trails           - Create trail (auth required)");
        System.out.println("   PUT    /api/trails/{id}      - Update trail (auth required)");
        System.out.println("   DELETE /api/trails/{id}      - Delete trail (auth required)");
        System.out.println("   GET    /api/trails/search    - Search trails");
        System.out.println("\n");
    }
}
