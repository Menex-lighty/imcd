import traci
import time
import math
import csv
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.animation import FuncAnimation
import matplotlib.dates as mdates
from matplotlib.colors import LinearSegmentedColormap

# Sumo configuration
sumo_cmd = ["sumo", "-c", "Indore2.sumocfg"]
traci.start(sumo_cmd)

# Vehicle Parameters (make sure the vehicle IDs here match the ones in your simulation)
VEHICLE_PARAMS = {
    "0": {'tire_circumference': 2.1, 'fuel_efficiency': 15.0, 'oil_change_interval': 10000, 'tire_lifespan': 50000, 'fuel_tank_capacity': 50},
    # Add more vehicle IDs and parameters as needed
}

# Function to calculate distance between two GPS coordinates
def calculate_distance(prev_loc, curr_loc):
    return math.sqrt((curr_loc[0] - prev_loc[0])**2 + (curr_loc[1] - prev_loc[1])**2) / 1000  # Convert to km

# Functions to calculate tire wear and fuel consumption
def calculate_tire_wear(distance, avg_speed, params):
    if 'tire_circumference' not in params:
        raise ValueError("Missing 'tire_circumference' in vehicle parameters.")
    tire_wear_factor = (1 + (avg_speed / 100)**2)
    return (distance * 1000 / params['tire_circumference']) * tire_wear_factor  # Convert distance to meters

def calculate_fuel_consumption(distance, avg_speed, params):
    if 'fuel_efficiency' not in params:
        raise ValueError("Missing 'fuel_efficiency' in vehicle parameters.")
    fuel_consumption_factor = (1 + (avg_speed / 80)**2)
    return (distance / params['fuel_efficiency']) * fuel_consumption_factor

# Create CSV file and write headers
csv_file_path = "vehicle_tracking.csv"
with open(csv_file_path, "w", newline="") as csvfile:
    fieldnames = [
        "vehicle_id", "timestamp", "latitude", "longitude", "distance_travelled",
        "average_speed", "tire_wear", "fuel_consumed", "oil_change_due_days",
        "days_till_tire_change", "trips_before_refuel", "days_till_oil_change_due"
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    # Store previous data for calculations
    previous_vehicle_data = {}

    # Simulation loop
    step = 0  # Step counter for debugging
    start_time = time.time()  # Record start time

    while traci.simulation.getMinExpectedNumber() > 0:
        traci.simulationStep()
        for veh_id in traci.vehicle.getIDList():
            try:
                if veh_id not in previous_vehicle_data:
                    previous_vehicle_data[veh_id] = {
                        'distance_travelled': 0,
                        'total_time': 0,
                        'previous_location': None,
                        'previous_time': None,
                        'total_tire_wear': 0,
                        'total_fuel_consumed': 0
                    }

                # Fetch current vehicle data from SUMO
                current_location = traci.vehicle.getPosition(veh_id)
                current_speed = traci.vehicle.getSpeed(veh_id) * 3.6  # Convert m/s to km/h
                current_time = time.time()

                prev_data = previous_vehicle_data[veh_id]
                if prev_data['previous_location'] and prev_data['previous_time']:
                    distance_increment = calculate_distance(prev_data['previous_location'], current_location)
                    distance_travelled = prev_data['distance_travelled'] + distance_increment
                    time_increment = current_time - prev_data['previous_time']
                    total_time = prev_data['total_time'] + time_increment
                else:
                    distance_travelled = 0
                    total_time = 0

                params = VEHICLE_PARAMS.get(veh_id, {})
                if 'tire_circumference' not in params or 'fuel_efficiency' not in params or 'tire_lifespan' not in params or 'fuel_tank_capacity' not in params:
                    print(f"Missing parameters for vehicle {veh_id}, skipping calculations.")
                    continue

                avg_speed = distance_travelled / (total_time / 3600) if total_time > 0 else 0  # Convert total_time to hours
                tire_wear = calculate_tire_wear(distance_travelled, avg_speed, params)
                fuel_consumed = calculate_fuel_consumption(distance_travelled, avg_speed, params)
                oil_change_due = params.get('oil_change_interval', 0) - (distance_travelled * 1000)  # Convert to meters

                # Update cumulative values
                total_tire_wear = prev_data['total_tire_wear'] + tire_wear
                total_fuel_consumed = prev_data['total_fuel_consumed'] + fuel_consumed

                # Calculate additional metrics
                days_till_tire_change = (params['tire_lifespan'] - total_tire_wear) / (distance_travelled / (total_time / 86400)) if total_time > 0 else float('inf')  # Convert total_time to days
                trips_before_refuel = (params['fuel_tank_capacity'] / fuel_consumed) * distance_travelled if fuel_consumed > 0 else float('inf')
                days_till_oil_change_due = oil_change_due / (distance_travelled / (total_time / 86400)) if total_time > 0 else float('inf')  # Convert total_time to days

                # Update previous data
                previous_vehicle_data[veh_id] = {
                    'distance_travelled': distance_travelled,
                    'total_time': total_time,
                    'previous_location': current_location,
                    'previous_time': current_time,  # Update previous time
                    'total_tire_wear': total_tire_wear,
                    'total_fuel_consumed': total_fuel_consumed
                }

                # Write data to CSV file
                writer.writerow({
                    "vehicle_id": veh_id,
                    "timestamp": time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(current_time)),
                    "latitude": current_location[0],
                    "longitude": current_location[1],
                    "distance_travelled": round(distance_travelled, 2),
                    "average_speed": round(avg_speed, 2),
                    "tire_wear": round(tire_wear, 2),
                    "fuel_consumed": round(fuel_consumed, 2),
                    "oil_change_due_days": round(oil_change_due / 1000, 2),  # Convert to km and add "days" suffix
                    "days_till_tire_change": f"{round(days_till_tire_change, 2) if days_till_tire_change != float('inf') else 'N/A'} days",
                    "trips_before_refuel": round(trips_before_refuel, 2) if trips_before_refuel != float('inf') else "N/A",
                    "days_till_oil_change_due": f"{round(days_till_oil_change_due, 2) if days_till_oil_change_due != float('inf') else 'N/A'} days"
                })

            except ValueError as e:
                print(f"Error processing vehicle {veh_id}: {e}")
            except traci.exceptions.TraCIException as e:
                print(f"Error processing vehicle {veh_id}: {e}")

        step += 1
        if step % 100 == 0:
            print(f"Processed step {step}")

        # Check for timeout (e.g., 1 hour)
        if time.time() - start_time > 20:
            print("Timeout reached, stopping simulation.")
            break

    traci.close()

