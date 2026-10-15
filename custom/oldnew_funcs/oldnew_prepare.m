function param = oldnew_prepare(param)

%% ============================================================
%  Prepare the study and recognition trial sequence
%  ============================================================

nStim = numel(param.stimuli);

nStudy = param.nStudy;
nTestOld = param.nTestOld;
nTestNew = param.nTestNew;

% Check that there are enough images for the experiment.
if nStim < nStudy + nTestNew
    error(['Not enough stimulus images. Found %d images, ', ...
        'but at least %d are required.'], ...
        nStim, nStudy + nTestNew);
end

% Randomly select images for the study phase.
randOrder = randperm(nStim);

studyIdx = randOrder(1:nStudy);

% Select new images from the remaining image pool.
remainingIdx = randOrder(nStudy+1:end);

newIdx = remainingIdx(1:nTestNew);

% Old test images are the same images shown during study.
oldIdx = studyIdx(randperm(nStudy, nTestOld));

% Construct the recognition test.
testIdx = [oldIdx(:); newIdx(:)];
testIsOld = [ones(nTestOld, 1); zeros(nTestNew, 1)];

% Randomize recognition test order.
testOrder = randperm(numel(testIdx));

testIdx = testIdx(testOrder);
testIsOld = testIsOld(testOrder);

% The study phase precedes the recognition phase.
param.tn = nStudy + numel(testIdx);

% Create a trial structure compatible with ptb_runexp.
param.ed = repmat(struct( ...
    'isStudy', 0, ...
    'stimIndex', 0, ...
    'isOld', NaN, ...
    'itemID', 0), param.tn, 1);

% Study trials.
for i = 1:nStudy

    param.ed(i).isStudy = 1;
    param.ed(i).stimIndex = studyIdx(i);
    param.ed(i).isOld = NaN;
    param.ed(i).itemID = i;

end

% Recognition trials.
for i = 1:numel(testIdx)

    t = nStudy + i;

    param.ed(t).isStudy = 0;
    param.ed(t).stimIndex = testIdx(i);
    param.ed(t).isOld = testIsOld(i);
    param.ed(t).itemID = i;

end

fprintf('\nOld/new task design prepared.\n');
fprintf('Available images: %d\n', nStim);
fprintf('Study trials: %d\n', nStudy);
fprintf('Old test trials: %d\n', nTestOld);
fprintf('New test trials: %d\n', nTestNew);
fprintf('Total trials: %d\n\n', param.tn);

end
