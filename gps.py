import gpsd
import time
import math
import os
import asyncio
import aiohttp
import psycopg2
from psycopg2 import pool, sql, OperationalError
from dotenv import load_dotenv
from flask import Flask, render_template, jsonify, request

# Load environment variables from .env file
load_dotenv()

# Flask app setup
app = Flask(__name__)

# PostgreSQL Setup with connection pooling
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

connection_pool = pool.SimpleConnectionPool(
    1, 20, dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD, host=DB_HOST, port=DB_PORT
)

# Create table if it doesn't exist
def create_table():
    conn = connection_pool.getconn()
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS vehicle_tracking (
        id SERIAL PRIMARY KEY,
        vehicle_id INT,
        timestamp TIMESTAMP,
        latitude NUMERIC,
        longitude NUMERIC,
        distance_travelled NUMERIC,
        average_speed NUMERIC,
        tire_wear NUMERIC,
        fuel_consumed NUMERIC,
        oil_change_due NUMERIC
    )
    """)
    conn.commit()
    cur.close()
    connection_pool.putconn(conn)

create_table()

# Vehicle Parameters (Adjust these)
VEHICLE_PARAMS = {
    1: {'tire_circumference': 2.1, 'fuel_efficiency': 15.0, 'oil_change_interval': 10000},
    # Add more vehicles as needed
}

# GPS Setup
gpsd.connect()

def get_connection():
    return connection_pool.getconn()

def release_connection(conn):
    connection_pool.putconn(conn)

def get_gps_data():
    """Fetch the current GPS data."""
    return gpsd.get_current()

def calculate_distance(prev_loc, curr_loc):
    """Calculate the distance between two GPS coordinates."""
    return gpsd.distance(*prev_loc, *curr_loc)

def calculate_tire_wear(distance, avg_speed, vehicle_id):
    """Calculate tire wear based on distance and average speed."""
    params = VEHICLE_PARAMS[vehicle_id]
    tire_wear_factor = (1 + (avg_speed / 100)**2)
    return (distance / params['tire_circumference']) * tire_wear_factor

def calculate_fuel_consumption(distance, avg_speed, vehicle_id):
    """Calculate fuel consumption based on distance and average speed."""
    params = VEHICLE_PARAMS[vehicle_id]
    fuel_consumption_factor = (1 + (avg_speed / 80)**2)
    return (distance / params['fuel_efficiency']) * fuel_consumption_factor

def insert_data_to_db(vehicle_id, timestamp, lat, lon, dist, avg_speed, tire_wear, fuel_consumed, oil_change_due):
    """Insert tracking data into the PostgreSQL database."""
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(
            sql.SQL("""
            INSERT INTO vehicle_tracking (vehicle_id, timestamp, latitude, longitude, distance_travelled, average_speed, tire_wear, fuel_consumed, oil_change_due)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """),
            (vehicle_id, timestamp, lat, lon, dist, avg_speed, tire_wear, fuel_consumed, oil_change_due)
        )
        conn.commit()
    except OperationalError as db_error:
        print(f"Database error: {db_error}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    finally:
        cur.close()
        release_connection(conn)

@app.route('/track/<int:vehicle_id>', methods=['GET'])
def track_vehicle(vehicle_id):
    packet = get_gps_data()
    if packet.mode >= 2:
        current_location = (packet.lat, packet.lon)
        current_speed = packet.hspeed * 3.6  # Convert m/s to km/h
        current_time = time.time()

        if 'previous_location' in request.args and 'previous_time' in request.args:
            previous_location = (float(request.args['previous_location'].split(',')[0]), float(request.args['previous_location'].split(',')[1]))
            previous_time = float(request.args['previous_time'])
            distance_travelled = float(request.args['distance_travelled'])
            total_time = float(request.args['total_time'])
        else:
            previous_location = None
            previous_time = None
            distance_travelled = 0
            total_time = 0

        if previous_location:
            distance_increment = calculate_distance(previous_location, current_location)
            distance_travelled += distance_increment
            total_time += current_time - previous_time

        previous_location = current_location
        previous_time = current_time

        average_speed = distance_travelled / total_time if total_time > 0 else 0
        tire_wear = calculate_tire_wear(distance_travelled, average_speed, vehicle_id)
        fuel_consumed = calculate_fuel_consumption(distance_travelled, average_speed, vehicle_id)
        oil_change_due = VEHICLE_PARAMS[vehicle_id]['oil_change_interval'] - distance_travelled

        # Insert data into PostgreSQL
        insert_data_to_db(
            vehicle_id=vehicle_id,
            timestamp=time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(current_time)),
            lat=current_location[0],
            lon=current_location[1],
            dist=round(distance_travelled, 2),
            avg_speed=round(average_speed, 2),
            tire_wear=round(tire_wear),
            fuel_consumed=round(fuel_consumed, 2),
            oil_change_due=round(oil_change_due, 2)
        )

        return jsonify({
            "Distance Travelled": round(distance_travelled, 2),
            "Average Speed": round(average_speed, 2),
            "Tire Rotations": round(tire_wear),
            "Fuel Consumed": round(fuel_consumed, 2),
            "Oil Change Due in": round(oil_change_due, 2),
            "previous_location": f"{current_location[0]},{current_location[1]}",
            "previous_time": current_time,
            "distance_travelled": distance_travelled,
            "total_time": total_time
        })

    return jsonify({"error": "No GPS fix"})

async def fetch_gps_data(vehicle_id):
    # Simulate fetching GPS data asynchronously
    async with aiohttp.ClientSession() as session:
        async with session.get(f'http://gps_service/{vehicle_id}') as response:
            return await response.json()

async def process_vehicle_data(vehicle_id):
    gps_data = await fetch_gps_data(vehicle_id)
    if gps_data:
        current_location = (gps_data['lat'], gps_data['lon'])
        current_speed = gps_data['speed']
        current_time = time.time()

        if 'previous_location' in gps_data and 'previous_time' in gps_data:
            previous_location = (gps_data['previous_location'][0], gps_data['previous_location'][1])
            previous_time = gps_data['previous_time']
            distance_travelled = gps_data['distance_travelled']
            total_time = gps_data['total_time']
        else:
            previous_location = None
            previous_time = None
            distance_travelled = 0
            total_time = 0

        if previous_location:
            distance_increment = calculate_distance(previous_location, current_location)
            distance_travelled += distance_increment
            total_time += current_time - previous_time

        previous_location = current_location
        previous_time = current_time

        average_speed = distance_travelled / total_time if total_time > 0 else 0
        tire_wear = calculate_tire_wear(distance_travelled, average_speed, vehicle_id)
        fuel_consumed = calculate_fuel_consumption(distance_travelled, average_speed, vehicle_id)
        oil_change_due = VEHICLE_PARAMS[vehicle_id]['oil_change_interval'] - distance_travelled

        # Insert data into PostgreSQL
        insert_data_to_db(
            vehicle_id=vehicle_id,
            timestamp=time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(current_time)),
            lat=current_location[0],
            lon=current_location[1],
            dist=round(distance_travelled, 2),
            avg_speed=round(average_speed, 2),
            tire_wear=round(tire_wear),
            fuel_consumed=round(fuel_consumed, 2),
            oil_change_due=round(oil_change_due, 2)
        )

async def main():
    vehicle_ids = [1, 2, 3, 4, 5]  # List of vehicle IDs
    tasks = [process_vehicle_data(vehicle_id) for vehicle_id in vehicle_ids]
    await asyncio.gather(*tasks)

if __name__ == '__main__':
    asyncio.run(main())
    app.run(debug=True)
