# ECG Dashboard - Developer Guide

## Table of Contents
1. [Development Environment Setup](#development-environment-setup)
2. [Architecture Overview](#architecture-overview)
3. [Customizing the GUI](#customizing-the-gui)
4. [Modifying Backend Processing](#modifying-backend-processing)
5. [Adding New Features](#adding-new-features)
6. [Testing and Debugging](#testing-and-debugging)
7. [Code Style Guide](#code-style-guide)
8. [Common Modification Scenarios](#common-modification-scenarios)

---

## Development Environment Setup

### Prerequisites

**Required:**
- MATLAB R2020b or later
- Signal Processing Toolbox
- WFDB Toolbox

**Recommended:**
- MATLAB Editor (built-in)
- Git for version control
- MATLAB Profiler for performance analysis

### Project Structure

```
ECG-Signal-Processing-Using-MATLAB/
├── run_dashboard.m              # Application launcher
├── src/
│   ├── gui/                     # Frontend layer
│   │   ├── ECGDashboard.m      # Main GUI class
│   │   ├── ECGController.m     # Controller class
│   │   └── docs/               # Documentation
│   ├── matlab/                  # Backend layer (processing)
│   │   ├── load_ecg.m
│   │   ├── preprocess_ecg.m
│   │   ├── filter_ecg.m
│   │   ├── r_peak_detection.m
│   │   ├── detect_p_t_waves.m
│   │   └── visualize_results.m
│   └── utils/                   # Shared utilities
│       └── PathManager.m
├── data/
│   ├── raw/                     # Input ECG data
│   └── processed/               # Intermediate results
└── results/
    ├── plots/                   # Exported visualizations
    ├── reports/                 # Exported data files
    └── logs/                    # Processing logs
```

### Setting Up Development Environment

```matlab
% 1. Add project to MATLAB path
addpath(genpath('src'));

% 2. Navigate to project root
cd 'path/to/ECG-Signal-Processing-Using-MATLAB'

% 3. Verify setup
pm = PathManager();
pm.getPathInfo()  % Should show all paths correctly
```

---

## Architecture Overview

### MVC Pattern Implementation

```
┌─────────────┐
│    VIEW     │  ECGDashboard.m
│  (GUI Only) │  - UI components
└──────┬──────┘  - Event handlers
       │         - Plotting
       ↓
┌─────────────┐
│ CONTROLLER  │  ECGController.m
│  (Mediator) │  - Business logic
└──────┬──────┘  - State management
       │         - Validation
       ↓
┌─────────────┐
│    MODEL    │  Backend functions
│  (Backend)  │  - Processing algorithms
└─────────────┘  - Pure functions
```

### Key Principles

1. **Separation of Concerns**
   - GUI never calls backend directly
   - Backend doesn't know GUI exists
   - Controller mediates all communication

2. **Modularity**
   - Each component has single responsibility
   - Changes isolated to appropriate layer
   - Components can be tested independently

3. **Loose Coupling**
   - Interfaces between layers are clean
   - Dependencies flow downward only
   - No circular dependencies

---

## Customizing the GUI

### Modifying Existing Components

#### Changing Button Colors

**Location:** `src/gui/ECGDashboard.m`

**Example:** Change "Load" button color:

```matlab
% Find in createRecordPanel() method:
app.LoadButton.BackgroundColor = [0.0 0.6 0.4];  % Current: Green
app.LoadButton.FontColor = [1 1 1];

% Modify to:
app.LoadButton.BackgroundColor = [0.2 0.5 0.9];  % New: Blue
app.LoadButton.FontColor = [1 1 1];
```

**Color Reference:**
```matlab
% RGB values [R G B] where each is 0.0 to 1.0
[1.0 0.0 0.0]    % Red
[0.0 1.0 0.0]    % Green
[0.0 0.0 1.0]    % Blue
[0.5 0.5 0.5]    % Gray
[1.0 0.65 0.0]   % Orange
[0.58 0.0 0.83]  % Purple
```

#### Adjusting Panel Sizes

**Location:** `src/gui/ECGDashboard.m` → `createLeftPanel()` method

```matlab
% Current layout:
leftGrid.RowHeight = {40, 150, 100, 120, 180, 100, '1x'};
%                     ↓    ↓    ↓    ↓    ↓    ↓    ↓
%                   Title Rec Ctrl Opts Stats Exp Status

% To make Statistics panel larger:
leftGrid.RowHeight = {40, 150, 100, 120, 250, 100, '1x'};
%                                          ↑ Changed from 180 to 250
```

#### Changing Default Parameters

**Location:** `src/gui/ECGController.m` → `initializeParameters()` method

```matlab
function initializeParameters(obj)
    obj.params = struct();
    
    % Modify these defaults:
    obj.params.enableNotchFilter = true;       % false to disable by default
    obj.params.notchFreq = 50;                 % Change to 60 for US power
    obj.params.bandpassLow = 5;                % Lower cutoff (Hz)
    obj.params.bandpassHigh = 15;              % Upper cutoff (Hz)
    obj.params.detectionSensitivity = 1.0;     % 0.5-2.0 range
    obj.params.enablePTDetection = true;       % false for R-peaks only
end
```

### Adding New UI Components

#### Example: Add a "Save Configuration" Button

**Step 1: Add Button Property**

```matlab
% In ECGDashboard.m, properties section:
properties (Access = public)
    % ... existing properties ...
    SaveConfigButton    matlab.ui.control.Button  % Add this line
end
```

**Step 2: Create Button in UI**

```matlab
% In createOptionsPanel() method, after existing components:
function createOptionsPanel(app, parentGrid, row)
    % ... existing code ...
    
    % Add save config button
    app.SaveConfigButton = uibutton(optGrid, 'push');
    app.SaveConfigButton.Text = 'Save Config';
    app.SaveConfigButton.Layout.Row = 5;  % New row
    app.SaveConfigButton.Layout.Column = 1;
    app.SaveConfigButton.ButtonPushedFcn = @(src,event) saveConfigButtonPushed(app);
    
    % Update optGrid.RowHeight to include new row:
    % optGrid.RowHeight = {25, 25, 20, 25, 30};  % Added 5th element
end
```

**Step 3: Implement Callback**

```matlab
% Add new method in "Callback Functions" section:
function saveConfigButtonPushed(app)
    % Get current parameters from controller
    params = app.Controller.getAllParameters();
    
    % Save to file
    [file, path] = uiputfile('config.mat', 'Save Configuration');
    if file ~= 0
        save(fullfile(path, file), 'params');
        logStatus(app, sprintf('Configuration saved: %s', file));
        uialert(app.UIFigure, 'Configuration saved successfully', 'Success');
    end
end
```

### Adding New Visualization Tabs

#### Example: Add "Heart Rate Plot" Tab

**Step 1: Add Tab Properties**

```matlab
% In properties section:
properties (Access = public)
    % ... existing tab properties ...
    HeartRateTab      matlab.ui.container.Tab
    HeartRateAxes     matlab.ui.control.UIAxes
end
```

**Step 2: Create Tab**

```matlab
% In createTabs() method:
function createTabs(app)
    % ... existing tabs ...
    
    % Create Heart Rate Tab
    app.HeartRateTab = uitab(app.PlotTabGroup);
    app.HeartRateTab.Title = 'Heart Rate';
    
    app.HeartRateAxes = uiaxes(app.HeartRateTab);
    app.HeartRateAxes.Position = [20 20 940 620];
    title(app.HeartRateAxes, 'Instantaneous Heart Rate')
    xlabel(app.HeartRateAxes, 'Time (s)')
    ylabel(app.HeartRateAxes, 'Heart Rate (BPM)')
    grid(app.HeartRateAxes, 'on')
end
```

**Step 3: Add Plotting Function**

```matlab
% In "Plotting Functions" section:
function plotHeartRate(app)
    try
        cla(app.HeartRateAxes);
        
        hr = app.Controller.getHeartRate();
        rPeaks = app.Controller.getRPeaks();
        fs = app.Controller.getSamplingRate();
        
        if isempty(hr)
            return;
        end
        
        % Time points (using midpoint between R-peaks)
        timePoints = (rPeaks(1:end-1) + diff(rPeaks)/2) / fs;
        
        plot(app.HeartRateAxes, timePoints, hr, 'b-', 'LineWidth', 2);
        xlabel(app.HeartRateAxes, 'Time (s)');
        ylabel(app.HeartRateAxes, 'Heart Rate (BPM)');
        title(app.HeartRateAxes, sprintf('Heart Rate - Record %s', ...
            app.Controller.getCurrentRecord()));
        grid(app.HeartRateAxes, 'on');
        
        % Add mean line
        hold(app.HeartRateAxes, 'on');
        yline(app.HeartRateAxes, mean(hr), 'r--', 'LineWidth', 1.5, ...
            'Label', sprintf('Mean: %.1f BPM', mean(hr)));
        hold(app.HeartRateAxes, 'off');
        
    catch ME
        logStatus(app, sprintf('Plot error: %s', ME.message));
    end
end
```

**Step 4: Call from processButtonPushed()**

```matlab
% In processButtonPushed() method, after existing plots:
if success
    % ... existing code ...
    plotFilteredSignal(app);
    plotDetection(app);
    plotHeartRate(app);  % Add this line
    % ... rest of code ...
end
```

---

## Modifying Backend Processing

### Adding Custom Preprocessing Step

**Location:** `src/matlab/preprocess_ecg.m`

**Example:** Add moving average smoothing

```matlab
% In preprocess_ecg.m, after normalization:

% Existing code:
ecg_normalized = ecg_baseline / max(abs(ecg_baseline));

% Add smoothing step:
window_size = 5;  % samples
ecg_smoothed = movmean(ecg_normalized, window_size);

% Return smoothed version:
clean_ecg = ecg_smoothed;
```

### Customizing Filter Parameters

**Location:** `src/matlab/filter_ecg.m`

**Example:** Change bandpass filter cutoffs

```matlab
% Current code:
lowcut = 5;   % Hz
highcut = 15; % Hz

% Modify to wider band:
lowcut = 0.5;  % Hz - Preserve more low-frequency content
highcut = 40;  % Hz - Allow higher frequencies

% Rest of filter_ecg.m remains the same
```

### Improving R-Peak Detection

**Location:** `src/matlab/r_peak_detection.m`

**Example:** Add minimum distance between peaks

```matlab
% In r_peak_detection.m, after initial peak detection:

% Existing peak detection code...
[peaks, locs] = findpeaks(/* ... */);

% Add minimum distance constraint:
min_distance = round(0.3 * Fs);  % 300ms minimum (prevents double-counting)
too_close = diff(locs) < min_distance;

% Remove peaks that are too close:
remove_idx = find(too_close);
for i = length(remove_idx):-1:1
    % Keep the larger peak
    if peaks(remove_idx(i)) < peaks(remove_idx(i)+1)
        locs(remove_idx(i)) = [];
        peaks(remove_idx(i)) = [];
    else
        locs(remove_idx(i)+1) = [];
        peaks(remove_idx(i)+1) = [];
    end
end
```

---

## Adding New Features

### Feature: Batch Processing Multiple Records

#### Step 1: Add Controller Method

**Location:** `src/gui/ECGController.m`

```matlab
% Add new method in ECGController:
function results = batchProcess(obj, recordList)
    % Process multiple records and return summary
    %
    % Inputs:
    %   recordList - Cell array of record names
    %
    % Outputs:
    %   results - Structure array with results for each record
    
    results = struct([]);
    
    for i = 1:length(recordList)
        try
            % Load record
            success = obj.loadRecord(recordList{i});
            if ~success
                continue;
            end
            
            % Process
            success = obj.processSignal();
            if ~success
                continue;
            end
            
            % Store results
            results(i).recordName = recordList{i};
            results(i).info = obj.getRecordInfo();
            results(i).metrics = obj.getHRVMetrics();
            results(i).success = true;
            
        catch ME
            results(i).recordName = recordList{i};
            results(i).error = ME.message;
            results(i).success = false;
        end
    end
end
```

#### Step 2: Add GUI Button

```matlab
% In createControlPanel():
app.BatchProcessButton = uibutton(ctrlGrid, 'push');
app.BatchProcessButton.Text = 'Batch Process';
app.BatchProcessButton.Layout.Row = 3;  % New row
app.BatchProcessButton.Layout.Column = 1;
app.BatchProcessButton.ButtonPushedFcn = @(src,event) batchProcessButtonPushed(app);
```

#### Step 3: Implement Callback

```matlab
% In callback section:
function batchProcessButtonPushed(app)
    % Get all available records
    records = app.Controller.getAvailableRecords();
    
    if isempty(records)
        uialert(app.UIFigure, 'No records available', 'Error');
        return;
    end
    
    % Confirm action
    selection = uiconfirm(app.UIFigure, ...
        sprintf('Process all %d records?', length(records)), ...
        'Batch Processing', ...
        'Options', {'Yes', 'No'});
    
    if strcmp(selection, 'No')
        return;
    end
    
    % Show progress dialog
    progress = uiprogressdlg(app.UIFigure, 'Title', 'Batch Processing', ...
        'Message', 'Processing records...', 'Indeterminate', 'on');
    
    % Process all records
    results = app.Controller.batchProcess(records);
    
    % Close progress dialog
    close(progress);
    
    % Display summary
    numSuccess = sum([results.success]);
    message = sprintf('Completed: %d/%d records processed successfully', ...
        numSuccess, length(records));
    uialert(app.UIFigure, message, 'Batch Complete');
    
    logStatus(app, message);
end
```

### Feature: Custom Filter Design

#### Step 1: Add Filter Designer Panel

```matlab
% Add properties:
properties (Access = public)
    CustomFilterPanel      matlab.ui.container.Panel
    LowCutoffEdit          matlab.ui.control.NumericEditField
    HighCutoffEdit         matlab.ui.control.NumericEditField
    FilterOrderEdit        matlab.ui.control.NumericEditField
end
```

#### Step 2: Create Panel

```matlab
function createCustomFilterPanel(app, parentGrid, row)
    app.CustomFilterPanel = uipanel(parentGrid);
    app.CustomFilterPanel.Title = 'Custom Filter';
    app.CustomFilterPanel.FontWeight = 'bold';
    app.CustomFilterPanel.Layout.Row = row;
    app.CustomFilterPanel.Layout.Column = 1;
    
    filterGrid = uigridlayout(app.CustomFilterPanel);
    filterGrid.RowHeight = {25, 25, 25};
    filterGrid.ColumnWidth = {100, '1x'};
    
    % Low cutoff
    uilabel(filterGrid, 'Text', 'Low Cutoff (Hz):', ...
        'Layout.Row', 1, 'Layout.Column', 1);
    app.LowCutoffEdit = uieditfield(filterGrid, 'numeric', ...
        'Value', 5, 'Limits', [0.1 50], ...
        'Layout.Row', 1, 'Layout.Column', 2);
    
    % High cutoff
    uilabel(filterGrid, 'Text', 'High Cutoff (Hz):', ...
        'Layout.Row', 2, 'Layout.Column', 1);
    app.HighCutoffEdit = uieditfield(filterGrid, 'numeric', ...
        'Value', 15, 'Limits', [1 100], ...
        'Layout.Row', 2, 'Layout.Column', 2);
    
    % Filter order
    uilabel(filterGrid, 'Text', 'Filter Order:', ...
        'Layout.Row', 3, 'Layout.Column', 1);
    app.FilterOrderEdit = uieditfield(filterGrid, 'numeric', ...
        'Value', 4, 'Limits', [1 10], 'RoundFractionalValues', 'on', ...
        'Layout.Row', 3, 'Layout.Column', 2);
end
```

#### Step 3: Update Controller with Custom Parameters

```matlab
% Before processing, update controller:
app.Controller.setParameter('bandpassLow', app.LowCutoffEdit.Value);
app.Controller.setParameter('bandpassHigh', app.HighCutoffEdit.Value);
app.Controller.setParameter('filterOrder', app.FilterOrderEdit.Value);
```

---

## Testing and Debugging

### Unit Testing Backend Functions

**Create:** `src/matlab/tests/test_preprocess.m`

```matlab
function test_preprocess()
    % Test preprocessing function
    
    % Create synthetic signal
    Fs = 360;
    t = 0:1/Fs:10;
    test_signal = sin(2*pi*1*t) + 0.1*randn(size(t));  % 1 Hz + noise
    
    % Add DC offset
    test_signal_dc = test_signal + 5;
    
    % Test DC removal (using internal logic from preprocess_ecg)
    signal_no_dc = test_signal_dc - mean(test_signal_dc);
    
    % Verify DC offset removed
    assert(abs(mean(signal_no_dc)) < 0.01, 'DC offset not removed');
    
    fprintf('✓ Preprocess test passed\n');
end
```

**Run:**
```matlab
>> test_preprocess()
✓ Preprocess test passed
```

### Testing Controller Methods

```matlab
% Test script: test_controller.m

% Create controller
controller = ECGController();

% Test record loading
assert(~controller.isLoaded(), 'Should not be loaded initially');

success = controller.loadRecord('100');
assert(success, 'Failed to load record');
assert(controller.isLoaded(), 'Should be loaded after loadRecord');

% Test data retrieval
rawData = controller.getRawData();
assert(~isempty(rawData), 'Raw data should not be empty');

fprintf('✓ Controller tests passed\n');
```

### Debugging GUI Issues

#### Enable Detailed Logging

**In ECGController.m**, add debug logging:

```matlab
function success = processSignal(obj)
    fprintf('DEBUG: Starting processSignal\n');
    fprintf('DEBUG: isDataLoaded = %d\n', obj.isDataLoaded);
    
    % ... existing code ...
    
    fprintf('DEBUG: Calling preprocess_ecg\n');
    [obj.cleanECG, ~, ~] = preprocess_ecg(obj.currentRecord, dataPath);
    fprintf('DEBUG: Preprocess complete, size = %d\n', length(obj.cleanECG));
    
    % ... rest of function ...
end
```

#### Using MATLAB Debugger

```matlab
% Set breakpoint in code:
dbstop in ECGController at 150  % Line number

% Run dashboard
app = ECGDashboard();

% When breakpoint hits:
% - Examine variables
% - Step through code
% - Evaluate expressions in Command Window

% Continue execution:
dbcont

% Clear breakpoints:
dbclear all
```

#### Catching UI Errors

**Wrap callbacks with try-catch:**

```matlab
function loadButtonPushed(app)
    try
        % ... existing code ...
    catch ME
        % Detailed error logging
        fprintf('ERROR in loadButtonPushed:\n');
        fprintf('  Message: %s\n', ME.message);
        fprintf('  Identifier: %s\n', ME.identifier);
        fprintf('  Stack:\n');
        for i = 1:length(ME.stack)
            fprintf('    %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        % Show to user
        uialert(app.UIFigure, ME.message, 'Error');
        logStatus(app, sprintf('ERROR: %s', ME.message));
    end
end
```

---

## Code Style Guide

### Naming Conventions

```matlab
% Classes: PascalCase
classname ECGController

% Methods: camelCase
function loadData(obj)

% Properties: camelCase
properties
    samplingRate
    isDataLoaded
end

% Constants: UPPER_SNAKE_CASE
MAX_SIGNAL_LENGTH = 1000000;

% Private functions: camelCase with underscore prefix
function data = _internalHelper(obj)
```

### Documentation Format

```matlab
function [output1, output2] = functionName(input1, input2)
    % FUNCTIONNAME Brief one-line description
    %
    % Detailed description of what the function does,
    % including any important algorithmic details.
    %
    % Inputs:
    %   input1 - Description of first input (units, constraints)
    %   input2 - Description of second input
    %
    % Outputs:
    %   output1 - Description of first output
    %   output2 - Description of second output
    %
    % Example:
    %   [out1, out2] = functionName(10, 'test');
    %
    % See also: RELATEDFUNCTION1, RELATEDFUNCTION2
    
    % Implementation here
end
```

### Code Organization

```matlab
classdef MyClass < handle
    % Class description
    
    %% Properties
    properties (Access = public)
        % Public properties
    end
    
    properties (Access = private)
        % Private properties
    end
    
    %% Constructor
    methods
        function obj = MyClass()
            % Constructor implementation
        end
    end
    
    %% Public Methods
    methods (Access = public)
        function output = publicMethod(obj, input)
            % Public method implementation
        end
    end
    
    %% Private Methods
    methods (Access = private)
        function output = privateMethod(obj, input)
            % Private method implementation
        end
    end
end
```

---

## Common Modification Scenarios

### Scenario 1: Change to 60 Hz Notch Filter (US Power)

**Files to modify:** 1

**Location:** `src/matlab/filter_ecg.m`

**Changes:**
```matlab
% Line ~15:
notch_freq = 60;  % Changed from 50
```

**Optional:** Also update default in controller:
```matlab
% src/gui/ECGController.m, initializeParameters():
obj.params.notchFreq = 60;  % Changed from 50
```

### Scenario 2: Display 30 Seconds Instead of 10

**Files to modify:** 1

**Location:** `src/gui/ECGDashboard.m`

**Changes:** In all plotting functions (`plotRawSignal`, `plotFilteredSignal`, `plotDetection`):

```matlab
% Change this line:
maxTime = min(10, timeVector(end));

% To:
maxTime = min(30, timeVector(end));
```

### Scenario 3: Add New HRV Metric (pNN50)

**Files to modify:** 2

**Step 1:** Add to controller (`src/gui/ECGController.m`):

```matlab
% In calculateMetrics() method:
function calculateMetrics(obj)
    % ... existing code ...
    
    % Add pNN50 calculation
    rrDiffs = diff(obj.rrIntervals) * 1000;  % ms
    nn50 = sum(abs(rrDiffs) > 50);
    obj.hrvMetrics.pNN50 = (nn50 / length(rrDiffs)) * 100;  % percentage
end
```

**Step 2:** Display in GUI (`src/gui/ECGDashboard.m`):

```matlab
% In updateStatistics() method:
statsText = {
    % ... existing lines ...
    sprintf('pNN50:    %.1f %%', metrics.pNN50)  % Add this line
};
```

### Scenario 4: Export to Excel Instead of CSV

**Files to modify:** 1

**Location:** `src/gui/ECGController.m`

**Changes:**

```matlab
function success = exportMetricsExcel(obj, filename)
    % Export HRV metrics to Excel file
    
    if ~obj.isProcessed
        error('ECGController:NoResults', 'No processed results to export.');
    end
    
    try
        % Create table with metrics
        metricNames = fieldnames(obj.hrvMetrics);
        metricValues = struct2cell(obj.hrvMetrics);
        T = table(metricNames, metricValues, ...
            'VariableNames', {'Metric', 'Value'});
        
        % Save to reports directory (as .xlsx)
        outputPath = obj.pathManager.getOutputFilePath('reports', filename);
        writetable(T, outputPath, 'Sheet', 'HRV Metrics');
        
        success = true;
    catch ME
        success = false;
        rethrow(ME);
    end
end
```

**Update GUI callback:**
```matlab
% In exportMetricsButtonPushed():
filename = pm.generateOutputFilename('metrics', recordName, '.xlsx');
app.Controller.exportMetricsExcel(filename);
```

---

## Performance Optimization

### Profiling Code

```matlab
% Profile a processing operation:
profile on
controller = ECGController();
controller.loadRecord('100');
controller.processSignal();
profile viewer  % Opens profiler GUI
```

### Common Bottlenecks and Solutions

| Bottleneck | Solution |
|------------|----------|
| Large signal loading | Load only required portion |
| Filter computation | Use IIR instead of FIR |
| Peak detection | Reduce sampling rate for detection |
| Plot rendering | Plot decimated data, show details on zoom |
| Memory usage | Process in chunks, clear unused variables |

### Example: Optimize Plotting for Long Signals

```matlab
function plotRawSignal(app)
    rawData = app.Controller.getRawData();
    timeVector = app.Controller.getTimeVector(length(rawData));
    
    % Only plot every Nth point if signal is very long
    if length(rawData) > 100000
        decimation_factor = ceil(length(rawData) / 100000);
        rawData = rawData(1:decimation_factor:end);
        timeVector = timeVector(1:decimation_factor:end);
    end
    
    % Plot with reduced data
    plot(app.RawAxes, timeVector, rawData, 'b', 'LineWidth', 0.8);
    % ... rest of plotting code ...
end
```

---

## Version Control Best Practices

### What to Commit

```
✅ Source code (.m files)
✅ Documentation (.md files)
✅ Project files (.prj)
✅ README and configuration files
```

### What NOT to Commit

```
❌ Data files (*.dat, *.hea, *.atr)
❌ Results (plots, reports, logs)
❌ MATLAB autosave files (.asv)
❌ Compiled files (.mex, .p)
```

### .gitignore Example

```gitignore
# MATLAB
*.asv
*.mex*
*.p

# Data and Results
data/raw/*.dat
data/raw/*.hea
data/raw/*.atr
data/processed/*
results/plots/*
results/reports/*
results/logs/*

# Keep directory structure
!data/raw/.gitkeep
!data/processed/.gitkeep
!results/plots/.gitkeep
!results/reports/.gitkeep
!results/logs/.gitkeep
```

---

## FAQ for Developers

**Q: Can I use this GUI with different ECG formats (not MIT-BIH)?**  
A: Yes, modify `load_ecg.m` to support your format. The controller and GUI are format-agnostic.

**Q: How do I add a new processing algorithm?**  
A: Create a new backend function (e.g., `my_algorithm.m`), add a controller method to call it, then add UI controls to trigger it.

**Q: Can I convert this to a standalone app?**  
A: Yes, use MATLAB Compiler: `mcc -m run_dashboard.m`. Requires MATLAB Runtime on target machine.

**Q: How do I change the default color scheme?**  
A: Modify `BackgroundColor` and `FontColor` properties for each UI component in `createComponents()`.

**Q: Can I run this without the GUI?**  
A: Yes, use `main.m` or call backend functions directly. The controller can also be used in scripts.

---

**Version:** 1.0  
**Last Updated:** March 2026  
**For architecture details, see:** `GUI_Architecture.md`  
**For usage instructions, see:** `User_Manual.md`