# Read the CSV file
df = pd.read_csv(csv_file_path)

# Convert timestamp to datetime format
df['timestamp'] = pd.to_datetime(df['timestamp'])

# Enhanced plotting function
def plot_vehicle_data(vehicle_id, df):
    vehicle_data = df[df['vehicle_id'] == vehicle_id]

    plt.style.use('dark_background')

    # Create a custom colormap
    colors = ['#FF00FF', '#00FFFF', '#FFFF00']  # Magenta, Cyan, Yellow
    n_bins = 100
    cmap = LinearSegmentedColormap.from_list('custom', colors, N=n_bins)

    fig, axes = plt.subplots(3, 1, figsize=(12, 18), sharex=True, facecolor='#1C1C1C')
    fig.suptitle(f'Vehicle {vehicle_id} - Performance Metrics Over Time', fontsize=20, color='white', fontweight='bold')

    # Distance Travelled
    sns.lineplot(x='timestamp', y='distance_travelled', data=vehicle_data, ax=axes[0], linewidth=2, color='#FF00FF')
    axes[0].set_ylabel('Distance (km)', fontsize=12, color='white')
    axes[0].set_title('Distance Travelled', fontsize=16, color='white', fontweight='bold')
    axes[0].fill_between(vehicle_data['timestamp'], vehicle_data['distance_travelled'], alpha=0.3, color='#FF00FF')

    # Tire Wear
    sns.lineplot(x='timestamp', y='tire_wear', data=vehicle_data, ax=axes[1], linewidth=2, color='#00FFFF')
    axes[1].set_ylabel('Tire Wear', fontsize=12, color='white')
    axes[1].set_title('Tire Wear', fontsize=16, color='white', fontweight='bold')
    axes[1].fill_between(vehicle_data['timestamp'], vehicle_data['tire_wear'], alpha=0.3, color='#00FFFF')

    # Fuel Consumed
    sns.lineplot(x='timestamp', y='fuel_consumed', data=vehicle_data, ax=axes[2], linewidth=2, color='#FFFF00')
    axes[2].set_ylabel('Fuel Consumed (liters)', fontsize=12, color='white')
    axes[2].set_title('Fuel Consumed', fontsize=16, color='white', fontweight='bold')
    axes[2].fill_between(vehicle_data['timestamp'], vehicle_data['fuel_consumed'], alpha=0.3, color='#FFFF00')

    for ax in axes:
        ax.grid(True, linestyle='--', alpha=0.7)
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_color('#888888')
        ax.spines['left'].set_color('#888888')
        ax.tick_params(colors='white')

    plt.xlabel('Timestamp', fontsize=12, color='white')
    plt.xticks(rotation=45)
    
    # Format x-axis to show dates nicely
    locator = mdates.AutoDateLocator()
    formatter = mdates.ConciseDateFormatter(locator)
    axes[2].xaxis.set_major_locator(locator)
    axes[2].xaxis.set_major_formatter(formatter)

    plt.tight_layout()
    
    # Add animation
    scatter_points = []
    for ax in axes:
        scatter, = ax.plot([], [], 'o', color='white', markersize=8)
        scatter_points.append(scatter)

    def animate(i):
        for j, metric in enumerate(['distance_travelled', 'tire_wear', 'fuel_consumed']):
            x = vehicle_data['timestamp'].iloc[:i]
            y = vehicle_data[metric].iloc[:i]
            scatter_points[j].set_data(x, y)
        return scatter_points

    anim = FuncAnimation(fig, animate, frames=len(vehicle_data), interval=50, blit=True, repeat=False)

    plt.show()

# List of vehicle IDs to plot
vehicle_ids = df['vehicle_id'].unique()

# Plot data for each vehicle
for vehicle_id in vehicle_ids:
    plot_vehicle_data(vehicle_id, df)
