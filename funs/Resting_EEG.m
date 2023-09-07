%% Settings

%% start recording EEG
disp('STARTING EEG RECORDING...');
initEEG;

% Calibrate ET
disp('CALIBRATING ET...');
calibrateET;

%% Settings
testmode = 0;
monitorwidth_cm = 53;
dist_cm = 72;
% Text
tSize1 = 20;
tSize2 = 20;
tSize3 = 20;
colorText = 0;
colorBG = [];
colorBrightBG = [255,255,255];
colorInfo = [255,0,0];
colorBrightGray = [];
colorDarkGray = [];

%% Instructions
ins=struct();
ins.misc=struct();
ins.misc.mouse = [...
    'Press any key to start the task'...
    ];
ins.misc.finished = [...
    'Fertig!'...
    ];
ins.resting=struct();
ins.resting.inst = [...
    'Experiment: Resting EEG' ...
    '\n\n\nYou will see a cross in the middle of the screen. '...
    '\n\nFocus your gaze on this cross. \nOpen and close your eyes when prompted.'...
    ];
ins.resting.end = [...
    'Nun folgen weitere Aufgaben. '...
    ];
%% Trials
NrOfTrials = 7;   % How many Cycles to run (8 if  you want to run 6 cycles)
eyeO = 3:60:303; % Audio cues
eyeC = 23:60:323;

% Setting the Audiofiles
wavfilename_probe1 = fullfile(FUNS_PATH, 'open_eyes.wav'); %Open Eyes
wavfilename_probe2 = fullfile(FUNS_PATH, 'close_eyes.wav');%Close Eyes

% Setting the Trigger codes
par.CD_START = 10;
par.CD_eyeO = 20;
par.CD_eyeC = 30;
par.CD_END  = 90;


%% Screen Calculations
[scresw, scresh]=Screen('WindowSize',whichScreen);  % Get screen resolution
center = [scresw scresh]/2;     % useful to have the pixel coordinates of the very center of the screen (usually where you have someone fixate)
fixRect = [center-2 center+2];  % fixation dot
hz=Screen('FrameRate', whichScreen, 1);
cm2px = scresw/monitorwidth_cm;     % multiplication factor to convert cm to pixels
deg2px = dist_cm*cm2px*pi/180;      % multiplication factor to convert degrees to pixels (uses aproximation tanT ~= T).


%% Sound Stuff
%dev = PsychPortAudio('GetDevices')
%count = PsychPortAudio('GetOpenDeviceCount')
try
    PsychPortAudio('Close');
catch
end
try
    [y_probe1, freq1] = audioread(wavfilename_probe1);
    [y_probe2, freq2] = audioread(wavfilename_probe2);
    wavedata_probe1 = y_probe1';
    wavedata_probe2 = y_probe2';
    nrchannels = size(wavedata_probe1,1); % Number of rows == number of channels.
    % Add 15 msecs latency on ptbWindows, to protect against shoddy drivers:
    sugLat = [];
    if IsWin
        sugLat = 0.015;
    end
    try
        InitializePsychSound;
        pahandle = PsychPortAudio('Open', [], [], 0, freq1, nrchannels, [], sugLat); % look for devices
        duration_probe1 = size(wavedata_probe1,2)/freq1;
        duration_probe2 = size(wavedata_probe2,2)/freq1;
    catch
        error('Sound Initialisation Error');
    end
catch
    error('Sound Error');
end

i = 1;
t = 1;
tt = 1;

%% Experiment ptbWindow
clc;
ptbWindow=Screen('OpenWindow', whichScreen, par.BGcolor); % dont need to open a screen again
Screen('TextSize', ptbWindow, tSize2);
DrawFormattedText(ptbWindow, ins.resting.inst, 'center', scresh / 3, colorText);
DrawFormattedText(ptbWindow, ins.misc.mouse,'center', 0.9*scresh, colorText);
Screen('Flip', ptbWindow);

HideCursor(whichScreen);

clc;
disp('THE SUBJECT IS READING THE INSTRUCTIONS');

waitResponse = 1;
while waitResponse
    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;
end

%% Experiment Block
time = GetSecs;

% send triggers: task starts!
% EThndl.sendMessage(par.CD_START);
Eyelink('Message',num2str(par.CD_START));
Eyelink('command', 'record_status_message "START"');
sendtrigger(par.CD_START,port,SITE,stayup)

%while ~KbCheck
if testmode == 1
    trials = 4; % Test Mode
else
    trials = NrOfTrials;
end
fprintf('Running Trials\n');
while t < trials
    Screen('DrawLine', ptbWindow,[0 0 0],center(1)-7,center(2), center(1)+7,center(2));
    Screen('DrawLine', ptbWindow,[0 0 0],center(1),center(2)-7, center(1),center(2)+7);
    vbl = Screen('Flip',ptbWindow); % clc
    if vbl >=time+eyeO(t) %Tests if a second has passed
        
        % send triggers
        % EThndl.sendMessage(par.CD_eyeO);
        Eyelink('Message',num2str(par.CD_eyeO));
        Eyelink('command', 'record_status_message "EyeO"');
        sendtrigger(par.CD_eyeO,port,SITE,stayup)

        disp('Eyes Open');
        
        PsychPortAudio('FillBuffer', pahandle,wavedata_probe1);
        PsychPortAudio('Start', pahandle, 1, 0, 1);
        t = t+1;
    end
    
    if vbl >=time+eyeC(tt) %Tests if a second has passed

        % send triggers
%         EThndl.sendMessage(par.CD_eyeC);
        Eyelink('Message',num2str(par.CD_eyeC));
        Eyelink('command', 'record_status_message "EyeC"');
        sendtrigger(par.CD_eyeC,port,SITE,stayup)

        disp('Eyes Closed');
        PsychPortAudio('FillBuffer', pahandle,wavedata_probe2);
        PsychPortAudio('Start', pahandle, 1, 0, 1);
        tt = tt+1;
    end
end

% send triggers
% EThndl.sendMessage(par.CD_END);
Eyelink('Message',num2str(par.CD_END));
Eyelink('command', 'record_status_message "End"');
sendtrigger(par.CD_END,port,SITE,stayup)

disp('Done');
Screen('TextSize', ptbWindow, tSize3);
DrawFormattedText(ptbWindow, ins.misc.finished,'center', 0.4*scresh, colorText);
Screen('TextSize', ptbWindow, tSize2);
DrawFormattedText(ptbWindow, ins.resting.end,'center', 0.5*scresh, colorText);
Screen('Flip', ptbWindow);
ShowCursor(whichScreen);
WaitSecs(5);

% save data
subjectID = num2str(subject.ID);
filePath = fullfile(DATA_PATH, subjectID);
mkdir(filePath)
save(fullfile(filePath, [subjectID,'_', TASK, '.mat']),'par','eyeO','eyeC');

% close and save EEG and ET
disp('SAVING DATA...');
closeEEGandET;

sca; %If Eyetracker wasn't used, close the Screens now
try
    PsychPortAudio('Close');
catch
end

