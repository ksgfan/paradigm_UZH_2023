% #EEGManyLabs | Vogel and Machizawa 2004 replication
%
% This is the base experimental code for a replication of the third
% experiment from Vogel, E. K., & Machizawa, M. G. (2004). Neural activity
% predicts individual differences in visual working memory capacity.
% Nature, 428(6984), 748-751.
%
% Code written by William Xiang Quan Ngiam, postdoc in the Awh/Vogel Lab.
% (Email: wngiam@uchicago.edu | Twitter: @will_ngiam | Website:
% williamngiam.github.io)
%
% This code requires PsychToolbox. https://psychtoolbox.org
% This was tested with PsychToolbox version 3.0.15, and with MATLAB R2019a.
%
% --- %

%% EEG and ET
if TRAINING == 0
    % Start recording EEG
    disp('STARTING EEG RECORDING...');
    initEEG;
end

% Calibrate ET (Tobii Pro Fusion)
disp('CALIBRATING ET...');
calibrateET

%% Audio file
wavfilename_probe1 = '/home/methlab/Desktop/EEGManyLabs/funs/InstructionFixation.wav'; %Open Eyes
try
    PsychPortAudio('Close');
catch
end
try
    [y_probe1, freq1] = audioread(wavfilename_probe1);
    wavedata_probe1 = y_probe1';
    nrchannels = size(wavedata_probe1,1); % Number of rows == number of channels.
    % Add 15 msecs latency on ptbWindows, to protect against shoddy drivers:
    sugLat = [];
    if IsWin
        sugLat = 0.015;
    end
    try
        InitializePsychSound;
        %PsychPortAudio('GetDevices')
        pahandle = PsychPortAudio('Open', [3], [], 0, freq1, nrchannels, [], sugLat); % DAWID - look for devices - here 4
        duration_probe1 = size(wavedata_probe1,2)/freq1;
    catch
        error('Sound Initialisation Error');
    end
catch
    error('Sound Error');
end

%% Task

% define triggers for CDA
TASK_START = 10;
TASK_END = 90;
CUE_LEFT = 3;
CUE_RIGHT = 7;
SETSIZE2 = 21;
SETSIZE4 = 41;
SETSIZE6 = 61;
RETENTION = 50;
TEST2 = 22;
TEST4 = 42;
TEST6 = 62;
RESP_SAME = 77;
RESP_DIFF = 78;

% Set up experiment parameters
% Number of trials for the experiment
if TRAINING == 1
    experiment.nTrials = 10;
else
    experiment.nTrials = 70; % 5 blocks x 144 trials = 720 trials               
end
experiment.setSizes = [2,4,6];          % Number of items presented on the screen

% Set up equipment parameters
equipment.viewDist = 700;               % Viewing distance in millimetres

% Pixels per millimetre !! NEEDS TO BE SET. USE THE MeasureDpi FUNCTION !! 
% http://www.endmemo.com/sconvert/dpipixel_cm.php
% Zürich: 51.14 dots per Inch = 20.13 cm per pixel = 2.013 mm per pixel
equipment.ppm = 2.013;

equipment.greyVal = .5;
equipment.blackVal = 0; 
equipment.whiteVal = 1;
equipment.gammaVals = [1 1 1];          % The gamma values for color calibration of the monitor

% Set up stimulus parameters Fixation
stimulus.fixationOn = 1;                % Toggle fixation on (1) or off (0)
stimulus.fixationSize_dva = .35;   % old 0.15     % Size of fixation cross in degress of visual angle
stimulus.fixationColor = 1;             % Color of fixation cross (1 = white)
stimulus.fixationLineWidth = 3;         % Line width of fixation cross

% Location
stimulus.regionHeight_dva = 7.3;         % Height of the region
stimulus.regionWidth_dva = 4;            % Width of the region
stimulus.regionEccentricity_dva = 3;     % Eccentricity of regions from central fixation

% Item
stimulus.itemSize_dva = 0.65;            % Size of the color squares
stimulus.minDist_dva = 2;                % Minimum distance between item centers

