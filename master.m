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
if not(isfile([DATA_PATH, filesep, num2str(subject.ID), filesep, num2str(subject.ID), '_Eye.mat']))
    eyeMovementMeasure_2
else
    disp(['EYE MEASURE ALREADY DONE. SKIPPING...'])
end
%% Resting state EEG
TASK = 'Resting';
if not(isfile([DATA_PATH, filesep, num2str(subject.ID), filesep, num2str(subject.ID), '_Resting.mat']))
    % Run Resting
    disp('RESTING EEG...');
    Resting_EEG;
else
    disp(['RESTING ALREADY DONE. SKIPPING...'])
end
%% CDA Task
TASK = 'ManyLabsCDA';
% Run 5 blocks of 144 trials each
for BLOCK = 1 : 5
    if not(isfile([DATA_PATH, filesep, num2str(subject.ID), filesep, num2str(subject.ID), '_ManyLabsCDA_block', num2str(BLOCK), '.mat']))
        % Start the actual task (EEG recording will start here, if TRAINING = 0)
        disp('CDA TASK...');
        EEGManyLabs_CDA_18_7_2022; 
    else
        disp(['BLOCK ' num2str(BLOCK) ' ALREADY DONE. SKIPPING...'])
    end
end


