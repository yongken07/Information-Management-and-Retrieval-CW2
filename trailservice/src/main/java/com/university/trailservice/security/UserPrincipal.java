package com.university.trailservice.security;

/**
 * User Principal for Security Context
 */
public record UserPrincipal(
    Integer userId,
    String username
) {
}
