% Need to add a continue button
% also, of you are continuing, plot the updated BF/Thresh

function update_bf_per_chin(ChinNum)
%%
TFiltWidthTC=5;
%%
hanTC=101;
figure(hanTC);
clf;
set (gcf, 'Units', 'normalized', 'Position', [.1 .1 .8 .8]);
hold on;
lwLines=3;
lwHeavy=5;
fSize= 16;
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

allCalibfiles=dir('*calib*');
allCalibPicNums= cellfun(@(x) getPicNum(x), {allCalibfiles.name}');
% fprintf('Using file : %s as calib files\n', allCalibfiles(end).name);
oldCalibNum= allCalibPicNums(1);
x_tc=load(allCalibfiles(allCalibPicNums(1)).name);
CalibData=x_tc.data.CalibData(:,1:2);

allTCfiles=dir('*tc*');
allUnitfiles=dir('Unit*');

if length(allUnitfiles)>length(allTCfiles)
    cd(CodesDir);
    error('There are %d TC files, but %d Unit files. Delete the unit files that are extra.', length(allTCfiles), length(allUnitfiles));
elseif length(allUnitfiles)<length(allTCfiles)
    cd(CodesDir);
    error('There are %d TC files, but %d Unit files. Delete extra TC or move it to a different folder', length(allTCfiles), length(allUnitfiles));
else
    BF_kHz=zeros(length(allTCfiles),5); % track | unit | BF from attenuation | BF from SPL | percentage difference
    for file_var=1:length(allTCfiles)
        
        curPicNum= getPicNum(allTCfiles(file_var).name);
        curCalibNum= find(curPicNum>allCalibPicNums, 1, 'last');
        if curCalibNum~=oldCalibNum
            oldCalibNum= curCalibNum;
            x_tc=load(allCalibfiles(curCalibNum).name);
            CalibData=x_tc.data.CalibData(:,1:2);
        end
        
        
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
        WhatTCData=3;
        [~, minInd]= min(TCdata(:,WhatTCData));
        BF_kHz(file_var,4)= TCdata(minInd, 1);
        [bf_freq, bf_thresh]= estimate_TC_props(TCdata(:,3), TCdata(:,1));
        
        %% Plot
        xtickVals= [.2 .5 1 2 5 10];
        figure(hanTC);
        clf;
        hold on;
        plot(TCdata(:,1),TCdata(:,3), '*-', 'LINEWIDTH',lwLines, 'markersize', MarkerSize);
        linHan(1)= plot(BF_kHz(file_var,4),TCdata(minInd,WhatTCData),'vg' ,'markersize',MarkerSize, 'linew', lwHeavy);
        set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xtickVals);
        linHan(2)= plot(bf_freq, bf_thresh,'^r' ,'markersize',MarkerSize, 'linew', lwHeavy);
        
        xlim([min(.9*min(TCdata(:,1)), .2) max(11, 1.05*max(TCdata(:,1)))]);
        ylim([-20 120]);
        
        x=load(allUnitfiles(file_var).name);
        data=x.data;
        
        title(strrep(allTCfiles(file_var).name(1:end-4), '_', '|'));
        set(gcf,'visible','on');
        xlabel('Frequncy (kHz)');
        ylabel('Threshold (SPL)');
        set(gca, 'xscale', 'log');
        drawnow;
        grid on;
        
        if isfield(data, 'Thresh_dB') % means already been analyzed
            delete(linHan);
            linHan(1)= plot(data.BFmod,data.Thresh_dB, 'rs', 'LINEWIDTH',lwLines, 'markersize', MarkerSize);
            [~, frhi, frlo, Q10lev] = findQ10(TCdata(:, 1),TCdata(:, WhatTCData),data.BFmod);
            linHan(2)= plot( [frhi, frlo], [Q10lev Q10lev],'r', 'linew', lwLines);
            title(strcat(strrep(allTCfiles(file_var).name(1:end-4), '_', '|'), sprintf('|Q10=%.1f', data.Q10_mod)));
            
            if ~isfield(data, 'Q10_mod') % means already been analyzed
                % TC data is there, already done, compute Q10
                [data.Q10_mod, frhi, frlo, Q10lev] = findQ10(TCdata(:, 1),TCdata(:, WhatTCData),data.BFmod);
                plot( [frhi, frlo], [Q10lev Q10lev],'r', 'linew', lwLines);
                %  save(allUnitfiles(file_var).name,'data');
                % fprintf('Updated Q10 for %s\n', allUnitfiles(file_var).name);
                pause(.3);
            end
            
            resp_ThisUnit= questdlg('Already done, redo?', 'BF selection', 'no', 'yes', 'stop', 'no');
            if ~ismember([data.BFmod data.Thresh_dB], TCdata(:, [1 WhatTCData]), 'rows')
                resp_ThisUnit= 'doesnot matter, redo';
                goAhead= true;
            end
            
            if strcmp(resp_ThisUnit, 'no')
                goAhead= false;
            elseif strcmp(resp_ThisUnit, 'yes')
                goAhead= true;
            elseif strcmp(resp_ThisUnit, 'stop')
                cd(CodesDir);
                close(hanTC);
                return;
            end
        else % means has not been analyzed
            goAhead= true;
        end
        %%
        if goAhead
            zoom on;
            hanMSG=msgbox('first zoom in and then hit ok');
            uiwait(hanMSG);
            resp= questdlg('green=original | red=update, which one?', 'BF selection', 'original', 'update', 'manual', 'original');
            switch resp
                case 'original'
                    data.BFmod= BF_kHz(file_var,4);
                    data.Thresh_dB= TCdata(minInd,WhatTCData);
                    [data.Q10_mod, ~, ~, ~] = findQ10(TCdata(:, 1),TCdata(:, WhatTCData),data.BFmod);
                    %                 questdlg('ok', 'ok', 'ok', 'ok');
                    % save(allUnitfiles(file_var).name,'data');
                    %                     fprintf('Saving %s with old values, old BF= %.1f, thresh= %.1f \n', allUnitfiles(file_var).name, data.BFmod, data.Thresh_dB);
                case 'update'
                    data.BFmod=bf_freq;
                    data.Thresh_dB=bf_thresh;
                    [data.Q10_mod, ~, ~, ~] = findQ10(TCdata(:, 1),TCdata(:, WhatTCData),data.BFmod);
                    %                     save(allUnitfiles(file_var).name,'data');
                    %                     fprintf('Updated %s, new BF= %.1f, thresh= %.1f \n', allUnitfiles(file_var).name, data.BFmod, data.Thresh_dB);
                case 'manual'
                    checkFlag= true;
                    
                    while checkFlag
                        zoom on;
                        hanMSG=msgbox('first zoom in and then hit ok');
                        uiwait(hanMSG);
                        
                        clickPoint= ginput(1);
                        ind= dsearchn(TCdata(:, 1), clickPoint(1));
                        delete(linHan);
                        linHan(1)= plot(TCdata(ind,1),TCdata(ind,3), 'rs', 'LINEWIDTH',lwLines, 'markersize', MarkerSize);
                        
                        [Q10, frhi, frlo, Q10lev] = findQ10(TCdata(:, 1),TCdata(:, WhatTCData), TCdata(ind,1));
                        linHan(2)= plot( [frhi, frlo], [Q10lev Q10lev],'r', 'linew', lwLines);
                        title(strcat(strrep(allTCfiles(file_var).name(1:end-4), '_', '|'), sprintf('|Q10=%.1f', Q10)));
                        
                        resp2= questdlg('Accept?', 'Choose BF', 'yes' ,'no', 'yes');
                        switch resp2
                            case 'yes'
                                checkFlag= false;
                                data.BFmod=TCdata(ind,1);
                                data.Thresh_dB=TCdata(ind,3);
                                [data.Q10_mod, ~, ~, ~] = findQ10(TCdata(:, 1),TCdata(:, WhatTCData),data.BFmod);
                                save(allUnitfiles(file_var).name,'data');
                                fprintf('Updated %s, new BF= %.1f, thresh= %.1f \n', allUnitfiles(file_var).name, data.BFmod, data.Thresh_dB);
                            case 'no'
                                % keep going
                        end
                    end
            end
        end
    end
end

cd(CodesDir);
fprintf('All done for Q%d! \n', ChinNum);
close(hanTC);