% Set up color parameters
stimulus.nColors = 7;                   % Number of colors used in the experiment

color.red = [255, 0, 0];
color.blue = [0, 0, 255];
color.violet = [238, 130, 238];
color.green = [0, 255, 0];
color.yellow = [255, 255, 0];
color.black = [0, 0, 0];
color.white = [255, 255, 255];

color.grey = [128, 128, 128];

color.allColors = [color.red; color.blue; color.violet; color.green; ...
color.yellow; color.black; color.white]/255;

color.textVal = 0;                  % Color of text

% Set up text parameters
text.instructionFont = 'Menlo';     % Font of instruction text
text.instructionPoints = 14;        % Size of instruction text
text.CueSize = 50;
text.instructionStyle = 0;          % Styling of instruction text (0 = normal)
text.instructionWrap = 80;          % Number of characters at which to wrap instruction text
text.color = 0;                     % Color of text (0 = black)

if TRAINING == 1
    loadingText = ['Loading training task...'];
    startExperimentText = ['Training task. \n\n On each trial, you will be cued to one side of the screen. \n\n' ...
    'Color squares will briefly appear on both sides of the screen. \n\n' ...
    'Without moving your eyes from the fixation cross, remember the colors on the cued side. \n\n' ...
    'After a delay, the display will reappear with either a change or no change. \n\n' ...
    'Your task is to detect if a change occured or not. \n\n' ...
    'Feedback will be provided after each trial. \n\n' ...
    'Press any key to continue.'];
else
    if BLOCK == 1
        loadingText = ['Loading actual task...'];
        startExperimentText = ['Actual task. \n\n On each trial, you will be cued to one side of the screen. \n\n' ...
        'Color squares will briefly appear on both sides of the screen. \n\n' ...
        'Without moving your eyes from the fixation cross, remember the colors on the cued side. \n\n' ...
        'After a delay, the display will reappear with either a change or no change. \n\n' ...
        'Your task is to detect if a change occured or not. \n\n' ...
        'Feedback will not be provided. \n\n' ...
        'Press any key to continue.'];
    else
        startExperimentText = ['Block ' num2str(BLOCK) ' / 5'];
    end
end


startBlockText = ['Press any key to begin the next block.'];

% Set up temporal parameters (all in seconds)
timing.cue = .2;                    % Duration of arrow cue
timing.minSOA = .3;                 % Minimum stimulus onset asynchrony
timing.maxSOA = .4;                 % Maximum stimulus onset asynchrony
timing.memoryArray = .1;            % Duration of memory array
timing.retentionInterval = 0.9;      % Duration of blank retention interval
timing.testArray = 2;               % Duration of test array
timing.ITI = 1.5;                   % Duration of the inter-trial interval     

% Shuffle rng for random elements
rng('default');             
rng('shuffle');                     % Use MATLAB twister for rng

% Set up Psychtoolbox Pipeline
AssertOpenGL;

% Imaging set up
screenID = whichScreen; 
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
Screen('Preference','SkipSyncTests', 0);

