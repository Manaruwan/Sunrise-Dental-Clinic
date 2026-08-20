// Dynamic Base URL Discovery
const URL_LIST = [
    'http://localhost:8080/Sunrise_Dental_Clinic-1.0-SNAPSHOT/api',
    'http://localhost:8080/Sunrise_Dental_Clinic/api'
];

async function apiFetch(endpoint, options = {}) {
    let opts = { ...options };
    if (!opts.headers) opts.headers = {};

    if (opts.body && typeof opts.body === 'object') {
        opts.body = JSON.stringify(opts.body);
        opts.headers['Content-Type'] = 'application/json';
    }

    for (let base of URL_LIST) {
        try {
            let res = await fetch(`${base}${endpoint}`, opts);
            if (res.ok) {
                return await res.json();
            }
        } catch (e) {
            // try next base url
        }
    }
    throw new Error('API server unreachable');
}

// 1. Load HTML Modules & Bind Events
async function loadComponents() {
    const files = [
        'staff_dashboard/register_doctor.html',
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
                console.error('Failed loading template:', file);
            }
        }
    }

    try {
        const printRes = await fetch('staff_dashboard/print_receipt_template.html');
        const printContainer = document.getElementById('print-template-container');
        if (printContainer && printRes.ok) {
            printContainer.innerHTML = await printRes.text();
        }
    } catch (e) {}

    bindDynamicEvents();
    fetchAllData();
}

// 2. Global Event Listener for Submissions
function bindDynamicEvents() {
    document.addEventListener('click', function (e) {
        const btn = e.target.closest('button');
        if (!btn) return;

        const text = btn.innerText.trim();
        if (text.includes('Register Doctor')) {
            e.preventDefault();
            submitDoctor();
        } else if (text.includes('Save Treatment')) {
            e.preventDefault();
            submitTreatment();
        } else if (text.includes('Save & Confirm')) {
            e.preventDefault();
            submitAppointment();
        }
    });
}

function fetchAllData() {
    loadDoctors();
    loadTreatments();
    loadAppointments();
    loadBills();
}

function switchTab(tabId) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));

    const target = document.getElementById(tabId);
    const btn = document.getElementById('tab-btn-' + tabId);

    if (target) target.classList.add('active');
    if (btn) btn.classList.add('active');
}

// 3. Load Doctors
async function loadDoctors() {
    try {
        const doctors = await apiFetch('/doctors');
        const tbody = document.getElementById('docTableBody');
        const dropdown = document.getElementById('dentistDropdown');

        if (tbody) tbody.innerHTML = '';
        if (dropdown) dropdown.innerHTML = '<option value="">-- Select Dentist --</option>';

        const statDoc = document.getElementById('statDocCount');
        if (statDoc) statDoc.innerText = doctors.length || 0;

        if (!doctors || doctors.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="4" style="text-align:center;">No doctors registered.</td></tr>';
            return;
        }

        doctors.forEach(doc => {
            const id = doc.doctor_id || doc.doctorId || doc.id || '-';
            const name = doc.doctor_name || doc.doctorName || doc.name || '-';
            const loc = doc.location || doc.branch || '-';
            const tel = doc.tel_no || doc.telNo || doc.telephone || doc.contact || '-';

            if (tbody) {
                tbody.innerHTML += `<tr>
                    <td><strong>${id}</strong></td>
                    <td><strong>${name}</strong></td>
                    <td><i class="fa-solid fa-location-dot" style="color:var(--text-muted); margin-right:4px;"></i> ${loc}</td>
                    <td><i class="fa-solid fa-phone" style="color:var(--text-muted); margin-right:4px;"></i> ${tel}</td>
                </tr>`;
            }
            if (dropdown) {
                const opt = document.createElement('option');
                opt.value = name;
                opt.textContent = `${name} (${loc})`;
                dropdown.appendChild(opt);
            }
        });
    } catch (e) {
        if (document.getElementById('docTableBody')) {
            document.getElementById('docTableBody').innerHTML = '<tr><td colspan="4" style="color:red; text-align:center;">Failed to load doctors.</td></tr>';
        }
    }
}

// 4. Load Treatments
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
            if (tbody) tbody.innerHTML = '<tr><td colspan="3" style="text-align:center;">No treatments found.</td></tr>';
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

