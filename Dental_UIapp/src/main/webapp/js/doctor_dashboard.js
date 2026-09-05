// Dynamic Base URL Configuration
const API_ENDPOINTS = [
    'http://localhost:8080/Sunrise_Dental_Clinic/api',
    'http://localhost:8080/Sunrise_Dental_Clinic-1.0-SNAPSHOT/api',
    'http://localhost:8080/Sunrise%20Dental%20Clinic/api'
];

// Strict Token Auth Guard
(function checkDoctorAuth() {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    const doctor = localStorage.getItem('doctorName') || localStorage.getItem('loggedUser');

    if (!token || !doctor) {
        localStorage.clear();
        sessionStorage.clear();
        window.location.replace('login.html');
    }
})();

// Browser Back Button Cache Guard
window.addEventListener('pageshow', function(event) {
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    if (event.persisted || !token || !localStorage.getItem('loggedUser')) {
        localStorage.clear();
        sessionStorage.clear();
        window.location.replace('login.html');
    }
});

// Modern Logout Modal Handlers (Yes / No)
function logoutDoctor() {
    const modal = document.getElementById('logoutModal');
    if (modal) {
        modal.style.display = 'flex';
    } else {
        if (confirm("Are you sure you want to log out?")) {
            confirmDoctorLogout();
        }
    }
}

