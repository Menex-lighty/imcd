-- Create the Asset Management database
CREATE DATABASE asset_management;

-- Connect to the Asset Management database
\c asset_management;

-- Create the Vehicles table
CREATE TABLE Vehicles (
    asset_id CHAR(10) PRIMARY KEY,
    vehicle_type VARCHAR(50),
    distance_travelled INTEGER,
    average_fuel INTEGER,
    last_service_date DATE,
    driver_name VARCHAR(100),
    driver_id CHAR(10) UNIQUE
);

-- Create the Parks table
CREATE TABLE Parks (
    asset_id CHAR(10) PRIMARY KEY,
    worker_name VARCHAR(100),
    worker_id CHAR(10) UNIQUE,
    salary NUMERIC(10, 2),
    last_maintenance_date DATE,
    budget_provided NUMERIC(10, 2)
);

-- Create the Buildings table
CREATE TABLE Buildings (
    asset_id CHAR(10) PRIMARY KEY,
    building_name VARCHAR(100) UNIQUE,
    last_maintenance DATE,
    maintenance_avg_cost NUMERIC(10, 2),
    water_bill NUMERIC(10, 2),
    electricity_bill NUMERIC(10, 2),
    budget_provided NUMERIC(10, 2)
);

-- Create the Roads table
CREATE TABLE Roads (
    asset_id CHAR(10) PRIMARY KEY,
    road_name VARCHAR(100) UNIQUE,
    road_length NUMERIC(10, 2),
    last_maintenance DATE,
    maintenance_avg_cost NUMERIC(10, 2),
    last_complaint DATE,
    last_complaint_resolved DATE,
    budget_provided NUMERIC(10, 2)
);

-- Create the Monuments table
CREATE TABLE Monuments (
    asset_id CHAR(10) PRIMARY KEY,
    monument_name VARCHAR(100) UNIQUE,
    monument_length NUMERIC(10, 2),
    last_maintenance DATE,
    maintenance_avg_cost NUMERIC(10, 2),
    last_complaint DATE,
    last_complaint_resolved DATE,
    budget_provided NUMERIC(10, 2),
    upcoming_maintenance DATE
);




-- Create a function to generate asset_id
CREATE OR REPLACE FUNCTION generate_asset_id(table_name TEXT, seq_num INTEGER) RETURNS CHAR(10) AS $$
BEGIN
    RETURN SUBSTRING(table_name, 1, 2) || LPAD(seq_num::TEXT, 8, '0');
END;
$$ LANGUAGE plpgsql;
