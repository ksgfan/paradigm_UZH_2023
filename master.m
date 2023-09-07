% Set up MATLAB workspace
clear all;
close all;
rootFilepath = pwd;                  % Retrieve the present working directory

% define paths
PPDEV_PATH = '/home/methlab/Documents/MATLAB/ppdev-mex-master';
DATA_PATH = '/home/methlab/Desktop/EEGManyLabs/data';
FUNS_PATH = '/home/methlab/Desktop/EEGManyLabs/funs';
EYE_PATH = '/home/methlab/Desktop/EEGManyLabs/eyemovement_update';

% add path to folder with functions
addpath(FUNS_PATH)
addpath(EYE_PATH)

% set screen params
screenParams

% Collect ID and Age  
dialogID;

%% Run calibration task
TASK = 'EyeMeasure';
eyeMovementMeasure_2

%% Resting state EEG
TASK = 'Resting';

% Run Resting
disp('RESTING EEG...');
Resting_EEG;

%% CDA Task
TASK = 'ManyLabsCDA';
% Run 5 blocks of 144 trials each
for BLOCK = 1 : 5
    % Start the actual task (EEG recording will start here, if TRAINING = 0)
    disp('CDA TASK...');
    EEGManyLabs_CDA_18_7_2022; 
end


