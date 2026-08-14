<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, Libs.DBUtil, Libs.MySQLUtils"%>
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard - Sunrise Dental Clinic</title>
    <!-- Google Fonts & FontAwesome -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary: #0284c7;
            --primary-hover: #0369a1;
            --secondary: #0f172a;
            --accent: #38bdf8;
            --bg-body: #f1f5f9;
            --card-bg: #ffffff;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --success: #10b981;
            --danger: #ef4444;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background-color: var(--bg-body); color: var(--text-main); min-height: 100vh; }

        /* Exact Doctor Portal Match Navbar Theme */
        .navbar {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: white;
            padding: 16px 6%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: var(--shadow-md);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .navbar .brand {
            font-size: 22px;
            font-weight: 800;
            color: white;
            display: flex;
            align-items: center;
            gap: 12px;
            letter-spacing: -0.5px;
        }

        .navbar .brand i {
            color: var(--accent);
            font-size: 24px;
            background: rgba(56, 189, 248, 0.15);
            padding: 10px;
            border-radius: 12px;
        }

        .user-info { display: flex; align-items: center; gap: 20px; }
        .user-profile {
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(255, 255, 255, 0.08);
            padding: 8px 16px;
            border-radius: 30px;
            border: 1px solid rgba(255, 255, 255, 0.12);
            font-size: 14px;
            font-weight: 600;
        }

        .user-profile i { color: var(--accent); }

        .btn-logout {
            background: rgba(239, 68, 68, 0.2);
            color: #fca5a5;
            border: 1px solid rgba(239, 68, 68, 0.3);
            padding: 8px 18px;
            border-radius: 20px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-logout:hover {
            background: #ef4444;
            color: white;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }

        /* Container Layout */
        .container { padding: 35px 6%; max-width: 1350px; margin: auto; }

        /* Stats Cards Widgets */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--card-bg);
            padding: 20px;
            border-radius: 16px;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 18px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .stat-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); }

        .stat-icon {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
        }

        .stat-icon.blue { background: #e0f2fe; color: #0284c7; }
        .stat-icon.green { background: #dcfce7; color: #10b981; }
        .stat-icon.purple { background: #f3e8ff; color: #9333ea; }
        .stat-icon.orange { background: #ffedd5; color: #ea580c; }

        .stat-details h4 { font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-details p { font-size: 20px; font-weight: 800; color: var(--text-main); margin-top: 2px; }

        /* Modern Tabs */
        .nav-tabs {
            display: flex;
            gap: 12px;
            margin-bottom: 25px;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 4px;
            flex-wrap: wrap;
        }

        .tab-btn {
            padding: 12px 22px;
            background: none;
            border: none;
            font-size: 14px;
            font-weight: 700;
            color: var(--text-muted);
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            border-radius: 10px 10px 0 0;
            transition: all 0.2s ease;
            position: relative;
        }

        .tab-btn:hover { color: var(--primary); background: rgba(2, 132, 199, 0.05); }

        .tab-btn.active {
            color: var(--primary);
            background: white;
            border-bottom: 3px solid var(--primary);
        }

        .tab-content {
            display: none;
            background: var(--card-bg);
            padding: 30px;
            border-radius: 18px;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-color);
            animation: fadeIn 0.3s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .tab-content.active { display: block; }

        /* Forms UI */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }

        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 13px; font-weight: 700; color: #475569; margin-bottom: 8px; }
        .form-group input, .form-group select {
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            font-size: 14px;
            outline: none;
            background: #f8fafc;
            transition: all 0.2s ease;
        }

        .form-group input:focus, .form-group select:focus {
            border-color: var(--primary);
            background: white;
            box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
        }

        .btn-submit {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 13px 28px;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            font-size: 15px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);
            transition: all 0.2s ease;
        }

        .btn-submit:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(16, 185, 129, 0.35); }

        /* Tables & Search */
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .search-box { position: relative; min-width: 260px; }
        .search-box input {
            width: 100%;
            padding: 10px 16px 10px 38px;
            border: 1px solid var(--border-color);
            border-radius: 20px;
            font-size: 13px;
            outline: none;
            background: #f8fafc;
        }
        .search-box input:focus { border-color: var(--primary); background: white; }
        .search-box i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 13px; }

        .table-responsive { overflow-x: auto; border-radius: 12px; border: 1px solid var(--border-color); }
        table { width: 100%; border-collapse: collapse; text-align: left; background: white; }
        
        th {
            background: #f8fafc;
            color: #475569;
            padding: 14px 16px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--border-color);
        }

        td {
            padding: 16px;
            border-bottom: 1px solid var(--border-color);
            font-size: 14px;
            color: #334155;
            vertical-align: middle;
        }

        tr:last-child td { border-bottom: none; }
        tr:hover td { background-color: #f8fafc; }

        /* Badges */
        .badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .badge-pending { background: #fef3c7; color: #d97706; }
        .badge-done { background: #e0f2fe; color: #0284c7; }
        .badge-completed { background: #dcfce7; color: #15803d; }

        /* Help Box Cards */
        .help-box {
            background: #f0f9ff;
            border-left: 4px solid var(--primary);
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 16px;
            border-top: 1px solid #e0f2fe;
            border-right: 1px solid #e0f2fe;
            border-bottom: 1px solid #e0f2fe;
        }

        .help-box h4 { color: #0369a1; font-size: 15px; font-weight: 700; margin-bottom: 6px; display: flex; align-items: center; gap: 8px; }
        .help-box p { font-size: 13.5px; color: #334155; line-height: 1.6; }

        .alert {
            padding: 14px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            font-weight: 600;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .alert-error { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }
    </style>
</head>
<body>

    <!-- Header Navbar (Matching Doctor Portal Theme) -->
    <div class="navbar">
        <div class="brand">
            <i class="fa-solid fa-tooth"></i> Sunrise Dental Staff Portal
        </div>
        <div class="user-info">
            <div class="user-profile">
                <i class="fa-solid fa-user-gear"></i>
                <span><%= fullName %> (Staff)</span>
            </div>
            <a href="LogoutServlet" class="btn-logout">
                <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
            </a>
        </div>
    </div>

    <div class="container">

        <!-- Status Notification Messages -->
        <%
            String status = request.getParameter("status");
            if ("doc_success".equals(status)) {
        %>
            <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Doctor Registered Successfully!</div>
        <% } else if ("doc_error".equals(status)) { %>
            <div class="alert alert-error"><i class="fa-solid fa-circle-xmark"></i> Failed to Add Doctor!</div>
        <% } %>

        <!-- Dashboard Stat Widgets -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue">
                    <i class="fa-solid fa-user-doctor"></i>
                </div>
                <div class="stat-details">
                    <h4>Doctors List</h4>
                    <p>Active Staff</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">
                    <i class="fa-solid fa-calendar-plus"></i>
                </div>
                <div class="stat-details">
                    <h4>Booking Portal</h4>
                    <p>Appointments</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple">
                    <i class="fa-solid fa-hospital-user"></i>
                </div>
                <div class="stat-details">
                    <h4>Patient Queue</h4>
                    <p>Live Tracking</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange">
                    <i class="fa-solid fa-file-invoice"></i>
                </div>
                <div class="stat-details">
                    <h4>System Receipts</h4>
                    <p>Billing Logs</p>
                </div>
            </div>
        </div>

        <!-- Navigation Tabs -->
        <div class="nav-tabs">
            <button class="tab-btn active" onclick="switchTab('add-doctor')"><i class="fa-solid fa-user-plus"></i> Register Doctor</button>
            <button class="tab-btn" onclick="switchTab('add-appointment')"><i class="fa-solid fa-calendar-plus"></i> New Appointment</button>
            <button class="tab-btn" onclick="switchTab('appointments')"><i class="fa-solid fa-calendar-check"></i> Schedule & Details</button>
            <button class="tab-btn" onclick="switchTab('billing-history')"><i class="fa-solid fa-file-invoice-dollar"></i> Saved Receipts</button>
            <button class="tab-btn" onclick="switchTab('help')"><i class="fa-solid fa-circle-question"></i> Staff Guide</button>
        </div>

        <!-- TAB 1: ADD NEW DOCTOR -->
        <div id="add-doctor" class="tab-content active">
            <h3 style="margin-bottom: 22px; color: var(--secondary); font-size: 18px; font-weight: 800;">
                <i class="fa-solid fa-user-doctor" style="color:var(--primary); margin-right:6px;"></i> Register New Dental Specialist
            </h3>

            <form action="AddDoctorServlet" method="POST">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Doctor ID</label>
                        <input type="text" name="doctorId" placeholder="e.g. DOC-101" required>
                    </div>
                    <div class="form-group">
                        <label>Doctor Full Name</label>
                        <input type="text" name="doctorName" placeholder="Dr. Firstname Lastname" required>
                    </div>
                    <div class="form-group">
                        <label>Location / Operating Branch</label>
                        <input type="text" name="location" placeholder="e.g. Colombo 03 Branch" required>
                    </div>
                    <div class="form-group">
                        <label>Contact Telephone No.</label>
                        <input type="text" name="telNo" placeholder="10 Digits Contact" pattern="\d{10}" required>
                    </div>
                </div>
                <button type="submit" class="btn-submit"><i class="fa-solid fa-floppy-disk"></i> Save Doctor Record</button>
            </form>

            <div class="card-header" style="margin-top: 35px;">
                <h4 style="color: var(--secondary); font-size: 16px; font-weight: 700;">Registered Medical Specialists</h4>
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="docSearch" onkeyup="filterTable('docTable', 'docSearch')" placeholder="Search Doctors...">
                </div>
            </div>

            <div class="table-responsive">
                <table id="docTable">
                    <thead>
                        <tr>
                            <th>Doctor ID</th>
                            <th>Doctor Name</th>
                            <th>Location / Branch</th>
                            <th>Telephone No.</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn1 = null;
                            try {
                                conn1 = DBUtil.getConnection();
                                Statement stmt = conn1.createStatement();
                                ResultSet rs = stmt.executeQuery("SELECT * FROM doctors ORDER BY doctor_id DESC");
                                while (rs.next()) {
                        %>
                        <tr>
                            <td><strong><%= rs.getString("doctor_id") %></strong></td>
                            <td><strong><%= rs.getString("doctor_name") %></strong></td>
                            <td><i class="fa-solid fa-location-dot" style="color:var(--text-muted); margin-right:4px;"></i> <%= rs.getString("location") %></td>
                            <td><i class="fa-solid fa-phone" style="color:var(--text-muted); margin-right:4px;"></i> <%= rs.getString("tel_no") %></td>
                        </tr>
                        <%      }
                            } catch(Exception e) { 
                                out.println("<tr><td colspan='4'>No doctors found in database.</td></tr>"); 
                            } finally {
                                DBUtil.closeConnection(conn1);
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- TAB 2: ADD APPOINTMENT FORM -->
        <div id="add-appointment" class="tab-content">
            <h3 style="margin-bottom: 22px; color: var(--secondary); font-size: 18px; font-weight: 800;">
                <i class="fa-solid fa-calendar-plus" style="color:var(--primary); margin-right:6px;"></i> Register Patient Appointment
            </h3>

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
                        <input type="text" name="patientName" placeholder="Enter Full Name" required>
                    </div>

                    <div class="form-group">
                        <label>Address</label>
                        <input type="text" name="address" placeholder="Enter Resident Address" required>
                    </div>

                    <div class="form-group">
                        <label>Contact Phone Number (10 Digits)</label>
                        <input type="text" name="contact" placeholder="0771234567" pattern="\d{10}" required>
                    </div>

                    <div class="form-group">
                        <label>Assigned Dentist (REST API Loaded)</label>
                        <select name="dentistName" id="dentistDropdown" required>
                            <option value="">-- Fetching Doctors via REST Service... --</option>
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
                        <label>Appointment Schedule Date & Time</label>
                        <input type="datetime-local" name="apptDateTime" required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-calendar-check"></i> Save & Confirm Appointment
                </button>
            </form>
        </div>

        <!-- TAB 3: APPOINTMENT DETAILS -->
        <div id="appointments" class="tab-content">
            <div class="card-header">
                <h3 class="card-title"><i class="fa-solid fa-list-check"></i> Patient Appointment Schedule & Care Tracking</h3>
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="apptSearch" onkeyup="filterTable('apptTable', 'apptSearch')" placeholder="Search Bookings...">
                </div>
            </div>
            
            <div class="table-responsive">
                <table id="apptTable">
                    <thead>
                        <tr>
                            <th>Appt No.</th>
                            <th>Patient Name</th>
                            <th>Contact</th>
                            <th>Assigned Dentist</th>
                            <th>Treatment</th>
                            <th>Date & Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn2 = null;
                            try {
                                conn2 = DBUtil.getConnection();
                                String sql = "SELECT a.appointment_num, p.name, p.contact, a.dentist_name, a.treatment_type, a.appt_date_time, COALESCE(a.status, 'Pending') AS appt_status " +
                                             "FROM appointments a JOIN patients p ON a.patient_id = p.patient_id ORDER BY a.appt_date_time DESC";
                                Statement stmt = conn2.createStatement();
                                ResultSet rs = stmt.executeQuery(sql);
                                while (rs.next()) {
                                    String st = rs.getString("appt_status");
                                    String badgeClass = "badge-pending";
                                    String icon = "fa-regular fa-clock";
                                    if ("Done".equalsIgnoreCase(st)) { badgeClass = "badge-done"; icon = "fa-solid fa-spinner"; }
                                    else if ("Completed".equalsIgnoreCase(st)) { badgeClass = "badge-completed"; icon = "fa-solid fa-check-double"; }
                        %>
                        <tr>
                            <td><strong><%= rs.getString("appointment_num") %></strong></td>
                            <td><strong><%= rs.getString("name") %></strong></td>
                            <td><i class="fa-solid fa-phone" style="color:var(--text-muted); margin-right:4px;"></i> <%= rs.getString("contact") %></td>
                            <td><%= rs.getString("dentist_name") %></td>
                            <td><%= rs.getString("treatment_type") %></td>
                            <td><i class="fa-regular fa-calendar" style="color:var(--text-muted); margin-right:4px;"></i> <%= rs.getString("appt_date_time") %></td>
                            <td><span class="badge <%= badgeClass %>"><i class="<%= icon %>"></i> <%= st %></span></td>
                        </tr>
                        <%      }
                            } catch(Exception e) { 
                                out.println("<tr><td colspan='7'>No appointments found.</td></tr>"); 
                            } finally {
                                DBUtil.closeConnection(conn2);
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- TAB 4: SAVED BILLS -->
        <div id="billing-history" class="tab-content">
            <div class="card-header">
                <h3 class="card-title"><i class="fa-solid fa-file-invoice-dollar"></i> Issued System Bills & Official Receipts</h3>
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="billSearch" onkeyup="filterTable('billTable', 'billSearch')" placeholder="Search Bills...">
                </div>
            </div>
            
            <div class="table-responsive">
                <table id="billTable">
                    <thead>
                        <tr>
                            <th>Receipt ID</th>
                            <th>Appt No.</th>
                            <th>Patient Name</th>
                            <th>Treatment</th>
                            <th>Consultation</th>
                            <th>Treatment Fee</th>
                            <th>Total Amount</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn3 = null;
                            try {
                                conn3 = DBUtil.getConnection();
                                Statement stmt = conn3.createStatement();
                                ResultSet rsBill = stmt.executeQuery("SELECT * FROM bills ORDER BY bill_id DESC");
                                while (rsBill.next()) {
                        %>
                        <tr>
                            <td><strong>BIL-<%= rsBill.getInt("bill_id") %></strong></td>
                            <td><%= rsBill.getString("appointment_num") %></td>
                            <td><strong><%= rsBill.getString("patient_name") %></strong></td>
                            <td><%= rsBill.getString("treatment_type") %></td>
                            <td>LKR <%= String.format("%.2f", rsBill.getDouble("consultation_fee")) %></td>
                            <td>LKR <%= String.format("%.2f", rsBill.getDouble("treatment_fee")) %></td>
                            <td><strong style="color:#10b981;">LKR <%= String.format("%.2f", rsBill.getDouble("total_amount")) %></strong></td>
                            <td>
                                <button onclick="window.print()" class="btn-submit" style="padding: 7px 14px; font-size:12px; background:var(--primary);">
                                    <i class="fa-solid fa-print"></i> Print Receipt
                                </button>
                            </td>
                        </tr>
                        <%      }
                            } catch(Exception e) { 
                                out.println("<tr><td colspan='8'>No bills generated yet.</td></tr>"); 
                            } finally {
                                DBUtil.closeConnection(conn3);
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- TAB 5: HELP SECTION -->
        <div id="help" class="tab-content">
            <h3 style="margin-bottom: 22px; color: var(--secondary); font-size: 18px; font-weight: 800;">
                <i class="fa-solid fa-circle-info" style="color:var(--primary); margin-right:6px;"></i> System Help & Operations Guide
            </h3>
            
            <div class="help-box">
                <h4><i class="fa-solid fa-1"></i> How to Add a New Doctor</h4>
                <p>Go to the <strong>Register Doctor</strong> tab, enter Doctor ID, Full Name, Operating Branch Location, and 10-digit Tel No, then click 'Save Doctor Record'.</p>
            </div>
            <div class="help-box">
                <h4><i class="fa-solid fa-2"></i> Registering a Patient Appointment</h4>
                <p>Go to the <strong>New Appointment</strong> tab, fill in patient details, choose assigned dentist (loaded dynamically via REST API) and treatment type, then click 'Save & Confirm Appointment'.</p>
            </div>
            <div class="help-box">
                <h4><i class="fa-solid fa-3"></i> Viewing Appointment Schedule</h4>
                <p>Click on the <strong>Schedule & Details</strong> tab to view real-time patient bookings, selected doctors, treatment types, assigned dates/times, and live treatment status (Pending/Done/Completed).</p>
            </div>
            <div class="help-box">
                <h4><i class="fa-solid fa-4"></i> Viewing & Printing Receipts</h4>
                <p>Click on the <strong>Saved Receipts</strong> tab to view bills calculated by doctors and print official payment receipts for patients.</p>
            </div>
        </div>

    </div>

    <!-- JavaScript REST API Integration & Dynamic UI -->
    <script>
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            
            document.getElementById(tabId).classList.add('active');
            event.currentTarget.classList.add('active');
        }

        // Fetch Doctors strictly using Dynamic Context Path DoctorResource API
        window.addEventListener('DOMContentLoaded', loadDoctorsViaAPI);

        function loadDoctorsViaAPI() {
            const dropdown = document.getElementById('dentistDropdown');
            const apiUrl = '<%= request.getContextPath() %>/api/doctors';
            
            fetch(apiUrl)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('API server returned error: ' + response.status);
                    }
                    return response.json();
                })
                .then(doctors => {
                    dropdown.innerHTML = '<option value="">-- Select Dentist --</option>';
                    
                    if (!doctors || doctors.length === 0) {
                        dropdown.innerHTML = '<option value="">No Doctors Registered Yet</option>';
                        return;
                    }
                    
                    doctors.forEach(doc => {
                        let opt = document.createElement('option');
                        opt.value = doc.name;
                        opt.textContent = doc.name + " (" + doc.location + ")";
                        dropdown.appendChild(opt);
                    });
                })
                .catch(err => {
                    console.error('REST API Error:', err);
                    dropdown.innerHTML = '<option value="">Failed to load doctors via REST API</option>';
                });
        }

        // Search Filter for Tables
        function filterTable(tableId, inputId) {
            const input = document.getElementById(inputId);
            const filter = input.value.toUpperCase();
            const table = document.getElementById(tableId);
            const tr = table.getElementsByTagName("tr");

            for (let i = 1; i < tr.length; i++) {
                let showRow = false;
                const td = tr[i].getElementsByTagName("td");
                for (let j = 0; j < td.length; j++) {
                    if (td[j]) {
                        const txtValue = td[j].textContent || td[j].innerText;
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            showRow = true;
                            break;
                        }
                    }
                }
                tr[i].style.display = showRow ? "" : "none";
            }
        }
    </script>
    
</body>
</html>