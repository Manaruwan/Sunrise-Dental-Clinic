package com.mycompany.sunrise_dental_clinic.resources;

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
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            stmt = conn.createStatement();
            String sql = "SELECT doctor_id, doctor_name, location, tel_no FROM doctors";
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("doctor_id", rs.getString("doctor_id") != null ? rs.getString("doctor_id") : "");
                obj.put("doctor_name", rs.getString("doctor_name") != null ? rs.getString("doctor_name") : "");
                obj.put("location", rs.getString("location") != null ? rs.getString("location") : "Nugegoda");
                obj.put("tel_no", rs.getString("tel_no") != null ? rs.getString("tel_no") : "-");
                arr.put(obj);
            }
            return addCors(Response.ok(arr.toString())).build();
        } catch (Exception e) {
            e.printStackTrace();
            return addCors(Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (stmt != null) try { stmt.close(); } catch (Exception ignored) {}
            DBUtil.closeConnection(conn);
        }
    }

    // 2. POST - REGISTER DOCTOR
    @POST
    @Path("doctors")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response addDoctor(String jsonBody) {
        Connection conn = null;
        try {
            JSONObject data = new JSONObject(jsonBody);
            String docId = data.optString("doctorId", data.optString("doctor_id", "DOC-" + (System.currentTimeMillis() % 10000)));
            String docName = data.optString("doctorName", data.optString("doctor_name", ""));
            String location = data.optString("location", data.optString("branch", "Nugegoda"));
            String telNo = data.optString("telNo", data.optString("tel_no", "-"));
            String username = data.optString("username", docId);
            String password = data.optString("password", "1234");

            if (docName.trim().isEmpty()) {
                return addCors(Response.status(400).entity("{\"error\":\"Doctor Name is required\"}")).build();
            }

            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String docSql = "INSERT INTO doctors (doctor_id, doctor_name, location, tel_no) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psDoc = conn.prepareStatement(docSql)) {
                psDoc.setString(1, docId);
                psDoc.setString(2, docName);
                psDoc.setString(3, location);
                psDoc.setString(4, telNo);
                psDoc.executeUpdate();
            }

            try {
                String userSql = "INSERT INTO users (username, password, role, full_name) VALUES (?, ?, 'DOCTOR', ?)";
                try (PreparedStatement psUser = conn.prepareStatement(userSql)) {
                    psUser.setString(1, username);
                    psUser.setString(2, password);
                    psUser.setString(3, docName);
                    psUser.executeUpdate();
                }
            } catch (Exception ignored) {}

            conn.commit();
            return addCors(Response.ok("{\"status\":\"success\",\"message\":\"Doctor registered successfully!\"}")).build();
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
            return addCors(Response.status(500).entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 3. GET ALL TREATMENTS
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

    // 4. POST - ADD TREATMENT
    @POST
    @Path("treatments")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response addTreatment(String jsonBody) {
        Connection conn = null;
        try {
            JSONObject data = new JSONObject(jsonBody);
            String name = data.getString("treatmentName");
            double cost = data.getDouble("cost");

            conn = DBUtil.getConnection();
            String sql = "INSERT INTO treatments (treatment_name, cost) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, name);
                ps.setDouble(2, cost);
                ps.executeUpdate();
            }
            return addCors(Response.ok("{\"status\":\"success\",\"message\":\"Treatment saved successfully!\"}")).build();
        } catch (Exception e) {
            return addCors(Response.status(500).entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 5. GET ALL PATIENTS
    @GET
    @Path("patients")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPatients() {
        JSONArray arr = new JSONArray();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT patient_id, name, address, contact FROM patients ORDER BY patient_id DESC");
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("patient_id", rs.getString("patient_id"));
                obj.put("name", rs.getString("name"));
                obj.put("address", rs.getString("address") != null ? rs.getString("address") : "-");
                obj.put("contact", rs.getString("contact") != null ? rs.getString("contact") : "-");
                arr.put(obj);
            }
            return addCors(Response.ok(arr.toString())).build();
        } catch (Exception e) {
            return addCors(Response.status(500).entity("{\"error\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 6. POST - REGISTER PATIENT
    @POST
    @Path("patients")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response addPatient(String jsonBody) {
        Connection conn = null;
        try {
            JSONObject data = new JSONObject(jsonBody);
            String patName = data.getString("name");
            String address = data.optString("address", "N/A");
            String contact = data.getString("contact");
            String patId = "PAT-" + (int)(Math.random() * 9000 + 1000);

            conn = DBUtil.getConnection();
            String sql = "INSERT INTO patients (patient_id, name, address, contact) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, patId);
                ps.setString(2, patName);
                ps.setString(3, address);
                ps.setString(4, contact);
                ps.executeUpdate();
            }

            return addCors(Response.ok("{\"status\":\"success\",\"patientId\":\"" + patId + "\",\"message\":\"Patient registered successfully!\"}")).build();
        } catch (Exception e) {
            return addCors(Response.status(500).entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 7. GET ALL APPOINTMENTS
    @GET
    @Path("all_appointments")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAppointments() {
        JSONArray arr = new JSONArray();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            Statement stmt = conn.createStatement();
            String sql = "SELECT a.*, p.name AS patient_name, p.contact AS patient_contact FROM appointments a LEFT JOIN patients p ON a.patient_id = p.patient_id ORDER BY a.appt_date_time DESC";
            ResultSet rs = stmt.executeQuery(sql);
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

    // 8. POST - CREATE APPOINTMENT
    @POST
    @Path("create_appointment")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createAppointment(String jsonBody) {
        Connection conn = null;
        try {
            JSONObject data = new JSONObject(jsonBody);
            String patName = data.getString("patientName");
            String address = data.optString("address", "N/A");
            String contact = data.getString("contact");
            String dentist = data.getString("dentistName");
            String treatment = data.getString("treatmentType");
            String apptDateTime = data.getString("apptDateTime");

            String patId = "PAT-" + (int)(Math.random() * 9000 + 1000);
            String apptNum = "APT-" + (System.currentTimeMillis() % 10000);

            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String pSql = "INSERT INTO patients (patient_id, name, address, contact) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psP = conn.prepareStatement(pSql)) {
                psP.setString(1, patId);
                psP.setString(2, patName);
                psP.setString(3, address);
                psP.setString(4, contact);
                psP.executeUpdate();
            }

            String aSql = "INSERT INTO appointments (appointment_num, patient_id, dentist_name, treatment_type, appt_date_time, status) VALUES (?, ?, ?, ?, ?, 'Pending')";
            try (PreparedStatement psA = conn.prepareStatement(aSql)) {
                psA.setString(1, apptNum);
                psA.setString(2, patId);
                psA.setString(3, dentist);
                psA.setString(4, treatment);
                psA.setString(5, apptDateTime);
                psA.executeUpdate();
            }

            conn.commit();
            return addCors(Response.ok("{\"status\":\"success\",\"appointmentNumber\":\"" + apptNum + "\"}")).build();
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            return addCors(Response.status(500).entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 9. POST - UPDATE APPOINTMENT STATUS
    @POST
    @Path("update_appointment_status")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateAppointmentStatus(String jsonBody) {
        Connection conn = null;
        try {
            JSONObject data = new JSONObject(jsonBody);
            String apptNo = data.optString("appointmentNumber", data.optString("appointment_num", ""));
            String newStatus = data.optString("status", "Completed");

            if (apptNo.trim().isEmpty()) {
                return addCors(Response.status(400).entity("{\"status\":\"error\",\"message\":\"Appointment Number is required\"}")).build();
            }

            conn = DBUtil.getConnection();
            String sql = "UPDATE appointments SET status = ? WHERE appointment_num = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setString(2, apptNo);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    return addCors(Response.ok("{\"status\":\"success\",\"message\":\"Status updated successfully!\"}")).build();
                } else {
                    return addCors(Response.status(404).entity("{\"status\":\"error\",\"message\":\"Appointment not found\"}")).build();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return addCors(Response.status(500).entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 10. GET ALL BILLS
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

    // 11. POST - ISSUE & SAVE BILL (Dual Path Support: /save_bill & /bills)
    @POST
    @Path("save_bill")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response saveBillDirect(String jsonBody) {
        return processSaveBill(jsonBody);
    }

    @POST
    @Path("bills")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response saveBillGeneric(String jsonBody) {
        return processSaveBill(jsonBody);
    }

    private Response processSaveBill(String jsonBody) {
        Connection conn = null;
        try {
            JSONObject data = new JSONObject(jsonBody);
            String apptNo = data.optString("appointmentNumber", data.optString("appointment_num", "-"));
            String pName = data.optString("patientName", data.optString("patient_name", "-"));
            String treatment = data.optString("treatment", data.optString("treatment_type", "-"));
            double consultFee = data.optDouble("consultationFee", data.optDouble("consultation_fee", 2000.00));
            double treatFee = data.optDouble("treatmentFee", data.optDouble("treatment_fee", 0.00));
            double totalAmount = data.optDouble("totalAmount", data.optDouble("total_amount", consultFee + treatFee));

            conn = DBUtil.getConnection();
            String sql = "INSERT INTO bills (appointment_num, patient_name, treatment_type, consultation_fee, treatment_fee, total_amount) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, apptNo);
                ps.setString(2, pName);
                ps.setString(3, treatment);
                ps.setDouble(4, consultFee);
                ps.setDouble(5, treatFee);
                ps.setDouble(6, totalAmount);
                ps.executeUpdate();
            }
            return addCors(Response.ok("{\"status\":\"success\",\"message\":\"Invoice saved successfully!\"}")).build();
        } catch (Exception e) {
            e.printStackTrace();
            return addCors(Response.status(500).entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    // 12. POST - AUTHENTICATE USER LOGIN
    @POST
    @Path("login")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response loginUser(String jsonBody) {
        Connection conn = null;
        try {
            JSONObject data = new JSONObject(jsonBody);
            String username = data.optString("username", "").trim();
            String password = data.optString("password", "").trim();

            if (username.isEmpty() || password.isEmpty()) {
                return addCors(Response.status(400).entity("{\"status\":\"error\",\"message\":\"Username and password are required\"}")).build();
            }

            conn = DBUtil.getConnection();
            String sql = "SELECT username, role, full_name FROM users WHERE username = ? AND password = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        JSONObject res = new JSONObject();
                        res.put("status", "success");
                        res.put("username", rs.getString("username"));
                        res.put("role", rs.getString("role"));
                        res.put("full_name", rs.getString("full_name") != null ? rs.getString("full_name") : rs.getString("username"));
                        return addCors(Response.ok(res.toString())).build();
                    }
                }
            }

            // Fallback for staff demo login
            if (username.equalsIgnoreCase("staff") || username.equalsIgnoreCase("staff1")) {
                if (password.equals("1234") || password.equals("admin") || password.equals("staff") || password.equals("staff123")) {
                    JSONObject res = new JSONObject();
                    res.put("status", "success");
                    res.put("username", username);
                    res.put("role", "Staff");
                    res.put("full_name", "Staff Officer");
                    return addCors(Response.ok(res.toString())).build();
                }
            }

            return addCors(Response.status(401).entity("{\"status\":\"error\",\"message\":\"Invalid username or password!\"}")).build();
        } catch (Exception e) {
            e.printStackTrace();
            return addCors(Response.status(500).entity("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}")).build();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }
}