// Dynamic Base URL Configuration
const API_ENDPOINTS = [
    'http://localhost:8080/Sunrise_Dental_Clinic/api',
    'http://localhost:8080/Sunrise_Dental_Clinic-1.0-SNAPSHOT/api',
    'http://localhost:8080/Sunrise%20Dental%20Clinic/api'
];

let allPatientsCache = [];

async function apiFetch(endpoint, options = {}) {
    let finalOptions = { ...options };
    if (!finalOptions.headers) {
        finalOptions.headers = {};
    }
    if (finalOptions.body && typeof finalOptions.body === 'object') {
        finalOptions.body = JSON.stringify(finalOptions.body);
        finalOptions.headers['Content-Type'] = 'application/json';
    }

    let lastError = null;
    for (const baseUrl of API_ENDPOINTS) {
        try {
            const res = await fetch(`${baseUrl}${endpoint}`, finalOptions);
            if (res.ok) {
                return await res.json();
            }
        } catch (e) {
            lastError = e;
        }
    }
    throw new Error(lastError ? lastError.message : 'Failed to connect to API');
}

// 1. Component Loader & Dynamic Form Event Binder
async function loadComponents() {
    // Logged User Name Display (Shows Full Name or Fallback)
    const loggedUser = localStorage.getItem('loggedUser') || localStorage.getItem('username') || 'Staff Officer';
    const navStaffName = document.getElementById('navStaffName');
    if (navStaffName) {
        navStaffName.innerText = loggedUser;
    }

    const files = [
        'staff_dashboard/register_doctor.html',
        'staff_dashboard/register_patient.html',
        'staff_dashboard/add_treatment.html',
        'staff_dashboard/new_appointment.html',
        'staff_dashboard/appointments.html',
        'staff_dashboard/saved_receipts.html',
        'staff_dashboard/staff_guide.html'
    ];

    const contentArea = document.getElementById('dynamic-content-area');
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

    try {
        const printRes = await fetch('staff_dashboard/print_receipt_template.html');
        const printContainer = document.getElementById('print-template-container');
        if (printContainer && printRes.ok) {
            printContainer.innerHTML = await printRes.text();
        }
    } catch(e) {}

    bindFormEvents();
    fetchAllData();
}

// 2. Attach Click/Submit Listeners ONLY to actual form action buttons
function bindFormEvents() {
    document.addEventListener('click', function(e) {
        const targetBtn = e.target.closest('button');
        if (!targetBtn) return;

        // Tab මාරු කරන Tab Buttons නම් Ignore කිරීම
        if (targetBtn.classList.contains('tab-btn')) {
            return;
        }

        const btnText = targetBtn.innerText.trim();

        // Form Submit Buttons පමණක් හඳුනා ගැනීම
        if (targetBtn.type === 'submit' || targetBtn.classList.contains('btn-submit') || targetBtn.classList.contains('btn-register-doc')) {
            if (btnText.includes('Register Doctor') || btnText.includes('Register Doctor & Account')) {
                e.preventDefault();
                submitDoctor();
            } else if (btnText.includes('Register Patient')) {
                e.preventDefault();
                submitPatient();
            } else if (btnText.includes('Save Treatment')) {
                e.preventDefault();
                submitTreatment();
            } else if (btnText.includes('Save & Confirm')) {
                e.preventDefault();
                submitAppointment();
            }
        }
    });
}

function fetchAllData() {
    loadDoctors();
    loadPatients();
    loadTreatments();
    loadAppointments();
    loadBills();
}

function switchTab(tabId) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
    
    // Normalize tab IDs
    let target = document.getElementById(tabId);
    let btn = document.getElementById('tab-btn-' + tabId);

    if (!target && tabId === 'add-appointment') {
        target = document.getElementById('new-appointment');
    } else if (!target && tabId === 'new-appointment') {
        target = document.getElementById('add-appointment');
    }

    if (!btn && tabId === 'add-appointment') {
        btn = document.getElementById('tab-btn-new-appointment');
    } else if (!btn && tabId === 'new-appointment') {
        btn = document.getElementById('tab-btn-add-appointment');
    }

    if (target) target.classList.add('active');
    if (btn) btn.classList.add('active');

    // Fresh data load on tab open
    if (tabId.includes('appointment') || tabId === 'add-appointment' || tabId === 'new-appointment') {
        loadDoctors();
        loadTreatments();
        loadPatients();
    } else if (tabId === 'register-patient') {
        loadPatients();
    } else if (tabId === 'add-doctor') {
        loadDoctors();
    } else if (tabId === 'add-treatment') {
        loadTreatments();
    }
}

