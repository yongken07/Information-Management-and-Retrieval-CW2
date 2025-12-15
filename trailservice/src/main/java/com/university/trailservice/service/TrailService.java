package com.university.trailservice.service;

import com.university.trailservice.dto.TrailRequest;
import com.university.trailservice.model.Trail;
import com.university.trailservice.repository.TrailRepository;
import com.university.trailservice.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * Trail Service
 * Business logic for trail operations
 */
@Service
public class TrailService {

    @Autowired
    private TrailRepository trailRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Get all public trails
     */
    public List<Trail> getAllTrails() {
        return trailRepository.findAllPublic();
    }

    /**
     * Get trail by ID
     */
    public Trail getTrailById(Integer trailId) {
        return trailRepository.findById(trailId)
            .orElseThrow(() -> new RuntimeException("Trail not found"));
    }

    /**
     * Create new trail
     */
    public Integer createTrail(TrailRequest request, Integer userId) {
        // Verify user exists and is active
        userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found or inactive"));

        // Create trail entity
        Trail trail = new Trail();
        trail.setUserId(userId);
        trail.setTrailName(request.getTrailName());
        trail.setSummary(request.getSummary());
        trail.setTrailDescription(request.getTrailDescription());
        trail.setLengthMiles(request.getLengthMiles());
        trail.setLengthKm(request.getLengthKm());
        trail.setDifficulty(request.getDifficulty());
        trail.setAccessibilityNotes(request.getAccessibilityNotes());
        trail.setRouteType(request.getRouteType());
        trail.setNearestTown(request.getNearestTown());
        trail.setStartPostcode(request.getStartPostcode());
        trail.setFinishLocation(request.getFinishLocation());
        trail.setFinishPostcode(request.getFinishPostcode());
        trail.setIsPublic(request.getIsPublic() != null ? request.getIsPublic() : true);

        return trailRepository.createTrail(trail);
    }

    /**
     * Update existing trail
     */
    public boolean updateTrail(Integer trailId, TrailRequest request, Integer userId) {
        // Get existing trail
        Trail existingTrail = trailRepository.findById(trailId)
            .orElseThrow(() -> new RuntimeException("Trail not found"));

        // Check authorization - user must own the trail
        if (!existingTrail.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized: You can only update your own trails");
        }

        // Update trail entity
        Trail trail = new Trail();
        trail.setTrailName(request.getTrailName());
        trail.setSummary(request.getSummary());
        trail.setTrailDescription(request.getTrailDescription());
        trail.setLengthMiles(request.getLengthMiles());
        trail.setLengthKm(request.getLengthKm());
        trail.setDifficulty(request.getDifficulty());
        trail.setAccessibilityNotes(request.getAccessibilityNotes());
        trail.setRouteType(request.getRouteType());
        trail.setNearestTown(request.getNearestTown());
        trail.setStartPostcode(request.getStartPostcode());
        trail.setFinishLocation(request.getFinishLocation());
        trail.setFinishPostcode(request.getFinishPostcode());
        trail.setIsPublic(request.getIsPublic() != null ? request.getIsPublic() : true);
        trail.setLastModifiedBy(userId);

        return trailRepository.updateTrail(trailId, trail);
    }

    /**
     * Delete trail (soft delete)
     */
    public boolean deleteTrail(Integer trailId, Integer userId) {
        // Get existing trail
        Trail existingTrail = trailRepository.findById(trailId)
            .orElseThrow(() -> new RuntimeException("Trail not found"));

        // Check authorization - user must own the trail
        if (!existingTrail.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized: You can only delete your own trails");
        }

        return trailRepository.deleteTrail(trailId, userId);
    }

    /**
     * Search trails by criteria
     */
    public List<Trail> searchTrails(String searchTerm, String difficulty) {
        return trailRepository.searchTrails(searchTerm, difficulty);
    }
}
