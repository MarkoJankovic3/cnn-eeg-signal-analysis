clear all;

load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/EEG data/raw-caffeine_311/EEG_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.13.23.hdf5_.mat')
load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Trained Network/CNN.mat')

XTest = EEG.data;
YPred = classify(net,XTest);

save("Predicted.mat", "YPred")