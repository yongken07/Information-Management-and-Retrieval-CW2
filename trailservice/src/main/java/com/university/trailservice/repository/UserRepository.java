package com.university.trailservice.repository;

import com.university.trailservice.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Optional;

/**
 * User Repository
 * Data access layer for User entity using stored procedures
 */
@Repository
public class UserRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final RowMapper<User> userRowMapper = (rs, rowNum) -> {
        User user = new User();
        user.setUserId(rs.getInt("UserID"));
        user.setUsername(rs.getString("Username"));
        user.setEmail(rs.getString("Email"));
        user.setPasswordHash(rs.getString("PasswordHash"));
        user.setCreatedDate(rs.getTimestamp("CreatedDate").toLocalDateTime());
        if (rs.getTimestamp("LastLoginDate") != null) {
            user.setLastLoginDate(rs.getTimestamp("LastLoginDate").toLocalDateTime());
        }
        user.setIsActive(rs.getBoolean("IsActive"));
        return user;
    };

    /**
     * Find user by username
     */
    public Optional<User> findByUsername(String username) {
        try {
            String sql = "SELECT * FROM CW2.[User] WHERE Username = ? AND IsActive = 1";
            User user = jdbcTemplate.queryForObject(sql, userRowMapper, username);
            return Optional.ofNullable(user);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    /**
     * Find user by ID
     */
    public Optional<User> findById(Integer userId) {
        try {
            String sql = "SELECT * FROM CW2.[User] WHERE UserID = ? AND IsActive = 1";
            User user = jdbcTemplate.queryForObject(sql, userRowMapper, userId);
            return Optional.ofNullable(user);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    /**
     * Create new user using direct INSERT
     */
    public Integer createUser(String username, String email, String passwordHash) {
        String sql = "INSERT INTO CW2.[User] (Username, Email, PasswordHash, CreatedDate, IsActive) " +
                     "VALUES (?, ?, ?, GETDATE(), 1)";
        
        KeyHolder keyHolder = new GeneratedKeyHolder();
        
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, passwordHash);
            return ps;
        }, keyHolder);
        
        return keyHolder.getKey().intValue();
    }

    /**
     * Update last login date
     */
    public void updateLastLogin(Integer userId) {
        String sql = "UPDATE CW2.[User] SET LastLoginDate = GETDATE() WHERE UserID = ?";
        jdbcTemplate.update(sql, userId);
    }

    /**
     * Check if username exists
     */
    public boolean existsByUsername(String username) {
        String sql = "SELECT COUNT(*) FROM CW2.[User] WHERE Username = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, username);
        return count != null && count > 0;
    }

    /**
     * Check if email exists
     */
    public boolean existsByEmail(String email) {
        String sql = "SELECT COUNT(*) FROM CW2.[User] WHERE Email = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, email);
        return count != null && count > 0;
    }
}