% Window set-up
[ptbWindow, winRect] = PsychImaging('OpenWindow', screenID, equipment.greyVal);
PsychColorCorrection('SetEncodingGamma', ptbWindow, equipment.gammaVals);
[screenWidth, screenHeight] = RectSize(winRect);
screenCentreX = round(screenWidth/2);
screenCentreY = round(screenHeight/2);
flipInterval = Screen('GetFlipInterval', ptbWindow);
Screen('BlendFunction', ptbWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
experiment.runPriority = MaxPriority(ptbWindow);
Screen('TextSize', ptbWindow, text.instructionPoints);

global psych_default_colormode;                     % Sets colormode to be unclamped 0-1 range.
psych_default_colormode = 1;

global ptb_drawformattedtext_disableClipping;       % Disable clipping of text 
ptb_drawformattedtext_disableClipping = 1;

% Show loading text
DrawFormattedText(ptbWindow,loadingText,'center','center',color.textVal);
Screen('Flip',ptbWindow);
  
% Retrieve response keys
KeyCodeA = KbName('A');         % Retrieve key code for the 1 button
KeyCodeL = KbName('L');% KbName('/?');    % Retrieve key code for the 3 button (/? is the PTB code for the keyboard rather than numpad slash button)
spaceKeyCode = KbName('Space'); % Retrieve key code for spacebar

% Assign response keys
if mod(subject.ID,2) == 0       % Use subject ID for assignment to ensure counterbalancing
    changeIsL = true;       % L is change, A is no change.
    responseInstructionText = ['If you think a change occurred, press the L key. ' ...
        'If you think a change did not occur, press the A key. \n\n'...
        'Use your left hand to press A and right hand to press L \n\n' ...
        'Press any key to continue.'];
elseif mod(subject.ID,2) == 1
    changeIsL = false;      % L is no change, A is change.
    responseInstructionText = ['If you think a change occurred, press the A key. \n\n' ...
        'If you think a change did not occur, press the L key. \n\n'...
        'Use your left hand to press A and right hand to press L \n\n' ...
        'Press any key to continue.'];

end

% Calculate experiment parameters
experiment.nSetSizes = numel(experiment.setSizes);  % Number of set sizes
experiment.nTrialsPerSetSize = experiment.nTrials/experiment.nSetSizes;     % Number of trials per set size

% Calculate equipment parameters
equipment.mpd = (equipment.viewDist/2)*tan(deg2rad(2*stimulus.regionEccentricity_dva))/stimulus.regionEccentricity_dva; % Millimetres per degree
equipment.ppd = equipment.ppm*equipment.mpd;    % Pixels per degree

% Calculate spatial parameters
% Fixation
stimulus.fixationSize_pix = round(stimulus.fixationSize_dva*equipment.ppd);

% Location
stimulus.regionHeight_pix = round(stimulus.regionHeight_dva*equipment.ppd);
stimulus.regionWidth_pix = round(stimulus.regionWidth_dva*equipment.ppd);
stimulus.regionEccentricity_pix = round(stimulus.regionEccentricity_dva*equipment.ppd);

% Item
stimulus.itemSize_pix = round(stimulus.itemSize_dva*equipment.ppd);
stimulus.minDist_pix = round(stimulus.minDist_dva*equipment.ppd);

% Set up location rects
fixHorizontal = [round(-stimulus.fixationSize_pix/2) round(stimulus.fixationSize_pix/2) 0 0];
fixVertical = [0 0 round(-stimulus.fixationSize_pix/2) round(stimulus.fixationSize_pix/2)];
fixCoords = [fixHorizontal; fixVertical];
itemRect = [0 0 stimulus.itemSize_pix stimulus.itemSize_pix];
leftRegionRect = [0 0 stimulus.regionWidth_pix stimulus.regionHeight_pix];
leftRegionRect = CenterRectOnPoint(leftRegionRect,screenCentreX-stimulus.regionEccentricity_pix,screenCentreY);
rightRegionRect = [0 0 stimulus.regionWidth_pix stimulus.regionHeight_pix];
rightRegionRect = CenterRectOnPoint(rightRegionRect,screenCentreX+stimulus.regionEccentricity_pix,screenCentreY);

% Create matrices for preallocating data
data.allResponses = NaN(experiment.nTrials,1);                                  % Vector containing all the keypress responses
data.allCorrect = NaN(experiment.nTrials,1);                                    % Vector containing whether response was correct or incorrect on each trial
data.allLeftItemCoordX = NaN(experiment.nTrials,max(experiment.setSizes));      % X-coordinates of items on the left side of the screen
data.allLeftItemCoordY = NaN(experiment.nTrials,max(experiment.setSizes));      % Y-coordinates of items on the left side of the screen
data.allRightItemCoordX = NaN(experiment.nTrials,max(experiment.setSizes));     % X-coordinates of items on the right side of the screen
data.allRightItemCoordY = NaN(experiment.nTrials,max(experiment.setSizes));     % Y-coordinates of items on the right side of the screen
data.allLeftItemColors = NaN(experiment.nTrials,max(experiment.setSizes));      % Colors of the itmes on the left side of the screen
data.allRightItemColors = NaN(experiment.nTrials,max(experiment.setSizes));     % Colors of the items on the right side of the screen
data.whichItemChanged = NaN(experiment.nTrials,1);                              % Vector containing which item is changed in the display
data.changedItemFoil = NaN(experiment.nTrials,1);                               % Vector containing which color is the item changed to

% Randomize trial condition
data.trialSetSize = experiment.setSizes(mod(randperm(experiment.nTrials),experiment.nSetSizes)+1);  % Determine set size on trial
data.trialIfChange = mod(randperm(experiment.nTrials),2);       % 0 for no change, 1 for change 
data.trialCuedSide = mod(randperm(experiment.nTrials),2);       % 0 for left, 1 for right
data.trialSOA = mod(randperm(experiment.nTrials),round((timing.maxSOA-timing.minSOA)/flipInterval));    % Determine each trial's stimulus onset asychrony

% Randomize item locations on each trial. This will take approximately 3
% seconds.
for thisTrial = 1:experiment.nTrials
    sampleLeft = true;
    sampleRight = true;
        % Randomly select two x and y coordinates for each region
    while sampleLeft
        % Randomly select x and y coordinate for each item in each region
        data.allLeftItemCoordX(thisTrial,1:data.trialSetSize(thisTrial)) = randi([leftRegionRect(1) leftRegionRect(3)],1,data.trialSetSize(thisTrial));
        data.allLeftItemCoordY(thisTrial,1:data.trialSetSize(thisTrial)) = randi([leftRegionRect(2) leftRegionRect(4)],1,data.trialSetSize(thisTrial));
        thisTrialLeftItemCoord = [data.allLeftItemCoordX(thisTrial,:)' data.allLeftItemCoordY(thisTrial,:)'];
        leftItemDist = pdist(thisTrialLeftItemCoord);
        if sum(leftItemDist <= stimulus.minDist_pix) == 0       % Checks no item distances are below the minimum distance
            sampleLeft = false;
        end
    end
    while sampleRight
        data.allRightItemCoordX(thisTrial,1:data.trialSetSize(thisTrial)) = randi([rightRegionRect(1) rightRegionRect(3)],1,data.trialSetSize(thisTrial));
        data.allRightItemCoordY(thisTrial,1:data.trialSetSize(thisTrial)) = randi([rightRegionRect(2) rightRegionRect(4)],1,data.trialSetSize(thisTrial));
        thisTrialRightItemCoord = [data.allRightItemCoordX(thisTrial,:)' data.allRightItemCoordY(thisTrial,:)'];
        rightItemDist = pdist(thisTrialRightItemCoord);
        if sum(rightItemDist <= stimulus.minDist_pix) == 0      % Checks no item distances are below the minimum distance
            sampleRight = false;
        end
    end
end

% Randomize item colors on each trial
for thisTrial = 1:experiment.nTrials
    data.allLeftItemColors(thisTrial,1:data.trialSetSize(thisTrial)) = randperm(stimulus.nColors,data.trialSetSize(thisTrial));
    data.allRightItemColors(thisTrial,1:data.trialSetSize(thisTrial)) = randperm(stimulus.nColors,data.trialSetSize(thisTrial)); 
end

% Show task instruction text
DrawFormattedText(ptbWindow,startExperimentText,'center','center',color.textVal);
startExperimentTime = Screen('Flip',ptbWindow);
waitResponse = 1;
while waitResponse

    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;

end

% Show response instruction text
DrawFormattedText(ptbWindow,responseInstructionText,'center','center',color.textVal);
Screen('Flip',ptbWindow);
waitResponse = 1;
while waitResponse
    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;
end

Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1); % black background for photo diode
endTime = Screen('Flip',ptbWindow);

