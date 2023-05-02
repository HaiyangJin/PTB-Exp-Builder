function prf_background(param)
% prf_background(param)
%
% Draw the default background.
%
% Created by Haiyang Jin (2023-May-1)

% draw line array
ptb_bgarray(param);
% draw dot array
Screen('DrawDots', param.w, param.prfposi2, param.dotva.pi, param.dcolor, ...
    [param.screenCenX, param.screenCenY], 1);

end