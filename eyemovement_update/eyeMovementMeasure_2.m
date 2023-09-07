%% HEOG Testing (updated)

% Made by Kevin Ortego (kevortego27@gmail.com) from BrainStoermer Lab @
% Dartmouth College
% edited by Yong Hoon Chung (yong.hoon.chung.gr@dartmouth.edu) for CDA
% replication project

% Simple experiment to test average HEOG amplitude for eye movements of a
% given visual angle. Can test whatever range of eccentricities you want.
% Subjects make a saccade to a target, press spacebar when fixated, and
% return to fixation, next trial begins automatically after a jittered
% ISI

% Standard finding in literature is ~16uv/degree of visual angle. This was
% validated on myself (15.5uv/degree) using 30 trials per eccentricity
% on angles [-10:-1 1:10], so 30 trials for each left/right seems sufficient
% to measure and it's a super fast task. Signal is highly reliable

% For the purpoes of current study, we measure 3 degree and 6 degree
% saccades left and right, then estimate 1 degree amplitude.

%% EEG CODES

% Codes populate leftmost eccentricity to rightmost starting at 101

% Ex: if testing the range [-10:-1 1:10] codes would populate as:
% 101-110 = offset to the left by 10,9,8,...1 deg
% 111-120 = offset to the right by 1,2,3,...10 deg
% Spacebar response indicating stable fixation is 55

% Ex: if testing the range [-6:2:-2 2:2:6] codes would populate as:
% 101-103 = offset to the left by 6 4 2 deg
% 104-106 = offset to the right by 2 4 6 deg
% Spacebar response indicating stable fixation is 55

TASK_START = 9;
TASK_END = 89;

%% Initialize EEG port
% Change to your lab's EEG event code script
% [obj,port] = initializePort(100); %FLAG EEG

% init EEG
disp('STARTING EEG RECORDING...');
initEEG;

% Calibrate ET (EyeLink 1000)
disp('CALIBRATING ET...');
calibrateET

%% Set up
%clear; clc;

Screen('Preference', 'SkipSyncTests', 0); 

% Set up basic screen preferences (functions in the folder)

% Preferences function stores various information such as monitor number,
% background color, distance from the monitor, size of the monitor, etc.
prefs = Preferences();

% Initialize function will check the data names and open up the window.
prefs = Initialize(prefs);

sid = subject.ID; %This is from master.m