// 3. Load Doctors (Populates Table, Stat Box & Dropdowns)
async function loadDoctors() {
    const tbody = document.getElementById('docTableBody');
    const statDoc = document.getElementById('statDocCount');
    const dropdowns = [
        document.getElementById('dentistDropdown'),
        document.getElementById('appointmentDoctor'),
        document.getElementById('docSelect'),
        document.querySelector('select[name="dentist"]'),
        document.querySelector('select[name="dentistName"]')
    ].filter(Boolean);

    dropdowns.forEach(d => d.innerHTML = '<option value="">-- Select Dentist --</option>');

    try {
        const res = await apiFetch('/doctors');
        let doctors = [];
        if (Array.isArray(res)) {
            doctors = res;
        } else if (res && Array.isArray(res.data)) {
            doctors = res.data;
        } else if (res && Array.isArray(res.doctors)) {
            doctors = res.doctors;
        }

        if (statDoc) statDoc.innerText = doctors.length || 0;
        if (tbody) tbody.innerHTML = '';

        if (doctors.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; color:var(--text-muted);">No doctors registered yet.</td></tr>';
            return;
        }

        doctors.forEach(doc => {
            const id = doc.doctor_id || doc.doctorId || doc.id || '-';
            const name = doc.doctor_name || doc.doctorName || doc.name || '-';
            const loc = doc.location || doc.branch || 'Nugegoda';
            const tel = doc.tel_no || doc.telNo || doc.telephone || '-';

            if (tbody) {
                tbody.innerHTML += `<tr>
                    <td><strong>${id}</strong></td>
                    <td><strong>${name}</strong></td>
                    <td><i class="fa-solid fa-location-dot" style="color:#888; margin-right:4px;"></i> ${loc}</td>
                    <td><i class="fa-solid fa-phone" style="color:#888; margin-right:4px;"></i> ${tel}</td>
                </tr>`;
            }

            dropdowns.forEach(d => {
                const opt = document.createElement('option');
                opt.value = name;
                opt.textContent = `${name} (${loc})`;
                d.appendChild(opt);
            });
        });
    } catch (err) {
        console.error('Load Doctors Error:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="4" style="color:red; text-align:center;">Failed to load doctors.</td></tr>';
    }
}

// 4. Load Patients & Auto-fill Dropdown
async function loadPatients() {
    const tbody = document.getElementById('patientTableBody');
    const dropdown = document.getElementById('patientSelectDropdown');

    try {
        const list = await apiFetch('/patients');
        allPatientsCache = Array.isArray(list) ? list : [];

        if (tbody) tbody.innerHTML = '';
        if (dropdown) dropdown.innerHTML = '<option value="">-- Choose Existing Patient --</option>';

        if (allPatientsCache.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; color:var(--text-muted);">No patients registered yet.</td></tr>';
            return;
        }

        allPatientsCache.forEach(p => {
            const pId = p.patient_id || p.patientId || '-';
            const name = p.name || p.patient_name || '-';
            const address = p.address || '-';
            const contact = p.contact || '-';

            if (tbody) {
                tbody.innerHTML += `<tr>
                    <td><strong>${pId}</strong></td>
                    <td><strong>${name}</strong></td>
                    <td>${address}</td>
                    <td><i class="fa-solid fa-phone" style="color:#888; margin-right:4px;"></i> ${contact}</td>
                </tr>`;
            }

            if (dropdown) {
                const opt = document.createElement('option');
                opt.value = pId;
                opt.textContent = `${name} (${pId} - ${contact})`;
                dropdown.appendChild(opt);
            }
        });
    } catch (e) {
        console.error('Failed to load patients:', e);
        if (tbody) tbody.innerHTML = '<tr><td colspan="4" style="color:red; text-align:center;">Failed to load patients.</td></tr>';
    }
}

// Auto-Fill Fields when Patient is selected
window.onPatientSelected = function(patId) {
    if (!patId) return;
    const pat = allPatientsCache.find(p => (p.patient_id === patId || p.patientId === patId));
    if (pat) {
        const nameInput = document.getElementById('apptPatientName') || document.querySelector('#add-appointment input[placeholder*="Full Name"]');
        const addrInput = document.getElementById('apptAddress') || document.querySelector('#add-appointment input[placeholder*="Address"]');
        const phoneInput = document.getElementById('apptContact') || document.querySelector('#add-appointment input[placeholder*="077"]');

        if (nameInput) nameInput.value = pat.name || '';
        if (addrInput) addrInput.value = pat.address || '';
        if (phoneInput) phoneInput.value = pat.contact || '';
    }
};

// 5. Load Treatments
async function loadTreatments() {
    try {
        const list = await apiFetch('/treatments');
        const tbody = document.getElementById('treatTableBody');
        const dropdown = document.getElementById('treatmentDropdown');

        if (tbody) tbody.innerHTML = '';
        if (dropdown) dropdown.innerHTML = '<option value="">-- Select Treatment --</option>';

        const statT = document.getElementById('statTreatCount');
        if (statT) statT.innerText = list.length || 0;

        if (!list || list.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="3" style="text-align:center; color:var(--text-muted);">No treatments found.</td></tr>';
            return;
        }

        list.forEach(t => {
            const id = t.treatment_id || t.treatmentId || t.id || '-';
            const name = t.treatment_name || t.treatmentName || t.name || '-';
            const cost = Number(t.cost || t.price || 0).toFixed(2);

            if (tbody) {
                tbody.innerHTML += `<tr>
                    <td><strong>TRT-${id}</strong></td>
                    <td><strong>${name}</strong></td>
                    <td><strong style="color:#10b981;">LKR ${cost}</strong></td>
                </tr>`;
            }
            if (dropdown) {
                const opt = document.createElement('option');
                opt.value = name;
                opt.textContent = `${name} (LKR ${cost})`;
                dropdown.appendChild(opt);
            }
        });
    } catch (e) {
        if (document.getElementById('treatTableBody')) {
            document.getElementById('treatTableBody').innerHTML = '<tr><td colspan="3" style="color:red; text-align:center;">Failed to load treatments.</td></tr>';
        }
    }
}

// 6. Load Appointments
async function loadAppointments() {
    try {
        const list = await apiFetch('/all_appointments');
        const tbody = document.getElementById('apptTableBody');
        if (tbody) tbody.innerHTML = '';

        const statA = document.getElementById('statApptCount');
        if (statA) statA.innerText = list.length || 0;
        let pending = 0;

        if (!list || list.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; color:var(--text-muted);">No appointments found.</td></tr>';
            return;
        }

        list.forEach(a => {
            const apptNo = a.appointment_num || a.appointment_no || a.id || '-';
            const patName = a.patient_name || a.patientName || a.name || '-';
            const contact = a.patient_contact || a.contact || '-';
            const dentist = a.dentist_name || a.dentistName || '-';
            const treat = a.treatment_type || a.treatmentType || '-';
            const dt = a.appt_date_time || a.apptDateTime || '-';
            const st = a.status || a.appt_status || 'Pending';

            if (st.toLowerCase() === 'pending') pending++;

            let badgeClass = 'badge-pending';
            let icon = 'fa-regular fa-clock';
            if (st.toLowerCase() === 'done') { 
                badgeClass = 'badge-done'; 
                icon = 'fa-solid fa-spinner'; 
            } else if (st.toLowerCase() === 'completed') { 
                badgeClass = 'badge-completed'; 
                icon = 'fa-solid fa-check-double'; 
            }

            if (tbody) {
                tbody.innerHTML += `<tr>
                    <td><strong>${apptNo}</strong></td>
                    <td><strong>${patName}</strong></td>
                    <td><i class="fa-solid fa-phone" style="color:var(--text-muted);"></i> ${contact}</td>
                    <td>${dentist}</td>
                    <td>${treat}</td>
                    <td><i class="fa-regular fa-calendar" style="color:var(--text-muted);"></i> ${dt}</td>
                    <td><span class="badge ${badgeClass}"><i class="${icon}"></i> ${st}</span></td>
                </tr>`;
            }
        });

        const statP = document.getElementById('statPendingCount');
        if (statP) statP.innerText = pending;
    } catch (e) {
        if (document.getElementById('apptTableBody')) {
            document.getElementById('apptTableBody').innerHTML = '<tr><td colspan="7" style="color:red; text-align:center;">Failed to load appointments.</td></tr>';
        }
    }
}

// 7. Load Bills
async function loadBills() {
    try {
        const list = await apiFetch('/bills');
        const tbody = document.getElementById('billTableBody');
        if (tbody) tbody.innerHTML = '';

        const statB = document.getElementById('statBillCount');
        if (statB) statB.innerText = list.length || 0;

        if (!list || list.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; color:var(--text-muted);">No receipts found.</td></tr>';
            return;
        }

        list.forEach(b => {
            const bId = 'BIL-' + (b.bill_id || b.billId || b.id || '0');
            const apptNo = b.appointment_num || b.appointmentNum || '-';
            const patName = b.patient_name || b.patientName || '-';
            const treat = b.treatment_type || b.treatmentType || '-';
            const consult = Number(b.consultation_fee || b.consultationFee || 0).toFixed(2);
            const treatFee = Number(b.treatment_fee || b.treatmentFee || 0).toFixed(2);
            const total = Number(b.total_amount || b.totalAmount || 0).toFixed(2);

            if (tbody) {
                tbody.innerHTML += `<tr>
                    <td><strong>${bId}</strong></td>
                    <td>${apptNo}</td>
                    <td><strong>${patName}</strong></td>
                    <td>${treat}</td>
                    <td>LKR ${consult}</td>
                    <td>LKR ${treatFee}</td>
                    <td><strong style="color:#10b981;">LKR ${total}</strong></td>
                    <td>
                        <button onclick="printSingleBill('${bId}', '${apptNo}', '${patName}', '${treat}', ${consult}, ${treatFee}, ${total})" 
                                class="btn-submit" style="padding: 7px 14px; font-size:12px; background:var(--primary);">
                            <i class="fa-solid fa-print"></i> Print Receipt
                        </button>
                    </td>
                </tr>`;
            }
        });
    } catch (e) {
        if (document.getElementById('billTableBody')) {
            document.getElementById('billTableBody').innerHTML = '<tr><td colspan="8" style="color:red; text-align:center;">Failed to load receipts.</td></tr>';
        }
    }
}

// 8. Submit Handlers

async function submitDoctor() {
    const inputs = document.querySelectorAll('#add-doctor input, #register-doctor input, .tab-content.active input');
    
    const docId = (document.getElementById('regDocId') || document.querySelector('input[placeholder*="DOC-"]') || inputs[0])?.value.trim() || '';
    const docName = (document.getElementById('regDocName') || document.querySelector('input[placeholder*="Firstname"]') || inputs[1])?.value.trim() || '';
    const location = (document.getElementById('regDocLocation') || document.querySelector('input[placeholder*="Branch"]') || inputs[2])?.value.trim() || 'Nugegoda';
    const telNo = (document.getElementById('regDocTel') || document.querySelector('input[placeholder*="Contact"]') || inputs[3])?.value.trim() || '-';
    const username = (document.getElementById('regDocUsername') || document.querySelector('input[placeholder*="username"]') || inputs[4])?.value.trim() || docId;
    const password = (document.getElementById('regDocPassword') || document.querySelector('input[placeholder*="Password"]') || inputs[5])?.value.trim() || '1234';

    if (!docName) {
        alert('Please fill in Doctor Full Name.');
        return;
    }

    const data = {
        doctorId: docId || ('DOC-' + Math.floor(100 + Math.random() * 900)),
        doctorName: docName,
        location: location,
        telNo: telNo,
        username: username,
        password: password
    };

    try {
        const res = await apiFetch('/doctors', { method: 'POST', body: data });
        alert(res.message || 'Doctor registered successfully!');
        inputs.forEach(i => i.value = '');
        loadDoctors();
    } catch (err) {
        alert('Failed to register doctor: ' + err.message);
    }
}

async function submitPatient() {
    const nameInput = document.getElementById('patientRegName') || document.querySelector('#add-patient input[placeholder*="Full Name"]');
    const addrInput = document.getElementById('patientRegAddress') || document.querySelector('#add-patient input[placeholder*="Address"]');
    const contactInput = document.getElementById('patientRegContact') || document.querySelector('#add-patient input[placeholder*="077"]');

    const name = nameInput ? nameInput.value.trim() : '';
    const address = addrInput ? addrInput.value.trim() : 'N/A';
    const contact = contactInput ? contactInput.value.trim() : '';

    if (!name || !contact) {
        alert('Please fill in Patient Name and Contact Number.');
        return;
    }

    try {
        const res = await apiFetch('/patients', {
            method: 'POST',
            body: { name, address, contact }
        });
        alert(res.message || 'Patient registered successfully!');
        if (nameInput) nameInput.value = '';
        if (addrInput) addrInput.value = '';
        if (contactInput) contactInput.value = '';
        loadPatients();
    } catch (err) {
        alert('Failed to register patient: ' + err.message);
    }
}

async function submitTreatment() {
    const inputs = document.querySelectorAll('#add-treatment input, .tab-content.active input');
    const name = inputs[0]?.value.trim();
    const cost = parseFloat(inputs[1]?.value);

    if (!name || isNaN(cost)) {
        alert('Please enter a valid treatment name and procedure cost.');
        return;
    }

    try {
        const res = await apiFetch('/treatments', { 
            method: 'POST', 
            body: { treatmentName: name, cost: cost } 
        });
        alert(res.message || 'Treatment added successfully!');
        inputs.forEach(i => i.value = '');
        loadTreatments();
    } catch (err) {
        alert('Failed to save treatment: ' + err.message);
    }
}

async function submitAppointment() {
    const inputs = document.querySelectorAll('#add-appointment input, .tab-content.active input');
    const selects = document.querySelectorAll('#add-appointment select, .tab-content.active select');

    const patName = (document.getElementById('apptPatientName') || inputs[0])?.value.trim();
    const address = (document.getElementById('apptAddress') || inputs[1])?.value.trim() || 'N/A';
    const contact = (document.getElementById('apptContact') || inputs[2])?.value.trim();
    const dentist = (document.getElementById('dentistDropdown') || selects[1] || selects[0])?.value;
    const treatment = (document.getElementById('treatmentDropdown') || selects[2] || selects[1])?.value;
    const apptDateTime = (document.getElementById('apptDateTime') || inputs[3])?.value;

    if (!patName || !contact || !dentist || !treatment || !apptDateTime) {
        alert('Please complete all appointment fields.');
        return;
    }

    const data = {
        patientName: patName,
        address: address,
        contact: contact,
        dentistName: dentist,
        treatmentType: treatment,
        apptDateTime: apptDateTime
    };

    try {
        const res = await apiFetch('/create_appointment', { method: 'POST', body: data });
        alert('Appointment Confirmed! Appointment Number: ' + (res.appointmentNumber || ''));
        inputs.forEach(i => i.value = '');
        loadAppointments();
        switchTab('appointments');
    } catch (err) {
        alert('Failed to register appointment: ' + err.message);
    }
}

// 9. Print Function
function printSingleBill(billId, apptNum, pName, treatment, consultFee, treatFee, total) {
    const setVal = (id, val) => {
        const el = document.getElementById(id);
        if (el) el.innerText = val;
    };

    setVal('prBillId', billId);
    setVal('prDate', new Date().toLocaleString());
    setVal('prApptNum', apptNum);
    setVal('prPatientName', pName);
    setVal('prTreatment', treatment);
    setVal('prConsultFee', Number(consultFee).toFixed(2));
    setVal('prTreatFee', Number(treatFee).toFixed(2));
    setVal('prTotal', Number(total).toFixed(2));
    
    window.print();
}

// 10. Table Search Filter
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

// 11. Logout Handler
function logoutStaff() {
    localStorage.clear();
    window.location.href = 'login.html';
}

window.addEventListener('DOMContentLoaded', loadComponents);