function newDat = convertTobii2EYE(dat, firstEvent)
% convert Tobii ET data to EYE-EEG format
% firstEvent - first task-related event, e.g. 10 in EEGManyLabs

% create required fields
newDat = struct;
newDat.comments = dat.settings;
newDat.colheader = {'TIME','L_GAZE_X','L_GAZE_Y','R_GAZE_X','R_GAZE_Y','L_PUPIL', 'R_PUPIL', ...
    'L_EYE_OPE', 'R_EYE_OPE','L_GAZE_valid','R_GAZE_valid'};
newDat.data = [];
newDat.data(:, 1) = dat.data.gaze.systemTimeStamp;
newDat.data(:, 2) = dat.data.gaze.left.gazePoint.onDisplayArea(1, :)' * dat.screenWidth;
newDat.data(:, 3) = dat.data.gaze.left.gazePoint.onDisplayArea(2, :)' * dat.screenHeight;
newDat.data(:, 4) = dat.data.gaze.right.gazePoint.onDisplayArea(1, :)' * dat.screenWidth;
newDat.data(:, 5) = dat.data.gaze.right.gazePoint.onDisplayArea(2, :)' * dat.screenHeight;
newDat.data(:, 6) = dat.data.gaze.left.pupil.diameter;
newDat.data(:, 7) = dat.data.gaze.right.pupil.diameter;
newDat.data(:, 8) = dat.data.gaze.left.eyeOpenness.diameter;
newDat.data(:, 9) = dat.data.gaze.right.eyeOpenness.diameter;
newDat.data(:, 10) = dat.data.gaze.left.gazePoint.valid;
newDat.data(:, 11) = dat.data.gaze.right.gazePoint.valid;
newDat.messages = dat.messages;
newDat.eyeevent = struct;

% remove calibration messages
allEvents = dat.messages(:, 2);

for ev = 1 : length(allEvents)
    var = cell2mat(allEvents(ev));
    if var == firstEvent
        idx = ev;
    end
end

% save task-related events to event variable
newDat.event = [];
newDat.event(:, 1) = cell2mat(dat.messages(idx:length(allEvents), 1));
newDat.event(:, 2) = cell2mat(dat.messages(idx:length(allEvents), 2));

% save dat to newDat
newDat.TobiiData = dat;

