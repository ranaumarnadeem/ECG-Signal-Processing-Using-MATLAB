# ECG Dashboard - GUI Architecture Documentation

## Overview

The ECG Signal Processing Dashboard implements a clean **Model-View-Controller (MVC)** architecture pattern, ensuring complete separation between the user interface (GUI), business logic (Controller), and data processing (Backend).

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      USER INTERFACE LAYER                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         ECGDashboard.m (View)                         │  │
│  │  - UI Components (buttons, plots, panels)             │  │
│  │  - Event handlers (callbacks)                         │  │
│  │  - Visualization logic                                │  │
│  └────────────┬──────────────────────────────────────────┘  │
└───────────────┼─────────────────────────────────────────────┘
                │
                │ calls methods
                ▼
┌─────────────────────────────────────────────────────────────┐
│                    CONTROLLER LAYER                          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         ECGController.m (Controller)                  │  │
│  │  - Business logic                                     │  │
│  │  - State management                                   │  │
│  │  - Data validation                                    │  │
│  │  - Error handling                                     │  │
│  │  - Coordinates backend calls                         │  │
│  └────────────┬──────────────────────────────────────────┘  │
└───────────────┼─────────────────────────────────────────────┘
                │
                │ delegates to
                ▼
┌─────────────────────────────────────────────────────────────┐
│                     BACKEND LAYER                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         Processing Functions (Model)                  │  │
│  │  - load_ecg.m                                         │  │
│  │  - preprocess_ecg.m                                   │  │
│  │  - filter_ecg.m                                       │  │
│  │  - r_peak_detection.m                                 │  │
│  │  - detect_p_t_waves.m                                 │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                │
                │ uses
                ▼
┌─────────────────────────────────────────────────────────────┐
│                     UTILITY LAYER                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         PathManager.m                                 │  │
│  │  - Centralized path management                        │  │
│  │  - File operations                                    │  │
│  │  - Record discovery                                   │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. User Interface Layer (View)

**File:** `src/gui/ECGDashboard.m`

**Purpose:** Handles all visual elements and user interactions

**Responsibilities:**
- Create and layout UI components (panels, buttons, plots, etc.)
- Handle user events (button clicks, dropdown changes, slider adjustments)
- Display data received from controller
- Update visual elements based on application state
- Show error messages and confirmations to user

**Key Features:**
- **Left Panel:** Control and configuration interface
  - Record selection dropdown
  - Load/Process/Clear buttons
  - Processing options (filters, sensitivity)
  - Statistics display
  - Export options
  - Status log
  
- **Right Panel:** Visualization area with tabs
  - Raw Signal: Original ECG waveform
  - Filtered Signal: After preprocessing and filtering
  - Peak Detection: Annotated with R, P, T peaks

**Does NOT:**
- Directly call backend processing functions
- Manage application state or data
- Handle file I/O operations
- Perform calculations or algorithms

### 2. Controller Layer

**File:** `src/gui/ECGController.m`

**Purpose:** Mediates between GUI and backend, manages application logic

**Responsibilities:**
- Coordinate backend function calls in proper sequence
- Maintain application state (loaded data, processing status)
- Validate user inputs and parameters
- Handle errors and exceptions gracefully
- Provide clean API for GUI to interact with
- Cache processed results to avoid redundant calculations
- Manage processing parameters

**Key Methods:**

| Method | Purpose |
|--------|---------|
| `loadRecord(recordName)` | Load ECG data from file |
| `processSignal()` | Execute full processing pipeline |
| `getRawData()` | Retrieve raw ECG signal |
| `getFilteredData()` | Retrieve filtered signal |
| `getRPeaks()`, `getPWaves()`, `getTWaves()` | Get detection results |
| `getHRVMetrics()` | Get calculated metrics |
| `setParameter(name, value)` | Update processing parameters |
| `exportResults(filename)` | Save results to file |

**State Management:**
```matlab
Properties:
- isDataLoaded: boolean     % Data successfully loaded?
- isProcessed: boolean      % Signal processed?
- isDetected: boolean       % Peaks detected?
```

