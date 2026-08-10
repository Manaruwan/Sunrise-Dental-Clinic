package com.mycompany.sunrise_dental_clinic;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/AddDoctorServlet")
public class AddDoctorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String docId = request.getParameter("doctorId");
        String docName = request.getParameter("doctorName");
        String location = request.getParameter("location");
        String telNo = request.getParameter("telNo");

        try {
            Connection conn = DatabaseManager.getInstance().getConnection();
            String sql = "INSERT INTO doctors (doctor_id, doctor_name, location, tel_no) VALUES (?, ?, ?, ?)";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, docId);
            stmt.setString(2, docName);
            stmt.setString(3, location);
            stmt.setString(4, telNo);
            
            stmt.executeUpdate();

            response.sendRedirect("staff_dashboard.jsp?status=doc_success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?status=doc_error");
        }
    }
}