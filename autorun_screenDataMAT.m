function autorun_screenDataMAT(chinID)

orgBadlinesDir= '/media/parida/DATAPART1/Matlab/GeneralOutput/BADlines_org/';
badlines_file= dir([orgBadlinesDir '*' num2str(chinID) '*']);
badLinesStruct= load([orgBadlinesDir badlines_file.name]);
badLinesStruct= badLinesStruct.badLinesStruct;

pics_done= auto_screenDataMAT(chinID);
if ~isempty(badLinesStruct(pics_done).badlines) | ~isnan(badLinesStruct(pics_done).badlines) %#ok<OR2>
    FIG= guidata(1001);
    set(FIG.handles.BadLineEdit, 'string', MakeInputPicString(badLinesStruct(pics_done).badlines));
    screenDataMAT('Badlines_Editcallback');
    screenDataMAT('badLinesRemoveAction');
end

while pics_done
    screenDataMAT('censor_refractory');
    pics_done=auto_screenDataMAT('NextPic_PBcallback');
    if pics_done>0
        if ~isempty(badLinesStruct(pics_done).badlines) & any(~isnan(badLinesStruct(pics_done).badlines))  %#ok<AND2>
            FIG= guidata(1001);
            set(FIG.handles.BadLineEdit, 'string', MakeInputPicString(badLinesStruct(pics_done).badlines));
            screenDataMAT('Badlines_Editcallback');
            screenDataMAT('badLinesRemoveAction');
        end
    end
end