% send triggers: task starts. If training, send only ET triggers
if TRAINING == 1
%     EThndl.sendMessage(TASK_START,endTime); % ET
    Eyelink('Message', num2str(TASK_START));
    Eyelink('command', 'record_status_message "Start"');
else
%     EThndl.sendMessage(TASK_START,endTime); % ET
    Eyelink('Message', num2str(TASK_START));
    Eyelink('command', 'record_status_message "Start"');
    sendtrigger(TASK_START,port,SITE,stayup); % EEG
end

%% Experiment Loop 
HideCursor(whichScreen);

noFixation = 0;
for thisTrial = 1:experiment.nTrials

    % Retrieve trial parameters
    thisTrialSetSize = data.trialSetSize(thisTrial);            % Get this trial's set size
    thisTrialLColors = data.allLeftItemColors(thisTrial,:);     % Get this trial's left item colors
    thisTrialLColors = thisTrialLColors(~isnan(thisTrialLColors));
    thisTrialRColors = data.allRightItemColors(thisTrial,:);    % Get this trial's right item colors
    thisTrialRColors = thisTrialRColors(~isnan(thisTrialRColors));
    thisTrialLCoordsX = data.allLeftItemCoordX(thisTrial,:);    % Get this trial's left item X coordinates
    thisTrialLCoordsY = data.allLeftItemCoordY(thisTrial,:);    % Get this trial's left item Y coordinates
    thisTrialRCoordsX = data.allRightItemCoordX(thisTrial,:);   % Get this trial's right item X coordinates
    thisTrialRCoordsY = data.allRightItemCoordY(thisTrial,:);   % Get this trial's right item Y coordinates
    thisTrialCuedSide = data.trialCuedSide(thisTrial);          % Get this trial's cued side
    thisTrialSOA = data.trialSOA(thisTrial);                    % Get this trial's random stimulus onset asychrony
    thisTrialChange = data.trialIfChange(thisTrial);            % Get whether this is a change trial or no change trial
    
    % Center item rects for the trial
    thisTrialLRects = [];       % Clear left item rects from previous trial
    thisTrialRRects = [];       % Clear right item rects from previous trial
    for thisItem = 1:thisTrialSetSize
        thisTrialLRects(thisItem,:) = CenterRectOnPoint(itemRect,thisTrialLCoordsX(thisItem),thisTrialLCoordsY(thisItem));
        thisTrialRRects(thisItem,:) = CenterRectOnPoint(itemRect,thisTrialRCoordsX(thisItem),thisTrialRCoordsY(thisItem));
    end
    
    % Cue
    Screen('TextSize', ptbWindow, text.CueSize);
    if thisTrialCuedSide        % Cue right side
        DrawFormattedText(ptbWindow, 8594,'center','center',text.color); % UTF-16 (decimal) code for right arrow
        TRIGGER = CUE_RIGHT;
    else                        % Cue left side
        DrawFormattedText(ptbWindow, 8592,'center','center',text.color); % UTF-16 (decimal) code for left arrow
        TRIGGER = CUE_LEFT;
    end
    % send trigger
    Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1);
    Screen('DrawDots',ptbWindow, stimPos, stimDiameter, stimColor,[],1);
    cueTime = Screen('Flip',ptbWindow, endTime + timing.ITI);
    Screen('TextSize', ptbWindow, text.instructionPoints);

    if TRAINING == 1
