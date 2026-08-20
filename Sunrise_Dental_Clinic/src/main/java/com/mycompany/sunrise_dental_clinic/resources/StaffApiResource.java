package com.mycompany.dental_uiapp.resources;

import Libs.DBUtil;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;

@Path("/")
public class StaffApiResource {

    private Response.ResponseBuilder addCors(Response.ResponseBuilder rb) {
        return rb.header("Access-Control-Allow-Origin", "*")
                 .header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
                 .header("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept");
    }

    @OPTIONS
    @Path("{path: .*}")
    public Response handleCors() {
        return addCors(Response.ok()).build();
    }

    // 1. GET ALL DOCTORS
    @GET
    @Path("doctors")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getDoctors() {
        JSONArray arr = new JSONArray();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT doctor_id, doctor_name, location, tel_no FROM doctors ORDER BY doctor_id DESC");
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("doctor_id", rs.getString("doctor_id"));
                obj.put("doctor_name", rs.getString("doctor_name"));
                obj.put("location", rs.getString("location"));
                obj.put("tel_no", rs.getString("tel_no"));
                arr.put(obj);
            }
            return addCors(Response.ok(arr.toString())).build();
        } catch (Exception e) {
            return addCors(Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 2. GET ALL TREATMENTS
    @GET
    @Path("treatments")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getTreatments() {
        JSONArray arr = new JSONArray();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT treatment_id, treatment_name, cost FROM treatments ORDER BY treatment_id ASC");
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("treatment_id", rs.getInt("treatment_id"));
                obj.put("treatment_name", rs.getString("treatment_name"));
                obj.put("cost", rs.getDouble("cost"));
                arr.put(obj);
            }
            return addCors(Response.ok(arr.toString())).build();
        } catch (Exception e) {
            return addCors(Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 3. GET ALL APPOINTMENTS
    @GET
    @Path("all_appointments")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAppointments() {
        JSONArray arr = new JSONArray();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            Statement stmt = conn.createStatement();
            String sql = "SELECT a.appointment_num, " +
                         "COALESCE(p.name, 'Unknown') AS patient_name, " +
                         "COALESCE(p.contact, '-') AS patient_contact, " +
                         "a.dentist_name, a.treatment_type, a.appt_date_time, " +
                         "COALESCE(a.status, 'Pending') AS status " +
                         "FROM appointments a " +
                         "LEFT JOIN patients p ON TRIM(LOWER(a.patient_id)) = TRIM(LOWER(p.patient_id)) " +
                         "ORDER BY a.appt_date_time DESC";

            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("appointment_num", rs.getString("appointment_num"));
                obj.put("patient_name", rs.getString("patient_name"));
                obj.put("patient_contact", rs.getString("patient_contact"));
                obj.put("dentist_name", rs.getString("dentist_name"));
                obj.put("treatment_type", rs.getString("treatment_type"));
                obj.put("appt_date_time", rs.getString("appt_date_time"));
                obj.put("status", rs.getString("status"));
                arr.put(obj);
            }
            return addCors(Response.ok(arr.toString())).build();
        } catch (Exception e) {
            return addCors(Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 4. GET ALL BILLS
    @GET
    @Path("bills")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getBills() {
        JSONArray arr = new JSONArray();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM bills ORDER BY bill_id DESC");
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                for (int i = 1; i <= cols; i++) {
                    obj.put(meta.getColumnLabel(i).toLowerCase(), rs.getString(i));
                }
                arr.put(obj);
            }
            return addCors(Response.ok(arr.toString())).build();
        } catch (Exception e) {
            return addCors(Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }
}