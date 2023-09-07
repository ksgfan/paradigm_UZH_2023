function p = Preferences(dist_cm, monitorwidth_cm)
% Setup preferences for this experiment
p.monitor     = 1; %max(Screen('Screens'));
p.keys	      = KbName('space');
p.quitKey     = KbName('q');
p.tmp = Screen('Resolution',p.monitor);
p.resolution = [p.tmp.width, p.tmp.height];
p.dist =  dist_cm;  % viewing distance (cm)
p.width = monitorwidth_cm;  % width of screen (cm) (macBook = 33)
p.pixelSize=p.width/p.resolution(1);
p.backColor = [128, 128, 128];
p.white = [200 200 200];
p.gray = [120 120 120];
p.adjClut = 0; % adjust monitor CLUT?
p.frameRate=Screen('FrameRate',p.monitor);
% if(p.frameRate == 0), p.frameRate=59; end % if MacOSX does not know the frame rate the 'FrameRate' will return 0. - set to 85Hz for now...
% end
