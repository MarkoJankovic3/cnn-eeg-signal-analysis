clear all;

load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/EEG data/raw-caffeine_311/EEG_RecordSession_311_oddball_po_kofeinu2019.07.24_13.02.42.hdf5_.mat')

XTrain = EEG.data;
TTrain = categorical(EEG.artefacts);

%% NN model
numFeatures = size(XTrain,1)

classes = categories(TTrain);
numClasses = numel(classes)

numFilters = 64;
filterSize = 5;
dropoutFactor = 0.005;
numBlocks = 4;

layer = sequenceInputLayer(numFeatures,Normalization="rescale-symmetric",Name="input");
lgraph = layerGraph(layer);

outputName = layer.Name;

for i = 1:numBlocks
    dilationFactor = 2^(i-1);
    
    layers = [
        convolution1dLayer(filterSize,numFilters,DilationFactor=dilationFactor,Padding="causal",Name="conv1_"+i)
        layerNormalizationLayer
        dropoutLayer(dropoutFactor)
        convolution1dLayer(filterSize,numFilters,DilationFactor=dilationFactor,Padding="causal")
        layerNormalizationLayer
        reluLayer
        dropoutLayer(dropoutFactor)
        additionLayer(2,Name="add_"+i)];

    % Add and connect layers.
    lgraph = addLayers(lgraph,layers);
    lgraph = connectLayers(lgraph,outputName,"conv1_"+i);

    % Skip connection.
    if i == 1
        % Include convolution in first skip connection.
        layer = convolution1dLayer(1,numFilters,Name="convSkip");

        lgraph = addLayers(lgraph,layer);
        lgraph = connectLayers(lgraph,outputName,"convSkip");
        lgraph = connectLayers(lgraph,"convSkip","add_" + i + "/in2");
    else
        lgraph = connectLayers(lgraph,outputName,"add_" + i + "/in2");
    end
    
    % Update layer output name.
    outputName = "add_" + i;
end

layers = [
    fullyConnectedLayer(numClasses,Name="fc")
    softmaxLayer
    classificationLayer];
lgraph = addLayers(lgraph,layers);
lgraph = connectLayers(lgraph,outputName,"fc");


%% Training options

validation_data = load('/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/EEG data/raw-caffeine_318/EEG_RecordSession_318_oddball_po_kofeinu2019.07.26_10.49.10.hdf5_.mat')

XTest = validation_data.EEG.data;
TTest = categorical(validation_data.EEG.artefacts);

options = trainingOptions("adam", ...
    MaxEpochs=60, ...
    miniBatchSize=1, ...
    ValidationData={XTest, TTest}, ...
    ValidationFrequency=5, ...
    Plots="training-progress", ...
    Verbose=1);

%% Training

net = trainNetwork(XTrain,TTrain,lgraph,options);

%% Test

%s = load("HumanActivityTest.mat");

s = load("/home/support-5/Documents/Diplomski/cnn-eeg-signal-analysis/Datasets/EEG data/raw-caffeine_311/EEG_RecordSession_311_oddball_pred_kofeinom2019.07.24_12.13.23.hdf5_.mat");

XTest = s.EEG.data; %= s.XTest;
TTest = categorical(s.EEG.artefacts) ; %= s.YTest;

YPred = classify(net,XTest);
figure
plot(YPred,".-")
hold on
plot(TTest)
hold off 
xlabel("Time Step")
ylabel("Activity")
legend(["Predicted" "Test Data"],Location="northeast")
title("Test Sequence Predictions")

figure
confusionchart(TTest,YPred)