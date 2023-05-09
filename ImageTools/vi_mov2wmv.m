function vi_mov2wmv(movfn, mmpath)
% vi_mov2wmv(movfn, mmpath)
%
% Convert *.mov (or other files that can be read via VideoReader()) into 
% *.wmv. This function has to be run in WINDOWS (with 
% K-Lite_Codec_Pack_1687_Full.exe installed).
% The mmwrite toolbox should be set up.
% https://www.mathworks.com/matlabcentral/fileexchange/15881-mmwrite
%
% Inputs:
%    movfn           <str> (path and) file name of the video file that can 
%                     be read by VideoReader(). 
%    mmpath          <str> path to the mmwrite toolbox.
%
% Created by Haiyang Jin (2023-May-3)
%
% See also:
% vi_mov2mat(); vi_mat2wmv()

assert(~isunix, 'vi_mov2wmv() only works in Windows.');

[thepath, fn] = fileparts(movfn);
outfn = fullfile(thepath, [fn '.wmv']);

% add necessary paths for external toolboxes
if ~exist('mmpath', 'var') || isempty(mmpath)
    mmpath = fullfile(pwd, 'mmwrite');
end
addpath(genpath(mmpath));

%% Load the video
mov = VideoReader(movfn);
% read(mov,iframe) % get each frame

%% Save video to wmv
% Set video parameters
wmv = struct;
wmv.height = mov.Height;
wmv.width = mov.Width;
nframes = mov.NumFrames;
wmv.times = (1:nframes) ./ mov.FrameRate; 

% Create video frames
frames = struct;
for iframe = 1:nframes
    frames(iframe).cdata = read(mov,iframe);
end 
wmv.frames = frames;

%% Save wmv locally
try
    mmwrite(outfn, wmv);
 catch error
    fprintf(['Please make sure the mmwrite toolbox (%s) is set up properly.', ...
        'https://www.mathworks.com/matlabcentral/fileexchange/15881-mmwrite']);
    rethrow(error);
end

end