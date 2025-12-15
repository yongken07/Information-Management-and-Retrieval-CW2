package com.university.trailservice.service;

import com.university.trailservice.dto.AuthResponse;
import com.university.trailservice.dto.LoginRequest;
import com.university.trailservice.dto.RegisterRequest;
import com.university.trailservice.model.User;
import com.university.trailservice.repository.UserRepository;
import com.university.trailservice.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Authentication Service
 * Handles user registration and login with security
 */
@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    /**
     * Register new user
     */
    public AuthResponse register(RegisterRequest request) {
        // Check if username already exists
        if (userRepository.existsByUsername(request.username())) {
            throw new RuntimeException("Username already exists");
        }

        // Check if email already exists
        if (userRepository.existsByEmail(request.email())) {
            throw new RuntimeException("Email already exists");
        }

        // Hash password
        String passwordHash = passwordEncoder.encode(request.password());

        // Create user
        Integer userId = userRepository.createUser(
            request.username(),
            request.email(),
            passwordHash
        );

        // Generate JWT token
        String token = jwtTokenProvider.generateToken(userId, request.username());

        return new AuthResponse(userId, request.username(), request.email(), token);
    }

    /**
     * Login user and return JWT token
     */
    public AuthResponse login(LoginRequest request) {
        // Find user by username
        User user = userRepository.findByUsername(request.username())
            .orElseThrow(() -> new RuntimeException("Invalid username or password"));

        // Verify password
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid username or password");
        }

        // Update last login
        userRepository.updateLastLogin(user.getUserId());

        // Generate JWT token
        String token = jwtTokenProvider.generateToken(user.getUserId(), user.getUsername());

        return new AuthResponse(user.getUserId(), user.getUsername(), user.getEmail(), token);
    }
}
