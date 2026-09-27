# Bhoomi Setu Field Officer (FO) App

Bhoomi Setu Field Officer is a robust, **offline-first** Flutter application designed for on-ground field verification and data collection. It empowers field officers to conduct land surveys, verify boundaries, capture evidence, and record asset details (structures, vegetation) even in areas with zero network connectivity.

## 🚀 Key Features

*   **Offline-First Architecture**: Built on a local SQLite database (Drift). All tasks, visits, and evidence are stored locally first.
*   **Robust Sync Engine**: A dedicated background sync queue intelligently monitors network connectivity (`connectivity_plus`) and synchronizes pending field data, images, and forms to the remote server automatically once online.
*   **Geolocation & Mapping**: Integrated `flutter_map` with WKT parsing for rendering parcel geometries. Enforces GPS-based location validation (`geolocator`) during field visits and evidence capture.
*   **Multimedia Evidence**: In-app camera module to capture geo-tagged, timestamped images of the land, documents, structures, and vegetation.
*   **Comprehensive Data Collection**: Specialized wizards for capturing specific land use metrics:
    *   **Structures**: Type, area, construction, and condition.
    *   **Vegetation**: Species, count, crop type, and area.
    *   **Documents**: Local file picking and safe storage.
*   **Secure & Performant**: Implements `flutter_secure_storage` for session management and token handling. Reactive state management powered by `Riverpod`.

## 🛠 Tech Stack & Libraries

*   **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.13.0)
*   **State Management**: `flutter_riverpod`
*   **Local Database**: `drift` (SQLite3)
*   **Networking & Sync**: `http`, `connectivity_plus`
*   **Mapping & Location**: `flutter_map`, `latlong2`, `geolocator`
*   **Hardware/Device APIs**: `camera`, `file_picker`, `permission_handler`
*   **Storage**: `flutter_secure_storage`, `shared_preferences`

## 📂 Project Structure

```text
lib/
├── core/
│   ├── config/       # API and Environment configs
│   ├── database/     # Drift local SQLite schemas and migrations
│   ├── network/      # API clients, connectivity, and health services
│   ├── sync/         # Sync engine, retry policies, and wiring
│   └── theme/        # App-wide UI theme definitions
├── features/
│   ├── assignments/  # Task lists and parcel details
│   ├── auth/         # Login, session management
│   ├── evidence/     # Camera and media capture screens
│   ├── field_visit/  # Survey wizard and data collection forms
│   ├── home/         # Main dashboard and shell
│   ├── map/          # Parcel mapping and geometry parsing
│   └── sync/         # Manual sync center UI
├── widgets/          # Shared, reusable UI components
└── main.dart         # App entry point
```

## 🗄️ Database Schema Overview

The app maintains a comprehensive local database to support its offline capabilities:

*   **`Sessions`**: Stores authenticated user session and JWT tokens.
*   **`AssignedTasks`**: Caches parcel assignments, geometry (WKT), and case details.
*   **`FieldVisits`**: Draft and completed field survey forms, including boundary confirmation and land use data.
*   **`Structures` & `Vegetations`**: Specific asset data linked to a field visit.
*   **`Evidences` & `LocalDocuments`**: Metadata and local file paths for captured geo-tagged photos and picked documents.
*   **`SyncQueues`**: Transactional table tracking pending API requests, retry counts, and payloads for the Sync Engine.

## ⚙️ Getting Started

### Prerequisites

*   Flutter SDK (^3.13.0)
*   Android Studio / Xcode (for platform-specific builds)

### Installation

1.  Clone the repository:
    ```bash
    git clone <repository_url>
    cd fo-app
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Generate Drift database files and Riverpod providers (if applicable):
    ```bash
    dart run build_runner build -d
    ```
4.  Run the application:
    ```bash
    flutter run
    ```

## 🔄 Sync Engine Workflow

1.  **Data Capture**: When a field officer submits a form or captures an image offline, the data is saved to `FieldVisits`, `Evidences`, etc., and a job is added to `SyncQueues`.
2.  **Network Listener**: `ConnectivityService` listens for active internet connections.
3.  **Sync Execution**: Once online, `SyncEngine` processes the `SyncQueues` sequentially based on dependency logic (e.g., uploading the visit form before the associated images).
4.  **Resolution**: Successfully synced items are marked, and failed items are scheduled for a retry based on the `RetryPolicy`.
