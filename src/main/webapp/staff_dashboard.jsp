<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.mycompany.sunrise_dental_clinic.DatabaseManager"%>
<%
    // Session Verification
    String user = (String) session.getAttribute("user");
    String fullName = (String) session.getAttribute("fullName");
    String role = (String) session.getAttribute("role");

    if (user == null || "DOCTOR".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Staff Dashboard - Sunrise Dental Clinic</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; }
        
        /* Top Navigation Bar */
        .navbar { background: #0284c7; color: white; padding: 15px 5%; display: flex; justify-content: space-between; align-items: center; }
        .navbar .brand { font-size: 20px; font-weight: 700; display: flex; align-items: center; gap: 10px; }
        .user-info { display: flex; align-items: center; gap: 20px; }
        .btn-logout { background: #ef4444; color: white; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 500; }
        .btn-logout:hover { background: #dc2626; }

        /* Dashboard Tabs Layout */
        .container { padding: 30px 5%; max-width: 1200px; margin: auto; }
        .nav-tabs { display: flex; gap: 10px; margin-bottom: 25px; border-bottom: 2px solid #e2e8f0; flex-wrap: wrap; }
        .tab-btn { padding: 12px 24px; background: none; border: none; font-size: 15px; font-weight: 600; color: #64748b; cursor: pointer; display: flex; align-items: center; gap: 8px; }
        .tab-btn.active { color: #0284c7; border-bottom: 3px solid #0284c7; }

        .tab-content { display: none; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .tab-content.active { display: block; }

        /* Form Controls */
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px; margin-bottom: 20px; }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 13px; font-weight: 500; color: #475569; margin-bottom: 5px; }
        .form-group input, .form-group select { padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; }
        
        .btn-submit { background: #16a34a; color: white; padding: 12px 24px; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 15px; }
        .btn-submit:hover { background: #15803d; }

        /* Table Styling */
        table { width: 100%; border-collapse: collapse; margin-top: 15px; text-align: left; }
        th, td { padding: 12px; border-bottom: 1px solid #e2e8f0; font-size: 14px; }
        th { background: #f1f5f9; color: #334155; }
        
        /* Status Badges */
        .badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }
        .badge-pending { background: #fef3c7; color: #b45309; }
        .badge-done { background: #e0f2fe; color: #0369a1; }
        .badge-completed { background: #dcfce7; color: #15803d; }

        /* Help Box */
        .help-box { background: #f0f9ff; border-left: 4px solid #0284c7; padding: 20px; border-radius: 6px; margin-bottom: 15px; }
        .help-box h4 { color: #0369a1; margin-bottom: 8px; }
        .alert { padding: 12px; border-radius: 6px; margin-bottom: 15px; font-weight: 500; }
        .alert-success { background: #dcfce7; color: #15803d; }
        .alert-error { background: #fee2e2; color: #b91c1c; }
    </style>
</head>
<body>

    <!-- Header Navbar -->
    <div class="navbar">
        <div class="brand">
            <i class="fa-solid fa-tooth"></i> Sunrise Dental - Staff Dashboard
        </div>
        <div class="user-info">
            <span><i class="fa-solid fa-user-gear"></i> <%= fullName %> (Staff)</span>
            <a href="LogoutServlet" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
        </div>
    </div>

    <div class="container">
        
        <!-- Status Notification Messages -->
        <%
            String status = request.getParameter("status");
            if ("doc_success".equals(status)) {
        %>
            <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Doctor Added Successfully!</div>
        <% } else if ("doc_error".equals(status)) { %>
            <div class="alert alert-error"><i class="fa-solid fa-circle-xmark"></i> Failed to Add Doctor!</div>
        <% } %>

        <!-- Navigation Tabs -->
        <div class="nav-tabs">
            <button class="tab-btn active" onclick="switchTab('add-doctor')"><i class="fa-solid fa-user-plus"></i> Add New Doctor</button>
            <button class="tab-btn" onclick="switchTab('add-appointment')"><i class="fa-solid fa-calendar-plus"></i> Add Appointment</button>
            <button class="tab-btn" onclick="switchTab('appointments')"><i class="fa-solid fa-calendar-check"></i> Appointment Details</button>
            <button class="tab-btn" onclick="switchTab('billing-history')"><i class="fa-solid fa-file-invoice-dollar"></i> Saved Bills</button>
            <button class="tab-btn" onclick="switchTab('help')"><i class="fa-solid fa-circle-question"></i> Help Section</button>
        </div>

        <!-- TAB 1: ADD NEW DOCTOR -->
        <div id="add-doctor" class="tab-content active">
            <h3 style="margin-bottom: 20px; color: #0284c7;"><i class="fa-solid fa-user-doctor"></i> Register New Doctor</h3>
            <form action="AddDoctorServlet" method="POST">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Doctor ID</label>
                        <input type="text" name="doctorId" placeholder="e.g. DOC-101" required>
                    </div>
                    <div class="form-group">
                        <label>Doctor Name</label>
                        <input type="text" name="doctorName" placeholder="Dr. Firstname Lastname" required>
                    </div>
                    <div class="form-group">
                        <label>Location / Branch</label>
                        <input type="text" name="location" placeholder="e.g. Colombo 03" required>
                    </div>
                    <div class="form-group">
                        <label>Telephone No.</label>
                        <input type="text" name="telNo" placeholder="10 Digits" pattern="\d{10}" required>
                    </div>
                </div>
                <button type="submit" class="btn-submit"><i class="fa-solid fa-floppy-disk"></i> Save Doctor</button>
            </form>

            <!-- Registered Doctors List -->
            <h4 style="margin-top: 35px; color: #334155;">Registered Doctors List</h4>
            <table>
                <thead>
                    <tr>
                        <th>Doctor ID</th>
                        <th>Name</th>
                        <th>Location</th>
                        <th>Tel No</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection conn = DatabaseManager.getInstance().getConnection();
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery("SELECT * FROM doctors ORDER BY doctor_id DESC");
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><strong><%= rs.getString("doctor_id") %></strong></td>
                        <td><%= rs.getString("doctor_name") %></td>
                        <td><%= rs.getString("location") %></td>
                        <td><%= rs.getString("tel_no") %></td>
                    </tr>
                    <%      }
                        } catch(Exception e) { out.println("<tr><td colspan='4'>No doctors found.</td></tr>"); }
                    %>
                </tbody>
            </table>
        </div>

        <!-- TAB 2: ADD APPOINTMENT FORM TAB CONTENT -->
        <div id="add-appointment" class="tab-content">
            <h3 style="margin-bottom: 20px; color: #0284c7;">
                <i class="fa-solid fa-calendar-plus"></i> Register New Patient Appointment
            </h3>

            <!-- Notification Message -->
            <% 
                String apptStatus = request.getParameter("status");
                String apptNum = request.getParameter("apptNum");
                if ("appt_success".equals(apptStatus)) { 
            %>
                <div class="alert alert-success">
                    <i class="fa-solid fa-circle-check"></i> Appointment Successfully Registered! 
                    <strong>Assigned Appointment Number: <%= apptNum %></strong>
                </div>
            <% } else if ("appt_error".equals(apptStatus)) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-xmark"></i> Failed to Register Appointment! Please try again.
                </div>
            <% } %>

            <form action="AddAppointmentServlet" method="POST">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Patient Full Name</label>
                        <input type="text" name="patientName" placeholder="Enter Patient Name" required>
                    </div>

                    <div class="form-group">
                        <label>Address</label>
                        <input type="text" name="address" placeholder="Enter Address" required>
                    </div>

                    <div class="form-group">
                        <label>Contact Number (10 Digits)</label>
                        <input type="text" name="contact" placeholder="0771234567" pattern="\d{10}" required>
                    </div>

                    <div class="form-group">
                        <label>Select Dentist</label>
                        <select name="dentistName" required>
                            <option value="">-- Choose Dentist --</option>
                            <%
                                try {
                                    Connection conn = DatabaseManager.getInstance().getConnection();
                                    Statement stmt = conn.createStatement();
                                    ResultSet rsDoc = stmt.executeQuery("SELECT doctor_name FROM doctors");
                                    while (rsDoc.next()) {
                            %>
                            <option value="<%= rsDoc.getString("doctor_name") %>"><%= rsDoc.getString("doctor_name") %></option>
                            <%
                                    }
                                } catch (Exception e) {
                            %>
                            <option value="Dr. Wickramasinghe">Dr. Wickramasinghe</option>
                            <option value="Dr. Perera">Dr. Perera</option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Treatment Type</label>
                        <select name="treatmentType" required>
                            <option value="Cleaning">Teeth Cleaning / Scaling (LKR 5,000)</option>
                            <option value="Filling">Dental Filling (LKR 4,000)</option>
                            <option value="Root Canal">Root Canal Treatment (LKR 25,000)</option>
                            <option value="Extraction">Tooth Extraction (LKR 6,000)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Appointment Date & Time</label>
                        <input type="datetime-local" name="apptDateTime" required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-calendar-check"></i> Save & Confirm Appointment
                </button>
            </form>
        </div>

        <!-- TAB 3: APPOINTMENT DETAILS & TIME/DATE WITH REAL-TIME STATUS -->
        <div id="appointments" class="tab-content">
            <h3 style="margin-bottom: 20px; color: #0284c7;"><i class="fa-solid fa-list-check"></i> Patient Appointment Details & Schedule</h3>
            
            <table>
                <thead>
                    <tr>
                        <th>Appt No.</th>
                        <th>Patient Name</th>
                        <th>Contact</th>
                        <th>Dentist Name</th>
                        <th>Treatment Type</th>
                        <th>Date & Time</th>
                        <th>Treatment Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection conn = DatabaseManager.getInstance().getConnection();
                            String sql = "SELECT a.appointment_num, p.name, p.contact, a.dentist_name, a.treatment_type, a.appt_date_time, COALESCE(a.status, 'Pending') AS appt_status " +
                                         "FROM appointments a JOIN patients p ON a.patient_id = p.patient_id ORDER BY a.appt_date_time DESC";
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);
                            while (rs.next()) {
                                String st = rs.getString("appt_status");
                                String badgeClass = "badge-pending";
                                if ("Done".equalsIgnoreCase(st)) badgeClass = "badge-done";
                                else if ("Completed".equalsIgnoreCase(st)) badgeClass = "badge-completed";
                    %>
                    <tr>
                        <td><strong><%= rs.getString("appointment_num") %></strong></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("contact") %></td>
                        <td><%= rs.getString("dentist_name") %></td>
                        <td><%= rs.getString("treatment_type") %></td>
                        <td><i class="fa-regular fa-clock"></i> <%= rs.getString("appt_date_time") %></td>
                        <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                    </tr>
                    <%      }
                        } catch(Exception e) { out.println("<tr><td colspan='7'>No appointments found.</td></tr>"); }
                    %>
                </tbody>
            </table>
        </div>

        <!-- TAB 4: SAVED BILLS & PATIENT RECEIPTS -->
        <div id="billing-history" class="tab-content">
            <h3 style="margin-bottom: 20px; color: #0284c7;">
                <i class="fa-solid fa-file-invoice-dollar"></i> Saved Bills & Patient Receipts
            </h3>
            
            <table>
                <thead>
                    <tr>
                        <th>Bill ID</th>
                        <th>Appt No.</th>
                        <th>Patient Name</th>
                        <th>Treatment</th>
                        <th>Consultation Fee</th>
                        <th>Treatment Fee</th>
                        <th>Total Amount</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection conn = DatabaseManager.getInstance().getConnection();
                            Statement stmt = conn.createStatement();
                            ResultSet rsBill = stmt.executeQuery("SELECT * FROM bills ORDER BY bill_id DESC");
                            while (rsBill.next()) {
                    %>
                    <tr>
                        <td><strong>BIL-<%= rsBill.getInt("bill_id") %></strong></td>
                        <td><%= rsBill.getString("appointment_num") %></td>
                        <td><%= rsBill.getString("patient_name") %></td>
                        <td><%= rsBill.getString("treatment_type") %></td>
                        <td>LKR <%= rsBill.getDouble("consultation_fee") %></td>
                        <td>LKR <%= rsBill.getDouble("treatment_fee") %></td>
                        <td><strong style="color:#16a34a;">LKR <%= rsBill.getDouble("total_amount") %></strong></td>
                        <td>
                            <button onclick="window.print()" class="btn-submit" style="padding: 6px 12px; font-size:12px; background:#0284c7;">
                                <i class="fa-solid fa-print"></i> Print Receipt
                            </button>
                        </td>
                    </tr>
                    <%      }
                        } catch(Exception e) { out.println("<tr><td colspan='8'>No bills generated yet.</td></tr>"); }
                    %>
                </tbody>
            </table>
        </div>

        <!-- TAB 5: HELP SECTION -->
        <div id="help" class="tab-content">
            <h3 style="margin-bottom: 20px; color: #0284c7;"><i class="fa-solid fa-circle-info"></i> System Help & Guide for Staff</h3>
            
            <div class="help-box">
                <h4><i class="fa-solid fa-1"></i> How to Add a New Doctor</h4>
                <p>Go to the <strong>Add New Doctor</strong> tab, enter Doctor ID, Full Name, Operating Location, and 10-digit Tel No, then click 'Save Doctor'.</p>
            </div>

            <div class="help-box">
                <h4><i class="fa-solid fa-2"></i> Registering a New Appointment</h4>
                <p>Go to the <strong>Add Appointment</strong> tab, fill in patient details, choose dentist and treatment type, then click 'Save & Confirm Appointment'.</p>
            </div>

            <div class="help-box">
                <h4><i class="fa-solid fa-3"></i> Viewing Appointment Details & Schedule</h4>
                <p>Click on the <strong>Appointment Details</strong> tab to view real-time patient bookings, selected doctors, treatment types, assigned dates/times, and live treatment status (Pending/Done/Completed).</p>
            </div>

            <div class="help-box">
                <h4><i class="fa-solid fa-4"></i> Viewing & Printing Patient Bills</h4>
                <p>Click on the <strong>Saved Bills</strong> tab to view bills issued by doctors and print official payment receipts for patients.</p>
            </div>

            <div class="help-box">
                <h4><i class="fa-solid fa-5"></i> System Security & Logout</h4>
                <p>Always click the <strong>Logout</strong> button in the top right navbar when leaving your workstation to invalidate your user session securely.</p>
            </div>
        </div>

    </div>

    <!-- Tab Switching JavaScript -->
    <script>
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            
            document.getElementById(tabId).classList.add('active');
            event.currentTarget.classList.add('active');
        }
    </script>
    
</body>
</html>