# Terranex Field Officer (FO) App

Terranex Field Officer is a robust, **offline-first** Flutter application designed for on-ground land-acquisition field verification and data collection. It empowers field officers to verify parcel boundaries, record landowner details, capture GPS-tagged evidence, and upload documents even in areas with zero network connectivity.

## 🚀 Key Features

*   **Offline-First Architecture**: Built on a local SQLite database (Drift). All tasks, visits, and evidence are stored locally first.
*   **Robust Sync Engine**: A dedicated background sync queue intelligently monitors network connectivity (`connectivity_plus`) and synchronizes pending field data, images, and forms to the remote server automatically once online.
*   **Geolocation & Mapping**: Integrated `flutter_map` with WKT parsing for rendering parcel geometries. Enforces GPS-based location validation (`geolocator`) during field visits and evidence capture.
*   **Multimedia Evidence**: In-app camera module to capture geo-tagged, timestamped images of the land, documents, structures, and vegetation.
*   **Comprehensive Data Collection**: Specialized wizards for capturing specific land use metrics:
    *   **Structures**: Type, area, construction, and condition.
    *   **Vegetation**: Species, count, crop type, and area.
    *   **Documents**: Local file picking and safe storage.
*   **No Login Required**: The app boots straight into the dashboard with a local field officer identity — no credentials or backend session needed.
*   **Demo Data by default**: Built with the in-app mock backend on, so tasks/parcels are available offline. Rebuild with `--dart-define=MOCK_API=false` to talk to a real server. Reactive state management powered by `Riverpod`.

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
│   ├── storage/      # On-device file store for evidence and documents
│   └── theme/        # App-wide UI theme definitions
├── data/
│   ├── mock/         # Centralised demo dataset (officer, cases, tasks, …)
│   └── models/       # Domain models and enums
├── features/
│   ├── assignments/  # Task lists and parcel details
│   ├── auth/         # Officer identity and sign-in
│   ├── cases/        # Case dossier and list
│   ├── documents/    # Document register and preview
│   ├── evidence/     # Camera and media capture screens
│   ├── field_visit/  # Survey wizard and data collection forms
│   ├── home/         # Main dashboard and shell
│   ├── map/          # Parcel mapping and geometry parsing
│   ├── more/         # Settings and profile
│   ├── notifications/# Alert inbox
│   ├── sync/         # Manual sync center UI
│   └── tasks/        # Assigned task list
├── services/         # App state (Riverpod) + mock data service + GPS
├── widgets/          # Shared, reusable UI components
└── main.dart         # App entry point
```

### Data layer

Every screen reads from a single `FoState` snapshot (`lib/services/mock_data_service.dart`)
exposed through `foStateProvider`. The demo dataset is built once in
`lib/data/mock/` and is keyed entirely off `caseNo`, so a case, its parcel,
task, timeline, evidence, documents and notifications can never disagree.
Dashboard figures are **derived** from that dataset, never hardcoded.

Swapping in a real backend means replacing `MockDataService` with an API-backed
implementation of the same shape — no widget changes.

## 🗄️ Database Schema Overview

The app maintains a comprehensive local database to support its offline capabilities:

*   **`Sessions`**: Legacy table, no longer written (the app has no login).
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
    By default the app uses built-in demo data (no server). To use a real backend instead:
    ```bash
    flutter run --dart-define=MOCK_API=false
    ```

### Tests

```bash
flutter analyze
flutter test
```

The suite covers sync ordering and idempotency (`p0_sync_test.dart`,
`sync_engine_test.dart`), offline persistence, the end-to-end wizard walk
(`flow_test.dart`), dataset integrity (`mock_data_consistency_test.dart`), and
a route-by-route visual sweep that fails on any layout overflow
(`visual_qa_test.dart`).

> The widget tests exercise real SQLite through `NativeDatabase`, which needs
> `libsqlite3.so` on the host. On a Linux box without the dev package:
> `sudo apt install libsqlite3-dev` (or point `LD_LIBRARY_PATH` at an existing
> `libsqlite3.so.0`).

## 🔄 Sync Engine Workflow

1.  **Data Capture**: When a field officer submits a form or captures an image offline, the data is saved to `FieldVisits`, `Evidences`, etc., and a job is added to `SyncQueues`.
2.  **Network Listener**: `ConnectivityService` listens for active internet connections.
3.  **Sync Execution**: Once online, `SyncEngine` processes the `SyncQueues` sequentially based on dependency logic (e.g., uploading the visit form before the associated images).
4.  **Resolution**: Successfully synced items are marked, and failed items are scheduled for a retry based on the `RetryPolicy`.
5.  **Backoff**: The automatic background run honours the retry window so a flaky link cannot spin; an explicit **SYNC NOW** always attempts every queued row so the officer's manual retry makes immediate progress.

## 🧪 Prototype walkthrough

Login → Dashboard → Assigned Cases → Case dossier (parcel, acquisition,
landowner, timeline, map) → **START FIELD VERIFICATION** → GPS fix → land use,
structures, cultivation, occupant → documents → evidence → review & declaration
→ submit → confirmation. The case moves to *Officer Review*, its tasks close,
the dashboard counts update, a notification is raised, and the submission sits
in the sync queue until connectivity returns.
