package com.mycompany.sunrise_dental_clinic.resources;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.OPTIONS;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/doctors")
public class DoctorResource {

    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection("jdbc:mysql://localhost:3307/sunrise_dental?useSSL=false&allowPublicKeyRetrieval=true", "root", "");
    }

    @OPTIONS
    public Response handleOptions() {
        return Response.ok()
                .header("Access-Control-Allow-Origin", "*")
                .header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
                .header("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept")
                .build();
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAllDoctors() {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT * FROM doctors";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> doc = new HashMap<>();
                    doc.put("doctorId", rs.getString("doctor_id"));
                    doc.put("doctorName", rs.getString("doctor_name"));
                    doc.put("location", rs.getString("location"));
                    doc.put("telNo", rs.getString("tel_no"));
                    doc.put("availableDays", rs.getString("available_days") != null ? rs.getString("available_days") : "Mon - Sat");
                    doc.put("availableTime", rs.getString("available_time") != null ? rs.getString("available_time") : "09:00 AM - 05:00 PM");
                    doc.put("specialization", rs.getString("specialization") != null ? rs.getString("specialization") : "All Treatments");
                    list.add(doc);
                }
            }
            return Response.ok(list).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}").build();
        }
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createDoctor(DoctorDto req) {
        if (req == null || req.doctorName == null || req.doctorName.trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"status\":\"error\",\"message\":\"Doctor name is required\"}").build();
        }

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sql = "INSERT INTO doctors (doctor_id, doctor_name, location, tel_no, available_days, available_time, specialization) VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, req.doctorId != null ? req.doctorId : "DOC-" + System.currentTimeMillis());
                    stmt.setString(2, req.doctorName);
                    stmt.setString(3, req.location != null ? req.location : "Nugegoda");
                    stmt.setString(4, req.telNo != null ? req.telNo : "-");
                    stmt.setString(5, req.availableDays != null ? req.availableDays : "Mon - Sat");
                    stmt.setString(6, req.availableTime != null ? req.availableTime : "09:00 AM - 05:00 PM");
                    stmt.setString(7, req.specialization != null && !req.specialization.isEmpty() ? req.specialization : "All Treatments");
                    stmt.executeUpdate();
                }

                String userSql = "INSERT INTO users (username, password, role, full_name) VALUES (?, ?, 'doctor', ?)";
                try (PreparedStatement uStmt = conn.prepareStatement(userSql)) {
                    uStmt.setString(1, req.username != null ? req.username : req.doctorId);
                    uStmt.setString(2, req.password != null ? req.password : "1234");
                    uStmt.setString(3, req.doctorName);
                    uStmt.executeUpdate();
                } catch (Exception ignored) {}

                conn.commit();
                return Response.ok("{\"status\":\"success\",\"message\":\"Doctor registered successfully!\"}").build();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}").build();
        }
    }

    @PUT
    @Path("/{id}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateDoctor(@PathParam("id") String id, DoctorDto req) {
        try (Connection conn = getConnection()) {
            String sql = "UPDATE doctors SET doctor_name=?, location=?, tel_no=?, available_days=COALESCE(NULLIF(?, ''), available_days), available_time=COALESCE(NULLIF(?, ''), available_time) WHERE doctor_id=?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, req.doctorName);
                stmt.setString(2, req.location);
                stmt.setString(3, req.telNo);
                stmt.setString(4, req.availableDays);
                stmt.setString(5, req.availableTime);
                stmt.setString(6, id);
                stmt.executeUpdate();
            }
            return Response.ok("{\"status\":\"success\",\"message\":\"Doctor updated successfully!\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}").build();
        }
    }

    @DELETE
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response deleteDoctor(@PathParam("id") String id) {
        try (Connection conn = getConnection()) {
            String sql = "DELETE FROM doctors WHERE doctor_id=?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, id);
                stmt.executeUpdate();
            }
            return Response.ok("{\"status\":\"success\",\"message\":\"Doctor deleted successfully!\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}").build();
        }
    }

    public static class DoctorDto {
        public String doctorId;
        public String doctorName;
        public String location;
        public String telNo;
        public String availableDays;
        public String availableTime;
        public String specialization;
        public String username;
        public String password;
    }
}