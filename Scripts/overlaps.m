clear all;

% Load the data
EEG1 = load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/EEG data/raw-caffeine_311/EEG_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.13.23.hdf5_.mat');
EEG2 = load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/Predicted EEG data/raw-caffeine_311_3/Predicted_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.13.23.hdf5_.mat');

% Find the first rejStart element

index1 = find(strcmp({EEG1.EEG.event.type}, 'rejStart'));
EEG1_start = index1(1);

index2 = find(strcmp({EEG2.EEG.event.type}, 'rejStart-new'));
EEG2_start = index2(1);

% Total number of artifacts in each EEG
total_EEG1_artifacts = (length(EEG1.EEG.event) - EEG1_start + 1) / 2;
total_EEG2_artifacts = (length(EEG2.EEG.event) - EEG2_start + 1) / 2;

% Initialize counters and flags
num_of_overlaps = 0;
EEG1_overlap_flag = false(1, length(EEG1.EEG.event));
EEG2_overlap_flag = false(1, length(EEG2.EEG.event));

% Check for overlaps
for j = EEG2_start:2:length(EEG2.EEG.event) % Iterate over EEG2 intervals
    for i = EEG1_start:2:length(EEG1.EEG.event) % Compare with EEG1 intervals
        % Check for overlap
        if (EEG2.EEG.event(j).latency >= EEG1.EEG.event(i).latency && ...
            EEG2.EEG.event(j).latency <= EEG1.EEG.event(i+1).latency) || ...
           (EEG2.EEG.event(j+1).latency >= EEG1.EEG.event(i).latency && ...
            EEG2.EEG.event(j+1).latency <= EEG1.EEG.event(i+1).latency) || ...
           (EEG1.EEG.event(i).latency >= EEG2.EEG.event(j).latency && ...
            EEG1.EEG.event(i).latency <= EEG2.EEG.event(j+1).latency)
            % Count overlap only once per pair
            if ~EEG1_overlap_flag(i) && ~EEG2_overlap_flag(j)
                num_of_overlaps = num_of_overlaps + 1;
                EEG1_overlap_flag(i) = true;
                EEG2_overlap_flag(j) = true;
            end
            break; % Stop checking further for this EEG2 interval
        end
    end
end

% Calculate non-overlapping artifacts
num_of_non_overlapping_artifacts_EEG1 = total_EEG1_artifacts - sum(EEG1_overlap_flag(EEG1_start:2:end));
num_of_non_overlapping_artifacts_EEG2 = total_EEG2_artifacts - sum(EEG2_overlap_flag(EEG2_start:2:end));

% Display results
fprintf('Number of overlaps: %d\n', num_of_overlaps);
fprintf('False positives (Number of non-overlapping artifacts in EEG2): %d\n', num_of_non_overlapping_artifacts_EEG2);
fprintf('Not counted original artefacts (Number of non-overlapping artifacts in EEG1): %d\n', num_of_non_overlapping_artifacts_EEG1);