**Does NOT:**
- Create or manipulate UI components
- Implement signal processing algorithms directly
- Handle GUI event callbacks

### 3. Backend Layer (Model)

**Directory:** `src/matlab/`

**Purpose:** Implement core signal processing algorithms

**Existing Functions:**
- `load_ecg.m` - Load ECG from MIT-BIH format
- `preprocess_ecg.m` - DC removal, baseline correction, normalization
- `filter_ecg.m` - Notch filter (50Hz) and bandpass filter (5-15Hz)
- `r_peak_detection.m` - Pan-Tompkins algorithm
- `detect_p_t_waves.m` - P and T wave detection
- `visualize_results.m` - Generate plots (legacy)

**Characteristics:**
- Pure functions: input → process → output
- No GUI dependencies
- No state management
- Reusable in command-line scripts
- Can be tested independently

**Does NOT:**
- Know about GUI existence
- Maintain application state
- Handle user interactions
- Manage file paths directly

### 4. Utility Layer

**File:** `src/utils/PathManager.m`

**Purpose:** Centralized path and file management

**Responsibilities:**
- Auto-detect project root directory
- Provide consistent paths to all modules
- Create output directories as needed
- Discover available ECG records
- Generate timestamped filenames
- Handle cross-platform path differences

**Key Methods:**
```matlab
getDataRawPath()           % Path to raw data
getResultsPlotsPath()      % Path to plots output
getAvailableRecords()      % List of ECG records
generateTimestamp()        % Standardized timestamp
```

## Data Flow Example: Loading and Processing

```
USER ACTION: Click "Load Record" button
    ↓
1. ECGDashboard.loadButtonPushed()
    │  - Get selected record from dropdown
    │  - Validate selection
    │  - Update UI state (disable button, show "Loading...")
    ↓
2. ECGController.loadRecord('100')
    │  - Get data path from PathManager
    │  - Call backend: load_ecg('100', dataPath)
    │  - Store results in properties
    │  - Update isDataLoaded flag
    │  - Return success status
    ↓
3. ECGDashboard receives success
    │  - Update record info display
    │  - Enable "Process" button
    │  - Call plotRawSignal()
    │  - Log status message
    │  - Re-enable "Load" button

USER ACTION: Click "Process Signal" button
    ↓
4. ECGDashboard.processButtonPushed()
    │  - Update parameters from UI controls
    │  - Update button state
    ↓
5. ECGController.processSignal()
    │  - Call preprocess_ecg() → cleanECG
    │  - Call filter_ecg() → filteredECG
    │  - Call r_peak_detection() → rPeaks
    │  - Call detect_p_t_waves() → pWaves, tWaves
    │  - Call calculateMetrics() → HRV metrics
    │  - Update processing flags
    │  - Return success
    ↓
6. ECGDashboard receives success
    │  - Plot filtered signal
    │  - Plot detection results
    │  - Update statistics display
    │  - Enable export buttons
    │  - Log completion message
```

## Design Patterns Used

### 1. Model-View-Controller (MVC)
- **Model:** Backend processing functions
- **View:** ECGDashboard GUI
- **Controller:** ECGController interface

### 2. Singleton Pattern (PathManager)
- Single instance manages all paths
- Shared across controller and GUI
- Ensures consistency

### 3. Facade Pattern (ECGController)
- Simplifies complex backend interactions
- Provides clean, simple API
- Hides implementation details

### 4. Observer Pattern (Callbacks)
- GUI components observe user actions
- Callbacks notify controller of events
- Loose coupling between components

## Benefits of This Architecture

### ✅ Separation of Concerns
- GUI code doesn't mix with processing logic
- Each layer has single responsibility
- Changes isolated to appropriate layer

### ✅ Maintainability
- Easy to modify GUI without touching backend
- Backend algorithms can evolve independently
- Clear boundaries make debugging easier

### ✅ Testability
- Backend functions testable without GUI
- Controller can be unit tested
- Mock interfaces can be created

