package com.university.trailservice.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.Components;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI/Swagger Configuration
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI trailServiceOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("TrailService API")
                .description("RESTful microservice for managing hiking trails with JWT authentication")
                .version("1.0.0")
                .contact(new Contact()
                    .name("University Project")
                    .email("support@trailservice.com"))
                .license(new License()
                    .name("MIT License")
                    .url("https://opensource.org/licenses/MIT")))
            .components(new Components()
                .addSecuritySchemes("bearer-jwt", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT")
                    .description("Enter JWT token obtained from /api/auth/login")))
            .addSecurityItem(new SecurityRequirement().addList("bearer-jwt"));
    }
}
