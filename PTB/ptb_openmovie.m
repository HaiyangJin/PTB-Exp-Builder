function stimDir = ptb_openmovie(videoDir, window)
% stimDir = ptb_openmovie(videoDir, window)
%
% Open movies in PTB. It could be used either in the preparation phase or
% within each trial.
% If the number of movies are not too large (maybe smaller than 100), they
% are recommended to be preloaded in the preparation phase. If there are
% too many movies, it is better to open movie on each trial (and close
% them).
%
% Inputs:
%    videoDir       <struct> video directory read by im_dir().
%    window         <int> the window index in PTB.
%
% Output:
%    stimDir        <struct> the stimulus structure.
%
% Created by Haiyang Jin (2021-11-23)
%
% See also:
% im_dir; im_readdir

nVideo = length(videoDir);
outcell = cell(nVideo, 1);

% open video for each separately
for iV = 1:nVideo

    tmp = videoDir(iV);

    % open movie
    [movieptr, duration, fps, imgx, imgy, count] = Screen('OpenMovie', ...
        window, fullfile(tmp.folder, tmp.name));

    % save the relevant information
    tmp.movieptr = movieptr;
    tmp.duration = duration;
    tmp.fps = fps;
    tmp.imgX = imgx;
    tmp.imgY = imgy;
    tmp.count = count;

    outcell{iV, 1} = tmp;
end

% save the output as struct
stimDir = vertcat(outcell{:});

end