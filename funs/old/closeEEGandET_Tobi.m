% Stop EEG and ET recordings and save the data

if TRAINING == 0
    % stop recoring EEG of current task:
    trigger = 2; % 2 stops the ANT Neuro
    sendtrigger(trigger,port,SITE,stayup)
    ppdev_mex('CloseAll');
end

% stop recording ET
EThndl.buffer.stop('gaze');

% get our gaze data conveniently from buffer before we drain it with
% EThndl.collectSessionData() below. 
% save data to mat file, adding info about the experiment
dat                 = EThndl.collectSessionData();
dat.screenHeight = screenHeight;
dat.screenWidth = screenWidth;

% convert to EYE-EEG
firstEvent = 10; % first task-related Event
dat = convertTobii2EYE(dat, firstEvent);

if strcmp(TASK, 'Resting')
    save(EThndl.getFileName(fullfile(filePath,[subjectID,'_', TASK, '_ET']), true),'-struct','dat');
else
    if TRAINING == 1
        save(EThndl.getFileName(fullfile(filePath,[subjectID,'_', TASK, '_block', num2str(BLOCK), '_training_ET']), true),'-struct','dat');
    else
        save(EThndl.getFileName(fullfile(filePath,[subjectID,'_', TASK, '_block', num2str(BLOCK), '_task_ET']), true),'-struct','dat');
    end
end
% shut down
EThndl.deInit();