// 5. Load Appointments
async function loadAppointments() {
    try {
        const list = await apiFetch('/all_appointments');
        const tbody = document.getElementById('apptTableBody');
        if (tbody) tbody.innerHTML = '';

        const statA = document.getElementById('statApptCount');
        if (statA) statA.innerText = list.length || 0;
        let pending = 0;

        if (!list || list.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;">No appointments found.</td></tr>';
            return;
        }

        list.forEach(a => {
            const apptNo = a.appointment_num || a.appointment_no || a.id || '-';
            const patName = a.patient_name || a.name || '-';
            const contact = a.patient_contact || a.contact || '-';
            const dentist = a.dentist_name || '-';
            const treat = a.treatment_type || '-';
            const dt = a.appt_date_time || '-';
            const st = a.status || 'Pending';

            if (st.toLowerCase() === 'pending') pending++;

            let badgeClass = 'badge-pending';
            let icon = 'fa-regular fa-clock';
            if (st.toLowerCase() === 'done') { badgeClass = 'badge-done'; icon = 'fa-solid fa-spinner'; }
            else if (st.toLowerCase() === 'completed') { badgeClass = 'badge-completed'; icon = 'fa-solid fa-check-double'; }

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

// 6. Load Bills
async function loadBills() {
    try {
        const list = await apiFetch('/bills');
        const tbody = document.getElementById('billTableBody');
        if (tbody) tbody.innerHTML = '';

        const statB = document.getElementById('statBillCount');
        if (statB) statB.innerText = list.length || 0;

        if (!list || list.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;">No receipts found.</td></tr>';
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

// 7. Form Handlers
async function submitDoctor() {
    const inputs = document.querySelectorAll('#add-doctor input');
    if (!inputs || inputs.length === 0) return;

    const data = {
        doctorId: inputs[0] ? inputs[0].value.trim() : '',
        doctorName: inputs[1] ? inputs[1].value.trim() : '',
        location: inputs[2] ? inputs[2].value.trim() : '',
        telNo: inputs[3] ? inputs[3].value.trim() : '',
        username: inputs[4] ? inputs[4].value.trim() : '',
        password: inputs[5] ? inputs[5].value.trim() : '1234'
    };

    if (!data.doctorId || !data.doctorName) {
        alert('Please fill Doctor ID and Full Name.');
        return;
    }

    try {
        const res = await apiFetch('/doctors', { method: 'POST', body: data });
        alert(res.message || 'Doctor registered successfully!');
        inputs.forEach(i => i.value = '');
        loadDoctors();
    } catch (err) {
        alert('Failed to register doctor: ' + err.message);
    }
}

async function submitTreatment() {
    const inputs = document.querySelectorAll('#add-treatment input');
    if (!inputs || inputs.length < 2) return;

    const data = {
        treatmentName: inputs[0].value.trim(),
        cost: parseFloat(inputs[1].value)
    };

    if (!data.treatmentName || isNaN(data.cost)) {
        alert('Please enter valid treatment name and cost.');
        return;
    }

    try {
        const res = await apiFetch('/treatments', { method: 'POST', body: data });
        alert(res.message || 'Treatment saved!');
        inputs.forEach(i => i.value = '');
        loadTreatments();
    } catch (err) {
        alert('Failed to save treatment: ' + err.message);
    }
}

async function submitAppointment() {
    const inputs = document.querySelectorAll('#add-appointment input');
    const selects = document.querySelectorAll('#add-appointment select');

    const data = {
        patientName: inputs[0] ? inputs[0].value.trim() : '',
        address: inputs[1] ? inputs[1].value.trim() : '',
        contact: inputs[2] ? inputs[2].value.trim() : '',
        dentistName: selects[0] ? selects[0].value : '',
        treatmentType: selects[1] ? selects[1].value : '',
        apptDateTime: inputs[3] ? inputs[3].value : ''
    };

    if (!data.patientName || !data.contact || !data.dentistName || !data.treatmentType) {
        alert('Please fill all appointment fields.');
        return;
    }

    try {
        const res = await apiFetch('/create_appointment', { method: 'POST', body: data });
        alert('Appointment Confirmed! No: ' + (res.appointmentNumber || ''));
        inputs.forEach(i => i.value = '');
        loadAppointments();
        switchTab('appointments');
    } catch (err) {
        alert('Failed: ' + err.message);
    }
}

// 8. Print Card
function printSingleBill(billId, apptNum, pName, treatment, consultFee, treatFee, total) {
    document.getElementById('prBillId').innerText = billId;
    document.getElementById('prDate').innerText = new Date().toLocaleString();
    document.getElementById('prApptNum').innerText = apptNum;
    document.getElementById('prPatientName').innerText = pName;
    document.getElementById('prTreatment').innerText = treatment;
    document.getElementById('prConsultFee').innerText = Number(consultFee).toFixed(2);
    document.getElementById('prTreatFee').innerText = Number(treatFee).toFixed(2);
    document.getElementById('prTotal').innerText = Number(total).toFixed(2);
    window.print();
}

// 9. Table Filter
function filterTable(tableId, inputId) {
    const input = document.getElementById(inputId);
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

window.addEventListener('DOMContentLoaded', loadComponents);