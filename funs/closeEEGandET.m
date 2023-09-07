% Stop EEG and ET recordings and save the data

trigger = 2; % 2 stops the ANT Neuro
sendtrigger(trigger,port,SITE,stayup)
ppdev_mex('CloseAll');

fprintf('Stop Recording Track\n');
Eyelink('StopRecording'); %Stop Recording
Eyelink('CloseFile');
fprintf('Downloading File\n');
EL_DownloadDataFile % Downloading the file
EL_Cleanup %Shutdown Eyetracker and close all Screens

% convert to text files
pathEdf2Asc = '/usr/bin/edf2asc';  
disp("CONVERTING EDF to ASCII...")
system([pathEdf2Asc ' "' fullfile(filePath, edfFile) '" -y']);


