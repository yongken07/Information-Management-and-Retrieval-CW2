package com.university.trailservice.controller;

import com.university.trailservice.dto.ApiResponse;
import com.university.trailservice.dto.TrailRequest;
import com.university.trailservice.model.Trail;
import com.university.trailservice.security.UserPrincipal;
import com.university.trailservice.service.TrailService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Trail Controller
 * Handles all trail-related HTTP requests
 */
@RestController
@RequestMapping("/api/trails")
public class TrailController {

    @Autowired
    private TrailService trailService;

    /**
     * Get all public trails
     * GET /api/trails
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Trail>>> getAllTrails() {
        List<Trail> trails = trailService.getAllTrails();
        return ResponseEntity.ok(ApiResponse.success("Trails retrieved successfully", trails));
    }

    /**
     * Get trail by ID
     * GET /api/trails/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Trail>> getTrailById(@PathVariable Integer id) {
        try {
            Trail trail = trailService.getTrailById(id);
            return ResponseEntity.ok(ApiResponse.success("Trail retrieved successfully", trail));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Create new trail (requires authentication)
     * POST /api/trails
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Integer>> createTrail(
            @Valid @RequestBody TrailRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            Integer trailId = trailService.createTrail(request, userPrincipal.userId());
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Trail created successfully", trailId));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Update trail (requires authentication and ownership)
     * PUT /api/trails/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Boolean>> updateTrail(
            @PathVariable Integer id,
            @Valid @RequestBody TrailRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            boolean updated = trailService.updateTrail(id, request, userPrincipal.userId());
            return ResponseEntity.ok(ApiResponse.success("Trail updated successfully", updated));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("Unauthorized")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error(e.getMessage()));
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Delete trail (requires authentication and ownership)
     * DELETE /api/trails/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Boolean>> deleteTrail(
            @PathVariable Integer id,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            boolean deleted = trailService.deleteTrail(id, userPrincipal.userId());
            return ResponseEntity.ok(ApiResponse.success("Trail deleted successfully", deleted));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("Unauthorized")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error(e.getMessage()));
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * Search trails
     * GET /api/trails/search?q=searchTerm&difficulty=Easy
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<Trail>>> searchTrails(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String difficulty) {
        List<Trail> trails = trailService.searchTrails(q, difficulty);
        return ResponseEntity.ok(ApiResponse.success("Search completed successfully", trails));
    }
}
