% Eye tracker

% add TITTA to path
cd(TITTA_PATH);
addTittaToPath;
cd(rootFilepath);

% ET settings
ET_NAME = 'Tobii Pro Fusion';

DEBUGlevel              = 0;
fixClrs                 = [0 255];
bgClr                   = 127;
useAnimatedCalibration  = true;
doBimonocularCalibration= false;
runInDummyMode          = false;

% get setup struct (can edit that of course):
settings = Titta.getDefaults(ET_NAME);
settings.freq = 250; % sampling rate
% request some debug output to command window, can skip for normal use
settings.debugMode      = false;
% customize colors of setup and calibration interface (colors of
% everything can be set, so there is a lot here).
% 1. setup screen
settings.UI.setup.bgColor       = bgClr;
settings.UI.setup.instruct.color= fixClrs(1);
settings.UI.setup.fixBackColor  = fixClrs(1);
settings.UI.setup.fixFrontColor = fixClrs(2);
% 2. validation result screen
settings.UI.val.bgColor                 = bgClr;
settings.UI.val.avg.text.color          = fixClrs(1);
settings.UI.val.fixBackColor            = fixClrs(1);
settings.UI.val.fixFrontColor           = fixClrs(2);
settings.UI.val.onlineGaze.fixBackColor = fixClrs(1);
settings.UI.val.onlineGaze.fixFrontColor= fixClrs(2);
% calibration display
if useAnimatedCalibration
    % custom calibration drawer
    calViz                      = AnimatedCalibrationDisplay();
    settings.cal.drawFunction   = @calViz.doDraw;
    calViz.bgColor              = bgClr;
    calViz.fixBackColor         = fixClrs(1);
    calViz.fixFrontColor        = fixClrs(2);
else
    % set color of built-in fixation points
    settings.cal.bgColor        = bgClr;
    settings.cal.fixBackColor   = fixClrs(1);
    settings.cal.fixFrontColor  = fixClrs(2);
end
% callback function for completion of each calibration point
settings.cal.pointNotifyFunction = @CalCompletionFun;

% init
EThndl          = Titta(settings);
if runInDummyMode
    EThndl          = EThndl.setDummyMode();
end
EThndl.init();

if DEBUGlevel>1
    % make screen partially transparent on OSX and windows vista or
    % higher, so we can debug.
    PsychDebugWindowConfiguration;
end
if DEBUGlevel
    % Be pretty verbose about information and hints to optimize your code and system.
    Screen('Preference', 'Verbosity', 4);
else
    % Only output critical errors and warnings.
    Screen('Preference', 'Verbosity', 2);
end
Screen('Preference', 'SyncTestSettings', 0.002);    % the systems are a little noisy, give the test a little more leeway
[ptbWindow,winRect] = PsychImaging('OpenWindow', whichScreen, bgClr, [], [], [], [], 4);
hz=Screen('NominalFrameRate', ptbWindow);
Priority(1);
Screen('BlendFunction', ptbWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Preference', 'TextAlphaBlending', 1);
Screen('Preference', 'TextAntiAliasing', 2);
% This preference setting selects the high quality text renderer on
% each operating system: It is not really needed, as the high quality
% renderer is the default on all operating systems, so this is more of
% a "better safe than sorry" setting.
Screen('Preference', 'TextRenderer', 1);
KbName('UnifyKeyNames');    % for correct operation of the setup/calibration interface, calling this is required

% do calibration
try
    ListenChar(-1);
catch ME
    % old PTBs don't have mode -1, use 2 instead which also supresses
    % keypresses from leaking through to matlab
    ListenChar(2);
end
if doBimonocularCalibration
    % do sequential monocular calibrations for the two eyes
    settings                = EThndl.getOptions();
    settings.calibrateEye   = 'left';
    settings.UI.button.setup.cal.string = 'calibrate left eye (<i>spacebar<i>)';
    str = settings.UI.button.val.continue.string;
    settings.UI.button.val.continue.string = 'calibrate other eye (<i>spacebar<i>)';
    EThndl.setOptions(settings);
    tobii.calVal{1}         = EThndl.calibrate(ptbWindow,1);
    if ~tobii.calVal{1}.wasSkipped
        settings.calibrateEye   = 'right';
        settings.UI.button.setup.cal.string = 'calibrate right eye (<i>spacebar<i>)';
        settings.UI.button.val.continue.string = str;
        EThndl.setOptions(settings);
        tobii.calVal{2}         = EThndl.calibrate(ptbWindow,2);
    end
else
    % do binocular calibration
    tobii.calVal{1}         = EThndl.calibrate(ptbWindow);
end
ListenChar(0);

% start ET recording
EThndl.buffer.start('gaze');
WaitSecs(.8);   % wait for eye tracker to start and gaze to be picked up


