% check, if the subject fixates at the center of the screen during memory
% array and retention interval. If doesn't fixate, set a flag, which will
% trigger a warning after the trial ends

numSamples = 500; % 1 second 
fixThresh = numSamples * 0.8; % 80% threshold


eye_used = Eyelink('EyeAvailable'); % 0 is left, 1 is right, 2 is binocular
if eye_used == 2
    eye_used = 0;
end

[et_samples, et_events, et_drained] = Eyelink('GetQueuedData');

distOK = 45 + 45; % about 1 degree from the center (+ 1 deg of ET error)

try
    % input from left or right eye?
    if eye_used == 0  % left
        gaze_x = et_samples(14, size(et_samples, 2));
        gaze_y = et_samples(16, size(et_samples, 2));
    elseif eye_used == 1 % right
        gaze_x = et_samples(15, size(et_samples, 2) - numSamples : end);
        gaze_y = et_samples(17, size(et_samples, 2) - numSamples : end);
    end

    % disp(['X: ' num2str(gaze_x), 'Y: ' num2str(gaze_y)])
    
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