%         EThndl.sendMessage(TRIGGER,cueTime);
        Eyelink('Message', num2str(TRIGGER));
        Eyelink('command', 'record_status_message "Cue"');
    else
%         EThndl.sendMessage(TRIGGER,cueTime);
        Eyelink('Message', num2str(TRIGGER));
        Eyelink('command', 'record_status_message "Cue"');
        sendtrigger(TRIGGER,port,SITE,stayup);
    end

    % Blank with jitter
    Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1); % black background for photo diode
    Screen('DrawLines',ptbWindow,fixCoords,stimulus.fixationLineWidth,stimulus.fixationColor,[screenCentreX screenCentreY],2); % Draw fixation cross
    blankTime = Screen('Flip',ptbWindow, cueTime + timing.cue);
    
    % Draw memory array
    Screen('DrawLines',ptbWindow,fixCoords,stimulus.fixationLineWidth,stimulus.fixationColor,[screenCentreX screenCentreY],2); % Draw fixation cross
    Screen('FillRect',ptbWindow,color.allColors(thisTrialLColors,:)',thisTrialLRects');                   % Draw left hemifield colour blocks
    Screen('FillRect',ptbWindow,color.allColors(thisTrialRColors,:)',thisTrialRRects');                    % Draw right hemifield colour blocks
    Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1);
    Screen('DrawDots',ptbWindow, stimPos, stimDiameter, stimColor,[],1);
    memoryTime = Screen('Flip',ptbWindow, blankTime + timing.minSOA + thisTrialSOA.*flipInterval);
    
    % send triggers
    if thisTrialSetSize == 2
        TRIGGER = SETSIZE2;
    elseif thisTrialSetSize == 4
        TRIGGER = SETSIZE4;
    elseif thisTrialSetSize == 6
        TRIGGER = SETSIZE6;
    end

    if TRAINING == 1
