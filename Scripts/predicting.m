clear all;

load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/EEG data/raw-caffeine_318/EEG_RecordSession_318_oddball_pred_kofeinom2019.07.26_10.04.35.hdf5_.mat')
load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Trained Network/CNN.mat')

XTest = EEG.data
YPred = classify(net,XTest)

save("Predicted.mat", "YPred")