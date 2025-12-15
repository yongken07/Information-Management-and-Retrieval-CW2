package com.university.trailservice.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Trail Entity
 */
public class Trail {
    private Integer trailId;
    private Integer userId;
    private String trailName;
    private String summary;
    private String trailDescription;
    private BigDecimal lengthMiles;
    private BigDecimal lengthKm;
    private String difficulty;
    private String accessibilityNotes;
    private String routeType;
    private String nearestTown;
    private String startPostcode;
    private String finishLocation;
    private String finishPostcode;
    private LocalDateTime createdDate;
    private LocalDateTime lastModifiedDate;
    private Integer lastModifiedBy;
    private Boolean isPublic;
    private Boolean isDeleted;
    
    public Trail() {}
    
    public Trail(Integer trailId, Integer userId, String trailName, String summary,
                 String trailDescription, BigDecimal lengthMiles, BigDecimal lengthKm,
                 String difficulty, String accessibilityNotes, String routeType,
                 String nearestTown, String startPostcode, String finishLocation,
                 String finishPostcode, LocalDateTime createdDate, LocalDateTime lastModifiedDate,
                 Integer lastModifiedBy, Boolean isPublic, Boolean isDeleted) {
        this.trailId = trailId;
        this.userId = userId;
        this.trailName = trailName;
        this.summary = summary;
        this.trailDescription = trailDescription;
        this.lengthMiles = lengthMiles;
        this.lengthKm = lengthKm;
        this.difficulty = difficulty;
        this.accessibilityNotes = accessibilityNotes;
        this.routeType = routeType;
        this.nearestTown = nearestTown;
        this.startPostcode = startPostcode;
        this.finishLocation = finishLocation;
        this.finishPostcode = finishPostcode;
        this.createdDate = createdDate;
        this.lastModifiedDate = lastModifiedDate;
        this.lastModifiedBy = lastModifiedBy;
        this.isPublic = isPublic;
        this.isDeleted = isDeleted;
    }
    
    public Integer getTrailId() { return trailId; }
    public void setTrailId(Integer trailId) { this.trailId = trailId; }
    
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public String getTrailName() { return trailName; }
    public void setTrailName(String trailName) { this.trailName = trailName; }
    
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    
    public String getTrailDescription() { return trailDescription; }
    public void setTrailDescription(String trailDescription) { this.trailDescription = trailDescription; }
    
    public BigDecimal getLengthMiles() { return lengthMiles; }
    public void setLengthMiles(BigDecimal lengthMiles) { this.lengthMiles = lengthMiles; }
    
    public BigDecimal getLengthKm() { return lengthKm; }
    public void setLengthKm(BigDecimal lengthKm) { this.lengthKm = lengthKm; }
    
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    
    public String getAccessibilityNotes() { return accessibilityNotes; }
    public void setAccessibilityNotes(String accessibilityNotes) { this.accessibilityNotes = accessibilityNotes; }
    
    public String getRouteType() { return routeType; }
    public void setRouteType(String routeType) { this.routeType = routeType; }
    
    public String getNearestTown() { return nearestTown; }
    public void setNearestTown(String nearestTown) { this.nearestTown = nearestTown; }
    
    public String getStartPostcode() { return startPostcode; }
    public void setStartPostcode(String startPostcode) { this.startPostcode = startPostcode; }
    
    public String getFinishLocation() { return finishLocation; }
    public void setFinishLocation(String finishLocation) { this.finishLocation = finishLocation; }
    
    public String getFinishPostcode() { return finishPostcode; }
    public void setFinishPostcode(String finishPostcode) { this.finishPostcode = finishPostcode; }
    
    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }
    
    public LocalDateTime getLastModifiedDate() { return lastModifiedDate; }
    public void setLastModifiedDate(LocalDateTime lastModifiedDate) { this.lastModifiedDate = lastModifiedDate; }
    
    public Integer getLastModifiedBy() { return lastModifiedBy; }
    public void setLastModifiedBy(Integer lastModifiedBy) { this.lastModifiedBy = lastModifiedBy; }
    
    public Boolean getIsPublic() { return isPublic; }
    public void setIsPublic(Boolean isPublic) { this.isPublic = isPublic; }
    
    public Boolean getIsDeleted() { return isDeleted; }
    public void setIsDeleted(Boolean isDeleted) { this.isDeleted = isDeleted; }
}
