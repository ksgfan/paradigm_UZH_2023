% check, if the subject fixates at the center of the screen during memory
% array and retention interval. If doesn't fixate, set a flag, which will
% trigger a warning after the trial ends

numSamples = 250; % 1 second 
fixThresh = numSamples * 0.8; % 80% threshold
trialGaze = EThndl.buffer.peekN('gaze', numSamples);

distOK = 45 + 45; % about 1 degree from the center (+ 1 deg of ET error)

try
    % input from left or right eye?
    if any(trialGaze.left.gazePoint.valid)
        gaze_x = trialGaze.left.gazePoint.onDisplayArea(1, :)' * screenWidth;
        gaze_y = trialGaze.left.gazePoint.onDisplayArea(2, :)' * screenHeight;
    else
        gaze_x = trialGaze.right.gazePoint.onDisplayArea(1, :)' * screenWidth;
        gaze_y = trialGaze.right.gazePoint.onDisplayArea(2, :)' * screenHeight;
    end
    
    % check the fixation (80% threshold)
    if sum(gaze_x > screenCentreX - distOK) > fixThresh & sum(gaze_x < screenCentreX + distOK) > fixThresh & ...
            sum(gaze_y > screenCentreY - distOK) > fixThresh & sum(gaze_y < screenCentreY + distOK) > fixThresh
        noFixation = 0; % reset
        %disp('FIXATION...')
    else
        noFixation = noFixation + 1;
        %disp('NO FIXATION...')
    end
catch
    disp('GAZE NOT FOUND. PLEASE CHECK YOUR EYE TRACKER...')
end