classdef PathManager
    % PATHMANAGER Centralized path management for ECG Signal Processing Project
    %
    % This class provides a single source of truth for all project paths,
    % ensuring consistency between GUI and backend components.
    %
    % Usage:
    %   pm = PathManager();
    %   dataPath = pm.getDataRawPath();
    %   resultsPath = pm.getResultsPlotsPath();
    %
    % Author: ECG Signal Processing Team
    % Date: March 2026
    
    properties (Access = private)
        projectRoot     % Root directory of the project
        dataRaw         % Path to raw ECG data
        dataProcessed   % Path to processed data
        resultsDir      % Path to results directory
        resultsPlots    % Path to plots subdirectory
        resultsReports  % Path to reports subdirectory
        resultsLogs     % Path to logs subdirectory
        srcMatlab       % Path to MATLAB backend source
        srcGui          % Path to GUI source
    end
    
    methods
        function obj = PathManager()
            % Constructor - Auto-detects project root from current location
            
            % Try to detect from this file's location
            currentFile = mfilename('fullpath');
            utilsDir = fileparts(currentFile);
            obj.projectRoot = fileparts(utilsDir);
            
            % If that fails, try from current directory
            if ~exist(fullfile(obj.projectRoot, 'data'), 'dir')
                currentDir = pwd;
                % Navigate up to find project root (look for 'data' folder)
                while ~exist(fullfile(currentDir, 'data'), 'dir')
                    parentDir = fileparts(currentDir);
                    if strcmp(parentDir, currentDir)
                        error('PathManager:RootNotFound', ...
                            'Could not locate project root. Ensure you are within the project directory.');
                    end
                    currentDir = parentDir;
                end
                obj.projectRoot = currentDir;
            end
            
            % Initialize all paths
            obj = obj.initializePaths();
            
            % Create directories if they don't exist
            obj.createDirectories();
        end
        
        function obj = initializePaths(obj)
            % Initialize all project paths relative to root
            obj.dataRaw = fullfile(obj.projectRoot, 'data', 'raw');
            obj.dataProcessed = fullfile(obj.projectRoot, 'data', 'processed');
            obj.resultsDir = fullfile(obj.projectRoot, 'results');
            obj.resultsPlots = fullfile(obj.resultsDir, 'plots');
            obj.resultsReports = fullfile(obj.resultsDir, 'reports');
            obj.resultsLogs = fullfile(obj.resultsDir, 'logs');
            obj.srcMatlab = fullfile(obj.projectRoot, 'src', 'matlab');
            obj.srcGui = fullfile(obj.projectRoot, 'src', 'gui');
        end
        
        function createDirectories(obj)
            % Create output directories if they don't exist
            dirs = {obj.dataProcessed, obj.resultsPlots, ...
                    obj.resultsReports, obj.resultsLogs};
            for i = 1:length(dirs)
                if ~exist(dirs{i}, 'dir')
                    mkdir(dirs{i});
                end
            end
        end
        
        % Getter methods
        function path = getProjectRoot(obj)
            path = obj.projectRoot;
        end
        
        function path = getDataRawPath(obj)
            path = obj.dataRaw;
        end
        
        function path = getDataProcessedPath(obj)
            path = obj.dataProcessed;
        end
        
        function path = getResultsPath(obj)
            path = obj.resultsDir;
        end
        
        function path = getResultsPlotsPath(obj)
            path = obj.resultsPlots;
        end
        
        function path = getResultsReportsPath(obj)
            path = obj.resultsReports;
        end
        
        function path = getResultsLogsPath(obj)
            path = obj.resultsLogs;
        end
        
        function path = getSrcMatlabPath(obj)
            path = obj.srcMatlab;
        end
        
        function path = getSrcGuiPath(obj)
            path = obj.srcGui;
        end
        
        function setupMatlabPath(obj)
            % Add necessary directories to MATLAB path
            addpath(genpath(obj.srcMatlab));
            addpath(obj.srcGui);
        end
        
        function records = getAvailableRecords(obj)
            % Get list of available ECG records from data/raw directory
            % Returns cell array of record names (without extensions)
            
            records = {};
            if ~exist(obj.dataRaw, 'dir')
                warning('PathManager:DataDirNotFound', ...
                    'Data directory not found: %s', obj.dataRaw);
                return;
            end
            
            % Look for .dat files (ECG data files)
            datFiles = dir(fullfile(obj.dataRaw, '*.dat'));
            
            if isempty(datFiles)
                warning('PathManager:NoRecordsFound', ...
                    'No ECG record files (.dat) found in: %s', obj.dataRaw);
                return;
            end
            
            % Extract record names (filename without extension)
            records = cell(length(datFiles), 1);
            for i = 1:length(datFiles)
                [~, records{i}, ~] = fileparts(datFiles(i).name);
            end
            
            % Sort records numerically if possible
            try
                numRecords = cellfun(@str2double, records);
                [~, sortIdx] = sort(numRecords);
                records = records(sortIdx);
            catch
                % If not numeric, sort alphabetically
                records = sort(records);
            end
        end
        
        function timestamp = generateTimestamp(~)
            % Generate timestamp string for file naming
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        end
        
        function filename = generateOutputFilename(obj, prefix, recordName, extension)
            % Generate standardized output filename with timestamp
            % Example: generateOutputFilename('results', '100', '.mat')
            %          returns 'results_100_20260331_185530.mat'
            
            timestamp = obj.generateTimestamp();
            filename = sprintf('%s_%s_%s%s', prefix, recordName, timestamp, extension);
        end
        
        function fullPath = getOutputFilePath(obj, subdirName, filename)
            % Get full path for output file in results subdirectory
            % subdirName: 'plots', 'reports', or 'logs'
            
            switch lower(subdirName)
                case 'plots'
                    fullPath = fullfile(obj.resultsPlots, filename);
                case 'reports'
                    fullPath = fullfile(obj.resultsReports, filename);
                case 'logs'
                    fullPath = fullfile(obj.resultsLogs, filename);
                otherwise
                    fullPath = fullfile(obj.resultsDir, filename);
            end
        end
        
        function info = getPathInfo(obj)
            % Return structure with all path information for debugging
            info = struct();
            info.projectRoot = obj.projectRoot;
            info.dataRaw = obj.dataRaw;
            info.dataProcessed = obj.dataProcessed;
            info.resultsDir = obj.resultsDir;
            info.resultsPlots = obj.resultsPlots;
            info.resultsReports = obj.resultsReports;
            info.resultsLogs = obj.resultsLogs;
            info.srcMatlab = obj.srcMatlab;
            info.srcGui = obj.srcGui;
        end
    end
end
