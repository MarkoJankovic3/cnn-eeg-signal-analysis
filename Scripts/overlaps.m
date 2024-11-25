clear all;

% Load the data
EEG1 = load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/EEG data/raw-caffeine_311/EEG_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.08.46.hdf5_.mat');
EEG2 = load('/home/support-5/Documents/Diplomski/diploma-thesis/scripts/New_Artifacts_EEG_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.08.46_.mat');

% Find the first rejStart element

index1 = find(strcmp({EEG1.EEG.event.type}, 'rejStart'));
EEG1_start = index1(1);

index2 = find(strcmp({EEG2.EEG.event.type}, 'rejStart-new'));
EEG2_start = index2(1);

% Initialize counters
num_of_overlaps = 0;
num_of_non_overlapping_artifacts_EEG2 = 0;
num_of_non_overlapping_artifacts_EEG1 = 0;

% Check for overlaps with EEG2 intervals
for j = EEG2_start:2:length(EEG2.EEG.event) % Iterate over EEG2 intervals
    overlap_count = 0; % Track overlaps for the current EEG2 interval
    
    for i = EEG1_start:2:length(EEG1.EEG.event) % Compare with EEG1 intervals
        % Check for overlap
        if (EEG2.EEG.event(j).latency >= EEG1.EEG.event(i).latency && ...
            EEG2.EEG.event(j).latency <= EEG1.EEG.event(i+1).latency) || ...
           (EEG2.EEG.event(j+1).latency >= EEG1.EEG.event(i).latency && ...
            EEG2.EEG.event(j+1).latency <= EEG1.EEG.event(i+1).latency) || ...
           (EEG1.EEG.event(i).latency >= EEG2.EEG.event(j).latency && ...
            EEG1.EEG.event(i).latency <= EEG2.EEG.event(j+1).latency)
            num_of_overlaps = num_of_overlaps + 1;
            overlap_count = overlap_count + 1; % Increment for this EEG2 interval
            break; % Stop further comparisons for this EEG2 interval
        end
    end
    
    % If no overlaps were found for this interval in EEG2
    if overlap_count == 0
        num_of_non_overlapping_artifacts_EEG2 = num_of_non_overlapping_artifacts_EEG2 + 1;
    end
end

% Check for overlaps with EEG1 intervals
for i = EEG1_start:2:length(EEG1.EEG.event) % Iterate over EEG1 intervals
    overlap_count = 0; % Track overlaps for the current EEG1 interval
    
    for j = EEG2_start:2:length(EEG2.EEG.event) % Compare with EEG2 intervals
        % Check for overlap
        if (EEG1.EEG.event(i).latency >= EEG2.EEG.event(j).latency && ...
            EEG1.EEG.event(i).latency <= EEG2.EEG.event(j+1).latency) || ...
           (EEG1.EEG.event(i+1).latency >= EEG2.EEG.event(j).latency && ...
            EEG1.EEG.event(i+1).latency <= EEG2.EEG.event(j+1).latency) || ...
           (EEG2.EEG.event(j).latency >= EEG1.EEG.event(i).latency && ...
            EEG2.EEG.event(j).latency <= EEG1.EEG.event(i+1).latency)
            overlap_count = overlap_count + 1; % Increment for this EEG1 interval
            break; % Stop further comparisons for this EEG1 interval
        end
    end
    
    % If no overlaps were found for this interval in EEG1
    if overlap_count == 0
        num_of_non_overlapping_artifacts_EEG1 = num_of_non_overlapping_artifacts_EEG1 + 1;
    end
end

% Display results
fprintf('Number of overlaps: %d\n', num_of_overlaps);
fprintf('False positives (Number of non-overlapping artifacts in EEG2): %d\n', num_of_non_overlapping_artifacts_EEG2);
fprintf('Not counted original artefacts (Number of non-overlapping artifacts in EEG1): %d\n', num_of_non_overlapping_artifacts_EEG1);