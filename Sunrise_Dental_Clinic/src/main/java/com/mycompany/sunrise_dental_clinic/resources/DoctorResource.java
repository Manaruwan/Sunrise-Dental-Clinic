package com.mycompany.sunrise_dental_clinic.resources;

import Libs.DBUtil;
import Libs.Doctor;
import Libs.MySQLUtils;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@Path("/doctors")
public class DoctorResource {

    // Browser Preflight Request (CORS) Handle කිරීම
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
        List<Doctor> list = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            ResultSet rs = MySQLUtils.executeQuery(conn, "SELECT doctor_id, doctor_name, location, tel_no FROM doctors ORDER BY doctor_id DESC");
            
            while (rs.next()) {
                Doctor doc = new Doctor(
                    rs.getString("doctor_id"),
                    rs.getString("doctor_name"),
                    rs.getString("location"),
                    rs.getString("tel_no")
                );
                list.add(doc);
            }
            
            return Response.ok(list)
                    .header("Access-Control-Allow-Origin", "*")
                    .header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
                    .header("Access-Control-Allow-Headers", "Content-Type, Authorization")
                    .build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(500)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .header("Access-Control-Allow-Origin", "*")
                    .build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response addDoctor(Doctor doctor) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO doctors (doctor_id, doctor_name, location, tel_no) VALUES (?, ?, ?, ?)";
            
            int rows = MySQLUtils.executeUpdate(conn, sql, 
                    doctor.getDoctorId(), 
                    doctor.getName(), 
                    doctor.getLocation(), 
                    doctor.getTelNo());

            if (rows > 0) {
                return Response.status(Response.Status.CREATED)
                        .entity("{\"message\":\"Doctor added successfully\"}")
                        .header("Access-Control-Allow-Origin", "*")
                        .build();
            } else {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Failed to insert doctor\"}")
                        .header("Access-Control-Allow-Origin", "*")
                        .build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(500)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .header("Access-Control-Allow-Origin", "*")
                    .build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }
}