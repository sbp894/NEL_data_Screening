function fix_track_unitnum_bf(ChinNum)

%%
TFiltWidthTC=5;
%%
hanTC=101;
figure(hanTC);
clf;
set (gcf, 'Units', 'normalized', 'Position', [.1 .1 .8 .8]);
hold on;
lwLines=2;
lwHeavy=5;
MarkerSize=15;

%%
CodesDir='/media/parida/DATAPART1/Matlab/Screening/';
addpath(CodesDir);
MATDataDir='/media/parida/DATAPART1/Matlab/ExpData/MatData/';

checkDIR=dir(sprintf('%s*Q%d*AN*',MATDataDir,ChinNum));
if isempty(checkDIR)
    error('No such directory for animal number %d',ChinNum);
elseif length(checkDIR)~=1
    
    
    fprintf('Multiple directories found.\n');
    for dirVar= 1:length(checkDIR)
        fprintf('(%d)-%s\n', dirVar, checkDIR(dirVar).name);
    end
    
    chosen_dir_num= input('Which one? \n');
    DataDir=[MATDataDir checkDIR(chosen_dir_num).name];
    
    %     error('Multiple directories. Change!');
    
else
    DataDir=[MATDataDir checkDIR.name];
end

cd(DataDir);

allCalibfiles=dir('*calib*raw*'); % for dataDirs after Sep 2019
if isempty(allCalibfiles)
    allCalibfiles=dir('*calib*'); % for dataDirs before Sep 2019
end
fprintf('Using file : %s as calib files\n', allCalibfiles(end).name);
x=load(allCalibfiles(end).name);
CalibData=x.data.CalibData(:,1:2);

allTCfiles=dir('*tc*');
allUnitfiles=dir('Unit*');
mismatch_names=[];

if length(allUnitfiles)>length(allTCfiles)
    cd(CodesDir);
    error('There are %d TC files, but %d Unit files. Delete the unit files that are extra.', length(allTCfiles), length(allUnitfiles));
elseif length(allUnitfiles)<length(allTCfiles)
    cd(CodesDir);
    error('There are %d TC files, but %d Unit files. Delete extra TC or move it to a different folder', length(allTCfiles), length(allUnitfiles));
