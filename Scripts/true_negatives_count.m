% Path to original EEG file (containing 'EEG' with .pnts and .srate)
input_file = '/home/marko/Documents/Diploma/cnn-eeg-signal-analysis/Datasets/Predicted EEG data/raw-caffeine_311_1/Predicted_RecordSession_311_artefakti2019.07.24_11.51.14.hdf5_.mat';

% Manually input artifact counts (segment-based)
TP = 31;    % Number of overlapping artifacts
FP = 137;   % Predicted artifacts not overlapping with real
FN = 3;     % Real artifacts not detected

% Set average artifact segment length (in seconds)
segment_len_sec = 1;

% ==== LOAD EEG FILE ====
EEG_data = load(input_file);
EEG = EEG_data.EEG;

% Get total number of samples and sampling rate
pnts = EEG.pnts;
srate = EEG.srate;

% Compute recording duration in seconds
duration_sec = pnts / srate;

% ==== CALCULATE TN ====
total_segments = floor(duration_sec / segment_len_sec);
TN = total_segments - (TP + FP + FN);
if TN < 0
    warning('TN is negative — check segment length or input values.');
    TN = 0;
end


confMat = [TP, FP; FN, TN];
labels = {'Artifact', 'Non-Artifact'};
confusionchart(confMat, labels);