function closeLogoutModal() {
    const modal = document.getElementById('logoutModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

function confirmDoctorLogout() {
    localStorage.removeItem('authToken');
    sessionStorage.removeItem('authToken');
    localStorage.clear();
    sessionStorage.clear();
    window.location.replace('login.html');
}

let loggedDoctorName = localStorage.getItem('doctorName') || localStorage.getItem('fullName') || localStorage.getItem('loggedUser') || 'Doctor';

function isMatchingDoctor(recordDocName, currentDoc) {
    if (!recordDocName || !currentDoc) return false;
    const clean = (str) => str.toString().toLowerCase().replace(/^dr\.?\s*/i, '').replace(/[^a-z0-9]/g, '').trim();
    const target = clean(currentDoc);
    const incoming = clean(recordDocName);
    return incoming.includes(target) || target.includes(incoming);
}

async function apiFetch(endpoint, options = {}) {
    let opts = { ...options };
    if (!opts.headers) opts.headers = {};
    
    const token = sessionStorage.getItem('authToken') || localStorage.getItem('authToken');
    if (token) opts.headers['Authorization'] = 'Bearer ' + token;

    if (opts.body && typeof opts.body === 'object') {
        opts.body = JSON.stringify(opts.body);
        opts.headers['Content-Type'] = 'application/json';
    }

    let lastError = null;
    for (const baseUrl of API_ENDPOINTS) {
        try {
            const res = await fetch(`${baseUrl}${endpoint}`, opts);
            if (res.ok) return await res.json();
            const errText = await res.text();
            lastError = new Error(`HTTP ${res.status}: ${errText}`);
        } catch (e) {
            lastError = e;
        }
    }
    throw lastError || new Error('API connection failed');
}

async function loadDoctorAvailability() {
    const daysEl = document.getElementById('docAvailableDays');
    const timeEl = document.getElementById('docAvailableTime');

    try {
        const doctors = await apiFetch('/doctors');
        const doctor = (Array.isArray(doctors) ? doctors : []).find(item => {
            const name = item.doctor_name || item.doctorName || item.name || '';
            return isMatchingDoctor(name, loggedDoctorName);
        });

        if (daysEl) daysEl.textContent = doctor?.available_days || doctor?.availableDays || 'Not assigned';
        if (timeEl) timeEl.textContent = doctor?.available_time || doctor?.availableTime || 'Not assigned';
    } catch (error) {
        console.error('Load Doctor Availability Error:', error);
        if (daysEl) daysEl.textContent = 'Unavailable';
        if (timeEl) timeEl.textContent = 'Unavailable';
    }
}

// 1. Dynamic Component Loader
async function loadDoctorComponents() {
    const navNameEl = document.getElementById('docNavName');
    if (navNameEl) navNameEl.innerText = loggedDoctorName.startsWith('Dr.') ? loggedDoctorName : 'Dr. ' + loggedDoctorName.replace(/^dr\.?\s*/i, '');

    const files = [
        'doctor_dashboard/appointments.html',
        'doctor_dashboard/patient_history.html',
        'doctor_dashboard/invoices.html',
        'doctor_dashboard/guide.html',
        'doctor_dashboard/profile.html'
    ];

    const contentArea = document.getElementById('doctor-dynamic-content');
    if (contentArea) {
        contentArea.innerHTML = '';
        for (const file of files) {
            try {
                const res = await fetch(file);
                if (res.ok) {
                    contentArea.innerHTML += await res.text();
                }
            } catch (e) {
                console.error('Failed to load component:', file);
            }
        }
    }

    fetchDoctorAppointments();
    fetchDoctorBills();
    fetchDoctorPatientHistory();
    loadDoctorAvailability();

    setTimeout(() => {
        switchTab('appointments-tab');
    }, 50);
}

// 2. Tab Switcher with Sidebar Support
function switchTab(tabId) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.sidebar-btn, .tab-btn').forEach(el => el.classList.remove('active'));

    let target = document.getElementById(tabId);
    let btn = document.getElementById('tab-btn-' + tabId);

    const titleEl = document.getElementById('currentDocSectionTitle');
    const subTitleEl = document.getElementById('currentDocSectionSubtitle');

    // Fallback IDs normalization
    if (!target && tabId === 'appointments-tab') target = document.getElementById('my-appointments');
    if (!target && tabId === 'my-appointments') target = document.getElementById('appointments-tab');
    if (!target && tabId === 'invoices-tab') target = document.getElementById('my-invoices');
    if (!target && tabId === 'my-invoices') target = document.getElementById('invoices-tab');
    if (!target && (tabId === 'guide-tab' || tabId === 'doc-guide-tab')) target = document.getElementById('doctor-guide');
    if (!target && tabId === 'doctor-guide') target = document.getElementById('guide-tab') || document.getElementById('doc-guide-tab');

    if (!btn && tabId === 'appointments-tab') btn = document.getElementById('tab-btn-my-appointments');
    if (!btn && tabId === 'my-appointments') btn = document.getElementById('tab-btn-appointments-tab');
    if (!btn && tabId === 'invoices-tab') btn = document.getElementById('tab-btn-my-invoices');
    if (!btn && tabId === 'my-invoices') btn = document.getElementById('tab-btn-invoices-tab');
    if (!btn && (tabId === 'guide-tab' || tabId === 'doc-guide-tab')) btn = document.getElementById('tab-btn-doctor-guide') || document.getElementById('tab-btn-guide-tab') || document.getElementById('tab-btn-doc-guide-tab');
    if (!btn && tabId === 'doctor-guide') btn = document.getElementById('tab-btn-guide-tab');

    if (target) target.classList.add('active');
    if (btn) btn.classList.add('active');

    if (tabId === 'appointments-tab' || tabId === 'my-appointments') {
        if (titleEl) titleEl.innerText = 'Patient Appointments';
        if (subTitleEl) subTitleEl.innerText = 'Review assigned patients, update consultation status, and calculate billing.';
        fetchDoctorAppointments();
    } else if (tabId === 'invoices-tab' || tabId === 'my-invoices') {
        if (titleEl) titleEl.innerText = 'Issued Receipts & Invoices';
        if (subTitleEl) subTitleEl.innerText = 'Track all finalized clinical receipts and revenue generated by your consultations.';
        fetchDoctorBills();
    } else if (tabId === 'patient-history-tab' || tabId === 'patient-history') {
        if (titleEl) titleEl.innerText = 'Patient Clinical History';
        if (subTitleEl) subTitleEl.innerText = 'Access previous dental treatment records and past consultation details.';
        fetchDoctorPatientHistory();
    } else if (tabId === 'guide-tab' || tabId === 'doc-guide-tab' || tabId === 'doctor-guide') {
        if (titleEl) titleEl.innerText = 'Clinical User Guide';
        if (subTitleEl) subTitleEl.innerText = 'Step-by-step workflow guide and operational instructions for medical specialists.';
    } else if (tabId === 'doctor-profile') {
        if (titleEl) titleEl.innerText = 'Doctor Profile & Security';
        if (subTitleEl) subTitleEl.innerText = 'Manage your doctor credentials, display title, and account password.';
        loadDoctorProfileData();
    }
}

window.openDoctorScheduleEditor = function() {
    switchTab('doctor-profile');

    setTimeout(() => {
        const scheduleField = document.getElementById('docProfAvailableDays');
        if (scheduleField) {
            scheduleField.scrollIntoView({ behavior: 'smooth', block: 'center' });
            scheduleField.focus();
        }
    }, 100);
};

// 3. Populate Profile Data (Fixed Username Detection)
function loadDoctorProfileData() {
    const rawUsername = localStorage.getItem('username') || 
                        localStorage.getItem('user') || 
                        sessionStorage.getItem('username') || 
                        localStorage.getItem('loggedUser') || 'doctor';

    const fullName = localStorage.getItem('fullName') || 
                     localStorage.getItem('doctorName') || 
                     localStorage.getItem('loggedUser') || 'Dr. Specialist';

    let cleanUsername = rawUsername;
    if (cleanUsername.includes('(')) {
        cleanUsername = cleanUsername.split('(')[0].trim();
    }

    const uInput = document.getElementById('docProfUsername');
    const nInput = document.getElementById('docProfFullName');
    const titleText = document.getElementById('docProfDisplayTitle');
    const badge = document.getElementById('docProfRoleBadge');

    if (uInput) uInput.value = cleanUsername;
    if (nInput) nInput.value = fullName.replace(/^dr\.?\s*/i, '').trim();
    if (titleText) titleText.innerText = fullName.startsWith('Dr.') ? fullName : 'Dr. ' + fullName;
    if (badge) badge.innerHTML = `<i class="fa-solid fa-shield-halved"></i> Verified Specialist`;

    loadDoctorProfileSchedule(fullName);
}

async function loadDoctorProfileSchedule(fullName) {
    try {
        const doctors = await apiFetch('/doctors');
        const doctor = (Array.isArray(doctors) ? doctors : []).find(item => {
            const name = item.doctor_name || item.doctorName || item.name || '';
            return isMatchingDoctor(name, fullName);
        });

        const daysInput = document.getElementById('docProfAvailableDays');
        const timeInput = document.getElementById('docProfAvailableTime');
        if (daysInput) daysInput.value = doctor?.available_days || doctor?.availableDays || 'Mon - Sat';
        if (timeInput) timeInput.value = doctor?.available_time || doctor?.availableTime || '09:00 AM - 05:00 PM';
    } catch (error) {
        console.error('Load Doctor Profile Schedule Error:', error);
    }
}

// 4. Update Profile Handler (Direct /auth/update_profile API Call)
window.handleUpdateDoctorProfile = async function(e) {
    if (e) e.preventDefault();

    const username = (document.getElementById('docProfUsername')?.value || localStorage.getItem('username') || localStorage.getItem('loggedUser') || '').trim();
    const fullName = document.getElementById('docProfFullName')?.value.trim();
    const currentPass = document.getElementById('docProfCurrentPass')?.value.trim();
    const newPass = document.getElementById('docProfNewPass')?.value.trim();
    const availableDays = document.getElementById('docProfAvailableDays')?.value.trim();
    const availableTime = document.getElementById('docProfAvailableTime')?.value.trim();

    if (!fullName) {
        alert('Doctor Full Name cannot be empty.');
        return;
    }

    if (newPass && !currentPass) {
        alert('Please enter your current password to set a new password.');
        return;
    }

    const formattedFullName = fullName.startsWith('Dr.') ? fullName : 'Dr. ' + fullName;

    const payload = {
        username: username,
        fullName: formattedFullName,
        currentPassword: currentPass || '',
        newPassword: newPass || '',
        availableDays: availableDays || 'Mon - Sat',
        availableTime: availableTime || '09:00 AM - 05:00 PM'
    };

    try {
        const doctors = await apiFetch('/doctors');
        const currentDoctor = (Array.isArray(doctors) ? doctors : []).find(item => {
            const name = item.doctor_name || item.doctorName || item.name || '';
            return isMatchingDoctor(name, loggedDoctorName) || isMatchingDoctor(name, fullName);
        });

        if (!currentDoctor) {
            throw new Error('Your doctor profile could not be found. Please log in again.');
        }

        const doctorId = currentDoctor.doctor_id || currentDoctor.doctorId || currentDoctor.id;
        if (!doctorId) {
            throw new Error('Doctor ID is missing from your profile.');
        }

        const doctorUpdate = await apiFetch(`/doctors/${encodeURIComponent(doctorId)}`, {
            method: 'PUT',
            body: {
                doctorName: formattedFullName,
                location: currentDoctor.location || currentDoctor.branch || '',
                telNo: currentDoctor.tel_no || currentDoctor.telNo || currentDoctor.telephone || '',
                availableDays: availableDays || 'Mon - Sat',
                availableTime: availableTime || '09:00 AM - 05:00 PM'
            }
        });

        if (doctorUpdate?.status && doctorUpdate.status !== 'success') {
            throw new Error(doctorUpdate.message || 'Doctor schedule update failed.');
        }

        let res;
        try {
            res = await apiFetch('/auth/update_profile', { method: 'POST', body: payload });
        } catch (e1) {
            try {
                res = await apiFetch('/update_profile', { method: 'POST', body: payload });
            } catch (e2) {
                res = await apiFetch('/users/update_profile', { method: 'POST', body: payload });
            }
        }

        if (res?.status && res.status !== 'success') {
            throw new Error(res.message || 'Profile update failed.');
        }

        alert('Profile and availability updated successfully!');
        
        localStorage.setItem('fullName', formattedFullName);
        localStorage.setItem('doctorName', formattedFullName);
        localStorage.setItem('loggedUser', formattedFullName);
        loggedDoctorName = formattedFullName;
        
        const navNameEl = document.getElementById('docNavName');
        if (navNameEl) navNameEl.innerText = formattedFullName;

        if (document.getElementById('docProfCurrentPass')) document.getElementById('docProfCurrentPass').value = '';
        if (document.getElementById('docProfNewPass')) document.getElementById('docProfNewPass').value = '';
        
        loadDoctorProfileData();
        loadDoctorAvailability();
    } catch (err) {
        console.error('Update profile error:', err);
        alert('Failed to update profile: ' + (err.message || 'Invalid credentials or server connection error.'));
    }
};

// 5. Fetch Doctor Appointments (Done-only calculate button)
async function fetchDoctorAppointments() {
    try {
        const list = await apiFetch('/all_appointments');
        const tbody = document.getElementById('docApptBody');
        if (!tbody) return;

        tbody.innerHTML = '';

        const myAppts = (Array.isArray(list) ? list : []).filter(a => {
            const doc = a.dentist_name || a.dentistName || '';
            return isMatchingDoctor(doc, loggedDoctorName);
        });

        const statAppt = document.getElementById('statApptCount');
        if (statAppt) statAppt.innerText = myAppts.length;

        let pendingCount = 0;
        let completedCount = 0;

        if (myAppts.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; color:#64748b; padding:20px;">No appointments assigned to you.</td></tr>';
            if (document.getElementById('statPendingCount')) document.getElementById('statPendingCount').innerText = '0';
            if (document.getElementById('statCompletedCount')) document.getElementById('statCompletedCount').innerText = '0';
            return;
        }

        myAppts.forEach(a => {
            const apptNo = a.appointment_num || a.appointment_no || a.id || '-';
            const patId = a.patient_id || 'PAT-001';
            const pName = a.patient_name || a.name || 'Patient';
            const treatment = a.treatment_type || '-';
            const dateTime = a.appt_date_time || '-';
            const st = (a.status || 'Pending').trim();

            if (st.toLowerCase() === 'pending') pendingCount++;
            if (st.toLowerCase() === 'completed' || st.toLowerCase() === 'done') completedCount++;

            let badgeClass = 'badge-pending';
            let icon = 'fa-regular fa-clock';
            if (st.toLowerCase() === 'done') { 
                badgeClass = 'badge-done'; 
                icon = 'fa-solid fa-spinner'; 
            } else if (st.toLowerCase() === 'completed') { 
                badgeClass = 'badge-completed'; 
                icon = 'fa-solid fa-check-double'; 
            }

            const safePName = pName.replace(/'/g, "\\'");
            const safeTreat = treatment.replace(/'/g, "\\'");

            let actionHtml = '';
            if (st.toLowerCase() === 'done') {
                actionHtml = `
                    <button class="btn-calc" onclick="calculateBillViaAPI('${apptNo}', '${safePName}', '${safeTreat}')">
                        <i class="fa-solid fa-calculator"></i> Calculate
                    </button>
                `;
            } else if (st.toLowerCase() === 'completed') {
                actionHtml = `
                    <span style="font-size: 12px; color: #16a34a; font-weight: 700; display: inline-flex; align-items: center; gap: 4px;">
                        <i class="fa-solid fa-circle-check"></i> Invoiced
                    </span>
                `;
            } else {
                actionHtml = `
                    <span style="font-size: 12px; color: #94a3b8; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
                        <i class="fa-solid fa-lock" style="font-size: 11px;"></i> Mark Done First
                    </span>
                `;
            }

            tbody.innerHTML += `
                <tr>
                    <td><strong>${apptNo}</strong></td>
                    <td><span style="color:#0284c7; font-weight:700;">${patId}</span></td>
                    <td><strong>${pName}</strong></td>
                    <td>${treatment}</td>
                    <td><i class="fa-regular fa-calendar" style="color:var(--text-muted); margin-right:4px;"></i> ${dateTime}</td>
                    <td><span class="badge ${badgeClass}"><i class="${icon}"></i> ${st}</span></td>
                    <td>
                        <div style="display:flex; gap:6px;">
                            <select id="statusSelect_${apptNo}" class="select-status">
                                <option value="Pending" ${st.toLowerCase() === 'pending' ? 'selected' : ''}>Pending</option>
                                <option value="Done" ${st.toLowerCase() === 'done' ? 'selected' : ''}>Done</option>
                                <option value="Completed" ${st.toLowerCase() === 'completed' ? 'selected' : ''}>Completed</option>
                            </select>
                            <button class="btn-update" onclick="updateAppointmentStatus('${apptNo}')">Save</button>
                        </div>
                    </td>
                    <td style="text-align:center;">
                        ${actionHtml}
                    </td>
                </tr>`;
        });

        const statPending = document.getElementById('statPendingCount');
        if (statPending) statPending.innerText = pendingCount;

        const statCompleted = document.getElementById('statCompletedCount');
        if (statCompleted) statCompleted.innerText = completedCount;

    } catch (e) {
        console.error('Fetch appointments error:', e);
        const tbody = document.getElementById('docApptBody');
        if (tbody) tbody.innerHTML = '<tr><td colspan="8" style="color:red; text-align:center;">Failed to load appointments.</td></tr>';
    }
}

// 6. Update Status
window.updateAppointmentStatus = async function(apptNo) {
    const selectEl = document.getElementById('statusSelect_' + apptNo);
    if (!selectEl) return;
    const newStatus = selectEl.value;

    try {
        await apiFetch('/update_appointment_status', {
            method: 'POST',
            body: { appointmentNumber: apptNo, status: newStatus }
        });
        alert(`Appointment ${apptNo} status updated to "${newStatus}"!`);
        fetchDoctorAppointments();
    } catch (err) {
        alert('Failed to update status: ' + err.message);
    }
};

// 7. Fetch Issued Bills
async function fetchDoctorBills() {
    try {
        const [billsList, apptsList] = await Promise.all([
            apiFetch('/bills'),
            apiFetch('/all_appointments')
        ]);

        const tbody = document.getElementById('docBillBody');
        const statBill = document.getElementById('statBillCount');
        const statRev = document.getElementById('statRevenueCount');

        const myApptNumbers = new Set(
            (Array.isArray(apptsList) ? apptsList : [])
                .filter(a => isMatchingDoctor(a.dentist_name || a.dentistName, loggedDoctorName))
                .map(a => a.appointment_num || a.appointment_no)
        );

        let billsArray = (Array.isArray(billsList) ? billsList : []).filter(b => {
            const apptNo = b.appointment_num || b.appointmentNum;
            return myApptNumbers.has(apptNo);
        });

        if (statBill) statBill.innerText = billsArray.length;
        if (tbody) tbody.innerHTML = '';

        let totalRevenue = 0;

        if (billsArray.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; color:#64748b; padding:20px;">No invoices issued for your appointments yet.</td></tr>';
            if (statRev) statRev.innerText = '0.00';
            return;
        }

        billsArray.forEach(b => {
            const bId = 'BIL-' + (b.bill_id || b.billId || b.id || '0');
            const apptNo = b.appointment_num || b.appointmentNum || '-';
            const patName = b.patient_name || b.patientName || '-';
            const treat = b.treatment_type || b.treatmentType || '-';
            
            const consult = parseFloat(b.consultation_fee || b.consultationFee || 2000) || 0;
            const treatFee = parseFloat(b.treatment_fee || b.treatmentFee || 0) || 0;
            let total = parseFloat(b.total_amount || b.totalAmount || (consult + treatFee)) || 0;

            totalRevenue += total;

            if (tbody) {
                tbody.innerHTML += `
                    <tr>
                        <td><strong>${bId}</strong></td>
                        <td>${apptNo}</td>
                        <td><strong>${patName}</strong></td>
                        <td>${treat}</td>
                        <td>LKR ${consult.toFixed(2)}</td>
                        <td>LKR ${treatFee.toFixed(2)}</td>
                        <td><strong style="color:#10b981;">LKR ${total.toFixed(2)}</strong></td>
                    </tr>`;
            }
        });

        if (statRev) {
            statRev.innerText = totalRevenue.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }
    } catch (e) {
        console.error('Failed to load bills:', e);
    }
}

// 8. Live Calculation
window.calculateBillViaAPI = async function(apptNum, pName, treatment) {
    try {
        let fee = 3000.00;
        const tLower = (treatment || '').toLowerCase();
        if (tLower.includes('clean')) fee = 5000.00;
        else if (tLower.includes('fill')) fee = 4000.00;
        else if (tLower.includes('root')) fee = 25000.00;
        else if (tLower.includes('extract')) fee = 6000.00;

        const total = 2000.00 + fee;

        const section = document.getElementById('invoiceSection');
        if (section) section.style.display = 'block';

        const billAppt = document.getElementById('billAppt');
        const billName = document.getElementById('billName');
        const billTreatment = document.getElementById('billTreatment');
        const billTreatmentFee = document.getElementById('billTreatmentFee');
        const billTotal = document.getElementById('billTotal');
        const billDate = document.getElementById('billDate');

        if (billAppt) billAppt.innerText = apptNum;
        if (billName) billName.innerText = pName;
        if (billTreatment) billTreatment.innerText = treatment;
        if (billTreatmentFee) billTreatmentFee.innerText = fee.toFixed(2);
        if (billTotal) billTotal.innerText = 'LKR ' + total.toFixed(2);
        if (billDate) billDate.innerText = new Date().toLocaleString();

        const fAppt = document.getElementById('formApptNum');
        const fName = document.getElementById('formPName');
        const fTreat = document.getElementById('formTreatment');
        const fTreatFee = document.getElementById('formTreatmentFee');
        const fTotal = document.getElementById('formTotalAmount');

        if (fAppt) fAppt.value = apptNum;
        if (fName) fName.value = pName;
        if (fTreat) fTreat.value = treatment;
        if (fTreatFee) fTreatFee.value = fee;
        if (fTotal) fTotal.value = total;

        if (section) section.scrollIntoView({ behavior: 'smooth' });
    } catch (err) {
        alert('Calculation failed: ' + err.message);
    }
};

// 9. Save Bill
window.handleSaveBill = async function(e) {
    if (e) e.preventDefault();

    const apptNum = document.getElementById('formApptNum')?.value;
    const pName = document.getElementById('formPName')?.value;
    const treatment = document.getElementById('formTreatment')?.value;
    const consultFee = parseFloat(document.getElementById('formConsultFee')?.value) || 2000.00;
    const treatFee = parseFloat(document.getElementById('formTreatmentFee')?.value) || 0.00;
    const totalAmount = parseFloat(document.getElementById('formTotalAmount')?.value) || (consultFee + treatFee);

    if (!apptNum || !pName) {
        alert('Please calculate an appointment bill first.');
        return;
    }

    const payload = {
        appointmentNumber: apptNum,
        patientName: pName,
        treatment: treatment,
        consultationFee: consultFee,
        treatmentFee: treatFee,
        totalAmount: totalAmount
    };

    try {
        try {
            await apiFetch('/save_bill', { method: 'POST', body: payload });
        } catch (err1) {
            await apiFetch('/bills', { method: 'POST', body: payload });
        }

        try {
            await apiFetch('/update_appointment_status', {
                method: 'POST',
                body: { appointmentNumber: apptNum, status: 'Completed' }
            });
        } catch (ignored) {}

        alert('Invoice Issued & Saved to Database Successfully!');
        const section = document.getElementById('invoiceSection');
        if (section) section.style.display = 'none';

        fetchDoctorAppointments();
        fetchDoctorBills();
        switchTab('invoices-tab');
    } catch (err) {
        alert('Failed to save invoice: ' + err.message);
    }
};

// 10. Patient History
async function fetchDoctorPatientHistory() {
    try {
        const list = await apiFetch('/all_appointments');
        const tbody = document.getElementById('patientHistoryBody');
        if (!tbody) return;

        tbody.innerHTML = '';

        let myHistory = (Array.isArray(list) ? list : []).filter(a => {
            const doc = a.dentist_name || a.dentistname || '';
            return isMatchingDoctor(doc, loggedDoctorName);
        });

        if (myHistory.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; color:#64748b; padding:20px;">No patient treatment history found for you.</td></tr>';
            return;
        }

        myHistory.forEach(item => {
            const patId = item.patient_id || 'PAT-001';
            const patName = item.patient_name || item.name || 'Patient';
            const contact = item.patient_contact || item.contact || '-';
            const apptNo = item.appointment_num || item.appointment_no || '-';
            const treatment = item.treatment_type || '-';
            const dt = item.appt_date_time || '-';
            const st = item.status || 'Pending';

            let badgeClass = 'badge-pending';
            let icon = 'fa-regular fa-clock';
            if (st.toLowerCase() === 'done') { 
                badgeClass = 'badge-done'; 
                icon = 'fa-solid fa-spinner'; 
            } else if (st.toLowerCase() === 'completed') { 
                badgeClass = 'badge-completed'; 
                icon = 'fa-solid fa-check-double'; 
            }

            tbody.innerHTML += `
                <tr>
                    <td><strong style="color:#0284c7;">${patId}</strong></td>
                    <td><strong>${patName}</strong></td>
                    <td><i class="fa-solid fa-phone" style="color:var(--text-muted); margin-right:4px;"></i> ${contact}</td>
                    <td><strong>${apptNo}</strong></td>
                    <td>${treatment}</td>
                    <td><i class="fa-regular fa-calendar" style="color:var(--text-muted); margin-right:4px;"></i> ${dt}</td>
                    <td><span class="badge ${badgeClass}"><i class="${icon}"></i> ${st}</span></td>
                </tr>
            `;
        });
    } catch (err) {
        console.error('Failed to load patient history:', err);
    }
}

// 11. Table Search Filter
function filterTable(tableId, inputId) {
    const input = document.getElementById(inputId);
    if (!input) return;
    const filter = input.value.toUpperCase();
    const table = document.getElementById(tableId);
    if (!table) return;
    const tr = table.getElementsByTagName('tr');
    for (let i = 1; i < tr.length; i++) {
        let show = false;
        const td = tr[i].getElementsByTagName('td');
        for (let j = 0; j < td.length; j++) {
            if (td[j] && (td[j].textContent || td[j].innerText).toUpperCase().indexOf(filter) > -1) {
                show = true;
                break;
            }
        }
        tr[i].style.display = show ? '' : 'none';
    }
}

window.addEventListener('DOMContentLoaded', loadDoctorComponents);