%         EThndl.sendMessage(TRIGGER,memoryTime);
        Eyelink('Message', num2str(TRIGGER));
        Eyelink('command', 'record_status_message "Array"');
    else
%         EThndl.sendMessage(TRIGGER,memoryTime);
        Eyelink('Message', num2str(TRIGGER));
        Eyelink('command', 'record_status_message "Array"');
        sendtrigger(TRIGGER,port,SITE,stayup);
    end

    % Retention interval
    Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1); % black background for photo diode
    Screen('DrawLines',ptbWindow,fixCoords,stimulus.fixationLineWidth,stimulus.fixationColor,[screenCentreX screenCentreY],2); % Draw fixation cross
    retentionTime = Screen('Flip',ptbWindow, memoryTime + timing.memoryArray);
    
    % send triggers
    if TRAINING == 1
%         EThndl.sendMessage(RETENTION,retentionTime);
        Eyelink('Message', num2str(RETENTION));
        Eyelink('command', 'record_status_message "Retention"');
    else
%         EThndl.sendMessage(RETENTION,retentionTime);
        Eyelink('Message', num2str(RETENTION));
        Eyelink('command', 'record_status_message "Retention"');
        sendtrigger(RETENTION,port,SITE,stayup)
    end

    % check if subject fixate at center, give warning if not
    % checkFixation

    % Draw test array
    if thisTrialChange == 1   % Change trial
        if thisTrialCuedSide == 0 % Left side was cued
           data.whichChangedItem(thisTrial) = randperm(thisTrialSetSize,1);                         % Select which item to change
           leftoverColors = setdiff(1:stimulus.nColors,thisTrialLColors);                           % Calculate which colors were not presented
           data.changedItemFoil(thisTrial) = leftoverColors(randperm(numel(leftoverColors),1));     % Choose randomly from one of the colors
           thisTrialLColors(data.whichChangedItem(thisTrial)) = data.changedItemFoil(thisTrial);    % Replace the to-be-changed item with the foil in the array
        elseif thisTrialCuedSide == 1 % Right side was cued
           data.whichChangedItem(thisTrial) = randperm(thisTrialSetSize,1);                         % Select which item to change
           leftoverColors = setdiff(1:stimulus.nColors,thisTrialRColors);                           % Calculate which colors were not presented
           data.changedItemFoil(thisTrial) = leftoverColors(randperm(numel(leftoverColors),1));     % Choose randomly from one of the colors
           thisTrialRColors(data.whichChangedItem(thisTrial)) = data.changedItemFoil(thisTrial);    % Replace the to-be-changed item with the foil in the array
        end
    end       
    Screen('DrawLines',ptbWindow,fixCoords,stimulus.fixationLineWidth,stimulus.fixationColor,[screenCentreX screenCentreY],2); % Draw fixation cross
    Screen('FillRect',ptbWindow,color.allColors(thisTrialLColors,:)',thisTrialLRects');                   % Draw left hemifield colour blocks
    Screen('FillRect',ptbWindow,color.allColors(thisTrialRColors,:)',thisTrialRRects');
    Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1);
    Screen('DrawDots',ptbWindow, stimPos, stimDiameter, stimColor,[],1);
    responseTime = Screen('Flip',ptbWindow,retentionTime + timing.retentionInterval);
    
    % send triggers
    if thisTrialSetSize == 2
        TRIGGER = TEST2;
    elseif thisTrialSetSize == 4
        TRIGGER = TEST4;
    elseif thisTrialSetSize == 6
        TRIGGER = TEST6;
    end
    
    if TRAINING == 1
