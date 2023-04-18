function ptb_feedback(acc, param)
% This functions displays the accuracy and response times for the current
% trial.
%
% Inputs:
%     acc         <numeric> the accuracy for the current trial.
%     window      <numeric> param.w
%
% Output:
%     display the feedback.
%
% Created by Haiyang Jin

if isnan(acc)
    return;
end

% feedback options
feedbackOptions = param.feedbackOptions;
feedbackColor = {[255 0 0 ],[ 0 0 255]}; % red, blue

% display feedback
DrawFormattedText(param.w,feedbackOptions{acc+1},'center','center',feedbackColor{acc+1});    
Screen('Flip',param.w);
WaitSecs(1);

end