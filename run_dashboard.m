%% ECG SIGNAL PROCESSING DASHBOARD LAUNCHER
% 
% Simple script to launch the ECG Dashboard GUI application
%
% Usage: Just run this script in MATLAB
%   >> run_dashboard
%
% Or from command line:
%   >> run_dashboard()
%
% The dashboard will automatically:
%   - Detect project paths
%   - Setup MATLAB path with necessary directories  
%   - Initialize the GUI interface
%   - Load available ECG records
%
% Author: ECG Signal Processing Team
% Date: March 2026

function run_dashboard()
    % Clear command window for clean start
    clc;
    
    fprintf('\n');
    fprintf('═══════════════════════════════════════════════════════════════\n');
    fprintf('   ECG SIGNAL PROCESSING DASHBOARD\n');
    fprintf('═══════════════════════════════════════════════════════════════\n\n');
    
    % Get script location and setup paths
    fprintf('Setting up environment...\n');
    scriptPath = fileparts(mfilename('fullpath'));
    projectRoot = scriptPath;
    
    % Add necessary paths
    addpath(fullfile(projectRoot, 'src', 'utils'));
    addpath(fullfile(projectRoot, 'src', 'gui'));
    addpath(genpath(fullfile(projectRoot, 'src', 'matlab')));
    
    fprintf('✓ Paths configured\n');
    
    % Check for required toolboxes
    fprintf('Checking requirements...\n');
    
    if license('test', 'Signal_Toolbox')
        fprintf('✓ Signal Processing Toolbox found\n');
    else
        warning('Signal Processing Toolbox not found - some features may not work');
    end
    
    % Check for data directory
    dataDir = fullfile(projectRoot, 'data', 'raw');
    if exist(dataDir, 'dir')
        datFiles = dir(fullfile(dataDir, '*.dat'));
        fprintf('✓ Data directory found (%d records available)\n', length(datFiles));
    else
        warning('Data directory not found at: %s', dataDir);
        fprintf('  Please ensure ECG data files are in data/raw/\n');
    end
    
    fprintf('\nLaunching dashboard...\n\n');
    
    % Launch the GUI
    try
        app = ECGDashboard();
        fprintf('✓ Dashboard launched successfully!\n\n');
        fprintf('═══════════════════════════════════════════════════════════════\n');
        fprintf('  Use the GUI to load and process ECG signals\n');
        fprintf('═══════════════════════════════════════════════════════════════\n\n');
        
    catch ME
        fprintf('\n✗ ERROR: Failed to launch dashboard\n');
        fprintf('  Reason: %s\n\n', ME.message);
        fprintf('  Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('    %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        fprintf('\n');
        rethrow(ME);
    end
end
