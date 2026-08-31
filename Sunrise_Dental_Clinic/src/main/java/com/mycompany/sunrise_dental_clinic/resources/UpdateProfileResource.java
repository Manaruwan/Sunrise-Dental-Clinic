package com.mycompany.sunrise_dental_clinic.resources;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@Path("/users")
public class UpdateProfileResource {

    // Database Connection Helper (ඔබගේ DB configuration අනුව port/name පරීක්ෂා කරගන්න)
    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/dental_db", "root", "");
    }

    @PUT
    @Path("/update_profile")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateProfile(ProfileRequest req) {
        return processUpdate(req);
    }

    @POST
    @Path("/update_profile")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateProfilePost(ProfileRequest req) {
        return processUpdate(req);
    }

    private Response processUpdate(ProfileRequest req) {
        if (req == null || req.username == null || req.username.trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"status\":\"error\",\"message\":\"Username is required\"}").build();
        }

        try (Connection conn = getConnection()) {
            // 1. Verify User Account
            String checkSql = "SELECT password FROM users WHERE username = ? OR full_name = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, req.username.trim());
                checkStmt.setString(2, req.username.trim());
                ResultSet rs = checkStmt.executeQuery();

                if (!rs.next()) {
                    return Response.status(Response.Status.NOT_FOUND)
                            .entity("{\"status\":\"error\",\"message\":\"User account not found\"}").build();
                }

                String dbPass = rs.getString("password");

                // 2. If password change requested, verify current password
                if (req.newPassword != null && !req.newPassword.trim().isEmpty()) {
                    if (req.currentPassword == null || !req.currentPassword.trim().equals(dbPass)) {
                        return Response.status(Response.Status.UNAUTHORIZED)
                                .entity("{\"status\":\"error\",\"message\":\"Current password does not match!\"}").build();
                    }
                }
            }

            // 3. Update User Table
            StringBuilder updateSql = new StringBuilder("UPDATE users SET full_name = ?");
            if (req.newPassword != null && !req.newPassword.trim().isEmpty()) {
                updateSql.append(", password = ?");
            }
            updateSql.append(" WHERE username = ? OR full_name = ?");

            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql.toString())) {
                updateStmt.setString(1, req.fullName != null ? req.fullName.trim() : req.username);
                int paramIdx = 2;
                if (req.newPassword != null && !req.newPassword.trim().isEmpty()) {
                    updateStmt.setString(paramIdx++, req.newPassword.trim());
                }
                updateStmt.setString(paramIdx++, req.username.trim());
                updateStmt.setString(paramIdx, req.username.trim());

                updateStmt.executeUpdate();
            }

            // 4. Update doctors table if it is a doctor record
            try (PreparedStatement docStmt = conn.prepareStatement(
                    "UPDATE doctors SET doctor_name = ? WHERE doctor_name = ? OR username = ?")) {
                docStmt.setString(1, req.fullName.trim());
                docStmt.setString(2, req.username.trim());
                docStmt.setString(3, req.username.trim());
                docStmt.executeUpdate();
            } catch (Exception ignored) {}

            return Response.ok("{\"status\":\"success\",\"message\":\"Profile updated successfully!\"}").build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage() + "\"}").build();
        }
    }

    public static class ProfileRequest {
        public String username;
        public String fullName;
        public String currentPassword;
        public String newPassword;
    }
}