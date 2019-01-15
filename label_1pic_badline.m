function badlines=label_1pic_badline( chinID, PICnum, badlines, MATDataDir)

checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,chinID));

if ~isempty(badlines(PICnum).vals)
    curFile=dir(sprintf('p%04d*',PICnum));
    data=load(curFile.name);
    data=data.data;
    %         curBadLines=sort(badlines(PICnum).vals, 'descend');
    %%         Do not alter the data. Only save the badlines.
    data.Stimuli.bad_lines=badlines(PICnum).vals;
    fprintf('Updated (labelled bad lines) file named %s\n', curFile.name);
    save(curFile.name, 'data')
end

%     badlines(PICnum).Done=1;
