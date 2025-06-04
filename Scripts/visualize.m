tmp1 = load('/home/marko/Documents/Diploma/cnn-eeg-signal-analysis/Datasets/EEG data/raw-caffeine_311/EEG_RecordSession_311_ECO_pred_kofeinom2019.07.24_11.54.47.hdf5_.mat');
tmp2 = load('/home/marko/Documents/Diploma/cnn-eeg-signal-analysis/Datasets/Predicted EEG data/raw-caffeine_311_3/Predicted_RecordSession_311_ECO_pred_kofeinom2019.07.24_11.54.47.hdf5_.mat');

EEG1 = tmp1.EEG;  % ICA-labeled
EEG2 = tmp2.EEG;  % Model-labeled

% Extract model artifact events from EEG2
modelArtifacts = EEG2.event(strcmp({EEG2.event.type}, 'rejStart-new') | ...
                            strcmp({EEG2.event.type}, 'rejEnd-new'));

% Rename event types to avoid conflict
for i = 1:length(modelArtifacts)
    modelArtifacts(i).type = [modelArtifacts(i).type '_model'];
end

% Append model events to EEG1
EEG1.event(end+1:end+length(modelArtifacts)) = modelArtifacts;

% Ensure consistency
EEG1 = eeg_checkset(EEG1, 'eventconsistency');

% Plot EEG1 data with all events (ICA + model)
eegplot(EEG1.data, 'srate', EEG1.srate, 'events', EEG1.event);