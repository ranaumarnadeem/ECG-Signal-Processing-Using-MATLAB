classdef ECGDashboard < handle
    % ECGDASHBOARD Professional GUI for ECG Signal Processing
    %
    % This dashboard provides a user-friendly interface for:
    %   - Loading ECG records from database
    %   - Processing ECG signals with customizable parameters
    %   - Visualizing raw, filtered, and detected signals
    %   - Displaying real-time statistics and metrics
    %   - Exporting results and plots
    %
    % Usage:
    %   app = ECGDashboard();
    %
    % NOTE: This file can be opened in App Designer for visual editing
    % or run directly as a standalone GUI application.
    %
    % Author: ECG Signal Processing Team
    % Date: March 2026
    
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        
        % Main Layout
        GridLayout                  matlab.ui.container.GridLayout
        LeftPanel                   matlab.ui.container.Panel
        RightPanel                  matlab.ui.container.Panel
        
        % Left Panel Components
        TitleLabel                  matlab.ui.control.Label
        RecordPanel                 matlab.ui.container.Panel
        RecordDropDown              matlab.ui.control.DropDown
        RecordInfoText              matlab.ui.control.TextArea
        LoadButton                  matlab.ui.control.Button
        
        ControlPanel                matlab.ui.container.Panel
        ProcessButton               matlab.ui.control.Button
        ClearButton                 matlab.ui.control.Button
        
        OptionsPanel                matlab.ui.container.Panel
        NotchFilterCheckBox         matlab.ui.control.CheckBox
        PTWaveCheckBox              matlab.ui.control.CheckBox
        SensitivityLabel            matlab.ui.control.Label
        SensitivitySlider           matlab.ui.control.Slider
        
        StatisticsPanel             matlab.ui.container.Panel
        StatsTextArea               matlab.ui.control.TextArea
        
        ExportPanel                 matlab.ui.container.Panel
        ExportPlotButton            matlab.ui.control.Button
        ExportDataButton            matlab.ui.control.Button
        ExportMetricsButton         matlab.ui.control.Button
        
        StatusPanel                 matlab.ui.container.Panel
        StatusTextArea              matlab.ui.control.TextArea
        
        % Right Panel Components
        PlotTabGroup                matlab.ui.container.TabGroup
        RawSignalTab                matlab.ui.container.Tab
        FilteredSignalTab           matlab.ui.container.Tab
        DetectionTab                matlab.ui.container.Tab
        
        RawAxes                     matlab.ui.control.UIAxes
        FilteredAxes                matlab.ui.control.UIAxes
        DetectionAxes               matlab.ui.control.UIAxes
    end
    
    properties (Access = private)
        Controller                  % ECGController instance
        CurrentAxes                 % Currently active axes
    end
    
    methods (Access = public)
        
        function app = ECGDashboard()
            % Constructor - Create and configure all UI components
            
            % Create UIFigure and components
            createComponents(app);
            
            % Initialize controller
            app.Controller = ECGController();
            
            % Populate record list
            populateRecordList(app);
            
            % Add welcome message
            logStatus(app, 'ECG Signal Processing Dashboard Initialized');
            logStatus(app, 'Load a record to begin processing');
            
            % Make figure visible
            app.UIFigure.Visible = 'on';
        end
    end
    
    methods (Access = private)
        
        %% Component Creation
        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1400 800];
            app.UIFigure.Name = 'ECG Signal Processing Dashboard';
            app.UIFigure.Icon = '';
            
            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {350, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.Padding = [10 10 10 10];
            app.GridLayout.ColumnSpacing = 10;
            
            % Create Left Panel
            createLeftPanel(app);
            
            % Create Right Panel
            createRightPanel(app);
        end
        
        function createLeftPanel(app)
            % Create main left panel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = 'Control Panel';
            app.LeftPanel.FontWeight = 'bold';
            app.LeftPanel.FontSize = 12;
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            
            % Create grid layout for left panel
            leftGrid = uigridlayout(app.LeftPanel);
            leftGrid.RowHeight = {40, 150, 100, 120, 180, 100, '1x'};
            leftGrid.ColumnWidth = {'1x'};
            leftGrid.Padding = [10 10 10 10];
            leftGrid.RowSpacing = 10;
            
            % Title Label
            app.TitleLabel = uilabel(leftGrid);
            app.TitleLabel.Text = 'ECG SIGNAL PROCESSOR';
            app.TitleLabel.FontSize = 16;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.FontColor = [0.0 0.4 0.7];
            app.TitleLabel.HorizontalAlignment = 'center';
            app.TitleLabel.Layout.Row = 1;
            app.TitleLabel.Layout.Column = 1;
            
            % Record Selection Panel
            createRecordPanel(app, leftGrid, 2);
            
            % Control Buttons Panel
            createControlPanel(app, leftGrid, 3);
            
            % Options Panel
            createOptionsPanel(app, leftGrid, 4);
            
            % Statistics Panel
            createStatisticsPanel(app, leftGrid, 5);
            
            % Export Panel
            createExportPanel(app, leftGrid, 6);
            
            % Status Panel
            createStatusPanel(app, leftGrid, 7);
        end
        
        function createRecordPanel(app, parentGrid, row)
            % Record Selection Panel
            app.RecordPanel = uipanel(parentGrid);
            app.RecordPanel.Title = 'ECG Record';
            app.RecordPanel.FontWeight = 'bold';
            app.RecordPanel.Layout.Row = row;
            app.RecordPanel.Layout.Column = 1;
            
            recGrid = uigridlayout(app.RecordPanel);
            recGrid.RowHeight = {25, 50, 30};
            recGrid.ColumnWidth = {'1x'};
            recGrid.Padding = [10 5 10 5];
            
            % Dropdown
            app.RecordDropDown = uidropdown(recGrid);
            app.RecordDropDown.Items = {'Select Record...'};
            app.RecordDropDown.Layout.Row = 1;
            app.RecordDropDown.Layout.Column = 1;
            app.RecordDropDown.ValueChangedFcn = @(src,event) recordSelected(app, event);
            
            % Info text
            app.RecordInfoText = uitextarea(recGrid);
            app.RecordInfoText.Value = {'No record selected'};
            app.RecordInfoText.Editable = 'off';
            app.RecordInfoText.Layout.Row = 2;
            app.RecordInfoText.Layout.Column = 1;
            
            % Load button
            app.LoadButton = uibutton(recGrid, 'push');
            app.LoadButton.Text = 'Load Record';
            app.LoadButton.Layout.Row = 3;
            app.LoadButton.Layout.Column = 1;
            app.LoadButton.ButtonPushedFcn = @(src,event) loadButtonPushed(app);
            app.LoadButton.BackgroundColor = [0.0 0.6 0.4];
            app.LoadButton.FontColor = [1 1 1];
            app.LoadButton.FontWeight = 'bold';
        end
        
        function createControlPanel(app, parentGrid, row)
            % Control Buttons Panel
            app.ControlPanel = uipanel(parentGrid);
            app.ControlPanel.Title = 'Processing Control';
            app.ControlPanel.FontWeight = 'bold';
            app.ControlPanel.Layout.Row = row;
            app.ControlPanel.Layout.Column = 1;
            
            ctrlGrid = uigridlayout(app.ControlPanel);
            ctrlGrid.RowHeight = {35, 35};
            ctrlGrid.ColumnWidth = {'1x'};
            ctrlGrid.Padding = [10 5 10 5];
            
            % Process button
            app.ProcessButton = uibutton(ctrlGrid, 'push');
            app.ProcessButton.Text = 'Process Signal';
            app.ProcessButton.Layout.Row = 1;
            app.ProcessButton.Layout.Column = 1;
            app.ProcessButton.ButtonPushedFcn = @(src,event) processButtonPushed(app);
            app.ProcessButton.Enable = 'off';
            app.ProcessButton.BackgroundColor = [0.2 0.5 0.9];
            app.ProcessButton.FontColor = [1 1 1];
            app.ProcessButton.FontWeight = 'bold';
            
            % Clear button
            app.ClearButton = uibutton(ctrlGrid, 'push');
            app.ClearButton.Text = 'Clear All';
            app.ClearButton.Layout.Row = 2;
            app.ClearButton.Layout.Column = 1;
            app.ClearButton.ButtonPushedFcn = @(src,event) clearButtonPushed(app);
            app.ClearButton.BackgroundColor = [0.8 0.3 0.3];
            app.ClearButton.FontColor = [1 1 1];
        end
        
        function createOptionsPanel(app, parentGrid, row)
            % Processing Options Panel
            app.OptionsPanel = uipanel(parentGrid);
            app.OptionsPanel.Title = 'Processing Options';
            app.OptionsPanel.FontWeight = 'bold';
            app.OptionsPanel.Layout.Row = row;
            app.OptionsPanel.Layout.Column = 1;
            
            optGrid = uigridlayout(app.OptionsPanel);
            optGrid.RowHeight = {25, 25, 20, 25};
            optGrid.ColumnWidth = {'1x'};
            optGrid.Padding = [10 5 10 5];
            
            % Notch filter checkbox
            app.NotchFilterCheckBox = uicheckbox(optGrid);
            app.NotchFilterCheckBox.Text = 'Enable 50 Hz Notch Filter';
            app.NotchFilterCheckBox.Value = true;
            app.NotchFilterCheckBox.Layout.Row = 1;
            app.NotchFilterCheckBox.Layout.Column = 1;
            
            % P/T wave checkbox
            app.PTWaveCheckBox = uicheckbox(optGrid);
            app.PTWaveCheckBox.Text = 'Detect P and T Waves';
            app.PTWaveCheckBox.Value = true;
            app.PTWaveCheckBox.Layout.Row = 2;
            app.PTWaveCheckBox.Layout.Column = 1;
            
            % Sensitivity label
            app.SensitivityLabel = uilabel(optGrid);
            app.SensitivityLabel.Text = 'Detection Sensitivity: 1.0';
            app.SensitivityLabel.Layout.Row = 3;
            app.SensitivityLabel.Layout.Column = 1;
            
            % Sensitivity slider
            app.SensitivitySlider = uislider(optGrid);
            app.SensitivitySlider.Limits = [0.5 2.0];
            app.SensitivitySlider.Value = 1.0;
            app.SensitivitySlider.Layout.Row = 4;
            app.SensitivitySlider.Layout.Column = 1;
            app.SensitivitySlider.ValueChangedFcn = @(src,event) sensitivityChanged(app, event);
        end
        
        function createStatisticsPanel(app, parentGrid, row)
            % Statistics Display Panel
            app.StatisticsPanel = uipanel(parentGrid);
            app.StatisticsPanel.Title = 'Statistics';
            app.StatisticsPanel.FontWeight = 'bold';
            app.StatisticsPanel.Layout.Row = row;
            app.StatisticsPanel.Layout.Column = 1;
            
            statGrid = uigridlayout(app.StatisticsPanel);
            statGrid.RowHeight = {'1x'};
            statGrid.ColumnWidth = {'1x'};
            statGrid.Padding = [10 5 10 5];
            
            % Stats text area
            app.StatsTextArea = uitextarea(statGrid);
            app.StatsTextArea.Value = {'No statistics available'};
            app.StatsTextArea.Editable = 'off';
            app.StatsTextArea.Layout.Row = 1;
            app.StatsTextArea.Layout.Column = 1;
            app.StatsTextArea.FontName = 'Courier New';
            app.StatsTextArea.FontSize = 10;
        end
        
        function createExportPanel(app, parentGrid, row)
            % Export Options Panel
            app.ExportPanel = uipanel(parentGrid);
            app.ExportPanel.Title = 'Export Results';
            app.ExportPanel.FontWeight = 'bold';
            app.ExportPanel.Layout.Row = row;
            app.ExportPanel.Layout.Column = 1;
            
            expGrid = uigridlayout(app.ExportPanel);
            expGrid.RowHeight = {28, 28, 28};
            expGrid.ColumnWidth = {'1x'};
            expGrid.Padding = [10 5 10 5];
            
            % Export plot button
            app.ExportPlotButton = uibutton(expGrid, 'push');
            app.ExportPlotButton.Text = 'Export Plot';
            app.ExportPlotButton.Layout.Row = 1;
            app.ExportPlotButton.Layout.Column = 1;
            app.ExportPlotButton.ButtonPushedFcn = @(src,event) exportPlotButtonPushed(app);
            app.ExportPlotButton.Enable = 'off';
            
            % Export data button
            app.ExportDataButton = uibutton(expGrid, 'push');
            app.ExportDataButton.Text = 'Export Data (.mat)';
            app.ExportDataButton.Layout.Row = 2;
            app.ExportDataButton.Layout.Column = 1;
            app.ExportDataButton.ButtonPushedFcn = @(src,event) exportDataButtonPushed(app);
            app.ExportDataButton.Enable = 'off';
            
            % Export metrics button
            app.ExportMetricsButton = uibutton(expGrid, 'push');
            app.ExportMetricsButton.Text = 'Export Metrics (.csv)';
            app.ExportMetricsButton.Layout.Row = 3;
            app.ExportMetricsButton.Layout.Column = 1;
            app.ExportMetricsButton.ButtonPushedFcn = @(src,event) exportMetricsButtonPushed(app);
            app.ExportMetricsButton.Enable = 'off';
        end
        
        function createStatusPanel(app, parentGrid, row)
            % Status Log Panel
            app.StatusPanel = uipanel(parentGrid);
            app.StatusPanel.Title = 'Status Log';
            app.StatusPanel.FontWeight = 'bold';
            app.StatusPanel.Layout.Row = row;
            app.StatusPanel.Layout.Column = 1;
            
            statGrid = uigridlayout(app.StatusPanel);
            statGrid.RowHeight = {'1x'};
            statGrid.ColumnWidth = {'1x'};
            statGrid.Padding = [10 5 10 5];
            
            % Status text area
            app.StatusTextArea = uitextarea(statGrid);
            app.StatusTextArea.Value = {''};
            app.StatusTextArea.Editable = 'off';
            app.StatusTextArea.Layout.Row = 1;
            app.StatusTextArea.Layout.Column = 1;
            app.StatusTextArea.FontSize = 9;
        end
        
        function createRightPanel(app)
            % Create main right panel with tabs
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Title = 'Signal Visualization';
            app.RightPanel.FontWeight = 'bold';
            app.RightPanel.FontSize = 12;
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            
            % Create grid layout for right panel
            rightGrid = uigridlayout(app.RightPanel);
            rightGrid.RowHeight = {'1x'};
            rightGrid.ColumnWidth = {'1x'};
            rightGrid.Padding = [10 10 10 10];
            
            % Create Tab Group
            app.PlotTabGroup = uitabgroup(rightGrid);
            app.PlotTabGroup.Layout.Row = 1;
            app.PlotTabGroup.Layout.Column = 1;
            
            % Create tabs
            createTabs(app);
        end
        
        function createTabs(app)
            % Create Raw Signal Tab
            app.RawSignalTab = uitab(app.PlotTabGroup);
            app.RawSignalTab.Title = 'Raw Signal';
            
            app.RawAxes = uiaxes(app.RawSignalTab);
            app.RawAxes.Position = [20 20 940 620];
            title(app.RawAxes, 'Raw ECG Signal')
            xlabel(app.RawAxes, 'Time (s)')
            ylabel(app.RawAxes, 'Amplitude (mV)')
            grid(app.RawAxes, 'on')
            
            % Create Filtered Signal Tab
            app.FilteredSignalTab = uitab(app.PlotTabGroup);
            app.FilteredSignalTab.Title = 'Filtered Signal';
            
            app.FilteredAxes = uiaxes(app.FilteredSignalTab);
            app.FilteredAxes.Position = [20 20 940 620];
            title(app.FilteredAxes, 'Filtered ECG Signal')
            xlabel(app.FilteredAxes, 'Time (s)')
            ylabel(app.FilteredAxes, 'Amplitude (normalized)')
            grid(app.FilteredAxes, 'on')
            
            % Create Detection Tab
            app.DetectionTab = uitab(app.PlotTabGroup);
            app.DetectionTab.Title = 'Peak Detection';
            
            app.DetectionAxes = uiaxes(app.DetectionTab);
            app.DetectionAxes.Position = [20 20 940 620];
            title(app.DetectionAxes, 'ECG with Detected Peaks')
            xlabel(app.DetectionAxes, 'Time (s)')
            ylabel(app.DetectionAxes, 'Amplitude (normalized)')
            grid(app.DetectionAxes, 'on')
        end
        
        %% Callback Functions
        function recordSelected(app, ~)
            % Handle record selection from dropdown
            selectedRecord = app.RecordDropDown.Value;
            if ~strcmp(selectedRecord, 'Select Record...')
                app.RecordInfoText.Value = {sprintf('Selected: %s', selectedRecord), ...
                    'Click "Load Record" to load data'};
            end
        end
        
        function loadButtonPushed(app)
            % Handle Load Record button press
            selectedRecord = app.RecordDropDown.Value;
            
            if strcmp(selectedRecord, 'Select Record...')
                uialert(app.UIFigure, 'Please select a record first', 'No Record Selected');
                return;
            end
            
            % Disable button and show progress
            app.LoadButton.Enable = 'off';
            app.LoadButton.Text = 'Loading...';
            drawnow;
            
            try
                logStatus(app, sprintf('Loading record: %s', selectedRecord));
                
                % Load using controller
                success = app.Controller.loadRecord(selectedRecord);
                
                if success
                    % Update UI
                    info = app.Controller.getRecordInfo();
                    app.RecordInfoText.Value = {
                        sprintf('Record: %s', info.recordName), ...
                        sprintf('Duration: %.1f s', info.duration), ...
                        sprintf('Sampling Rate: %d Hz', info.samplingRate), ...
                        sprintf('Samples: %d', info.samples)
                    };
                    
                    % Enable process button
                    app.ProcessButton.Enable = 'on';
                    
                    % Plot raw signal
                    plotRawSignal(app);
                    
                    logStatus(app, sprintf('Successfully loaded record %s', selectedRecord));
                else
                    uialert(app.UIFigure, 'Failed to load record', 'Load Error');
                    logStatus(app, 'ERROR: Failed to load record');
                end
                
            catch ME
                uialert(app.UIFigure, ME.message, 'Load Error');
                logStatus(app, sprintf('ERROR: %s', ME.message));
            end
            
            % Re-enable button
            app.LoadButton.Enable = 'on';
            app.LoadButton.Text = 'Load Record';
        end
        
        function processButtonPushed(app)
            % Handle Process Signal button press
            
            if ~app.Controller.isLoaded()
                uialert(app.UIFigure, 'Please load a record first', 'No Data');
                return;
            end
            
            % Disable button and show progress
            app.ProcessButton.Enable = 'off';
            app.ProcessButton.Text = 'Processing...';
            drawnow;
            
            try
                logStatus(app, 'Starting signal processing...');
                
                % Update controller parameters from UI
                app.Controller.setParameter('enableNotchFilter', app.NotchFilterCheckBox.Value);
                app.Controller.setParameter('enablePTDetection', app.PTWaveCheckBox.Value);
                app.Controller.setParameter('detectionSensitivity', app.SensitivitySlider.Value);
                
                % Process using controller
                success = app.Controller.processSignal();
                
                if success
                    logStatus(app, 'Signal processing completed successfully');
                    
                    % Plot results
                    plotFilteredSignal(app);
                    plotDetection(app);
                    
                    % Update statistics
                    updateStatistics(app);
                    
                    % Enable export buttons
                    app.ExportPlotButton.Enable = 'on';
                    app.ExportDataButton.Enable = 'on';
                    app.ExportMetricsButton.Enable = 'on';
                    
                    logStatus(app, 'All visualizations updated');
                else
                    uialert(app.UIFigure, 'Processing failed', 'Process Error');
                    logStatus(app, 'ERROR: Processing failed');
                end
                
            catch ME
                uialert(app.UIFigure, ME.message, 'Process Error');
                logStatus(app, sprintf('ERROR: %s', ME.message));
            end
            
            % Re-enable button
            app.ProcessButton.Enable = 'on';
            app.ProcessButton.Text = 'Process Signal';
        end
        
        function clearButtonPushed(app)
            % Handle Clear All button press
            
            % Confirm action
            selection = uiconfirm(app.UIFigure, ...
                'This will clear all loaded data and plots. Continue?', ...
                'Confirm Clear', ...
                'Options', {'Yes', 'No'}, ...
                'DefaultOption', 2);
            
            if strcmp(selection, 'Yes')
                % Reset controller
                app.Controller.resetData();
                
                % Clear plots
                cla(app.RawAxes);
                cla(app.FilteredAxes);
                cla(app.DetectionAxes);
                title(app.RawAxes, 'Raw ECG Signal')
                title(app.FilteredAxes, 'Filtered ECG Signal')
                title(app.DetectionAxes, 'ECG with Detected Peaks')
                
                % Reset UI elements
                app.RecordInfoText.Value = {'No record selected'};
                app.StatsTextArea.Value = {'No statistics available'};
                app.ProcessButton.Enable = 'off';
                app.ExportPlotButton.Enable = 'off';
                app.ExportDataButton.Enable = 'off';
                app.ExportMetricsButton.Enable = 'off';
                
                logStatus(app, 'All data cleared');
            end
        end
        
        function sensitivityChanged(app, event)
            % Handle sensitivity slider change
            value = event.Value;
            app.SensitivityLabel.Text = sprintf('Detection Sensitivity: %.1f', value);
        end
        
        function exportPlotButtonPushed(app)
            % Handle Export Plot button press
            
            % Get current tab
            selectedTab = app.PlotTabGroup.SelectedTab;
            
            if selectedTab == app.RawSignalTab
                currentAxes = app.RawAxes;
                plotType = 'raw';
            elseif selectedTab == app.FilteredSignalTab
                currentAxes = app.FilteredAxes;
                plotType = 'filtered';
            else
                currentAxes = app.DetectionAxes;
                plotType = 'detection';
            end
            
            try
                % Generate filename
                pm = app.Controller.getPathManager();
                recordName = app.Controller.getCurrentRecord();
                filename = pm.generateOutputFilename(plotType, recordName, '.png');
                
                % Export
                app.Controller.exportPlot(currentAxes, filename);
                
                logStatus(app, sprintf('Plot exported: %s', filename));
                uialert(app.UIFigure, sprintf('Plot saved to results/plots/%s', filename), ...
                    'Export Successful', 'Icon', 'success');
                
            catch ME
                uialert(app.UIFigure, ME.message, 'Export Error');
                logStatus(app, sprintf('ERROR: %s', ME.message));
            end
        end
        
        function exportDataButtonPushed(app)
            % Handle Export Data button press
            
            try
                % Generate filename
                pm = app.Controller.getPathManager();
                recordName = app.Controller.getCurrentRecord();
                filename = pm.generateOutputFilename('results', recordName, '.mat');
                
                % Export
                app.Controller.exportResults(filename);
                
                logStatus(app, sprintf('Data exported: %s', filename));
                uialert(app.UIFigure, sprintf('Data saved to results/reports/%s', filename), ...
                    'Export Successful', 'Icon', 'success');
                
            catch ME
                uialert(app.UIFigure, ME.message, 'Export Error');
                logStatus(app, sprintf('ERROR: %s', ME.message));
            end
        end
        
        function exportMetricsButtonPushed(app)
            % Handle Export Metrics button press
            
            try
                % Generate filename
                pm = app.Controller.getPathManager();
                recordName = app.Controller.getCurrentRecord();
                filename = pm.generateOutputFilename('metrics', recordName, '.csv');
                
                % Export
                app.Controller.exportMetricsCSV(filename);
                
                logStatus(app, sprintf('Metrics exported: %s', filename));
                uialert(app.UIFigure, sprintf('Metrics saved to results/reports/%s', filename), ...
                    'Export Successful', 'Icon', 'success');
                
            catch ME
                uialert(app.UIFigure, ME.message, 'Export Error');
                logStatus(app, sprintf('ERROR: %s', ME.message));
            end
        end
        
        %% Plotting Functions
        function plotRawSignal(app)
            % Plot raw ECG signal
            try
                cla(app.RawAxes);
                
                rawData = app.Controller.getRawData();
                fs = app.Controller.getSamplingRate();
                timeVector = app.Controller.getTimeVector(length(rawData));
                
                % Plot first 10 seconds
                maxTime = min(10, timeVector(end));
                idx = timeVector <= maxTime;
                
                plot(app.RawAxes, timeVector(idx), rawData(idx), 'b', 'LineWidth', 0.8);
                xlabel(app.RawAxes, 'Time (s)');
                ylabel(app.RawAxes, 'Amplitude (mV)');
                title(app.RawAxes, sprintf('Raw ECG Signal - Record %s', ...
                    app.Controller.getCurrentRecord()));
                grid(app.RawAxes, 'on');
                
            catch ME
                logStatus(app, sprintf('Plot error: %s', ME.message));
            end
        end
        
        function plotFilteredSignal(app)
            % Plot filtered ECG signal
            try
                cla(app.FilteredAxes);
                
                filteredData = app.Controller.getFilteredData();
                timeVector = app.Controller.getTimeVector(length(filteredData));
                
                % Plot first 10 seconds
                maxTime = min(10, timeVector(end));
                idx = timeVector <= maxTime;
                
                plot(app.FilteredAxes, timeVector(idx), filteredData(idx), ...
                    'Color', [0.2 0.6 0.8], 'LineWidth', 1.0);
                xlabel(app.FilteredAxes, 'Time (s)');
                ylabel(app.FilteredAxes, 'Amplitude (normalized)');
                title(app.FilteredAxes, sprintf('Filtered ECG Signal - Record %s', ...
                    app.Controller.getCurrentRecord()));
                grid(app.FilteredAxes, 'on');
                
            catch ME
                logStatus(app, sprintf('Plot error: %s', ME.message));
            end
        end
        
        function plotDetection(app)
            % Plot ECG with detected peaks
            try
                cla(app.DetectionAxes);
                hold(app.DetectionAxes, 'on');
                
                filteredData = app.Controller.getFilteredData();
                timeVector = app.Controller.getTimeVector(length(filteredData));
                rPeaks = app.Controller.getRPeaks();
                pWaves = app.Controller.getPWaves();
                tWaves = app.Controller.getTWaves();
                fs = app.Controller.getSamplingRate();
                
                % Plot first 10 seconds
                maxTime = min(10, timeVector(end));
                idx = timeVector <= maxTime;
                
                % Plot signal
                plot(app.DetectionAxes, timeVector(idx), filteredData(idx), ...
                    'Color', [0.5 0.5 0.5], 'LineWidth', 0.8);
                
                % Plot R-peaks (red)
                rInWindow = rPeaks(rPeaks <= find(idx, 1, 'last'));
                if ~isempty(rInWindow)
                    rTimes = (rInWindow - 1) / fs;
                    plot(app.DetectionAxes, rTimes, filteredData(rInWindow), ...
                        'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r', ...
                        'DisplayName', 'R-peaks');
                end
                
                % Plot P-waves (blue) if detected
                if ~isempty(pWaves)
                    pInWindow = pWaves(pWaves <= find(idx, 1, 'last'));
                    if ~isempty(pInWindow)
                        pTimes = (pInWindow - 1) / fs;
                        plot(app.DetectionAxes, pTimes, filteredData(pInWindow), ...
                            'bo', 'MarkerSize', 8, 'DisplayName', 'P-waves');
                    end
                end
                
                % Plot T-waves (green) if detected
                if ~isempty(tWaves)
                    tInWindow = tWaves(tWaves <= find(idx, 1, 'last'));
                    if ~isempty(tInWindow)
                        tTimes = (tInWindow - 1) / fs;
                        plot(app.DetectionAxes, tTimes, filteredData(tInWindow), ...
                            'g^', 'MarkerSize', 8, 'DisplayName', 'T-waves');
                    end
                end
                
                xlabel(app.DetectionAxes, 'Time (s)');
                ylabel(app.DetectionAxes, 'Amplitude (normalized)');
                title(app.DetectionAxes, sprintf('Peak Detection - Record %s', ...
                    app.Controller.getCurrentRecord()));
                legend(app.DetectionAxes, 'Location', 'best');
                grid(app.DetectionAxes, 'on');
                hold(app.DetectionAxes, 'off');
                
            catch ME
                logStatus(app, sprintf('Plot error: %s', ME.message));
            end
        end
        
        function updateStatistics(app)
            % Update statistics display
            try
                info = app.Controller.getRecordInfo();
                metrics = app.Controller.getHRVMetrics();
                
                statsText = {
                    '=== DETECTION RESULTS ==='
                    sprintf('R-peaks:  %d', info.numRPeaks)
                    sprintf('P-waves:  %d', info.numPWaves)
                    sprintf('T-waves:  %d', info.numTWaves)
                    ''
                    '=== HEART RATE METRICS ==='
                    sprintf('Mean HR:  %.1f BPM', metrics.meanHR)
                    sprintf('Std HR:   %.1f BPM', metrics.stdHR)
                    sprintf('Min HR:   %.1f BPM', metrics.minHR)
                    sprintf('Max HR:   %.1f BPM', metrics.maxHR)
                    ''
                    '=== HRV METRICS ==='
                    sprintf('Mean RR:  %.1f ms', metrics.meanRR)
                    sprintf('SDNN:     %.1f ms', metrics.sdnn)
                    sprintf('RMSSD:    %.1f ms', metrics.rmssd)
                };
                
                app.StatsTextArea.Value = statsText;
                
            catch ME
                logStatus(app, sprintf('Stats error: %s', ME.message));
            end
        end
        
        %% Utility Functions
        function populateRecordList(app)
            % Populate record dropdown with available records
            try
                records = app.Controller.getAvailableRecords();
                if ~isempty(records)
                    app.RecordDropDown.Items = ['Select Record...'; records];
                    logStatus(app, sprintf('Found %d ECG records', length(records)));
                else
                    app.RecordDropDown.Items = {'No records found'};
                    logStatus(app, 'WARNING: No ECG records found in data/raw/');
                end
            catch ME
                logStatus(app, sprintf('Error loading records: %s', ME.message));
            end
        end
        
        function logStatus(app, message)
            % Add message to status log
            timestamp = datestr(now, 'HH:MM:SS');
            logMessage = sprintf('[%s] %s', timestamp, message);
            
            currentLog = app.StatusTextArea.Value;
            newLog = [currentLog; {logMessage}];
            
            % Keep only last 50 messages
            if length(newLog) > 50
                newLog = newLog(end-49:end);
            end
            
            app.StatusTextArea.Value = newLog;
            
            % Scroll to bottom
            drawnow;
            scroll(app.StatusTextArea, 'bottom');
        end
    end
end
