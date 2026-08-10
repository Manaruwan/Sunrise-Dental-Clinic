```jsp
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Sunrise Dental Clinic</title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <style>

        /* ================================
           GLOBAL
        ================================= */

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
            scroll-behavior: smooth;
        }

        :root {
            --primary: #0284c7;
            --primary-dark: #0369a1;
            --secondary: #0f172a;
            --accent: #38bdf8;
            --light-blue: #e0f2fe;
            --light-bg: #f8fafc;
            --white: #ffffff;
            --gray: #64748b;
            --dark-gray: #334155;
            --success: #16a34a;
        }

        body {
            background: var(--light-bg);
            color: var(--secondary);
            line-height: 1.7;
            overflow-x: hidden;
        }

        a {
            text-decoration: none;
        }

        /* ================================
           NAVBAR
        ================================= */

        nav {
            width: 100%;
            background: rgba(255, 255, 255, 0.94);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);

            display: flex;
            justify-content: space-between;
            align-items: center;

            padding: 18px 7%;

            position: fixed;
            top: 0;
            left: 0;

            z-index: 9999;

            border-bottom: 1px solid rgba(226, 232, 240, 0.7);

            box-shadow: 0 5px 25px rgba(15, 23, 42, 0.06);
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 12px;

            color: var(--primary);
            font-size: 22px;
            font-weight: 800;

            letter-spacing: -0.5px;
        }

        .logo-icon {
            width: 45px;
            height: 45px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 14px;

            color: white;

            background: linear-gradient(
                135deg,
                var(--primary),
                var(--accent)
            );

            box-shadow: 0 8px 20px rgba(2, 132, 199, 0.25);
        }

        .logo-icon i {
            font-size: 23px;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 32px;

            list-style: none;
        }

        .nav-links a {
            color: var(--secondary);
            font-size: 14px;
            font-weight: 600;

            position: relative;

            transition: 0.3s ease;
        }

        .nav-links a:not(.btn-login)::after {
            content: "";

            position: absolute;
            left: 0;
            bottom: -8px;

            width: 0;
            height: 2px;

            background: var(--primary);

            transition: 0.3s ease;
        }

        .nav-links a:not(.btn-login):hover {
            color: var(--primary);
        }

        .nav-links a:not(.btn-login):hover::after {
            width: 100%;
        }

        .btn-login {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            padding: 11px 20px;

            color: white !important;

            border-radius: 10px;

            background: linear-gradient(
                135deg,
                var(--primary),
                var(--primary-dark)
            );

            box-shadow: 0 8px 20px rgba(2, 132, 199, 0.25);

            transition: 0.3s ease;
        }

        .btn-login:hover {
            transform: translateY(-2px);

            box-shadow: 0 12px 25px rgba(2, 132, 199, 0.35);
        }

        /* ================================
           HERO
        ================================= */

        .hero {
            min-height: 720px;

            margin-top: 78px;

            display: flex;
            align-items: center;
            justify-content: center;

            text-align: center;

            color: white;

            padding: 100px 8%;

            position: relative;

            background:
                linear-gradient(
                    135deg,
                    rgba(2, 132, 199, 0.94),
                    rgba(15, 23, 42, 0.92)
                ),
                url('https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=90')
                center/cover no-repeat;

            overflow: hidden;
        }

        .hero::before {
            content: "";

            position: absolute;

            width: 500px;
            height: 500px;

            border-radius: 50%;

            background: rgba(56, 189, 248, 0.12);

            top: -200px;
            right: -150px;

            filter: blur(2px);
        }

        .hero::after {
            content: "";

            position: absolute;

            width: 350px;
            height: 350px;

            border-radius: 50%;

            background: rgba(255, 255, 255, 0.07);

            bottom: -150px;
            left: -100px;
        }

        .hero-content {
            max-width: 900px;

            position: relative;
            z-index: 2;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            padding: 8px 18px;

            margin-bottom: 25px;

            border: 1px solid rgba(255, 255, 255, 0.25);

            background: rgba(255, 255, 255, 0.12);

            backdrop-filter: blur(10px);

            border-radius: 50px;

            font-size: 13px;
            font-weight: 500;
        }

        .hero h1 {
            font-size: clamp(42px, 6vw, 70px);

            line-height: 1.12;

            font-weight: 800;

            margin-bottom: 25px;

            letter-spacing: -2px;
        }

        .hero h1 span {
            color: #bae6fd;
        }

        .hero p {
            max-width: 760px;

            margin: 0 auto 35px;

            font-size: 17px;

            color: rgba(255, 255, 255, 0.88);
        }

        .hero-buttons {
            display: flex;
            justify-content: center;
            align-items: center;

            gap: 15px;

            flex-wrap: wrap;
        }

        .hero-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;

            padding: 14px 26px;

            border-radius: 12px;

            font-weight: 600;

            color: var(--secondary);

            background: white;

            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);

            transition: 0.3s ease;
        }

        .hero-btn:hover {
            transform: translateY(-4px);

            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
        }

        .hero-btn-outline {
            color: white;

            background: rgba(255, 255, 255, 0.1);

            border: 1px solid rgba(255, 255, 255, 0.35);

            backdrop-filter: blur(10px);
        }

        /* ================================
           STATS
        ================================= */

        .stats {
            width: 84%;
            max-width: 1100px;

            margin: -55px auto 0;

            position: relative;
            z-index: 10;

            display: grid;

            grid-template-columns: repeat(3, 1fr);

            background: white;

            border-radius: 20px;

            box-shadow: 0 15px 45px rgba(15, 23, 42, 0.1);

            overflow: hidden;
        }

        .stat {
            padding: 28px;

            text-align: center;

            border-right: 1px solid #e2e8f0;
        }

        .stat:last-child {
            border-right: none;
        }

        .stat i {
            font-size: 27px;

            color: var(--primary);

            margin-bottom: 8px;
        }

        .stat h3 {
            font-size: 27px;
            font-weight: 700;
        }

        .stat p {
            color: var(--gray);
            font-size: 13px;
        }

        /* ================================
           SECTION
        ================================= */

        .section {
            padding: 100px 8%;
        }

        .section-title {
            text-align: center;

            max-width: 700px;

            margin: 0 auto 55px;
        }

        .section-label {
            color: var(--primary);

            font-size: 13px;
            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: 2px;

            margin-bottom: 10px;
        }

        .section-title h2 {
            font-size: clamp(30px, 4vw, 42px);

            line-height: 1.2;

            margin-bottom: 15px;
        }

        .section-title p {
            color: var(--gray);

            font-size: 15px;
        }

        /* ================================
           SERVICES
        ================================= */

        .services-grid {
            display: grid;

            grid-template-columns: repeat(
                auto-fit,
                minmax(240px, 1fr)
            );

            gap: 25px;
        }

        .service-card {
            background: white;

            padding: 32px 26px;

            border-radius: 18px;

            border: 1px solid #e2e8f0;

            position: relative;

            overflow: hidden;

            transition: 0.35s ease;

            box-shadow: 0 8px 25px rgba(15, 23, 42, 0.04);
        }

        .service-card::before {
            content: "";

            position: absolute;

            top: 0;
            left: 0;

            width: 100%;
            height: 4px;

            background: linear-gradient(
                90deg,
                var(--primary),
                var(--accent)
            );

            transform: scaleX(0);

            transform-origin: left;

            transition: 0.35s ease;
        }

        .service-card:hover {
            transform: translateY(-10px);

            border-color: #bae6fd;

            box-shadow: 0 20px 45px rgba(15, 23, 42, 0.1);
        }

        .service-card:hover::before {
            transform: scaleX(1);
        }

        .service-icon {
            width: 60px;
            height: 60px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 16px;

            background: var(--light-blue);

            color: var(--primary);

            margin-bottom: 22px;

            transition: 0.3s ease;
        }

        .service-card:hover .service-icon {
            background: var(--primary);
            color: white;

            transform: rotate(-5deg) scale(1.05);
        }

        .service-icon i {
            font-size: 25px;
        }

        .service-card h3 {
            font-size: 19px;

            margin-bottom: 12px;
        }

        .service-card p {
            color: var(--gray);

            font-size: 13px;

            margin-bottom: 20px;
        }

        .price-tag {
            display: inline-flex;
            align-items: center;

            padding: 7px 14px;

            border-radius: 50px;

            background: #ecfeff;

            color: var(--primary-dark);

            font-size: 13px;

            font-weight: 700;
        }

        /* ================================
           ABOUT
        ================================= */

        .about-section {
            padding: 100px 8%;

            background: white;
        }

        .about-wrapper {
            max-width: 1200px;

            margin: auto;

            display: grid;

            grid-template-columns: 1fr 1fr;

            gap: 70px;

            align-items: center;
        }

        .about-image {
            min-height: 430px;

            border-radius: 25px;

            position: relative;

            background:
                linear-gradient(
                    rgba(2, 132, 199, 0.18),
                    rgba(15, 23, 42, 0.2)
                ),
                url('https://images.unsplash.com/photo-1606811971618-4486d14f3f99?auto=format&fit=crop&q=85')
                center/cover;

            box-shadow: 0 25px 55px rgba(15, 23, 42, 0.15);
        }

        .about-badge {
            position: absolute;

            bottom: 25px;
            right: -25px;

            background: white;

            padding: 20px 25px;

            border-radius: 16px;

            box-shadow: 0 15px 35px rgba(15, 23, 42, 0.14);
        }

        .about-badge strong {
            display: block;

            color: var(--primary);

            font-size: 24px;
        }

        .about-badge span {
            color: var(--gray);

            font-size: 12px;
        }

        .about-content .section-label {
            text-align: left;
        }

        .about-content h2 {
            font-size: 38px;

            line-height: 1.25;

            margin-bottom: 20px;
        }

        .about-content > p {
            color: var(--gray);

            font-size: 14px;

            margin-bottom: 25px;
        }

        .info-list {
            list-style: none;
        }

        .info-list li {
            display: flex;
            align-items: center;

            gap: 12px;

            margin-bottom: 14px;

            font-size: 14px;
            font-weight: 600;
        }

        .info-list i {
            width: 23px;
            height: 23px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            color: var(--success);

            background: #dcfce7;

            font-size: 12px;
        }

        /* ================================
           CONTACT
        ================================= */

        .contact-section {
            padding: 100px 8%;

            background:
                linear-gradient(
                    135deg,
                    #eff6ff,
                    #f8fafc
                );
        }

        .contact-cards {
            max-width: 1150px;

            margin: auto;

            display: grid;

            grid-template-columns: repeat(3, 1fr);

            gap: 25px;
        }

        .contact-card {
            padding: 32px 25px;

            text-align: center;

            background: white;

            border-radius: 18px;

            border: 1px solid #e2e8f0;

            transition: 0.3s ease;
        }

        .contact-card:hover {
            transform: translateY(-7px);

            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.08);
        }

        .contact-icon {
            width: 60px;
            height: 60px;

            margin: 0 auto 18px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            background: var(--light-blue);

            color: var(--primary);

            font-size: 22px;
        }

        .contact-card h3 {
            margin-bottom: 10px;

            font-size: 18px;
        }

        .contact-card p {
            color: var(--gray);

            font-size: 13px;
        }

        /* ================================
           FOOTER
        ================================= */

        footer {
            background: #020617;

            color: #94a3b8;

            padding: 45px 8% 25px;

            text-align: center;
        }

        .footer-logo {
            display: inline-flex;

            align-items: center;

            gap: 10px;

            color: white;

            font-size: 20px;

            font-weight: 700;

            margin-bottom: 12px;
        }

        .footer-logo i {
            color: var(--accent);
        }

        footer p {
            font-size: 13px;
        }

        .footer-line {
            width: 70px;

            height: 3px;

            margin: 20px auto;

            border-radius: 5px;

            background: linear-gradient(
                90deg,
                var(--primary),
                var(--accent)
            );
        }

        /* ================================
           RESPONSIVE
        ================================= */

        @media (max-width: 900px) {

            .nav-links {
                gap: 16px;
            }

            .about-wrapper {
                grid-template-columns: 1fr;

                gap: 45px;
            }

            .about-image {
                min-height: 350px;
            }

            .contact-cards {
                grid-template-columns: 1fr;
            }

        }

        @media (max-width: 700px) {

            nav {
                padding: 14px 5%;
            }

            .logo {
                font-size: 18px;
            }

            .logo-icon {
                width: 40px;
                height: 40px;
            }

            .nav-links {
                display: none;
            }

            .hero {
                min-height: 650px;

                padding: 80px 6%;
            }

            .hero h1 {
                font-size: 42px;

                letter-spacing: -1px;
            }

            .hero p {
                font-size: 14px;
            }

            .stats {
                width: 90%;

                grid-template-columns: 1fr;

                margin-top: -30px;
            }

            .stat {
                border-right: none;

                border-bottom: 1px solid #e2e8f0;
            }

            .stat:last-child {
                border-bottom: none;
            }

            .section,
            .about-section,
            .contact-section {
                padding: 70px 6%;
            }

            .about-content h2 {
                font-size: 30px;
            }

            .about-badge {
                right: 15px;
            }

        }

        /* ================================
           ANIMATION
        ================================= */

        @keyframes float {

            0%, 100% {
                transform: translateY(0);
            }

            50% {
                transform: translateY(-8px);
            }

        }

        .hero-badge {
            animation: float 4s ease-in-out infinite;
        }

    </style>
</head>

<body>

<!-- ================================
     NAVIGATION
================================= -->

<nav>

    <a href="index.jsp" class="logo">

        <span class="logo-icon">
            <i class="fa-solid fa-tooth"></i>
        </span>

        <span>Sunrise Dental</span>

    </a>

    <ul class="nav-links">

        <li>
            <a href="index.jsp">Home</a>
        </li>

        <li>
            <a href="#services">Services</a>
        </li>

        <li>
            <a href="#about">About Us</a>
        </li>

        <li>
            <a href="#contact">Contact</a>
        </li>

        <li>
            <a href="login.jsp" class="btn-login">
                <i class="fa-solid fa-right-to-bracket"></i>
                Staff Login
            </a>
        </li>

    </ul>

</nav>


<!-- ================================
     HERO SECTION
================================= -->

<section class="hero">

    <div class="hero-content">

        <div class="hero-badge">
            <i class="fa-solid fa-shield-heart"></i>
            Trusted Dental Care in Colombo
        </div>

        <h1>
            Your Smile,
            <span>Our Priority.</span>
        </h1>

        <p>
            Comprehensive dental care and computerized patient
            appointment management system in Colombo.
            Experience precision, hygiene, comfort and
            professional treatment.
        </p>

        <div class="hero-buttons">

            <a href="login.jsp" class="hero-btn">
                <i class="fa-solid fa-calendar-check"></i>
                Book Appointment
            </a>

            <a href="#services" class="hero-btn hero-btn-outline">
                <i class="fa-solid fa-tooth"></i>
                Explore Services
            </a>

        </div>

    </div>

</section>


<!-- ================================
     STATS
================================= -->

<section class="stats">

    <div class="stat">

        <i class="fa-solid fa-user-doctor"></i>

        <h3>10+</h3>

        <p>Expert Dentists</p>

    </div>

    <div class="stat">

        <i class="fa-solid fa-face-smile"></i>

        <h3>5K+</h3>

        <p>Happy Patients</p>

    </div>

    <div class="stat">

        <i class="fa-solid fa-calendar-check"></i>

        <h3>24/7</h3>

        <p>Appointment Management</p>

    </div>

</section>


<!-- ================================
     SERVICES
================================= -->

<section id="services" class="section">

    <div class="section-title">

        <div class="section-label">
            Our Services
        </div>

        <h2>
            Specialized Dental Treatments
        </h2>

        <p>
            High-quality dental procedures provided
            by experienced dental professionals.
        </p>

    </div>


    <div class="services-grid">


        <!-- Service 01 -->

        <div class="service-card">

            <div class="service-icon">
                <i class="fa-solid fa-pump-soap"></i>
            </div>

            <h3>
                Teeth Cleaning & Scaling
            </h3>

            <p>
                Removal of plaque and tartar deposits
                to keep teeth clean and help prevent
                gum diseases.
            </p>

            <span class="price-tag">
                LKR 5,000.00
            </span>

        </div>


        <!-- Service 02 -->

        <div class="service-card">

            <div class="service-icon">
                <i class="fa-solid fa-teeth"></i>
            </div>

            <h3>
                Dental Filling
            </h3>

            <p>
                Restoration of damaged or decayed teeth
                using modern tooth-colored materials.
            </p>

            <span class="price-tag">
                LKR 4,000.00
            </span>

        </div>


        <!-- Service 03 -->

        <div class="service-card">

            <div class="service-icon">
                <i class="fa-solid fa-tooth"></i>
            </div>

            <h3>
                Root Canal Treatment
            </h3>

            <p>
                Advanced nerve treatment to save infected
                or highly damaged teeth with professional care.
            </p>

            <span class="price-tag">
                LKR 25,000.00
            </span>

        </div>


        <!-- Service 04 -->

        <div class="service-card">

            <div class="service-icon">
                <i class="fa-solid fa-notes-medical"></i>
            </div>

            <h3>
                Tooth Extraction
            </h3>

            <p>
                Safe and sterile extraction procedures
                performed under professional supervision.
            </p>

            <span class="price-tag">
                LKR 6,000.00
            </span>

        </div>


    </div>

</section>


<!-- ================================
     ABOUT
================================= -->

<section id="about" class="about-section">

    <div class="about-wrapper">


        <div class="about-image">

            <div class="about-badge">

                <strong>100%</strong>

                <span>
                    Patient-focused care
                </span>

            </div>

        </div>


        <div class="about-content">

            <div class="section-label">
                About Sunrise Dental
            </div>

            <h2>
                Modern Dentistry.
                <br>
                Exceptional Care.
            </h2>

            <p>
                Sunrise Dental Clinic is a premier private
                dental hospital located in Colombo. Our
                computerized management system helps prevent
                double bookings, reduce waiting times and
                maintain organized patient records.
            </p>


            <ul class="info-list">

                <li>
                    <i class="fa-solid fa-check"></i>
                    Highly Qualified & Experienced Dentists
                </li>

                <li>
                    <i class="fa-solid fa-check"></i>
                    Automated & Precise Appointment Scheduling
                </li>

                <li>
                    <i class="fa-solid fa-check"></i>
                    Modern Medical Equipment
                </li>

                <li>
                    <i class="fa-solid fa-check"></i>
                    Transparent Billing System
                </li>

                <li>
                    <i class="fa-solid fa-check"></i>
                    Instant Receipt Generation
                </li>

            </ul>

        </div>

    </div>

</section>


<!-- ================================
     CONTACT
================================= -->

<section id="contact" class="contact-section">

    <div class="section-title">

        <div class="section-label">
            Contact Us
        </div>

        <h2>
            Visit Our Clinic
        </h2>

        <p>
            We are here to provide professional dental
            care. Reach out to schedule your clinic visit.
        </p>

    </div>


    <div class="contact-cards">


        <!-- Address -->

        <div class="contact-card">

            <div class="contact-icon">
                <i class="fa-solid fa-location-dot"></i>
            </div>

            <h3>
                Our Address
            </h3>

            <p>
                No. 123, Galle Road,
                <br>
                Colombo 03, Sri Lanka
            </p>

        </div>


        <!-- Phone -->

        <div class="contact-card">

            <div class="contact-icon">
                <i class="fa-solid fa-phone"></i>
            </div>

            <h3>
                Contact Number
            </h3>

            <p>
                +94 11 234 5678
                <br>
                +94 77 123 4567
            </p>

        </div>


        <!-- Opening Hours -->

        <div class="contact-card">

            <div class="contact-icon">
                <i class="fa-solid fa-clock"></i>
            </div>

            <h3>
                Opening Hours
            </h3>

            <p>
                Mon - Sat: 8:30 AM - 7:30 PM
                <br>
                Sunday: Closed
            </p>

        </div>


    </div>

</section>


<!-- ================================
     FOOTER
================================= -->

<footer>

    <div class="footer-logo">

        <i class="fa-solid fa-tooth"></i>

        Sunrise Dental Clinic

    </div>

    <div class="footer-line"></div>

    <p>
        © 2026 Sunrise Dental Clinic.
        All Rights Reserved.
        | Computerized Management System
    </p>

</footer>


</body>
</html>
```
