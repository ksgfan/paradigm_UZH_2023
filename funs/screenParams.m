% setup the Screen
% XOrgConfCreator % run only once and tell psychtoolbox, how to organize
% screens
% XOrgConfSelector % if issues with copying the file on LInux, run the next line in
% terminal:
% sudo cp /home/methlab/.Psychtoolbox/XorgConfs/90-ptbconfig_2_xscreens_2_outputs_amdgpu.conf /etc/X11/xorg.conf.d/90-ptbxorg.conf
% to reverse:
% sudo cp /home/methlab/.Psychtoolbox/XorgConfs/90-ptbconfig_1_xscreens_1_outputs_amdgpu.conf /etc/X11/xorg.conf.d/90-ptbxorg.conf
% Restart computer to confirm the changes!

% sanity check, whether 2 screens detected
% Screen('Screens')
% Screen('Resolutions', 0)
% Screen('Resolutions', 1)

% Set Screen to run experiment on
whichScreen = 1;  

% set resolution and refresh rate
screenWidth = 800;
screenHeight = 600;
refreshRate = 100;
SetResolution(whichScreen, screenWidth, screenHeight, []);
Screen('ConfigureDisplay', 'Scanout', whichScreen, 0, screenWidth, screenHeight, refreshRate); % refresh rate of 100hz

monitorwidth_cm = 40;
dist_cm = 70;

load gammafnCRT;   % load the gamma function parameters for this monitor - or some other CRT and hope they're similar! (none of our questions rely on precise quantification of physical contrast)
maxLum = GrayLevel2Lum(255,Cg,gam,b0);
par.BGcolor = Lum2GrayLevel(maxLum/2,Cg,gam,b0);
