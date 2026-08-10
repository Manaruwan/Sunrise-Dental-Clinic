<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.mycompany.sunrise_dental_clinic.DatabaseManager"%>
<%
    // Session Check - Ensure user is logged in as DOCTOR
    String user = (String) session.getAttribute("user");
    String fullName = (String) session.getAttribute("fullName");
    String role = (String) session.getAttribute("role");

    if (user == null || !"DOCTOR".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Doctor Dashboard - Sunrise Dental Clinic</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; }
        
        /* Top Navigation */
        .navbar { background: #0f172a; color: white; padding: 15px 5%; display: flex; justify-content: space-between; align-items: center; }
        .navbar .brand { font-size: 20px; font-weight: 600; color: #38bdf8; display: flex; align-items: center; gap: 10px; }
        .user-info { display: flex; align-items: center; gap: 20px; }
        .btn-logout { background: #ef4444; color: white; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 500; }
        
        /* Main Container */
        .container { padding: 40px 5%; max-width: 1200px; margin: auto; }
        .welcome-card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        .welcome-card h2 { color: #0284c7; }

        /* Appointments Table */
        .table-card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .table-card h3 { margin-bottom: 20px; font-size: 18px; color: #334155; }
        
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th, td { padding: 14px; border-bottom: 1px solid #e2e8f0; font-size: 14px; }
        th { background-color: #f1f5f9; color: #475569; font-weight: 600; }
        tr:hover { background-color: #f8fafc; }

        .badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }
        .badge-cleaning { background: #e0f2fe; color: #0369a1; }
        .badge-filling { background: #fef3c7; color: #b45309; }
        .badge-rct { background: #fce7f3; color: #be185d; }
        .badge-extraction { background: #fee2e2; color: #b91c1c; }
    </style>
</head>
<body>

    <!-- Header -->
    <div class="navbar">
        <div class="brand">
            <i class="fa-solid fa-user-doctor"></i> Sunrise Dental - Doctor Portal
        </div>
        <div class="user-info">
            <span><i class="fa-solid fa-circle-user"></i> <%= fullName %></span>
            <a href="LogoutServlet" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container">
        <div class="welcome-card">
            <div>
                <h2>Welcome Back, <%= fullName %>!</h2>
                <p style="color: #64748b; margin-top: 5px;">Here is the schedule of patient appointments assigned to you.</p>
            </div>
            <div>
                <i class="fa-solid fa-hospital-user" style="font-size: 50px; color: #0284c7;"></i>
            </div>
        </div>

        <!-- Appointments List -->
        <div class="table-card">
            <h3><i class="fa-solid fa-calendar-check"></i> Scheduled Appointments</h3>
            <table>
                <thead>
                    <tr>
                        <th>Appt No.</th>
                        <th>Patient Name</th>
                        <th>Contact</th>
                        <th>Treatment Type</th>
                        <th>Date & Time</th>
                        <th>Address</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection conn = DatabaseManager.getInstance().getConnection();
                            String sql = "SELECT a.appointment_num, p.name, p.contact, p.address, a.treatment_type, a.appt_date_time " +
                                         "FROM appointments a JOIN patients p ON a.patient_id = p.patient_id " +
                                         "ORDER BY a.appt_date_time DESC";
                            
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            ResultSet rs = pstmt.executeQuery();

                            boolean hasRecords = false;
                            while (rs.next()) {
                                hasRecords = true;
                                String treatment = rs.getString("treatment_type");
                                String badgeClass = "badge-cleaning";
                                if ("Filling".equalsIgnoreCase(treatment)) badgeClass = "badge-filling";
                                else if ("Root Canal".equalsIgnoreCase(treatment)) badgeClass = "badge-rct";
                                else if ("Extraction".equalsIgnoreCase(treatment)) badgeClass = "badge-extraction";
                    %>
                    <tr>
                        <td><strong><%= rs.getString("appointment_num") %></strong></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("contact") %></td>
                        <td><span class="badge <%= badgeClass %>"><%= treatment %></span></td>
                        <td><%= rs.getString("appt_date_time") %></td>
                        <td><%= rs.getString("address") %></td>
                    </tr>
                    <%
                            }
                            if (!hasRecords) {
                    %>
                    <tr>
                        <td colspan="6" style="text-align: center; color: #94a3b8; padding: 30px;">
                            No patient appointments registered yet.
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6' style='color:red;'>Error loading data: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>