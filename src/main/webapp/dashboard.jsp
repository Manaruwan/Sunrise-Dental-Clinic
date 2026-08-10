<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Sunrise Dental</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f8fafc; }
        .form-box { background: white; padding: 25px; border-radius: 8px; max-width: 500px; margin: auto; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        input, select { width: 100%; padding: 10px; margin: 8px 0; border: 1px solid #cbd5e1; border-radius: 4px; box-sizing: border-box; }
        button { background: #16a34a; color: white; padding: 12px; width: 100%; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
    </style>
</head>
<body>
    <div class="form-box">
        <h2>Register New Appointment</h2>
        <form action="api/appointments" method="POST">
            <input type="text" name="name" placeholder="Patient Name" required>
            <input type="text" name="address" placeholder="Address" required>
            <input type="text" name="contact" placeholder="Contact Number (10 Digits)" pattern="\d{10}" required>
            <input type="text" name="dentist" placeholder="Dentist Name" required>
            <select name="treatment">
                <option value="Cleaning">Teeth Cleaning</option>
                <option value="Filling">Filling</option>
                <option value="Root Canal">Root Canal</option>
                <option value="Extraction">Extraction</option>
            </select>
            <input type="datetime-local" name="datetime" required>
            <button type="submit">Book Appointment</button>
        </form>
    </div>
</body>
</html>-