package com.university.trailservice.repository;

import com.university.trailservice.model.Trail;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;
import java.util.Optional;

/**
 * Trail Repository
 * Data access layer for Trail entity using stored procedures
 */
@Repository
public class TrailRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // Row mapper for view vw_PublicTrails (limited fields)
    private final RowMapper<Trail> publicTrailRowMapper = (rs, rowNum) -> {
        Trail trail = new Trail();
        trail.setTrailId(rs.getInt("TrailID"));
        trail.setTrailName(rs.getString("TrailName"));
        trail.setSummary(rs.getString("Summary"));
        trail.setLengthMiles(rs.getBigDecimal("Length_Miles"));
        trail.setLengthKm(rs.getBigDecimal("Length_Km"));
        trail.setDifficulty(rs.getString("Difficulty"));
        trail.setRouteType(rs.getString("RouteType"));
        trail.setNearestTown(rs.getString("NearestTown"));
        trail.setCreatedDate(rs.getTimestamp("CreatedDate").toLocalDateTime());
        trail.setIsPublic(true); // View only shows public trails
        trail.setIsDeleted(false); // View only shows non-deleted trails
        return trail;
    };

    // Full row mapper for stored procedures and complete data
    private final RowMapper<Trail> trailRowMapper = (rs, rowNum) -> {
        Trail trail = new Trail();
        trail.setTrailId(rs.getInt("TrailID"));
        trail.setUserId(rs.getInt("UserID"));
        trail.setTrailName(rs.getString("TrailName"));
        trail.setSummary(rs.getString("Summary"));
        trail.setTrailDescription(rs.getString("TrailDescription"));
        trail.setLengthMiles(rs.getBigDecimal("Length_Miles"));
        trail.setLengthKm(rs.getBigDecimal("Length_Km"));
        trail.setDifficulty(rs.getString("Difficulty"));
        trail.setAccessibilityNotes(rs.getString("AccessibilityNotes"));
        trail.setRouteType(rs.getString("RouteType"));
        trail.setNearestTown(rs.getString("NearestTown"));
        trail.setStartPostcode(rs.getString("StartPostcode"));
        trail.setFinishLocation(rs.getString("FinishLocation"));
        trail.setFinishPostcode(rs.getString("FinishPostcode"));
        trail.setCreatedDate(rs.getTimestamp("CreatedDate").toLocalDateTime());
        if (rs.getTimestamp("LastModifiedDate") != null) {
            trail.setLastModifiedDate(rs.getTimestamp("LastModifiedDate").toLocalDateTime());
        }
        trail.setLastModifiedBy(rs.getInt("LastModifiedBy"));
        trail.setIsPublic(rs.getBoolean("IsPublic"));
        trail.setIsDeleted(rs.getBoolean("IsDeleted"));
        return trail;
    };

    /**
     * Get all public trails
     */
    public List<Trail> findAllPublic() {
        String sql = "SELECT * FROM CW2.vw_PublicTrails ORDER BY CreatedDate DESC";
        return jdbcTemplate.query(sql, publicTrailRowMapper);
    }

    /**
     * Find trail by ID
     */
    public Optional<Trail> findById(Integer trailId) {
        try {
            String sql = "SELECT * FROM CW2.Trail WHERE TrailID = ? AND IsDeleted = 0";
            Trail trail = jdbcTemplate.queryForObject(sql, trailRowMapper, trailId);
            return Optional.ofNullable(trail);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    /**
     * Create trail using stored procedure
     */
    public Integer createTrail(Trail trail) {
        String sql = "{CALL CW2.sp_InsertTrail(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        
        KeyHolder keyHolder = new GeneratedKeyHolder();
        
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, trail.getUserId());
            ps.setString(2, trail.getTrailName());
            ps.setString(3, trail.getSummary());
            ps.setString(4, trail.getTrailDescription());
            ps.setBigDecimal(5, trail.getLengthMiles());
            ps.setBigDecimal(6, trail.getLengthKm());
            ps.setString(7, trail.getDifficulty());
            ps.setString(8, trail.getAccessibilityNotes());
            ps.setString(9, trail.getRouteType());
            ps.setString(10, trail.getNearestTown());
            ps.setString(11, trail.getStartPostcode());
            ps.setString(12, trail.getFinishLocation());
            ps.setString(13, trail.getFinishPostcode());
            ps.setBoolean(14, trail.getIsPublic());
            return ps;
        }, keyHolder);
        
        return keyHolder.getKey().intValue();
    }

    /**
     * Update trail using stored procedure
     */
    public boolean updateTrail(Integer trailId, Trail trail) {
        String sql = "{CALL CW2.sp_UpdateTrail(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        
        int rowsAffected = jdbcTemplate.update(sql,
            trailId,
            trail.getTrailName(),
            trail.getSummary(),
            trail.getTrailDescription(),
            trail.getLengthMiles(),
            trail.getLengthKm(),
            trail.getDifficulty(),
            trail.getAccessibilityNotes(),
            trail.getRouteType(),
            trail.getNearestTown(),
            trail.getStartPostcode(),
            trail.getFinishLocation(),
            trail.getFinishPostcode(),
            trail.getIsPublic(),
            trail.getLastModifiedBy()
        );
        
        return rowsAffected > 0;
    }

    /**
     * Soft delete trail using stored procedure
     */
    public boolean deleteTrail(Integer trailId, Integer userId) {
        String sql = "{CALL CW2.sp_DeleteTrail(?, ?)}";
        int rowsAffected = jdbcTemplate.update(sql, trailId, userId);
        return rowsAffected > 0;
    }

    /**
     * Search trails by criteria
     */
    public List<Trail> searchTrails(String searchTerm, String difficulty) {
        StringBuilder sql = new StringBuilder(
            "SELECT * FROM CW2.Trail WHERE IsDeleted = 0 AND IsPublic = 1"
        );
        
        if (searchTerm != null && !searchTerm.isEmpty()) {
            sql.append(" AND (TrailName LIKE ? OR NearestTown LIKE ?)");
        }
        
        if (difficulty != null && !difficulty.isEmpty()) {
            sql.append(" AND Difficulty = ?");
        }
        
        sql.append(" ORDER BY CreatedDate DESC");
        
        if (searchTerm != null && !searchTerm.isEmpty() && difficulty != null && !difficulty.isEmpty()) {
            String search = "%" + searchTerm + "%";
            return jdbcTemplate.query(sql.toString(), trailRowMapper, search, search, difficulty);
        } else if (searchTerm != null && !searchTerm.isEmpty()) {
            String search = "%" + searchTerm + "%";
            return jdbcTemplate.query(sql.toString(), trailRowMapper, search, search);
        } else if (difficulty != null && !difficulty.isEmpty()) {
            return jdbcTemplate.query(sql.toString(), trailRowMapper, difficulty);
        } else {
            return jdbcTemplate.query(sql.toString(), trailRowMapper);
        }
    }
}
