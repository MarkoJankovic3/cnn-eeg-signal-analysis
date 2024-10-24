clear all;

% Load the data
EEG1 = load('/home/support-5/Documents/Diplomski/Data/EEG data/EEG_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.08.46.hdf5_.mat');
EEG2 = load('/home/support-5/Documents/Diplomski/diploma-thesis/scripts/New_Artifacts_EEG_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.08.46_.mat');

% Find the first rejStart element

index1 = find(strcmp({EEG1.EEG.event.type}, 'rejStart'));
EEG1_start = index1(1);

index2 = find(strcmp({EEG2.EEG.event.type}, 'rejStart-new'));
EEG2_start = index2(1);

% Count the overlaps %
num_of_overlaps = 0;

for i = EEG1_start:2:length(EEG1.EEG.event)
    for j = EEG2_start:2:length(EEG2.EEG.event)
        if EEG2.EEG.event(j).latency >= EEG1.EEG.event(i).latency
            if EEG2.EEG.event(j).latency <= EEG1.EEG.event(i+1).latency
                num_of_overlaps = num_of_overlaps + 1;
            end
        elseif EEG2.EEG.event(j+1).latency >= EEG1.EEG.event(i).latency
            if EEG2.EEG.event(j+1).latency <= EEG1.EEG.event(i+1).latency
                num_of_overlaps = num_of_overlaps + 1;
            end
        elseif EEG1.EEG.event(i).latency >= EEG2.EEG.event(j).latency
            if EEG1.EEG.event(i).latency <= EEG2.EEG.event(j+1).latency
                num_of_overlaps = num_of_overlaps + 1;
            end
        end
    end
end
