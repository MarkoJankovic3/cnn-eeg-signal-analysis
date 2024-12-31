clc;clear all;close all;

eeglab;
%% 1.Import .hdf5
filename='RecordSession_311_oddball_pred_kofeinom2019.07.24_12.13.23.hdf5';
filepath= '/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/Raw data/raw-caffeine_311';

%filename='RecordSession_311_ECO_po_kofeinu2019.07.24_12.54.43.hdf5';
%filepath= '/home/peter/Projects/EEG/raw-caffeine';

EEG = pop_loadhdf5('filename',filename,'filepath',filepath, 'rejectchans', [], 'ref_ch', []);

%% 2. 	Add channel location data
EEG=pop_chanedit(EEG, 'load',{'/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Scripts/EEG artifacts/Locs32_30_05_2017 (2).locs' 'filetype' 'autodetect'});

%% processing
% filter 1-45 hz
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',50);

% cut away the first 1000 samples
EEG = eeg_eegrej( EEG, [1 1000] );% obrisano prvih 10000 sample-ova

% 4. Re-reference to average 
EEG = pop_reref( EEG, []);

% resample from 600 to 300 hz 
EEG = pop_resample( EEG, 300);
EEG = eeg_checkset( EEG );

%% detect start % stop of reject regions as events
load('Predicted.mat')
r=double(string(YPred));
rp=[0, r(1:end-1)];
dp=r-rp;
e1=find(dp>0);
e2=find(dp<0);

%write the event list to EEG structure
nev=length(e2);
nev0=length(EEG.event);
for iev=1:nev
    EEG.event(nev0+2*iev-1).type='rejStart-new';
    EEG.event(nev0+2*iev-1).position=1;
    EEG.event(nev0+2*iev-1).latency=e1(iev);
    EEG.event(nev0+2*iev-1).urevent=nev0+2*iev-1;
    EEG.event(nev0+2*iev-1).duration=0;
    
    EEG.event(nev0+2*iev).type='rejEnd-new';
    EEG.event(nev0+2*iev).position=1;
    EEG.event(nev0+2*iev).latency=e2(iev);
    EEG.event(nev0+2*iev).urevent=nev0+2*iev;
    EEG.event(nev0+2*iev).duration=0;
    
end
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
%% finish
eeglab redraw;

%% save the data
EEG.artefacts=r;
save(['../Datasets/Predicted EEG data/raw-caffeine_311_3/Predicted_' filename '_.mat'],"EEG");