function fix_track_unitnum_bf(ChinNum)

%%
TFiltWidthTC=5;
%%
hanTC=101;
figure(hanTC);
clf;
set (gcf, 'Units', 'normalized', 'Position', [.1 .1 .8 .8]);
hold on;
LineWidth=2;
MarkerSize=15;

%%
CodesDir=pwd;
addpath(CodesDir);
MATDataDir='R:\Users\Satya\SP\MATData\';

checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,ChinNum));
if isempty(checkDIR)
    error('No such directory for animal number %d',ChinNum);
elseif length(checkDIR)~=1
    error('Multiple directories. Change!');
else
    DataDir=[MATDataDir checkDIR.name];
end

cd(DataDir);

allCalibfiles=dir('*calib*');
sprintf('Using file : %s as calib files', allCalibfiles(end).name);
x=load(allCalibfiles(end).name);
CalibData=x.data.CalibData(:,1:2);

allTCfiles=dir('*tc*');
allUnitfiles=dir('Unit*');

if length(allUnitfiles)>length(allTCfiles)
    cd(CodesDir);
    error('There are %d TC files, but %d Unit files. Delete the unit files that are extra.', length(allTCfiles), length(allUnitfiles));
elseif length(allUnitfiles)<length(allTCfiles)
    cd(CodesDir);
    error('There are %d TC files, but %d Unit files. Delete extra TC or move it to a different folder', length(allTCfiles), length(allUnitfiles));
else
    BF_kHz=zeros(length(allTCfiles),2);
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
            BF_kHz(file_var,1)=x.Thresh.BF;
        else
            BF_kHz(file_var,1)=nan;
        end
        WhatTCData=4;
        BF_kHz(file_var,2)=TCdata(TCdata(:,WhatTCData)==min(TCdata(:,WhatTCData)),1);
        h1=semilogx(TCdata(:,1),TCdata(:,4),'LINEWIDTH',LineWidth);
        color = get(h1, 'Color');
        semilogx(BF_kHz(file_var,2),min(TCdata(:,WhatTCData)),'x','color',color ,'MARKERSIZE',MarkerSize);
        
        x=load(allUnitfiles(file_var).name);
        data=x.data;
        fprintf('PIC %s is for Unit file %s with TrackNum %d and UnitNum %d\n', ...
            allTCfiles(file_var).name, allUnitfiles(file_var).name,data.track,data.No);
        
    end
end
set(gcf,'visible','off');
resp1=questdlg('Are the TC files and Unit files consistent?', 'Hit yes to compare the BF values','NO','YES','NO');
set(gcf,'visible','on');
xlabel('Frequncy (kHz)');
ylabel('Threshold (SPL)');
title(sprintf('Tuning Curves for Chin %d',ChinNum));
resp2=questdlg('Are the TC files and Unit files consistent?', 'Hit yes to compare the BF values','NO','YES','NO');
set(gcf,'visible','off');

if strcmp(resp1,'YES') && strcmp(resp2,'YES')
    disp(BF_kHz);
    resp3=questdlg('Does everything look okay [BF from atten || BF from SPL]?', 'Confirm to add BFfromSPL field to Unit files','NO','YES','NO');
    
    if strcmp(resp3,'YES')
        for file_var=1:length(allUnitfiles)
            x=load(allUnitfiles(file_var).name);
            data=x.data;
            data.BFmod=BF_kHz(file_var,2);
            save(allUnitfiles(file_var).name,'data');
        end
    end
end