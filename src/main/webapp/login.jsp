</html><%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sunrise Dental Clinic - Staff & Doctor Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: 'Poppins', sans-serif; background: #e0f2fe; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-card { background: white; padding: 40px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); width: 360px; text-align: center; }
        .login-card i.logo-icon { font-size: 45px; color: #0284c7; margin-bottom: 10px; }
        .login-card h2 { font-size: 22px; margin-bottom: 20px; color: #0f172a; }
        .input-group { margin-bottom: 15px; text-align: left; }
        .input-group label { font-size: 13px; font-weight: 500; color: #64748b; display: block; margin-bottom: 5px; }
        .input-group input { width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box; font-size: 14px; }
        .btn-login { width: 100%; padding: 12px; background: #0284c7; color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; transition: background 0.3s; margin-top: 10px; }
        .btn-login:hover { background: #0369a1; }
        .error-msg { color: #ef4444; font-size: 13px; margin-top: 15px; }
        .back-link { display: inline-block; margin-top: 15px; color: #64748b; text-decoration: none; font-size: 13px; }
    </style>
</head>
<body>

    <div class="login-card">
        <i class="fa-solid fa-tooth logo-icon"></i>
        <h2>Portal Login</h2>
        
        <form action="LoginServlet" method="POST">
            <div class="input-group">
                <label>Username</label>
                <input type="text" name="username" placeholder="Enter username" required>
            </div>
            
            <div class="input-group">
                <label>Password</label>
                <input type="password" name="password" placeholder="Enter password" required>
            </div>
            
            <button type="submit" class="btn-login"><i class="fa-solid fa-right-to-bracket"></i> Sign In</button>
        </form>

        <% 
            String error = (String) request.getAttribute("errorMessage");
            if (error != null) { 
        %>
            <div class="error-msg"><i class="fa-solid fa-circle-exclamation"></i> <%= error %></div>
        <% } %>

        <a href="index.jsp" class="back-link"><i class="fa-solid fa-arrow-left"></i> Back to Homepage</a>
    </div>

</body>
</html>