### ✅ Reusability
- Backend functions usable in other projects
- Controller can support multiple views
- Utility classes shared across modules

### ✅ Extensibility
- New features added without breaking existing code
- Additional views can share same controller
- New processing functions easily integrated

## File Organization

```
ECG-Signal-Processing-Using-MATLAB/
├── run_dashboard.m                 # Launch script
├── src/
│   ├── gui/                        # GUI Layer
│   │   ├── ECGDashboard.m         # View
│   │   ├── ECGController.m        # Controller
│   │   └── docs/                  # Documentation
│   │       ├── GUI_Architecture.md
│   │       ├── User_Manual.md
│   │       └── Developer_Guide.md
│   ├── matlab/                     # Backend Layer (Model)
│   │   ├── main.m                 # Legacy CLI interface
│   │   ├── load_ecg.m
│   │   ├── preprocess_ecg.m
│   │   ├── filter_ecg.m
│   │   ├── r_peak_detection.m
│   │   ├── detect_p_t_waves.m
│   │   └── visualize_results.m
│   └── utils/                      # Utility Layer
│       └── PathManager.m
├── data/
│   ├── raw/                        # Input data
│   └── processed/                  # Intermediate results
└── results/
    ├── plots/                      # Exported plots
    ├── reports/                    # Exported data
    └── logs/                       # Processing logs
```

## Dependency Graph

```
run_dashboard.m
    └─→ ECGDashboard.m
            └─→ ECGController.m
                    ├─→ PathManager.m
                    ├─→ load_ecg.m
                    ├─→ preprocess_ecg.m
                    ├─→ filter_ecg.m
                    ├─→ r_peak_detection.m
                    └─→ detect_p_t_waves.m
```

## Communication Rules

### ✅ ALLOWED
- GUI → Controller
- Controller → Backend
- Controller → PathManager
- Backend → PathManager
- GUI → PathManager (for display purposes only)

### ❌ NOT ALLOWED
- GUI → Backend (direct)
- Backend → Controller
- Backend → GUI
- Backend → Backend with side effects

## State Management

The controller maintains all application state:

```matlab
% Data State
currentRecord      % Which record is loaded
rawECG            % Original signal
filteredECG       % Processed signal
rPeaks, pWaves, tWaves  % Detections

% Status Flags
isDataLoaded      % Has data been loaded?
isProcessed       % Has signal been processed?
isDetected        % Have peaks been detected?

% Parameters
params            % Processing configuration
```

The GUI queries controller for state information rather than maintaining its own copies.

## Error Handling Strategy

### Controller Level
```matlab
try
    % Call backend function
    [result] = backend_function(params);
    return success;
catch ME
    % Log error
    % Return failure status
    % Rethrow for GUI to handle
    rethrow(ME);
end
```

### GUI Level
```matlab
try
    success = controller.method();
    if success
        % Update UI for success
    end
catch ME
    % Show user-friendly error dialog
    uialert(app.UIFigure, ME.message, 'Error');
    % Log to status
    logStatus(app, sprintf('ERROR: %s', ME.message));
end
```

## Performance Considerations

1. **Lazy Loading:** Data loaded only when requested
2. **Caching:** Processed results cached in controller
3. **Partial Plotting:** Only plot visible time window (0-10s)
4. **Asynchronous Updates:** UI updates don't block processing
5. **Memory Management:** Large signals processed in segments

## Future Extension Points

### Easy to Add:
- New visualization tabs
- Additional export formats
- More processing parameters
- Batch processing mode
- Real-time data streaming

### Requires Planning:
- Multiple simultaneous records
- Undo/redo functionality
- Plugin architecture
- Cloud data integration

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | March 2026 | Initial MVC architecture implementation |

## Contact & Support

For questions about the architecture or extending the system, refer to:
- **User Manual:** How to use the dashboard
- **Developer Guide:** How to modify and extend

---

*This architecture ensures a maintainable, testable, and extensible ECG processing system suitable for both educational and research purposes.*
