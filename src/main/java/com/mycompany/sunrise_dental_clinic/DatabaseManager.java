package com.mycompany.sunrise_dental_clinic;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseManager {
    private static DatabaseManager instance;
    private Connection connection;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/sunrise_dental?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root"; // Workbench Username
    private static final String DB_PASS = ""; // Workbench Password

    private DatabaseManager() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static synchronized DatabaseManager getInstance() {
        if (instance == null) {
            instance = new DatabaseManager();
        }
        return instance;
    }

    public Connection getConnection() {
        return connection;
    }
}