%         EThndl.sendMessage(TRIGGER,responseTime);
        Eyelink('Message', num2str(TRIGGER));
        Eyelink('command', 'record_status_message "Test"');
    else
%         EThndl.sendMessage(TRIGGER,responseTime);
        Eyelink('Message', num2str(TRIGGER));
        Eyelink('command', 'record_status_message "Test"');
        sendtrigger(TRIGGER,port,SITE,stayup)
    end

    % Get response
    getResponse = true;
    while getResponse
        [time,keyCode] = KbWait(-1,2,responseTime+timing.testArray);
        whichKey = find(keyCode);
        if ~isempty(whichKey)
            if whichKey == KeyCodeA || whichKey == KeyCodeL
                getResponse = false;
                data.allResponses(thisTrial) = whichKey;

                % Send triggers
                if whichKey == KeyCodeA & changeIsL == true
                    TRIGGER = RESP_SAME;
                elseif whichKey == KeyCodeA & changeIsL == false
                    TRIGGER = RESP_DIFF;
                elseif whichKey == KeyCodeL & changeIsL == true
                    TRIGGER = RESP_DIFF;
                elseif whichKey == KeyCodeL & changeIsL == false
                    TRIGGER = RESP_SAME;
                end

                if TRAINING == 1
%                     EThndl.sendMessage(TRIGGER,time);
                    Eyelink('Message', num2str(TRIGGER));
                    Eyelink('command', 'record_status_message "Response"');
                else
%                     EThndl.sendMessage(TRIGGER,time);
                    Eyelink('Message', num2str(TRIGGER));
                    Eyelink('command', 'record_status_message "Response"');
                    sendtrigger(TRIGGER,port,SITE,stayup)
                end

            end
        end
        if time > responseTime + timing.testArray
            getResponse = false;
        end
    end
    
    % Check if response was correct
    if changeIsL == 1       % L is change, A is no change
        if thisTrialChange == 1     % Change trial
            data.allCorrect(thisTrial) = data.allResponses(thisTrial) == KeyCodeL;
        elseif thisTrialChange == 0 % No change trial
            data.allCorrect(thisTrial) = data.allResponses(thisTrial) == KeyCodeA;
        end
    elseif changeIsL == 0   % L is no change, A is change
        if thisTrialChange == 1     % Change trial
            data.allCorrect(thisTrial) = data.allResponses(thisTrial) == KeyCodeA;
        elseif thisTrialChange == 0 % No change trial
            data.allCorrect(thisTrial) = data.allResponses(thisTrial) == KeyCodeL;
        end
    end
    
    Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1); % black background for photo diode
    endTime = Screen('Flip',ptbWindow,responseTime+timing.testArray);

    % If training, give feedback
    if TRAINING == 1
        if data.allCorrect(thisTrial) == 1
            feedbackText = 'Correct!';
        else
            feedbackText = 'Incorrect!';
        end
        disp(feedbackText)
        DrawFormattedText(ptbWindow,feedbackText,'center','center',color.textVal);
        Screen('Flip',ptbWindow); 
    end

    % check if subject fixate at center, give warning if not
    if noFixation > 2
        PsychPortAudio('FillBuffer', pahandle,wavedata_probe1);
        PsychPortAudio('Start', pahandle, 1, 0, 1);
        disp('NO FIXATION. PLAYING AUDIO INSTRUCTION...')
        noFixation = 0; % reset
        WaitSecs(6);
    end
