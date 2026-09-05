package com.mycompany.sunrise_dental_clinic.resources;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/auth")
public class AuthResource {

    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection("jdbc:mysql://localhost:3307/sunrise_dental?useSSL=false&allowPublicKeyRetrieval=true", "root", "");
    }

    public static class LoginRequest {
        public String username;
        public String password;
    }

    public static class ProfileDto {
        public String username;
        public String fullName;
        public String currentPassword;
        public String newPassword;
        public String availableDays;
        public String availableTime;
    }

    @POST
    @Path("/login")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response login(LoginRequest req) {
        if (req == null || req.username == null || req.password == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"status\":\"error\",\"message\":\"Username and password required\"}").build();
        }

        try (Connection conn = getConnection()) {
            String sql = "SELECT * FROM users WHERE (username = ? OR full_name = ?) AND password = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, req.username.trim());
                stmt.setString(2, req.username.trim());
                stmt.setString(3, req.password.trim());
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    String role = rs.getString("role");
                    String fullName = rs.getString("full_name");
                    String token = "TOKEN_" + System.currentTimeMillis();

                    return Response.ok(String.format(
                            "{\"status\":\"success\",\"token\":\"%s\",\"role\":\"%s\",\"username\":\"%s\",\"fullName\":\"%s\"}",
                            token, role, req.username.trim(), fullName != null ? fullName : req.username.trim()
                    )).build();
                } else {
                    return Response.status(Response.Status.UNAUTHORIZED)
                            .entity("{\"status\":\"error\",\"message\":\"Invalid credentials!\"}").build();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage() + "\"}").build();
        }
    }

    @POST
    @Path("/update_profile")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateProfile(ProfileDto req) {
        if (req == null || req.username == null || req.username.trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"status\":\"error\",\"message\":\"Username is required\"}").build();
        }

        try (Connection conn = getConnection()) {
            String targetUser = req.username.trim();
            String cleanTarget = targetUser.replaceAll("(?i)^dr\\.?\\s*", "").trim();

            if (req.newPassword != null && !req.newPassword.trim().isEmpty()) {
                String verifySql = "SELECT password FROM users WHERE username = ? OR full_name = ? OR full_name = ?";
                try (PreparedStatement vStmt = conn.prepareStatement(verifySql)) {
                    vStmt.setString(1, targetUser);
                    vStmt.setString(2, targetUser);
                    vStmt.setString(3, cleanTarget);
                    ResultSet rs = vStmt.executeQuery();

                    if (rs.next()) {
                        String dbPass = rs.getString("password");
                        if (req.currentPassword == null || !req.currentPassword.trim().equals(dbPass)) {
                            return Response.status(Response.Status.UNAUTHORIZED)
                                    .entity("{\"status\":\"error\",\"message\":\"Current password does not match!\"}").build();
                        }
                    }
                }
            }

            StringBuilder userSql = new StringBuilder("UPDATE users SET full_name = ?");
            if (req.newPassword != null && !req.newPassword.trim().isEmpty()) {
                userSql.append(", password = ?");
            }
            userSql.append(" WHERE username = ? OR full_name = ? OR full_name = ?");

            try (PreparedStatement uStmt = conn.prepareStatement(userSql.toString())) {
                uStmt.setString(1, req.fullName != null ? req.fullName.trim() : targetUser);
                int idx = 2;
                if (req.newPassword != null && !req.newPassword.trim().isEmpty()) {
                    uStmt.setString(idx++, req.newPassword.trim());
                }
                uStmt.setString(idx++, targetUser);
                uStmt.setString(idx++, targetUser);
                uStmt.setString(idx, cleanTarget);
                uStmt.executeUpdate();
            }

            try {
                String docSql = "UPDATE doctors SET doctor_name = ?, available_days = ?, available_time = ? WHERE doctor_name = ? OR doctor_name = ? OR username = ?";
                try (PreparedStatement dStmt = conn.prepareStatement(docSql)) {
                    dStmt.setString(1, req.fullName != null ? req.fullName.trim() : targetUser);
                    dStmt.setString(2, req.availableDays != null && !req.availableDays.isEmpty() ? req.availableDays : "Mon - Sat");
                    dStmt.setString(3, req.availableTime != null && !req.availableTime.isEmpty() ? req.availableTime : "09:00 AM - 05:00 PM");
                    dStmt.setString(4, targetUser);
                    dStmt.setString(5, cleanTarget);
                    dStmt.setString(6, targetUser);
                    dStmt.executeUpdate();
                }
            } catch (Exception ignored) {}

            return Response.ok("{\"status\":\"success\",\"message\":\"Profile updated successfully!\"}").build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage() + "\"}").build();
        }
    }
}