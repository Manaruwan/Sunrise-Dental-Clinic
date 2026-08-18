<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, Libs.DBUtil, Libs.MySQLUtils"%>
<%
    // Session Verification - Only Allow Logged-in Doctors
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Portal - Sunrise Dental Clinic</title>
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
            --warning: #f59e0b;
            --info: #3b82f6;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background-color: var(--bg-body); color: var(--text-main); min-height: 100vh; }

        /* Navbar Theme */
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
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--card-bg);
            padding: 22px;
            border-radius: 16px;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 20px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .stat-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); }

        .stat-icon {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        .stat-icon.blue { background: #e0f2fe; color: #0284c7; }
        .stat-icon.green { background: #dcfce7; color: #10b981; }
        .stat-icon.purple { background: #f3e8ff; color: #9333ea; }

        .stat-details h4 { font-size: 13px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-details p { font-size: 24px; font-weight: 800; color: var(--text-main); margin-top: 4px; }

        /* Modern Navigation Tabs */
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

        /* Card Panels */
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .card-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--secondary);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-title i { color: var(--primary); }

        .search-box {
            position: relative;
            min-width: 260px;
        }

        .search-box input {
            width: 100%;
            padding: 10px 16px 10px 38px;
            border: 1px solid var(--border-color);
            border-radius: 20px;
            font-size: 13px;
            outline: none;
            background: #f8fafc;
            transition: all 0.3s ease;
        }

        .search-box input:focus { border-color: var(--primary); background: white; box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15); }
        .search-box i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 13px; }

        /* Tables */
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

        /* Controls & Buttons */
        .select-status {
            padding: 7px 12px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            font-size: 13px;
            font-weight: 500;
            outline: none;
            background: #f8fafc;
            cursor: pointer;
        }

        .btn-update {
            background: var(--primary);
            color: white;
            border: none;
            padding: 7px 14px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: background 0.2s ease;
        }

        .btn-update:hover { background: var(--primary-hover); }

        .btn-calc {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            box-shadow: 0 2px 4px rgba(16, 185, 129, 0.2);
            transition: all 0.2s ease;
        }

        .btn-calc:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(16, 185, 129, 0.3);
        }

        /* Invoice Modal Card */
        .invoice-box {
            display: none;
            background: linear-gradient(180deg, #ffffff 0%, #f0fdf4 100%);
            border: 2px dashed #10b981;
            padding: 30px;
            border-radius: 18px;
            margin-top: 25px;
            box-shadow: var(--shadow-lg);
            animation: fadeIn 0.4s ease-out;
        }

        .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #bbf7d0;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }

        .invoice-header h4 { color: #065f46; font-size: 20px; font-weight: 800; display: flex; align-items: center; gap: 10px; }

        .receipt-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
            background: white;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #dcfce7;
        }

        .receipt-details p { font-size: 13px; color: var(--text-muted); }
        .receipt-details span { display: block; font-size: 15px; font-weight: 700; color: var(--text-main); margin-top: 2px; }

        .amount-summary {
            background: white;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #dcfce7;
        }

        .amount-row { display: flex; justify-content: space-between; font-size: 14px; margin-bottom: 8px; color: #475569; }
        .amount-row.total { font-size: 18px; font-weight: 800; color: #047857; border-top: 2px solid #a7f3d0; padding-top: 10px; margin-top: 10px; }

        .btn-submit {
            background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
            color: white;
            padding: 12px 28px;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 20px;
            box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25);
            transition: all 0.2s ease;
        }

        .btn-submit:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(2, 132, 199, 0.35); }

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
    </style>
</head>
<body>

    <!-- Header Navbar -->
    <div class="navbar">
        <div class="brand">
            <i class="fa-solid fa-tooth"></i> Sunrise Dental Portal
        </div>
        <div class="user-info">
            <div class="user-profile">
                <i class="fa-solid fa-user-md"></i>
                <span>Dr. <%= fullName %></span>
            </div>
            <a href="LogoutServlet" class="btn-logout">
                <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
            </a>
        </div>
    </div>

    <div class="container">

        <!-- Alert Banner -->
        <%
            String msg = request.getParameter("msg");
            if ("bill_saved".equals(msg)) {
        %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i> Patient Invoice Generated & Saved to System Successfully!
            </div>
        <% } %>

        <!-- Dashboard Stat Widgets -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue">
                    <i class="fa-solid fa-calendar-day"></i>
                </div>
                <div class="stat-details">
                    <h4>Assigned Schedule</h4>
                    <p>My Patients</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">
                    <i class="fa-solid fa-user-check"></i>
                </div>
                <div class="stat-details">
                    <h4>Care Status</h4>
                    <p>Active Portal</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple">
                    <i class="fa-solid fa-file-invoice-dollar"></i>
                </div>
                <div class="stat-details">
                    <h4>Billing Engine</h4>
                    <p>REST Connected</p>
                </div>
            </div>
        </div>

        <!-- Navigation Tabs Bar -->
        <div class="nav-tabs">
            <button id="tab-btn-appointments-tab" class="tab-btn active" onclick="switchTab('appointments-tab')">
                <i class="fa-solid fa-list-check"></i> My Appointments
            </button>
            <button id="tab-btn-invoices-tab" class="tab-btn" onclick="switchTab('invoices-tab')">
                <i class="fa-solid fa-receipt"></i> My Issued Invoices
            </button>
            <button id="tab-btn-doc-guide-tab" class="tab-btn" onclick="switchTab('doc-guide-tab')">
                <i class="fa-solid fa-circle-question"></i> Doctor Guide
            </button>
        </div>

        <!-- TAB 1: APPOINTMENT WORKFLOW (FILTERED BY LOGGED IN DOCTOR) -->
        <div id="appointments-tab" class="tab-content active">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-solid fa-list-check"></i> Patient Appointments Assigned to Dr. <%= fullName %>
                </div>
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="appointmentSearch" onkeyup="filterTable('appointmentTable', 'appointmentSearch')" placeholder="Search Patients or Appt No...">
                </div>
            </div>

            <div class="table-responsive">
                <table id="appointmentTable">
                    <thead>
                        <tr>
                            <th>Appt No.</th>
                            <th>Patient ID</th>
                            <th>Patient Name</th>
                            <th>Treatment</th>
                            <th>Date & Time</th>
                            <th>Status</th>
                            <th>Update Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn1 = null;
                            PreparedStatement stmt1 = null;
                            try {
                                conn1 = DBUtil.getConnection();
                                String sql = "SELECT a.appointment_num, a.patient_id, p.name, a.treatment_type, a.appt_date_time, COALESCE(a.status, 'Pending') AS appt_status " +
                                             "FROM appointments a JOIN patients p ON a.patient_id = p.patient_id " +
                                             "WHERE a.dentist_name = ? ORDER BY a.appt_date_time DESC";
                                
                                stmt1 = conn1.prepareStatement(sql);
                                stmt1.setString(1, fullName);
                                ResultSet rs = stmt1.executeQuery();

                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    String apptNum = rs.getString("appointment_num");
                                    String patId = rs.getString("patient_id");
                                    String pName = rs.getString("name");
                                    String treatment = rs.getString("treatment_type");
                                    String dateTime = rs.getString("appt_date_time");
                                    String st = rs.getString("appt_status");

                                    String badgeClass = "badge-pending";
                                    String icon = "fa-regular fa-clock";
                                    if ("Done".equalsIgnoreCase(st)) { badgeClass = "badge-done"; icon = "fa-solid fa-spinner"; }
                                    else if ("Completed".equalsIgnoreCase(st)) { badgeClass = "badge-completed"; icon = "fa-solid fa-check-double"; }
                        %>
                        <tr>
                            <td><strong><%= apptNum %></strong></td>
                            <td><span style="color:#0284c7; font-weight:700;"><%= patId %></span></td>
                            <td><strong><%= pName %></strong></td>
                            <td><%= treatment %></td>
                            <td><i class="fa-regular fa-calendar" style="color:var(--text-muted); margin-right:4px;"></i> <%= dateTime %></td>
                            <td><span class="badge <%= badgeClass %>"><i class="<%= icon %>"></i> <%= st %></span></td>
                            
                            <td>
                                <form action="UpdateAppointmentServlet" method="POST" style="display:flex; gap:6px;">
                                    <input type="hidden" name="appointmentNum" value="<%= apptNum %>">
                                    <select name="status" class="select-status">
                                        <option value="Pending" <%= "Pending".equalsIgnoreCase(st)?"selected":"" %>>Pending</option>
                                        <option value="Done" <%= "Done".equalsIgnoreCase(st)?"selected":"" %>>Done</option>
                                        <option value="Completed" <%= "Completed".equalsIgnoreCase(st)?"selected":"" %>>Completed</option>
                                    </select>
                                    <button type="submit" class="btn-update">Save</button>
                                </form>
                            </td>

                            <td>
                                <button class="btn-calc" onclick="calculateBillViaAPI('<%= apptNum %>')">
                                    <i class="fa-solid fa-calculator"></i> Calculate
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                                if (!hasData) {
                                    out.println("<tr><td colspan='8' style='text-align:center; color:#64748b; padding:20px;'>No appointments assigned to you currently.</td></tr>");
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='8'>Error loading appointments.</td></tr>");
                            } finally {
                                if (stmt1 != null) stmt1.close();
                                DBUtil.closeConnection(conn1);
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- DOCTOR BILL CALCULATOR DISPLAY (FETCHED VIA REST API) -->
            <div id="invoiceSection" class="invoice-box">
                <div class="invoice-header">
                    <h4>
                        <i class="fa-solid fa-file-invoice-dollar"></i> Patient Billing Summary (via REST API)
                    </h4>
                    <span class="badge badge-completed"><i class="fa-solid fa-shield-halved"></i> Live Calculated</span>
                </div>

                <form action="SaveBillServlet" method="POST">
                    <input type="hidden" name="appointmentNum" id="formApptNum">
                    <input type="hidden" name="patientName" id="formPName">
                    <input type="hidden" name="treatmentType" id="formTreatment">
                    <input type="hidden" name="consultationFee" value="2000.00">
                    <input type="hidden" name="treatmentFee" id="formTreatmentFee">
                    <input type="hidden" name="totalAmount" id="formTotalAmount">

                    <div class="receipt-details">
                        <div>
                            <p>Appointment Number</p>
                            <span id="billAppt">-</span>
                        </div>
                        <div>
                            <p>Patient Full Name</p>
                            <span id="billName">-</span>
                        </div>
                        <div>
                            <p>Treatment Category</p>
                            <span id="billTreatment">-</span>
                        </div>
                    </div>

                    <div class="amount-summary">
                        <div class="amount-row">
                            <span>Consultation Base Fee</span>
                            <span>LKR 2,000.00</span>
                        </div>
                        <div class="amount-row">
                            <span>Specific Treatment Fee</span>
                            <span>LKR <span id="billTreatmentFee">0.00</span></span>
                        </div>
                        <div class="amount-row total">
                            <span>Net Payable Amount</span>
                            <span>LKR <span id="billTotal">0.00</span></span>
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fa-solid fa-floppy-disk"></i> Issue & Save Invoice Receipt
                    </button>
                </form>
            </div>
        </div>

        <!-- TAB 2: ISSUED INVOICES HISTORY (FILTERED FOR THIS DOCTOR ONLY) -->
        <div id="invoices-tab" class="tab-content">
            <div class="card-header">
                <div class="card-title">
                    <i class="fa-solid fa-receipt"></i> Invoices Issued by Dr. <%= fullName %>
                </div>
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="billSearch" onkeyup="filterTable('billsTable', 'billSearch')" placeholder="Search Invoices...">
                </div>
            </div>

            <div class="table-responsive">
                <table id="billsTable">
                    <thead>
                        <tr>
                            <th>Receipt ID</th>
                            <th>Appt No.</th>
                            <th>Patient Name</th>
                            <th>Treatment</th>
                            <th>Consultation Fee</th>
                            <th>Treatment Fee</th>
                            <th>Total Amount</th>
                            <th>Issued Date & Time</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn2 = null;
                            PreparedStatement stmt2 = null;
                            try {
                                conn2 = DBUtil.getConnection();
                                // Join appointments table to show only bills of appointments assigned to this doctor
                                String sqlBills = "SELECT b.* FROM bills b " +
                                                  "JOIN appointments a ON b.appointment_num = a.appointment_num " +
                                                  "WHERE a.dentist_name = ? ORDER BY b.bill_id DESC";
                                
                                stmt2 = conn2.prepareStatement(sqlBills);
                                stmt2.setString(1, fullName);
                                ResultSet rsBill = stmt2.executeQuery();

                                boolean hasBills = false;
                                while (rsBill.next()) {
                                    hasBills = true;
                        %>
                        <tr>
                            <td><strong>BIL-<%= rsBill.getInt("bill_id") %></strong></td>
                            <td><%= rsBill.getString("appointment_num") %></td>
                            <td><strong><%= rsBill.getString("patient_name") %></strong></td>
                            <td><%= rsBill.getString("treatment_type") %></td>
                            <td>LKR <%= String.format("%.2f", rsBill.getDouble("consultation_fee")) %></td>
                            <td>LKR <%= String.format("%.2f", rsBill.getDouble("treatment_fee")) %></td>
                            <td><strong style="color:#10b981;">LKR <%= String.format("%.2f", rsBill.getDouble("total_amount")) %></strong></td>
                            <td><i class="fa-regular fa-clock" style="color:var(--text-muted); margin-right:4px;"></i> <%= rsBill.getTimestamp("created_at") %></td>
                        </tr>
                        <%      }
                                if (!hasBills) {
                                    out.println("<tr><td colspan='8' style='text-align:center; color:#64748b; padding:20px;'>No bills issued by you yet.</td></tr>");
                                }
                            } catch(Exception e) { 
                                out.println("<tr><td colspan='8'>No bills generated yet.</td></tr>"); 
                            } finally {
                                if (stmt2 != null) stmt2.close();
                                DBUtil.closeConnection(conn2);
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- TAB 3: DOCTOR GUIDE -->
        <div id="doc-guide-tab" class="tab-content">
            <h3 style="margin-bottom: 22px; color: var(--secondary); font-size: 18px; font-weight: 800;">
                <i class="fa-solid fa-circle-info" style="color:var(--primary); margin-right:6px;"></i> Doctor Portal Operations Guide
            </h3>
            
            <div class="help-box">
                <h4><i class="fa-solid fa-1"></i> My Appointments View</h4>
                <p>This table strictly filters and displays only the patient appointments assigned to you (<strong>Dr. <%= fullName %></strong>).</p>
            </div>
            <div class="help-box">
                <h4><i class="fa-solid fa-2"></i> Calculating Patient Bill via REST API</h4>
                <p>Click 'Calculate' button on the appointment row. The REST Service fetches treatment pricing and calculates the total automatically.</p>
            </div>
            <div class="help-box">
                <h4><i class="fa-solid fa-3"></i> Isolated Billing History</h4>
                <p>Your issued invoices tab strictly shows only the bills issued for your own patients, maintaining complete doctor-patient privacy.</p>
            </div>
        </div>

    </div>

    <!-- JavaScript REST API Integration & Dynamic UI -->
    <script>
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            
            const targetContent = document.getElementById(tabId);
            const targetBtn = document.getElementById('tab-btn-' + tabId);

            if (targetContent) targetContent.classList.add('active');
            if (targetBtn) targetBtn.classList.add('active');
        }

        // Fetch Bill Details using Backend REST API Project Endpoint
        function calculateBillViaAPI(apptNum) {
            const primaryUrl = 'http://localhost:8080/Sunrise_Dental_Clinic-1.0-SNAPSHOT/api/billing/' + apptNum;
            const secondaryUrl = 'http://localhost:8080/Sunrise_Dental_Clinic/api/billing/' + apptNum;

            function renderBill(data) {
                if (data.error) {
                    alert("Error from REST API: " + data.error);
                    return;
                }
                
                document.getElementById('invoiceSection').style.display = 'block';
                document.getElementById('billAppt').innerText = data.appointmentNumber;
                document.getElementById('billName').innerText = data.patientName;
                document.getElementById('billTreatment').innerText = data.treatment;
                document.getElementById('billTreatmentFee').innerText = Number(data.treatmentFee).toLocaleString('en-US', {minimumFractionDigits: 2});
                document.getElementById('billTotal').innerText = Number(data.totalAmount).toLocaleString('en-US', {minimumFractionDigits: 2});

                document.getElementById('formApptNum').value = data.appointmentNumber;
                document.getElementById('formPName').value = data.patientName;
                document.getElementById('formTreatment').value = data.treatment;
                document.getElementById('formTreatmentFee').value = data.treatmentFee;
                document.getElementById('formTotalAmount').value = data.totalAmount;

                document.getElementById('invoiceSection').scrollIntoView({ behavior: 'smooth' });
            }

            fetch(primaryUrl)
                .then(response => {
                    if (!response.ok) throw new Error('Primary failed');
                    return response.json();
                })
                .then(renderBill)
                .catch(() => {
                    fetch(secondaryUrl)
                        .then(response => {
                            if (!response.ok) throw new Error('Secondary failed');
                            return response.json();
                        })
                        .then(renderBill)
                        .catch(err => {
                            console.error('REST API Error:', err);
                            alert("Failed to calculate bill via BillingResource REST API.");
                        });
                });
        }

        // Search Filter for Tables
        function filterTable(tableId, inputId) {
            const input = document.getElementById(inputId);
            const filter = input.value.toUpperCase();
            const table = document.getElementById(tableId);
            if (!table) return;
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