% Get screen dimensions and center, set a few things
[ptbWindow, winRect] = PsychImaging('OpenWindow', whichScreen, 0.5);
rect = Screen('Rect', prefs.monitor);
[prefs.cx, prefs.cy] = RectCenter(rect); % get center of the screen
Screen('Preference','DefaultFontName', 'Helvetica');
Screen('BlendFunction', ptbWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % Set to enable smoothing when drawing lines

% Randomize seed and save random seed in case need to rerun and extract
% more info later
randSeed = sum(sid*clock);
rng(randSeed, 'twister');
d.randSeed = randSeed;

% Keys
KbName('UnifyKeyNames');
spacebar = KbName('Space');
upKey =  KbName('UpArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
downKey = KbName('DownArrow');


%% DISPLAY PARAMETERS

% FIXED STUFF ABOUT THE DISPLAY
colorBackground = prefs.backColor; %[128 128 128];

minStimDuration = 0.095; %Minimum time to display stim before response is allowed (saccades take ~200ms)
minFixDuration = 0.195; % Time after spacebar indicating fixation before target disappears
isiDuration = 1.2;
jitter = 0.4;

colorProbe = [255 0 0]; % color of the saccade target

fixationSize = angle2pix(prefs, 0.6); %Size of the outermost ring of the fixation bullseye in angles
fixationStep = (fixationSize - 0.5) / 3; % Step size of the bullseye (fixationSize - 3*fixationStep = fixationStep)

% Photodiode
% Change to your lab's set up
photo_loc = [24, prefs.cy*2-24];
photo_size = 24;

%% EXPERIMENT PARAMETERS

% Which eccentricities in degrees visual angle to use
angles = [-6 -3 3 6]; %What angles to test. Negative indicates left.
anglePix = angle2pix(prefs,angles); % Convert those to pixels
whichAngle = 1:length(angles); % Array to use for indexing

% Save paramters to a data structure:
d.angles = angles;

% Design matrix
nTrialsPerAngle = 15;
nTrialsPerBlock = 15;
nTrials = nTrialsPerAngle*length(whichAngle);
nBlocks = nTrials/nTrialsPerBlock;

if nTrials ~= nBlocks*nTrialsPerBlock
    fprintf('WARNING unbalanced trial/block numbers \n');
end

% Make and shuffle design matrix
designMatrix = repmat(whichAngle,[1 nTrialsPerAngle]);
designMatrix = Shuffle(designMatrix);

instructionsText = 'Make a saccade to the target dot AS SOON AS it appears, and press the spacebar when you are stabely fixated on it. \n\n Return to fixating the central dot once the target disappears. Press spacebar to continue.';
endText = 'You are done';
Screen('TextSize', ptbWindow, 15);

%% Running the trials

% Change to your lab's EEG event code script
% sendEventCode(obj, port, code); %FLAG EEG
Eyelink('Message', num2str(TASK_START));
Eyelink('command', 'record_status_message "Start"');
sendtrigger(TASK_START,port,SITE,stayup);

trialCounter = 1; % Variable to count trials across blocks

for b = 1:nBlocks

    % Generate and show text at the start of each block
    blockText = ['You are on number ' num2str(b) ' out of ' num2str(nBlocks) ' blocks.\n\n\n\n'];
    Screen('FillRect', ptbWindow, colorBackground, rect);
    DrawFormattedText(ptbWindow, instructionsText, 'center', 'center', [0 0 0]);
    DrawFormattedText(ptbWindow, blockText, 'center', prefs.cy+100, [0 0 0]);
    Screen('Flip', ptbWindow);
    WaitSecs(0.500);

    % Wait for key response to start trial
    respToBeMade = true;
    while respToBeMade == true
        [~,~, keyCode] = KbCheck;
        if keyCode(prefs.quitKey) %If you want to quit press q
            ShowCursor;
            Screen('CloseAll');
            sca;
            return;
        elseif keyCode(spacebar)
            respToBeMade = false;
        end
    end

    % Run the trials for this block

    for t = 1:nTrialsPerBlock

        % Grab the current location and generate EEG code
        currentLoc = [prefs.cx + anglePix(designMatrix(trialCounter)) prefs.cy];
        code = designMatrix(trialCounter) + 100;
        d.eccentricity(trialCounter) = designMatrix(trialCounter);
        disp(code);

        % Blank ISI with fixation stimulus before the trial
        Screen('FillRect', ptbWindow, [colorBackground], rect);
        Screen('DrawDots',ptbWindow, [prefs.cx prefs.cy], fixationSize, [255 255 255], [0 0], 3);
        Screen('DrawDots',ptbWindow, [prefs.cx prefs.cy], fixationSize-fixationStep, [0 0 0], [0 0], 3); %Probe size = 12
        Screen('DrawDots',ptbWindow, [prefs.cx prefs.cy], fixationSize-fixationStep*2, [255 255 255], [0 0], 3);
        Screen('DrawDots',ptbWindow, [prefs.cx prefs.cy], fixationSize-fixationStep*3, [0 0 0], [0 0], 3);
        Screen('Flip', ptbWindow);
        WaitSecs(isiDuration + rand()*jitter);

        % Draw the fixation stimulus (first chunk) and saccade target
        Screen('FillRect', ptbWindow, [colorBackground], rect);
        Screen('DrawDots',ptbWindow, [prefs.cx prefs.cy], fixationSize, [255 255 255], [0 0], 3);
        Screen('DrawDots',ptbWindow, [prefs.cx prefs.cy], fixationSize-fixationStep, [0 0 0], [0 0], 3);
        Screen('DrawDots',ptbWindow, [prefs.cx prefs.cy], fixationSize-fixationStep*2, [255 255 255], [0 0], 3);
        Screen('DrawDots',ptbWindow, [prefs.cx prefs.cy], fixationSize-fixationStep*3, [0 0 0], [0 0], 3);

        Screen('DrawDots',ptbWindow, currentLoc, fixationSize, colorProbe, [0 0], 3);
        Screen('DrawDots',ptbWindow, currentLoc, fixationSize-fixationStep, [0 0 0], [0 0], 3);
        Screen('DrawDots',ptbWindow, currentLoc, fixationSize-fixationStep*2, colorProbe, [0 0], 3);
        Screen('DrawDots',ptbWindow, currentLoc, fixationSize-fixationStep*3, [0 0 0], [0 0], 3);
        
        %For photodiode
        %Screen('DrawDots',win, photo_loc, photo_size, [255 255 255], [0 0], 3);
        Screen('Flip', ptbWindow);

        % Change to your lab's EEG event code script
        % sendEventCode(obj, port, code); %FLAG EEG
        Eyelink('Message', num2str(code));
        Eyelink('command', 'record_status_message "Stim"');
        sendtrigger(code,port,SITE,stayup);

        d.targetTime(trialCounter) = GetSecs(); % Save target onset time
        d.trigger(trialCounter) = code; % Save triggers
        WaitSecs(minStimDuration);

        % Wait for response to indicate stable fixation
        respToBeMade = true;
        while respToBeMade == true
            % Check the keyboard. The person should press the spacebar
            [~,~, keyCode] = KbCheck;
            if keyCode(prefs.quitKey) %If you want to quit. For us it's 'q'
                ShowCursor;
                Screen('CloseAll');
                sca;
                return;
            elseif keyCode(spacebar)
                d.responseTime(trialCounter) = GetSecs(); % Save response time
                % sendEventCode(obj, port, 55);
                respToBeMade = false;
            end
        end
        % Change to your lab's EEG event code script
        % sendEventCode(obj, port, 55); %FLAG EEG
        Eyelink('Message', num2str(55));
        Eyelink('command', 'record_status_message "Resp"');
        sendtrigger(55,port,SITE,stayup);

        WaitSecs(minFixDuration);
        trialCounter = trialCounter + 1;

    end % End of trial loop within a block

end % End of Block Loop

% Change to your lab's EEG event code script
% sendEventCode(obj, port, code); %FLAG EEG
Eyelink('Message', num2str(TASK_END));
Eyelink('command', 'record_status_message "End"');
sendtrigger(TASK_END,port,SITE,stayup);

% Save the data
filePath = fullfile(DATA_PATH, num2str(sid));
mkdir(filePath)
save(fullfile(filePath, strcat(num2str(sid), '_Eye.mat')), 'd');

% close EEG and ET
% Change to your lab's EEG event code script
closeEEGandET;

% Display end of experiment text
Screen('FillRect', ptbWindow, colorBackground, rect);
DrawFormattedText(ptbWindow, endText, 'center', 'center', [0 0 0]);
Screen('Flip', ptbWindow);
WaitSecs(1.500);
sca;



