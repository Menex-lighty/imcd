import random
import xml.etree.ElementTree as ET

def generate_routes(network_file, output_file, num_vehicles=10000):
    try:
        tree = ET.parse(network_file)
        root = tree.getroot()
    except FileNotFoundError:
        print(f"Error: Network file '{network_file}' not found.")
        return  # Exit the function gracefully

    edges = [edge.get('id') for edge in root.findall('edge') if 'function' not in edge.attrib]

    if not edges:
        print(f"Error: No suitable edges found in '{network_file}'.")
        return 

    with open(output_file, 'w') as routes:
        routes.write('<routes>\n')
        routes.write('    <vType id="car" accel="0.8" decel="4.5" sigma="0.5" length="5" maxSpeed="70"/>\n')

        for i in range(num_vehicles):
            from_edge = random.choice(edges)
            to_edge = random.choice(edges)
            while to_edge == from_edge:
                to_edge = random.choice(edges)

            routes.write(f'    <vehicle id="veh{i}" type="car" depart="0">\n')
            routes.write(f'        <route edges="{from_edge} {to_edge}"/>\n')
            routes.write('    </vehicle>\n')

        routes.write('</routes>\n')

if __name__ == "__main__":
    network_file = 'indore2.net.xml'  # Assume it's in the same directory
    output_file = 'random_routes2.rou.xml'

    generate_routes(network_file, output_file)

