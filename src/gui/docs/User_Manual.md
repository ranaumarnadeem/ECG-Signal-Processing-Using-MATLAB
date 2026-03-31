# ECG Dashboard - User Manual

## Table of Contents
1. [Getting Started](#getting-started)
2. [Interface Overview](#interface-overview)
3. [Loading ECG Data](#loading-ecg-data)
4. [Processing Signals](#processing-signals)
5. [Adjusting Parameters](#adjusting-parameters)
6. [Understanding Results](#understanding-results)
7. [Exporting Data](#exporting-data)
8. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

Before using the ECG Dashboard, ensure you have:

✅ **MATLAB R2020b or later**
✅ **Signal Processing Toolbox**
✅ **WFDB Toolbox** (for MIT-BIH format support)
✅ **ECG data files** in `data/raw/` directory

### Installation

1. **Download/Clone the Project**
   ```bash
   git clone <repository-url>
   cd ECG-Signal-Processing-Using-MATLAB
   ```

2. **Add ECG Data Files**
   - Place your ECG data files (`.dat`, `.hea`, `.atr`) in `data/raw/`
   - Sample data: MIT-BIH Arrhythmia Database from PhysioNet

3. **Install WFDB Toolbox**
   ```matlab
   % Download from: https://physionet.org/content/wfdb-matlab/
   % Add to MATLAB path:
   addpath(genpath('path/to/wfdb-toolbox'));
   savepath
   ```

### Launching the Dashboard

**Method 1: Using the Launcher Script (Recommended)**
```matlab
>> run_dashboard
```

**Method 2: Manual Launch**
```matlab
>> addpath(genpath('src'));
>> app = ECGDashboard();
```

The dashboard window will open automatically.

---

## Interface Overview

The dashboard is divided into two main panels:

### Left Panel: Control Panel

```
┌─────────────────────────────┐
│   ECG SIGNAL PROCESSOR      │  ← Title
├─────────────────────────────┤
│ [ECG Record]                │  ← Record Selection
│  • Dropdown menu            │
│  • Record info display      │
│  • Load button              │
├─────────────────────────────┤
│ [Processing Control]        │  ← Main Controls
│  • Process Signal           │
│  • Clear All                │
├─────────────────────────────┤
│ [Processing Options]        │  ← Parameters
│  • 50 Hz Notch Filter       │
│  • P and T Wave Detection   │
│  • Sensitivity Slider       │
├─────────────────────────────┤
│ [Statistics]                │  ← Results Summary
│  • R-peaks, P, T counts     │
│  • Heart Rate metrics       │
│  • HRV parameters           │
├─────────────────────────────┤
│ [Export Results]            │  ← Export Options
│  • Export Plot              │
│  • Export Data (.mat)       │
│  • Export Metrics (.csv)    │
├─────────────────────────────┤
│ [Status Log]                │  ← Activity Log
│  • Timestamped messages     │
│  • Error notifications      │
└─────────────────────────────┘
```

### Right Panel: Visualization Area

Three tabs for different views:

1. **Raw Signal Tab** - Original ECG waveform
2. **Filtered Signal Tab** - After preprocessing and filtering
3. **Peak Detection Tab** - Annotated with detected peaks

---

## Loading ECG Data

### Step-by-Step Process

#### 1. Select a Record

![Step 1: Record Selection](docs/images/step1-select.png)

- Click the **dropdown menu** under "ECG Record"
- Available records are automatically detected from `data/raw/`
- Records are listed as: `100`, `101`, `103`, etc.

**Example:**
```
┌─────────────────────────┐
│ Select Record...    ▼   │  ← Click here
├─────────────────────────┤
│ 100                     │  ← Select record
│ 103                     │
│ 104                     │
│ 105                     │
└─────────────────────────┘
```

#### 2. View Record Information

After selecting, you'll see:
```
Selected: 100
Click "Load Record" to load data
```

#### 3. Load the Data

- Click the **"Load Record"** button (green)
- Button will temporarily show "Loading..."
- Wait for completion

#### 4. Verify Successful Load

Once loaded, the record info updates:
```
Record: 100
Duration: 650.0 s
Sampling Rate: 360 Hz
Samples: 234000
```

**Status Log:** You'll see:
```
[10:15:32] Loading record: 100
[10:15:33] Successfully loaded record 100
```

**Visualization:** The Raw Signal tab automatically displays the first 10 seconds of the ECG.

---

## Processing Signals

### Standard Processing Workflow

#### 1. Configure Options (Optional)

Before processing, adjust parameters if needed:

**50 Hz Notch Filter:**
- ✅ Checked: Removes powerline interference (recommended)
- ☐ Unchecked: Skip notch filtering

**Detect P and T Waves:**
- ✅ Checked: Detect all waves (R, P, T)
- ☐ Unchecked: Detect R-peaks only (faster)

**Detection Sensitivity:**
- Slider range: 0.5 to 2.0
- Default: 1.0
- Lower values: More selective (fewer peaks)
- Higher values: More sensitive (more peaks)

#### 2. Start Processing

- Click the **"Process Signal"** button (blue)
- Button shows "Processing..." during operation
- Processing takes 2-10 seconds depending on signal length

#### 3. Processing Steps (Automatic)

The system performs these steps sequentially:

```
1. Preprocessing
   ├─ DC offset removal
   ├─ Baseline wander correction
   └─ Signal normalization

2. Filtering
   ├─ 50 Hz notch filter (if enabled)
   └─ 5-15 Hz bandpass filter

3. R-Peak Detection
   └─ Pan-Tompkins algorithm

4. P and T Wave Detection (if enabled)
   ├─ P-wave detection
   └─ T-wave detection

5. Metrics Calculation
   ├─ RR intervals
   ├─ Heart rate
   └─ HRV parameters
```

#### 4. View Results

After processing completes:

**Status Log:**
```
[10:16:05] Starting signal processing...
[10:16:07] Signal processing completed successfully
[10:16:07] All visualizations updated
```

**Statistics Panel:**
```
=== DETECTION RESULTS ===
R-peaks:  1540
P-waves:  1523
T-waves:  1535

=== HEART RATE METRICS ===
Mean HR:  72.4 BPM
Std HR:   4.2 BPM
Min HR:   62.1 BPM
Max HR:   85.3 BPM

=== HRV METRICS ===
Mean RR:  828.7 ms
SDNN:     48.2 ms
RMSSD:    35.6 ms
```

---

## Adjusting Parameters

### When to Adjust Parameters?

| Scenario | Adjustment | Effect |
|----------|------------|--------|
| Too many false peaks | Decrease sensitivity | Stricter detection |
| Missing real peaks | Increase sensitivity | More detections |
| Clean signal | Disable notch filter | Faster processing |
| Noisy signal (50/60 Hz) | Enable notch filter | Remove interference |
| Quick analysis | Disable P/T detection | Faster processing |
| Complete analysis | Enable P/T detection | Full PQRST complex |

### Parameter Details

#### Detection Sensitivity

**Default: 1.0**

```
0.5 ←──── 1.0 ────→ 2.0
Less         More
Sensitive    Sensitive
```

**Low Sensitivity (0.5-0.8):**
- Detects only strong, clear R-peaks
- Good for noisy signals
- May miss some valid peaks

**Medium Sensitivity (0.8-1.2):**
- Balanced detection
- Works for most signals
- Default setting

**High Sensitivity (1.2-2.0):**
- Detects weaker peaks
- Good for low-amplitude signals
- May detect some noise as peaks

#### 50 Hz Notch Filter

**When to Enable:**
- Signal recorded in Europe/Asia/Africa (50 Hz power)
- Visible 50 Hz noise in raw signal
- Baseline shows repetitive oscillations

**When to Disable:**
- Signal recorded in Americas (60 Hz power)
- Very clean signal
- Want maximum processing speed

#### P and T Wave Detection

**Enable When:**
- Need complete cardiac cycle analysis
- Studying P-R intervals or QT intervals
- Preparing detailed report
- Time is not critical

**Disable When:**
- Only interested in heart rate
- Quick screening needed
- Signal quality is poor (P/T waves unclear)

---

## Understanding Results

### Visualization Tabs

#### 1. Raw Signal Tab

**What it shows:**
- Original, unprocessed ECG signal
- First 10 seconds displayed
- Amplitude in millivolts (mV)

**What to look for:**
- Overall signal quality
- Baseline wander
- Noise levels
- QRS complex visibility

**Normal appearance:**
- Regular QRS complexes
- Stable baseline
- Minimal noise

**Problems to identify:**
- Excessive noise → Poor recording quality
- Severe baseline wander → Movement artifacts
- Irregular rhythm → Potential arrhythmia

#### 2. Filtered Signal Tab

**What it shows:**
- Signal after preprocessing and filtering
- Normalized amplitude (-1 to 1)
- First 10 seconds displayed

**What to look for:**
- Clean baseline (should be near zero)
- Enhanced QRS complexes
- Reduced noise
- Preserved waveform morphology

**Comparison with raw:**
- Should be smoother
- Baseline more stable
- QRS peaks more prominent

#### 3. Peak Detection Tab

**What it shows:**
- Filtered signal with annotations
- Color-coded peak markers:
  - 🔴 **Red triangles:** R-peaks
  - 🔵 **Blue circles:** P-waves
  - 🟢 **Green triangles:** T-waves

**What to look for:**
- R-peaks aligned with QRS peaks
- P-waves before each QRS
- T-waves after each QRS
- Regular spacing (normal rhythm)

**Quality indicators:**
- **Good:** All beats detected, no false positives
- **Fair:** Few missed beats or extra detections
- **Poor:** Many errors, irregular detection

### Statistics Interpretation

#### Detection Results

```
R-peaks:  1540  ← Number of heartbeats detected
P-waves:  1523  ← Should be close to R-peaks
T-waves:  1535  ← Should be close to R-peaks
```

**Normal:** P, R, T counts within 1-2% of each other
**Problem:** Large difference indicates detection issues

#### Heart Rate Metrics

```
Mean HR:  72.4 BPM   ← Average heart rate
Std HR:   4.2 BPM    ← Heart rate variability (standard deviation)
Min HR:   62.1 BPM   ← Lowest instantaneous heart rate
Max HR:   85.3 BPM   ← Highest instantaneous heart rate
```

**Reference Ranges:**
- **Resting HR:** 60-100 BPM (normal)
- **Athletic:** 40-60 BPM
- **Bradycardia:** <60 BPM
- **Tachycardia:** >100 BPM

**Std HR Interpretation:**
- Low (< 3 BPM): Very regular rhythm
- Normal (3-10 BPM): Healthy variation
- High (> 15 BPM): Irregular rhythm or artifacts

#### HRV Metrics

```
Mean RR:  828.7 ms   ← Average time between beats
SDNN:     48.2 ms    ← Standard deviation of RR intervals
RMSSD:    35.6 ms    ← Root mean square of successive differences
```

**SDNN (Overall HRV):**
- < 50 ms: Low variability
- 50-100 ms: Normal variability
- \> 100 ms: High variability

**RMSSD (Short-term HRV):**
- < 20 ms: Low
- 20-50 ms: Normal
- \> 50 ms: High

**Higher HRV generally indicates:**
- Better cardiovascular fitness
- Good autonomic function
- Lower stress levels

---

## Exporting Data

### Export Plot

**Purpose:** Save current visualization as image file

**Steps:**
1. Switch to the tab you want to export (Raw/Filtered/Detection)
2. Click **"Export Plot"** button
3. Confirmation dialog shows save location
4. File saved as: `<type>_<record>_<timestamp>.png`

**Example filename:**
```
detection_100_20260331_154523.png
```

**Location:** `results/plots/`

**Format:** PNG (high resolution, suitable for reports/presentations)

### Export Data (.mat)

**Purpose:** Save all processed data for later analysis

**Steps:**
1. After processing is complete
2. Click **"Export Data (.mat)"** button
3. Confirmation dialog shows save location

**What's included:**
- Raw ECG signal
- Filtered ECG signal
- R-peak locations
- P-wave and T-wave locations (if detected)
- Heart rate array
- HRV metrics structure
- Processing parameters used
- Timestamp

**Example filename:**
```
results_100_20260331_154612.mat
```

**Location:** `results/reports/`

**How to load in MATLAB:**
```matlab
load('results/reports/results_100_20260331_154612.mat');
% Variables now available:
% - rawECG, filteredECG
% - rPeaks, pWaves, tWaves
% - heartRate, hrvMetrics
% - processingParams
```

### Export Metrics (.csv)

**Purpose:** Save summary statistics in spreadsheet format

**Steps:**
1. After processing is complete
2. Click **"Export Metrics (.csv)"** button
3. Confirmation dialog shows save location

**Format:**
```csv
Metric,Value
meanHR,72.4
stdHR,4.2
minHR,62.1
maxHR,85.3
meanRR,828.7
sdnn,48.2
rmssd,35.6
```

**Example filename:**
```
metrics_100_20260331_154648.csv
```

**Location:** `results/reports/`

**Use cases:**
- Import to Excel/Google Sheets
- Statistical analysis in R/Python
- Batch comparison of multiple records

---

## Troubleshooting

### Common Issues

#### Issue: "No records found" in dropdown

**Symptoms:**
- Dropdown shows "No records found"
- Cannot load any data

**Causes:**
- No ECG data files in `data/raw/` directory
- Incorrect file format

**Solutions:**
1. Check if `data/raw/` directory exists
2. Ensure you have `.dat` files (ECG data format)
3. Verify filenames: should be like `100.dat`, `103.dat`
4. Download sample data from MIT-BIH Database

#### Issue: "Failed to load record" error

**Symptoms:**
- Error message when clicking "Load Record"
- Status log shows "ERROR: Failed to load record"

**Causes:**
- Missing `.hea` (header) file
- Missing `.atr` (annotation) file
- Corrupted data file
- WFDB Toolbox not installed

**Solutions:**
1. Verify all three files exist:
   - `100.dat` (data)
   - `100.hea` (header)
   - `100.atr` (annotations)
2. Check WFDB Toolbox installation:
   ```matlab
   which rdsamp  % Should show path to WFDB function
   ```
3. Reinstall WFDB if necessary

#### Issue: No peaks detected or too many peaks

**Symptoms:**
- Statistics show 0 R-peaks or unrealistic number
- Detection plot has no markers or too many markers

**Causes:**
- Wrong sensitivity setting
- Poor signal quality
- Incorrect sampling rate

**Solutions:**
1. **Too few peaks:** Increase sensitivity slider
2. **Too many peaks:** Decrease sensitivity slider
3. Check raw signal quality in Raw Signal tab
4. Try different record if current one is too noisy

#### Issue: Export buttons disabled

**Symptoms:**
- Cannot click export buttons
- Buttons appear grayed out

**Causes:**
- Data not loaded yet
- Processing not completed

**Solutions:**
1. Load a record first
2. Click "Process Signal" button
3. Wait for processing to complete
4. Export buttons will enable automatically

#### Issue: GUI becomes unresponsive

**Symptoms:**
- Dashboard stops responding
- MATLAB shows "Busy" status

**Causes:**
- Processing very long signal
- MATLAB running out of memory
- Background computation in progress

**Solutions:**
1. **Wait:** Processing can take time for long signals
2. **Check memory:** Close other MATLAB variables
3. **Use shorter records:** Process smaller data segments
4. **Restart:** Close dashboard and try again

#### Issue: Plots are empty or not updating

**Symptoms:**
- Tabs show empty plots
- Axes present but no data displayed

**Causes:**
- Processing hasn't run yet
- Error during plot generation
- Tab not refreshed

**Solutions:**
1. Switch between tabs to refresh
2. Click "Process Signal" again
3. Check status log for errors
4. Try "Clear All" and reload

### Getting Help

If problems persist:

1. **Check Status Log:** Look for error messages
2. **Check MATLAB Command Window:** May show additional errors
3. **Review Documentation:** 
   - `GUI_Architecture.md` for technical details
   - `Developer_Guide.md` for customization
4. **Contact Support:** Provide:
   - Error message from status log
   - MATLAB version
   - Record name being processed
   - Steps to reproduce issue

---

## Quick Reference

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Switch tabs | Ctrl+Tab |
| Zoom in plot | Scroll up |
| Zoom out plot | Scroll down |
| Pan plot | Click and drag |
| Reset zoom | Double-click plot |

### Default Settings

| Parameter | Default Value |
|-----------|---------------|
| Notch Filter | Enabled (50 Hz) |
| P/T Detection | Enabled |
| Sensitivity | 1.0 |
| Display Duration | 10 seconds |

### Typical Workflow

```
1. Launch Dashboard (run_dashboard)
2. Select Record from dropdown
3. Click "Load Record"
4. (Optional) Adjust parameters
5. Click "Process Signal"
6. Review visualizations and statistics
7. Export results as needed
8. Repeat for other records or Clear All
```

### File Locations

| Content | Location |
|---------|----------|
| ECG Data | `data/raw/` |
| Exported Plots | `results/plots/` |
| Exported Data | `results/reports/` |
| Status Logs | `results/logs/` |

---

## Best Practices

### For Accurate Results:
✅ Use high-quality ECG recordings
✅ Start with default sensitivity (1.0)
✅ Enable notch filter for noisy signals
✅ Verify detection visually before trusting metrics

### For Efficient Workflow:
✅ Process multiple records in sequence
✅ Export all formats (plot + data + metrics) at once
✅ Use consistent naming conventions
✅ Document any parameter changes

### For Troubleshooting:
✅ Check status log first
✅ Try different sensitivity values
✅ Compare with raw signal tab
✅ Test with known good record

---

## Appendix: ECG Terminology

| Term | Description |
|------|-------------|
| **ECG/EKG** | Electrocardiogram - electrical activity of heart |
| **P wave** | Atrial depolarization |
| **QRS complex** | Ventricular depolarization |
| **R-peak** | Highest point of QRS complex |
| **T wave** | Ventricular repolarization |
| **RR interval** | Time between consecutive R-peaks |
| **Heart Rate** | Beats per minute (BPM) |
| **HRV** | Heart Rate Variability |
| **SDNN** | Standard deviation of RR intervals |
| **RMSSD** | Root mean square of successive differences |
| **BPM** | Beats per minute |

---

**Version:** 1.0  
**Last Updated:** March 2026  
**For technical details, see:** `GUI_Architecture.md` and `Developer_Guide.md`
