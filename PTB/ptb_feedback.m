function ptb_feedback(acc, window)
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
feedbackOptions = {'Incorrect!','Correct!'};
feedbackColor = {[255 0 0 ],[ 0 0 255]}; % red, blue

% display feedback
DrawFormattedText(window,feedbackOptions{acc+1},'center','center',feedbackColor{acc+1});    
Screen('Flip',window);
WaitSecs(1);

end