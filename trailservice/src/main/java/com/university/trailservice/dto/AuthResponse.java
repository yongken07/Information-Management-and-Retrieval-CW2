package com.university.trailservice.dto;

/**
 * Authentication Response DTO
 */
public class AuthResponse {
    private Integer userId;
    private String username;
    private String email;
    private String token;

    public AuthResponse() {}

    public AuthResponse(Integer userId, String username, String email, String token) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.token = token;
    }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
}
