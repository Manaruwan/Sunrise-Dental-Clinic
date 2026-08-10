<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.mycompany.sunrise_dental_clinic.DatabaseManager"%>
<%
    // Session Verification - Only Allow Doctors
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
        
        /* Top Navigation Bar */
        .navbar { background: #0f172a; color: white; padding: 15px 5%; display: flex; justify-content: space-between; align-items: center; }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #38bdf8; display: flex; align-items: center; gap: 10px; }
        .user-info { display: flex; align-items: center; gap: 20px; }
        .btn-logout { background: #ef4444; color: white; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 500; }
        .btn-logout:hover { background: #dc2626; }

        .container { padding: 30px 5%; max-width: 1200px; margin: auto; }
        
        /* Cards */
        .card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 25px; }
        .card h3 { color: #0284c7; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }

        /* Table Styling */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; text-align: left; }
        th, td { padding: 12px; border-bottom: 1px solid #e2e8f0; font-size: 14px; vertical-align: middle; }
        th { background: #f1f5f9; color: #334155; }

        /* Status Badges */
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }
        .badge-pending { background: #fef3c7; color: #b45309; }
        .badge-done { background: #e0f2fe; color: #0369a1; }
        .badge-completed { background: #dcfce7; color: #15803d; }

        /* Buttons & Forms */
        .select-status { padding: 6px 10px; border-radius: 4px; border: 1px solid #cbd5e1; font-size: 13px; }
        .btn-update { background: #0284c7; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 13px; font-weight: 500; }
        .btn-calc { background: #16a34a; color: white; border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-size: 13px; font-weight: 600; }
        .btn-submit { background: #0284c7; color: white; padding: 10px 20px; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 14px; }
        .btn-submit:hover { background: #0369a1; }

        /* Modal / Invoice Box */
        .invoice-box { display: none; background: #f0fdf4; border: 2px dashed #16a34a; padding: 20px; border-radius: 8px; margin-top: 20px; }
        .alert { padding: 12px; border-radius: 6px; margin-bottom: 15px; font-weight: 500; }
        .alert-success { background: #dcfce7; color: #15803d; }
    </style>
</head>
<body>

    <!-- Header Navbar -->
    <div class="navbar">
        <div class="brand">
            <i class="fa-solid fa-user-doctor"></i> Sunrise Dental - Doctor Portal
        </div>
        <div class="user-info">
            <span><i class="fa-solid fa-circle-user"></i> <%= fullName %></span>
            <a href="LogoutServlet" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
        </div>
    </div>

    <div class="container">

        <!-- Status Notification Messages -->
        <%
            String msg = request.getParameter("msg");
            if ("bill_saved".equals(msg)) {
        %>
            <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Bill Saved and Issued Successfully!</div>
        <% } %>

        <!-- APPOINTMENTS & TREATMENT STATUS SECTION -->
        <div class="card">
            <h3><i class="fa-solid fa-calendar-check"></i> Patient Appointments & Treatment Status</h3>
            
            <table>
                <thead>
                    <tr>
                        <th>Appt No.</th>
                        <th>Unique Patient ID</th>
                        <th>Patient Name</th>
                        <th>Treatment</th>
                        <th>Date & Time</th>
                        <th>Current Status</th>
                        <th>Update Status</th>
                        <th>Calculate Bill</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection conn = DatabaseManager.getInstance().getConnection();
                            String sql = "SELECT a.appointment_num, a.patient_id, p.name, a.treatment_type, a.appt_date_time, COALESCE(a.status, 'Pending') AS appt_status " +
                                         "FROM appointments a JOIN patients p ON a.patient_id = p.patient_id ORDER BY a.appt_date_time DESC";
                            
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);

                            while (rs.next()) {
                                String apptNum = rs.getString("appointment_num");
                                String patId = rs.getString("patient_id");
                                String pName = rs.getString("name");
                                String treatment = rs.getString("treatment_type");
                                String dateTime = rs.getString("appt_date_time");
                                String st = rs.getString("appt_status");

                                String badgeClass = "badge-pending";
                                if ("Done".equalsIgnoreCase(st)) badgeClass = "badge-done";
                                else if ("Completed".equalsIgnoreCase(st)) badgeClass = "badge-completed";
                    %>
                    <tr>
                        <td><strong><%= apptNum %></strong></td>
                        <td><span style="color:#64748b; font-weight:600;"><%= patId %></span></td>
                        <td><%= pName %></td>
                        <td><%= treatment %></td>
                        <td><%= dateTime %></td>
                        <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                        
                        <!-- Form to Change Status (Pending / Done / Completed) -->
                        <td>
                            <form action="UpdateAppointmentServlet" method="POST" style="display:flex; gap:5px;">
                                <input type="hidden" name="appointmentNum" value="<%= apptNum %>">
                                <select name="status" class="select-status">
                                    <option value="Pending" <%= "Pending".equalsIgnoreCase(st)?"selected":"" %>>Pending</option>
                                    <option value="Done" <%= "Done".equalsIgnoreCase(st)?"selected":"" %>>Done</option>
                                    <option value="Completed" <%= "Completed".equalsIgnoreCase(st)?"selected":"" %>>Completed</option>
                                </select>
                                <button type="submit" class="btn-update">Save</button>
                            </form>
                        </td>

                        <!-- Calculate Bill Button -->
                        <td>
                            <button class="btn-calc" onclick="calculateBill('<%= apptNum %>', '<%= pName %>', '<%= treatment %>')">
                                <i class="fa-solid fa-calculator"></i> Calculate
                            </button>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='8'>Error loading appointments.</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>

        <!-- DOCTOR BILL CALCULATOR & SAVE FORM AREA -->
        <div id="invoiceSection" class="invoice-box">
            <h4 style="color:#15803d; font-size:18px; margin-bottom:10px;">
                <i class="fa-solid fa-file-invoice-dollar"></i> Patient Final Bill Summary
            </h4>

            <form action="SaveBillServlet" method="POST">
                <input type="hidden" name="appointmentNum" id="formApptNum">
                <input type="hidden" name="patientName" id="formPName">
                <input type="hidden" name="treatmentType" id="formTreatment">
                <input type="hidden" name="consultationFee" value="2000.00">
                <input type="hidden" name="treatmentFee" id="formTreatmentFee">
                <input type="hidden" name="totalAmount" id="formTotalAmount">

                <p><strong>Appointment No:</strong> <span id="billAppt"></span></p>
                <p><strong>Patient Name:</strong> <span id="billName"></span></p>
                <p><strong>Treatment Conducted:</strong> <span id="billTreatment"></span></p>
                <hr style="margin: 10px 0; border: 0; border-top: 1px solid #cbd5e1;">
                <p>Consultation Fee: <strong>LKR 2,000.00</strong></p>
                <p>Treatment Fee: <strong>LKR <span id="billTreatmentFee"></span>.00</strong></p>
                <h3 style="color:#16a34a; margin-top:10px;">Total Bill Amount: LKR <span id="billTotal"></span>.00</h3>

                <button type="submit" class="btn-submit" style="margin-top:15px;">
                    <i class="fa-solid fa-floppy-disk"></i> Save & Send Bill to System
                </button>
            </form>
        </div>

        <!-- ISSUED BILLS HISTORY SECTION -->
        <div class="card" style="margin-top: 30px;">
            <h3><i class="fa-solid fa-receipt"></i> Issued Patient Bills History</h3>
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
                        <th>Date & Time</th>
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
                        <td><%= rsBill.getTimestamp("created_at") %></td>
                    </tr>
                    <%      }
                        } catch(Exception e) { out.println("<tr><td colspan='8'>No bills generated yet.</td></tr>"); }
                    %>
                </tbody>
            </table>
        </div>

    </div>

    <!-- JavaScript for Dynamic Bill Calculation -->
    <script>
        function calculateBill(apptNum, name, treatment) {
            document.getElementById('invoiceSection').style.display = 'block';
            
            document.getElementById('billAppt').innerText = apptNum;
            document.getElementById('billName').innerText = name;
            document.getElementById('billTreatment').innerText = treatment;

            var consultation = 2000;
            var treatmentFee = 3000; // Default

            if (treatment.toLowerCase().includes("cleaning")) treatmentFee = 5000;
            else if (treatment.toLowerCase().includes("filling")) treatmentFee = 4000;
            else if (treatment.toLowerCase().includes("root")) treatmentFee = 25000;
            else if (treatment.toLowerCase().includes("extraction")) treatmentFee = 6000;

            var total = consultation + treatmentFee;

            document.getElementById('billTreatmentFee').innerText = treatmentFee.toLocaleString();
            document.getElementById('billTotal').innerText = total.toLocaleString();

            // Set values to Hidden Form Inputs for Saving to Database
            document.getElementById('formApptNum').value = apptNum;
            document.getElementById('formPName').value = name;
            document.getElementById('formTreatment').value = treatment;
            document.getElementById('formTreatmentFee').value = treatmentFee;
            document.getElementById('formTotalAmount').value = total;

            window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
        }
    </script>

</body>
</html>