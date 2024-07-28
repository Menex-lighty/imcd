# imcd
Asset management software for indore municipal corporation
# Municipal Asset Management System

[![GitHub License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This project aims to streamline the management of municipal vehicles by providing real-time tracking, maintenance logging, and citizen feedback mechanisms. The system utilizes Flutter for the cross-platform app, PostgreSQL for data storage, and Firebase for real-time updates and cloud services.

## Features

*  **Real-time Vehicle Tracking:** Visualize vehicle locations and status on a map using Google Maps integration.

*  **Maintenance Logging:** Drivers can log maintenance activities and report issues directly through the app.

*  **Admin Dashboard:** Administrators gain insights through reports, schedule maintenance, and manage resources efficiently.

*  **Citizen Feedback:** A platform for citizens to provide feedback and report concerns about vehicles or routes.

*  **SUMO Simulation:** A large-scale simulation (10,000 vehicles) using SUMO demonstrates the system's effectiveness in a realistic environment.

## Tech Stack

*  **Frontend:** Flutter
*  **Backend:** PostgreSQL, Firebase (Realtime Database, Cloud Functions, Authentication, Cloud Messaging, Hosting)
*  **Mapping:** Google Maps, Open Street Maps
*  **Simulation:** SUMO

## Getting Started

1. **Prerequisites:**
  *  Flutter development environment
  *  PostgreSQL database server
  *  Firebase project
  *  Google Maps API key
2. **Installation:**
  *  Clone the repository: `git clone https://github.com/<your-username>/<your-repo-name>.git`
  *  Set up environment variables:
      *   `FIREBASE_API_KEY`
      *   `FIREBASE_AUTH_DOMAIN`
      *   `FIREBASE_PROJECT_ID`
      *   `FIREBASE_STORAGE_BUCKET`
      *   `FIREBASE_MESSAGING_SENDER_ID`
      *   `FIREBASE_APP_ID`
      *   `FIREBASE_MEASUREMENT_ID`
      *   `DATABASE_URL`
  *  Run `flutter pub get` to install dependencies.
3. **Running the App:**
  *  Start the PostgreSQL server and create the required database schema.
  *  Connect the app to your Firebase project and database.
  *  Run the Flutter app: `flutter run`

## Project Structure

*  `/lib`: Contains Flutter source code.
  *  `/widgets`: Reusable UI components.
  *  `/services`: Logic for data fetching, Firebase interaction, etc.
*  `/database`: PostgreSQL database scripts (schema creation, initial data).


## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines on how to contribute.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

*  This project was inspired by the need for efficient municipal asset management.
*  Special thanks to the Flutter, PostgreSQL, and Firebase communities for their excellent tools and resources.

## Contact

For any questions or feedback, please contact Rishabh Sinha at rishabhsinha1712@gmail.com.