else
    BF_kHz=zeros(length(allTCfiles),5); % track | unit | BF from attenuation | BF from SPL | percentage difference
    for file_var=1:length(allTCfiles)
        x=load(allTCfiles(file_var).name);
        x=x.data;
        TCdata=x.TcData;
        TCdata=TCdata(TCdata(:,1)~=0,:);  % Get rid of all 0 freqs
        TCdata=TCdata(TCdata(:,2)~=x.Stimuli.file_attlo,:);  % Get rid of all 'upper atten limit points'
        
        for i=1:size(TCdata,1)
            TCdata(i,3)=CalibInterp(TCdata(i,1),CalibData)-TCdata(i,2);
        end
        TCdata(:,4)=trifilt(TCdata(:,3)',TFiltWidthTC)';
        if isfield(x.Thresh,'BF')
            BF_kHz(file_var,3)=x.Thresh.BF;
        else
            BF_kHz(file_var,3)=nan;
        end
        WhatTCData=4;
        BF_kHz(file_var,4)=TCdata(TCdata(:,WhatTCData)==min(TCdata(:,WhatTCData)),1);
        h1=semilogx(TCdata(:,1),TCdata(:,4),'LINEWIDTH',lwLines);
        color = get(h1, 'Color');
        semilogx(BF_kHz(file_var,4),min(TCdata(:,WhatTCData)),'x','color',color ,'markersize',MarkerSize, 'linew', lwHeavy);
        
        x=load(allUnitfiles(file_var).name);
        data=x.data;
        
        temp=sscanf(allTCfiles(file_var).name, 'p%04d_u%d_%02d_tc*');
        picNum=temp(1);
        TCtrack=temp(2);
        TCunit=temp(3);
        BF_kHz(file_var,1)=TCtrack;
        BF_kHz(file_var,2)=TCunit;
        
        if TCtrack==data.track && TCunit==data.No
            fprintf('PIC %s is for Unit file %s with TrackNum %d and UnitNum %d\n', ...
                allTCfiles(file_var).name, allUnitfiles(file_var).name,data.track,data.No);
        else
            fprintf(2, 'PIC %s is for Unit file %s with TrackNum %d and UnitNum %d\n', ...
                allTCfiles(file_var).name, allUnitfiles(file_var).name,data.track,data.No);
            mismatch_names(end+1).picNumStart=picNum; %#ok<AGROW>
            temp=sscanf(allTCfiles(file_var+1).name, 'p%04d_u%d_%02d_tc*');
            mismatch_names(end).picNumEnd=temp(1)-1;
            mismatch_names(end).old_track=TCtrack;
            mismatch_names(end).old_unit=TCunit;
            mismatch_names(end).next_track=data.track;
            mismatch_names(end).next_unit=data.No;
        end
    end
end
set(gcf,'visible','off');

if ~isempty(mismatch_names)
    for errVar=1:length(mismatch_names)
        %         resp0=questdlg(sprintf('Hit yes to rename file number %d-%d to track %d and unit %d', ...
        %             mismatch_names(errVar).picNumStart, mismatch_names(errVar).picNumEnd, mismatch_names(errVar).next_track, mismatch_names(errVar).next_unit),...
        %             'Inconsistent naming of files (see red output)?',...
        %             'NO','YES','NO');
        %
        resp0=input(sprintf('Hit yes to rename file number %d-%d to track %d and unit %d, consistent naming of files (see red output)? (y/n)', ...
            mismatch_names(errVar).picNumStart, mismatch_names(errVar).picNumEnd, mismatch_names(errVar).next_track, mismatch_names(errVar).next_unit), 's');
        
        
        if strcmp(resp0, 'y')
            for picNum=mismatch_names(errVar).picNumStart:mismatch_names(errVar).picNumEnd
                fNameOld=getFileName(picNum);
                fNameNew=strrep(fNameOld, sprintf('_u%d_%02d_',mismatch_names(errVar).old_track,mismatch_names(errVar).old_unit), sprintf('_u%d_%02d_',mismatch_names(errVar).next_track,mismatch_names(errVar).next_unit));
                fprintf('changed file %s -- to -> %s\n', fNameOld, fNameNew);
                if ~isequal(fNameOld, fNameNew)
                    movefile(fNameOld, fNameNew);
                end
            end
        end
    end
end


set(gcf,'visible','on');
xlabel('Frequncy (kHz)');
ylabel('Threshold (SPL)');
title(sprintf('Tuning Curves for Chin %d',ChinNum));
set(gca, 'xscale', 'log', 'xtick', [200 500 1e3 2e3 5e3 10e3 12e3]/1e3);
grid on;
% resp2=questdlg('TCs and track_units look good!', 'Hit NEXT to compare the BF values','STOP','NEXT','NEXT');
resp2=input('All good? (y/n)', 's');

set(gcf,'visible','off');

switch lower(resp2)
    case {'y', 'yes'}
        BF_kHz(:,5)=100*(BF_kHz(:,3)-BF_kHz(:,4))./BF_kHz(:,4);
        fprintf('--------------------------------------------\n--------------------------------------------\n');
        fprintf('[Track| Unit| BF_atten| BF_SPL| %%difference]\n');
        fprintf('%.0f \t %.0f \t %.2f \t %.2f \t %.2f \n', BF_kHz');
        %     resp3=input('Does everything look okay [BF from atten || BF from SPL|| %%difference]? (say yes)', 'Confirm to add BFfromSPL field to Unit files','NO','YES','NO');
        resp3=input('Does everything look okay [BF from atten || BF from SPL|| %%difference]? (y/n)', 's');
        
        switch lower(resp3)
            case {'yes', 'y'}
                for file_var=1:length(allUnitfiles)
                    x=load(allUnitfiles(file_var).name);
                    data=x.data;
                    data.BFcalib=BF_kHz(file_var,4);
                    save(allUnitfiles(file_var).name,'data');
                end
            case {'no', 'n'}
                return;
        end
end


allfiles=dir('p*.mat');
for fileVar=1:length(allfiles)
    fName=allfiles(fileVar).name;
    if contains(fName(6:7), '_u')  % Should be p*_u*.mat
        load(fName);
        TrackUnitNum=getTrackUnit(fName);
        
        if data.General.track~=TrackUnitNum(1)
            fprintf('%s --> track updated from %d to %d in data.general\n', fName, data.General.track, TrackUnitNum(1));
            data.General.track=TrackUnitNum(1);
        end
        
        if data.General.unit~=TrackUnitNum(2)
            fprintf('%s --> unit updated from %d to %d in data.general\n', fName, data.General.unit, TrackUnitNum(2));
            data.General.unit=TrackUnitNum(2);
        end
        save(fName, 'data');
    end
end



cd(CodesDir);
update_bf_per_chin(ChinNum);