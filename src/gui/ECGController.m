classdef ECGController < handle
    % ECGCONTROLLER Interface layer between GUI and ECG processing backend
    %
    % This controller implements the Model-View-Controller (MVC) pattern,
    % separating GUI logic from data processing. It manages:
    %   - ECG data loading and processing
    %   - State management (loaded data, processing status)
    %   - Error handling and validation
    %   - Communication between GUI and backend functions
    %
    % Usage:
    %   controller = ECGController();
    %   controller.loadRecord('100');
    %   controller.processSignal();
    %   data = controller.getProcessedData();
    %
    % Author: ECG Signal Processing Team
    % Date: March 2026
    
    properties (Access = private)
        % Path management
        pathManager
        
        % Data storage
        currentRecord       % Current record name
        rawECG              % Raw ECG signal
        cleanECG            % Preprocessed ECG
        filteredECG         % Filtered ECG
        samplingRate        % Sampling frequency (Hz)
        annotations         % R-peak annotations from file
        annotationSymbols   % Annotation symbols
        
        % Detection results
        rPeaks              % Detected R-peak locations
        rPeakAmplitudes     % R-peak amplitudes
        pWaves              % Detected P-wave locations
        tWaves              % Detected T-wave locations
        
        % Calculated metrics
        rrIntervals         % RR intervals (seconds)
        heartRate           % Instantaneous heart rate (BPM)
        hrvMetrics          % HRV metrics structure
        
        % Processing parameters
        params              % Processing parameters structure
        
        % Status flags
        isDataLoaded        % Flag: data loaded
        isProcessed         % Flag: signal processed
        isDetected          % Flag: peaks detected
    end
    
    methods
        %% Constructor
        function obj = ECGController()
            % Initialize controller with default settings
            
            % Setup path management
            obj.pathManager = PathManager();
            obj.pathManager.setupMatlabPath();
            
            % Initialize status flags
            obj.isDataLoaded = false;
            obj.isProcessed = false;
            obj.isDetected = false;
            
            % Set default processing parameters
            obj.initializeParameters();
        end
        
        %% Initialization
        function initializeParameters(obj)
            % Set default processing parameters
            obj.params = struct();
            obj.params.enableNotchFilter = true;      % Enable 50Hz notch filter
            obj.params.notchFreq = 50;                % Notch filter frequency
            obj.params.bandpassLow = 5;               % Bandpass low cutoff
            obj.params.bandpassHigh = 15;             % Bandpass high cutoff
            obj.params.detectionSensitivity = 1.0;    % R-peak detection sensitivity (0.5-2.0)
            obj.params.enablePTDetection = true;      % Enable P and T wave detection
        end
        
        %% Data Management
        function recordList = getAvailableRecords(obj)
            % Get list of available ECG records
            recordList = obj.pathManager.getAvailableRecords();
        end
        
        function success = loadRecord(obj, recordName)
            % Load ECG record from data directory
            %
            % Inputs:
            %   recordName - String name of record (e.g., '100', '103')
            %
            % Outputs:
            %   success - Boolean indicating successful load
            
            try
                % Reset previous data
                obj.resetData();
                
                % Load ECG data using backend function
                dataPath = obj.pathManager.getDataRawPath();
                [obj.rawECG, obj.samplingRate, obj.annotations, obj.annotationSymbols] = ...
                    load_ecg(recordName, dataPath);
                
                % Store record name
                obj.currentRecord = recordName;
                
                % Update status
                obj.isDataLoaded = true;
                success = true;
                
            catch ME
                obj.isDataLoaded = false;
                success = false;
                rethrow(ME);
            end
        end
        
        function success = processSignal(obj)
            % Process loaded ECG signal (preprocess + filter + detect)
            %
            % Outputs:
            %   success - Boolean indicating successful processing
            
            if ~obj.isDataLoaded
                error('ECGController:NoData', 'No ECG data loaded. Load a record first.');
            end
            
            try
                % Step 1: Preprocess
                dataPath = obj.pathManager.getDataRawPath();
                [obj.cleanECG, ~, ~] = preprocess_ecg(obj.currentRecord, dataPath);
                
                % Step 2: Filter
                [obj.filteredECG, ~] = filter_ecg(obj.cleanECG, obj.samplingRate);
                
                % Step 3: Detect R-peaks
                [obj.rPeaks, obj.rPeakAmplitudes] = ...
                    r_peak_detection(obj.filteredECG, obj.samplingRate);
                
                % Step 4: Detect P and T waves (if enabled)
                if obj.params.enablePTDetection && ~isempty(obj.rPeaks)
                    [obj.pWaves, obj.tWaves] = ...
                        detect_p_t_waves(obj.filteredECG, obj.rPeaks, obj.samplingRate);
                else
                    obj.pWaves = [];
                    obj.tWaves = [];
                end
                
                % Step 5: Calculate metrics
                obj.calculateMetrics();
                
                % Update status
                obj.isProcessed = true;
                obj.isDetected = true;
                success = true;
                
            catch ME
                obj.isProcessed = false;
                obj.isDetected = false;
                success = false;
                rethrow(ME);
            end
        end
        
        function calculateMetrics(obj)
            % Calculate heart rate and HRV metrics from detected R-peaks
            
            if isempty(obj.rPeaks) || length(obj.rPeaks) < 2
                obj.rrIntervals = [];
                obj.heartRate = [];
                obj.hrvMetrics = struct();
                return;
            end
            
            % Calculate RR intervals in seconds
            obj.rrIntervals = diff(obj.rPeaks) / obj.samplingRate;
            
            % Calculate instantaneous heart rate in BPM
            obj.heartRate = 60 ./ obj.rrIntervals;
            
            % Calculate HRV metrics
            obj.hrvMetrics = struct();
            obj.hrvMetrics.meanHR = mean(obj.heartRate);
            obj.hrvMetrics.stdHR = std(obj.heartRate);
            obj.hrvMetrics.minHR = min(obj.heartRate);
            obj.hrvMetrics.maxHR = max(obj.heartRate);
            obj.hrvMetrics.meanRR = mean(obj.rrIntervals) * 1000;  % ms
            obj.hrvMetrics.sdnn = std(obj.rrIntervals) * 1000;     % ms (SDNN)
            obj.hrvMetrics.rmssd = sqrt(mean(diff(obj.rrIntervals).^2)) * 1000; % ms (RMSSD)
        end
        
        function resetData(obj)
            % Clear all loaded data and reset status
            obj.currentRecord = '';
            obj.rawECG = [];
            obj.cleanECG = [];
            obj.filteredECG = [];
            obj.samplingRate = [];
            obj.annotations = [];
            obj.annotationSymbols = [];
            obj.rPeaks = [];
            obj.rPeakAmplitudes = [];
            obj.pWaves = [];
            obj.tWaves = [];
            obj.rrIntervals = [];
            obj.heartRate = [];
            obj.hrvMetrics = struct();
            obj.isDataLoaded = false;
            obj.isProcessed = false;
            obj.isDetected = false;
        end
        
        %% Getters
        function data = getRawData(obj)
            % Return raw ECG data
            data = obj.rawECG;
        end
        
        function data = getFilteredData(obj)
            % Return filtered ECG data
            data = obj.filteredECG;
        end
        
        function data = getCleanData(obj)
            % Return preprocessed (clean) ECG data
            data = obj.cleanECG;
        end
        
        function fs = getSamplingRate(obj)
            % Return sampling rate
            fs = obj.samplingRate;
        end
        
        function duration = getSignalDuration(obj)
            % Return signal duration in seconds
            if obj.isDataLoaded
                duration = length(obj.rawECG) / obj.samplingRate;
            else
                duration = 0;
            end
        end
        
        function peaks = getRPeaks(obj)
            % Return R-peak locations
            peaks = obj.rPeaks;
        end
        
        function peaks = getPWaves(obj)
            % Return P-wave locations
            peaks = obj.pWaves;
        end
        
        function peaks = getTWaves(obj)
            % Return T-wave locations
            peaks = obj.tWaves;
        end
        
        function hr = getHeartRate(obj)
            % Return heart rate array
            hr = obj.heartRate;
        end
        
        function metrics = getHRVMetrics(obj)
            % Return HRV metrics structure
            metrics = obj.hrvMetrics;
        end
        
        function name = getCurrentRecord(obj)
            % Return current record name
            name = obj.currentRecord;
        end
        
        function info = getRecordInfo(obj)
            % Return comprehensive record information
            info = struct();
            info.recordName = obj.currentRecord;
            info.isLoaded = obj.isDataLoaded;
            info.isProcessed = obj.isProcessed;
            
            if obj.isDataLoaded
                info.samplingRate = obj.samplingRate;
                info.duration = obj.getSignalDuration();
                info.samples = length(obj.rawECG);
            end
            
            if obj.isDetected
                info.numRPeaks = length(obj.rPeaks);
                info.numPWaves = length(obj.pWaves);
                info.numTWaves = length(obj.tWaves);
            end
        end
        
        %% Status Checks
        function status = isLoaded(obj)
            % Check if data is loaded
            status = obj.isDataLoaded;
        end
        
        function status = isSignalProcessed(obj)
            % Check if signal is processed
            status = obj.isProcessed;
        end
        
        function status = arePeaksDetected(obj)
            % Check if peaks are detected
            status = obj.isDetected;
        end
        
        %% Parameter Management
        function setParameter(obj, paramName, value)
            % Set processing parameter
            %
            % Inputs:
            %   paramName - String name of parameter
            %   value - New parameter value
            
            if isfield(obj.params, paramName)
                obj.params.(paramName) = value;
            else
                error('ECGController:InvalidParam', ...
                    'Unknown parameter: %s', paramName);
            end
        end
        
        function value = getParameter(obj, paramName)
            % Get processing parameter value
            if isfield(obj.params, paramName)
                value = obj.params.(paramName);
            else
                error('ECGController:InvalidParam', ...
                    'Unknown parameter: %s', paramName);
            end
        end
        
        function params = getAllParameters(obj)
            % Return all processing parameters
            params = obj.params;
        end
        
        %% Export Functions
        function success = exportPlot(obj, axesHandle, filename)
            % Export current plot to file
            %
            % Inputs:
            %   axesHandle - Handle to axes to export
            %   filename - Output filename (with extension)
            
            try
                % Create figure from axes
                fig = figure('Visible', 'off', 'Position', [0, 0, 1200, 600]);
                newAx = copyobj(axesHandle, fig);
                newAx.Position = [0.1, 0.1, 0.85, 0.8];
                
                % Save to plots directory
                outputPath = obj.pathManager.getOutputFilePath('plots', filename);
                saveas(fig, outputPath);
                close(fig);
                
                success = true;
            catch ME
                success = false;
                rethrow(ME);
            end
        end
        
        function success = exportResults(obj, filename)
            % Export processing results to MAT file
            %
            % Inputs:
            %   filename - Output filename (with .mat extension)
            
            if ~obj.isProcessed
                error('ECGController:NoResults', 'No processed results to export.');
            end
            
            try
                % Prepare data structure
                results = struct();
                results.recordName = obj.currentRecord;
                results.samplingRate = obj.samplingRate;
                results.rawECG = obj.rawECG;
                results.filteredECG = obj.filteredECG;
                results.rPeaks = obj.rPeaks;
                results.pWaves = obj.pWaves;
                results.tWaves = obj.tWaves;
                results.heartRate = obj.heartRate;
                results.hrvMetrics = obj.hrvMetrics;
                results.processingParams = obj.params;
                results.timestamp = datestr(now);
                
                % Save to reports directory
                outputPath = obj.pathManager.getOutputFilePath('reports', filename);
                save(outputPath, '-struct', 'results');
                
                success = true;
            catch ME
                success = false;
                rethrow(ME);
            end
        end
        
        function success = exportMetricsCSV(obj, filename)
            % Export HRV metrics to CSV file
            %
            % Inputs:
            %   filename - Output filename (with .csv extension)
            
            if ~obj.isProcessed
                error('ECGController:NoResults', 'No processed results to export.');
            end
            
            try
                % Create table with metrics
                metricNames = fieldnames(obj.hrvMetrics);
                metricValues = struct2cell(obj.hrvMetrics);
                T = table(metricNames, metricValues, ...
                    'VariableNames', {'Metric', 'Value'});
                
                % Save to reports directory
                outputPath = obj.pathManager.getOutputFilePath('reports', filename);
                writetable(T, outputPath);
                
                success = true;
            catch ME
                success = false;
                rethrow(ME);
            end
        end
        
        %% Utility Functions
        function timeVector = getTimeVector(obj, signalLength)
            % Generate time vector for plotting
            %
            % Inputs:
            %   signalLength - Length of signal in samples
            %
            % Outputs:
            %   timeVector - Time vector in seconds
            
            if nargin < 2
                signalLength = length(obj.rawECG);
            end
            
            timeVector = (0:signalLength-1) / obj.samplingRate;
        end
        
        function pm = getPathManager(obj)
            % Return PathManager instance
            pm = obj.pathManager;
        end
    end
end
