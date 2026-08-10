package com.mycompany.sunrise_dental_clinic;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.UUID;

@WebServlet("/AddAppointmentServlet")
public class AddAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Form Inputs
        String patientName = request.getParameter("patientName");
        String address = request.getParameter("address");
        String contact = request.getParameter("contact");
        String dentistName = request.getParameter("dentistName");
        String treatmentType = request.getParameter("treatmentType");
        String apptDateTime = request.getParameter("apptDateTime");

        // System Generated Auto IDs
        String apptNum = "APT-" + (System.currentTimeMillis() % 10000);
        String patientId = "PAT-" + UUID.randomUUID().toString().substring(0, 5);

        try {
            Connection conn = DatabaseManager.getInstance().getConnection();

            // 1. Save Patient Details First
            String sqlPatient = "INSERT INTO patients (patient_id, name, address, contact) VALUES (?, ?, ?, ?)";
            PreparedStatement pstmtPatient = conn.prepareStatement(sqlPatient);
            pstmtPatient.setString(1, patientId);
            pstmtPatient.setString(2, patientName);
            pstmtPatient.setString(3, address);
            pstmtPatient.setString(4, contact);
            pstmtPatient.executeUpdate();

            // 2. Save Appointment Details
            String sqlAppt = "INSERT INTO appointments (appointment_num, patient_id, dentist_name, treatment_type, appt_date_time) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement pstmtAppt = conn.prepareStatement(sqlAppt);
            pstmtAppt.setString(1, apptNum);
            pstmtAppt.setString(2, patientId);
            pstmtAppt.setString(3, dentistName);
            pstmtAppt.setString(4, treatmentType);
            pstmtAppt.setString(5, apptDateTime);
            pstmtAppt.executeUpdate();

            // Success Redirect with Generated Appointment Number
            response.sendRedirect("staff_dashboard.jsp?status=appt_success&apptNum=" + apptNum);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff_dashboard.jsp?status=appt_error");
        }
    }
}