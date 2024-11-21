clc;clear all;close all;

eeglab;
%% 1.Import .hdf5
filename='RecordSession_366_oddball_pred_kofeinom2019.07.25_09.38.33.hdf5';
filepath= '/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/Raw data/raw-caffeine_311';

%filename='RecordSession_311_ECO_po_kofeinu2019.07.24_12.54.43.hdf5';
%filepath= '/home/peter/Projects/EEG/raw-caffeine';

EEG = pop_loadhdf5('filename',filename,'filepath',filepath, 'rejectchans', [], 'ref_ch', []);

%% 2. 	Add channel location data
EEG=pop_chanedit(EEG, 'load',{'/home/support-5/Documents/Diplomski/diploma-thesis/scripts/EEG artifacts/Locs32_30_05_2017 (2).locs' 'filetype' 'autodetect'});

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

%% backup data to EEG.data0
%EEG.data0=EEG.data;

%% ica
EEG = pop_runica( EEG, 'runica','options', {'extended',1,'block',floor(sqrt(EEG.pnts/3)),'anneal',0.98, 'maxsteps',300 } );

%% select eyeblink components
% documentation: https://education.msu.edu/kin/hbcl/_files/icablinkmetrics_Documentation.pdf
% https://github.com/mattpontifex/icablinkmetrics
artifactChan=(EEG.data(find(strcmp({EEG.chanlocs.labels},'Fp1')),:)+EEG.data(find(strcmp({EEG.chanlocs.labels},'Fp2')),:) )/2;
EEG.icaquant = icablinkmetrics(EEG, 'ArtifactChannel', artifactChan, 'Alpha', 0.001, 'VisualizeData', 'False');% 'True'
EEG.icaquant.identifiedcomponents

%% Remove Artifact ICA component(s)
EEG2 = pop_subcomp(EEG,EEG.icaquant.identifiedcomponents,0);
%EEG = pop_subcomp(EEG,EEG.icaquant.identifiedcomponents,1);

%% plot
figure(20); plot(EEG.times, EEG.data([1 2],:));
hold on; 
plot(EEG.times, EEG2.data([1 2],:));
plot(EEG.times, abs( EEG.data(1,:)-EEG2.data(1,:)),'k-');
plot(EEG.times, abs( EEG.data(2,:)-EEG2.data(2,:)),'k-');
plot(EEG.times, abs( EEG.data(1,:)-EEG2.data(1,:))+abs( EEG.data(2,:)-EEG2.data(2,:)),'k--');
plot(EEG.times, sum( abs( EEG.data-EEG2.data ), 1),'r-');
hold off;

%% thresholding with hysteresis 
%detect maxima over Max (6000) and extend the range until it falls below Min (50)
M=1000;
m=50;
s=sum( abs( EEG.data-EEG2.data ), 1);
r=0.5*ones(1,EEG.pnts);
r(s>M)=1;
r(s<m)=0;

for i=1:EEG.pnts-1
    if r(i)==1
        if r(i+1)>0
            r(i+1)=1;
        end
    end
end
for i=EEG.pnts:-1:2
    if r(i)==1
        if r(i-1)>0
            r(i-1)=1;
        end
    end
end
r(r<1)=0;
figure(20); hold on; plot(EEG.times, M*r, 'b-');

%% detect start % stop of reject regions as events
rp=[0, r(1:end-1)];
dp=r-rp;
e1=find(dp>0);
e2=find(dp<0);

%write the event list to EEG structure
nev=length(e1);
nev0=length(EEG.event)
for iev=1:nev
    EEG.event(nev0+2*iev-1).type='rejStart';
    EEG.event(nev0+2*iev-1).position=1;
    EEG.event(nev0+2*iev-1).latency=e1(iev);
    EEG.event(nev0+2*iev-1).urevent=nev0+2*iev-1;
    EEG.event(nev0+2*iev-1).duration=0;
    
    EEG.event(nev0+2*iev).type='rejEnd';
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
%data=EEG.data;
EEG.artefacts=r;
%save(['Reject_' filename '_.mat'],"r");
%save(['Data_' filename '_.mat'],"data");
save(['EEG_' filename '_.mat'],"EEG");