end

% send triggers to end task
Screen('DrawDots',ptbWindow, backPos, backDiameter, backColor,[],1); % black background for photo diode
endT = Screen('Flip',ptbWindow);
if TRAINING == 1
%     EThndl.sendMessage(TASK_END,endT);
    Eyelink('Message', num2str(TASK_END));
    Eyelink('command', 'record_status_message "End"');
else
%     EThndl.sendMessage(TASK_END,endT);
    Eyelink('Message', num2str(TASK_END));
    Eyelink('command', 'record_status_message "End"');
    sendtrigger(TASK_END,port,SITE,stayup)
end

% Compute accuracy for setsize 2 and 4 to check, whether subject understood
% the task.
i = data.trialSetSize == 2 | data.trialSetSize == 4;
total = sum(i);
totalCorrect = sum(data.allCorrect(i));
percentTotalCorrect = totalCorrect / total * 100;

% Save data
subjectID = num2str(subject.ID);
filePath = fullfile(DATA_PATH, subjectID);
mkdir(filePath)
if TRAINING == 1
    fileName = [subjectID '_', TASK, '_block' num2str(BLOCK) '_training.mat'];
else
    fileName = [subjectID '_', TASK, '_block' num2str(BLOCK) '_task.mat'];
end

beh = struct;
beh.data = data;
beh.experiment = experiment;
beh.hz = hz;
beh.itemRect = itemRect;
beh.leftItemDist = leftItemDist;
beh.rightItemDist = rightItemDist;
beh.leftRegionRect = leftRegionRect;
beh.rightRegionRect = rightRegionRect;
beh.screenWidth = screenWidth;
beh.screenHeight = screenHeight;
beh.screenCentreX = screenCentreX;
beh.screenCentreY = screenCentreY;
beh.startBlockText = startBlockText;
beh.startExperimentTime = startExperimentTime;
beh.startExperimentText = startExperimentText;
beh.stimulus = stimulus;
beh.subjectID = subjectID;
beh.subject = subject;
beh.text = text;
beh.timing = timing;
beh.waitResponse = waitResponse;
beh.winRect = winRect;
beh.flipInterval = flipInterval;

trigger = struct;
trigger.TASK_START = TASK_START;
trigger.TASK_END = TASK_END;
trigger.CUE_LEFT = CUE_LEFT;
trigger.CUE_RIGHT = CUE_RIGHT;
trigger.SETSIZE2 = SETSIZE2;
trigger.SETSIZE4 = SETSIZE4;
trigger.SETSIZE6 = SETSIZE6;
trigger.RETENTION = RETENTION;
trigger.TEST2 = TEST2;
trigger.TEST4 = TEST4;
trigger.TEST6 = TEST6;
trigger.RESP_SAME = RESP_SAME;
trigger.RESP_DIFF = RESP_DIFF;

% stop and close EEG and ET recordings
disp(['BLOCK ' num2str(BLOCK) ' FINISHED...']);
disp('SAVING DATA...');
save(fullfile(filePath, fileName), 'beh', 'trigger'); 
closeEEGandET;

try
    PsychPortAudio('Close');
catch
end

% Show break instruction text
if TRAINING == 1
    if percentTotalCorrect >= THRESH
        breakInstructionText = ['Well done! \n\n Press any key to start the actual task!'];
    else
        breakInstructionText = ['Score too low! ' num2str(percentTotalCorrect) ' % correct. \n\n Press any key to repeat the training task!'];
    end
else
    breakInstructionText = ['Break! Rest for while... Press any key to start a new block!'];
end
DrawFormattedText(ptbWindow,breakInstructionText,'center','center',color.textVal);
Screen('Flip',ptbWindow);
WaitSecs(10)
waitResponse = 1;
while waitResponse
    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;
end

% Quit
Screen('CloseAll');