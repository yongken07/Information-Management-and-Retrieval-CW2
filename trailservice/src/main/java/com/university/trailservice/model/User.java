package com.university.trailservice.model;

import java.time.LocalDateTime;

/**
 * User Entity
 */
public class User {
    private Integer userId;
    private String username;
    private String email;
    private String passwordHash;
    private LocalDateTime createdDate;
    private LocalDateTime lastLoginDate;
    private Boolean isActive;
    
    public User() {}
    
    public User(Integer userId, String username, String email) {
        this.userId = userId;
        this.username = username;
        this.email = email;
    }
    
    public User(Integer userId, String username, String email, String passwordHash,
                LocalDateTime createdDate, LocalDateTime lastLoginDate, Boolean isActive) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.createdDate = createdDate;
        this.lastLoginDate = lastLoginDate;
        this.isActive = isActive;
    }
    
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }
    
    public LocalDateTime getLastLoginDate() { return lastLoginDate; }
    public void setLastLoginDate(LocalDateTime lastLoginDate) { this.lastLoginDate = lastLoginDate; }
    
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
}
