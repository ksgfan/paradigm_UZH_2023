function prefs = Initialize(prefs)
% Do setup for the experiment
commandwindow;
clc;
% Ensure they enter digits for the subject name and it isn't already used:
%sid = input('enter subject ID:', 's');
%while ~all(isstrprop(sid, 'digit')) || exist(fullfile('data', sprintf('s%02s.mat',sid)), 'file')
%    fprintf('If you entered a number, it may already be taken.\n');
%    sid = input('Enter Subject Number:', 's');
%end
s_rng = rng('shuffle');  % randomize seed
rng(s_rng);
%prefs.sid = sid;
prefs.rng = s_rng;
end
