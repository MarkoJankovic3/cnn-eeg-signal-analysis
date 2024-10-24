clear all;

load('/home/support-5/Documents/Diplomski/Data/EEG data/EEG_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.08.46.hdf5_.mat')
load('/home/support-5/Documents/Diplomski/Data/Neural Networks/CNN.mat')

XTest = EEG.data
YPred = classify(net,XTest)

save("Predicted.mat", "YPred")