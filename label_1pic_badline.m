% label_1pic_badline(FIG)
%   1. Loads data with PICnum=FIG.PICnum
%   2. Updates data.Stimuli.bad_lines with FIG.badlines
%   3. Saves updated data
function badlines=label_1pic_badline(FIG)

PICnum= FIG.PICnum;
badlines= FIG.badlines;

% if ~isempty(badlines(PICnum).vals)
curFile=dir(sprintf('p%04d*',PICnum));
data=load(curFile.name);
data=data.data;

if isequal(data.Stimuli.bad_lines, badlines(PICnum).vals)
    fprintf('-------- Nothing to label, same badlines \n');
    return;
else
    data.screening.refract_check_tag= false;
    maxLine= max([max(data.spikes{1}(:,1)), data.Stimuli.fully_presented_stimuli]);
    badlines(PICnum).vals(badlines(PICnum).vals > maxLine)=[];
    %         curBadLines=sort(badlines(PICnum).vals, 'descend');
    %%         Do not alter the data. Only save the badlines.
    data.Stimuli.bad_lines=badlines(PICnum).vals;
    fprintf('Updated (labelled bad lines) file named %s\n', curFile.name);
    save(curFile.name, 'data')
end