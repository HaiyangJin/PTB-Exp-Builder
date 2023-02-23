function param = ptb_language(param)
% param = ptb_language(param)
%
% check whether English or Chinese should be used.
%
% Inputs:
%    param         experiment parameters
%
% Created by Haiyang Jin (2023)

% use English by default
if ~isfield(param, 'language')
    param.language = 'en';
end

switch param.language
    case 'en'

        param.loadingText = sprintf('Experiment is loading... Please wait...');
        param.forceQuitText = sprintf(['The experiment will quit now. \n\n'...
            'Please press any key to continue...']);
        param.noRespText = sprintf(['Something wrong happended... \n\n'...
            'Please press any key to continue...']);
        param.breakEndText = sprintf(['You can now continue with this part.' ...
            '\n \nPress any key when ready.']);
        param.partEnd = sprintf(['This part is finished!' ...
            '\n \nPlease contact the experimenter.']);
        param.expEnd = sprintf(['This task is finished!' ...
            '\n \nPlease contact the experimenter.']);

    case 'cn'

        allfonts = FontInfo('Fonts');
        Screen('TextFont',param.w,allfonts(26).number);

        param.loadingText = double('正在载入实验，请稍后...');
        param.forceQuitText = double(['正在退出实验... \n\n'...
            '请按任意键继续...']);
        param.noRespText = double(['未知错误... \n\n'...
            '请按任意键继续...']);
        param.breakEndText = double('你现在可以继续进行实验。\n\n请准备好后按任意键继续.');
        param.partEnd = double('恭喜你完成了这一部分.\n \n请联系实验主试.');
        param.expEnd = double('恭喜你完成了这个实验!\n \n请联系实验主试.');

    otherwise
        error('Unknown language...');
end

end