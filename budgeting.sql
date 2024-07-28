-- Create the Budgeting database
CREATE DATABASE budgeting;

-- Connect to the Budgeting database
\c budgeting;

-- Create the Assets table
CREATE TABLE Assets (
    asset_id CHAR(10) PRIMARY KEY,
    asset_name VARCHAR(100),
    asset_type VARCHAR(50),
    location VARCHAR(100),
    department_id CHAR(10),
    purchase_date DATE,
    last_maintenance_date DATE,
    iot_device_id CHAR(10)
);

-- Create the Departments table
CREATE TABLE Departments (
    asset_id CHAR(10) PRIMARY KEY,
    department_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(15)
);

-- Create the MaintenanceTasks table
CREATE TABLE MaintenanceTasks (
    asset_id CHAR(10) PRIMARY KEY,
    task_description TEXT,
    due_date DATE,
    status VARCHAR(20),
    completion_date DATE
);

-- Create the Budgets table
CREATE TABLE Budgets (
    asset_id CHAR(10) PRIMARY KEY,
    department_id CHAR(10),
    year INTEGER,
    allocated_amount NUMERIC(10, 2),
    spent_amount NUMERIC(10, 2)
);

-- Create the Notifications table
CREATE TABLE Notifications (
    asset_id CHAR(10) PRIMARY KEY,
    department_id CHAR(10),
    message TEXT,
    timestamp TIMESTAMP,
    channel VARCHAR(10)
);


-- Create a function to generate asset_id
CREATE OR REPLACE FUNCTION generate_asset_id(table_name TEXT, seq_num INTEGER) RETURNS CHAR(10) AS $$
BEGIN
    RETURN SUBSTRING(table_name, 1, 2) || LPAD(seq_num::TEXT, 8, '0');
END;
$$ LANGUAGE plpgsql;
