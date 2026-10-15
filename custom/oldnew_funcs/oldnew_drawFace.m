function oldnew_drawFace(w, stim, param)

%% ============================================================
%  Draw a face while preserving its aspect ratio
%  ============================================================

imgH = size(stim.matrix, 1);
imgW = size(stim.matrix, 2);

% Fit the image within the specified maximum dimensions.
scaleFactor = min([ ...
    param.maxStimSize / imgW, ...
    param.maxStimSize / imgH, ...
    1]);

destW = imgW * scaleFactor;
destH = imgH * scaleFactor;

destRect = [ ...
    param.screenCenX - destW/2, ...
    param.screenCenY - destH/2, ...
    param.screenCenX + destW/2, ...
    param.screenCenY + destH/2];

Screen('DrawTexture', w, stim.texture, [], destRect);

end
