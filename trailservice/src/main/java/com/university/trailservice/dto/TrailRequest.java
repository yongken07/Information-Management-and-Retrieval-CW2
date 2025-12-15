package com.university.trailservice.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

/**
 * Trail Request DTO
 */
public class TrailRequest {
    @NotBlank(message = "Trail name is required")
    @Size(max = 200)
    private String trailName;
    
    @Size(max = 1000)
    private String summary;
    
    private String trailDescription;
    
    @DecimalMin(value = "0.0")
    private BigDecimal lengthMiles;
    
    @DecimalMin(value = "0.0")
    private BigDecimal lengthKm;
    
    @Pattern(regexp = "Easy|Moderate|Hard|Challenging")
    private String difficulty;
    
    @Size(max = 500)
    private String accessibilityNotes;
    
    @Size(max = 50)
    private String routeType;
    
    @Size(max = 100)
    private String nearestTown;
    
    @Size(max = 20)
    private String startPostcode;
    
    @Size(max = 200)
    private String finishLocation;
    
    @Size(max = 20)
    private String finishPostcode;
    
    private Boolean isPublic = true;

    public TrailRequest() {}

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

    public Boolean getIsPublic() { return isPublic; }
    public void setIsPublic(Boolean isPublic) { this.isPublic = isPublic; }
}
