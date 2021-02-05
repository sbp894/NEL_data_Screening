% Need to add a continue button
% also, of you are continuing, plot the updated BF/Thresh

function update_bf_per_chin(ChinNum)
%%

%%
hanTC=101;
figure(hanTC);
clf;
set (gcf, 'Units', 'normalized', 'Position', [.1 .1 .8 .7]);

hold on;
TFiltWidthTC=5;
lwData= 1.5;
lwIndicators=2;
lwLines=3;
fSize= 16;
fSize_est= 12;
MarkerSize= 5;
MarkerSize2= 12;
forceRedo= 1;

%%
CodesDir='/media/parida/DATAPART1/Matlab/Screening/';
addpath(CodesDir);
MATDataDir='/media/parida/DATAPART1/Matlab/ExpData/MatData/';
TCRootDir= '/media/parida/DATAPART1/Matlab/GeneralOutput/TCoutput/';

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

TCoutputDir= [TCRootDir checkDIR.name filesep];
if ~isfolder(TCoutputDir)
    mkdir(TCoutputDir);
end

cd(DataDir);
ind_filesep= max(strfind(DataDir, filesep));
chinDirStr= DataDir(ind_filesep+1:end);

allCalibfiles=dir('p*calib*raw*');
if isempty(allCalibfiles)
    allCalibfiles=dir('p*calib*');
end


allCalibPicNums= cellfun(@(x) getPicNum(x), {allCalibfiles.name}');
% fprintf('Using file : %s as calib files\n', allCalibfiles(end).name);
oldCalibNum= allCalibPicNums(1);
x_calib=load(allCalibfiles(allCalibPicNums(1)).name);
CalibData= x_calib.data.CalibData(:,1:2);

allTCfiles=dir('*tc*');
allUnitfiles=dir('Unit*');

if length(allUnitfiles)>length(allTCfiles)
    cd(CodesDir);
    error('There are %d TC files, but %d Unit files. Delete the unit files that are extra.', length(allTCfiles), length(allUnitfiles));
elseif length(allUnitfiles)<length(allTCfiles)
    cd(CodesDir);
    error('There are %d TC files, but %d Unit files. Delete extra TC or move it to a different folder', length(allTCfiles), length(allUnitfiles));
else
    BF_kHz=zeros(length(allTCfiles),5); % track | unit | BF from attenuation | BF from SPL (raw) | BF from SPL (smooth)
    thresh_org_upd_man= zeros(length(allTCfiles),3); % [org | upd | man]
    Q10_org_upd_man= zeros(length(allTCfiles),3); % [org | upd | man]
    
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
        
        rawTCdata_point= 3;
        calib_corr_TCData_point= 4;
        [thresh_org_upd_man(file_var,1), minInd]= min(TCdata(:,calib_corr_TCData_point));
        BF_kHz(file_var,4)= TCdata(minInd,1);
        
        [BF_kHz(file_var,5), thresh_org_upd_man(file_var,2)]= estimate_TC_props(TCdata(:,calib_corr_TCData_point), TCdata(:,1));
        
        %% Plot
        xtickVals= [.2 .5 1 2 5 10];
        figure(hanTC);
        clf;
        set(gca, 'Position', [.06 .1 .9 .85]);
        hold on;
        plot(TCdata(:,1),TCdata(:,3), 'o', 'LINEWIDTH', lwData, 'markersize', MarkerSize, 'Color', .3*[1, 1, 1]);
        plot(TCdata(:,1),TCdata(:,4), '-', 'LINEWIDTH', lwLines, 'markersize', MarkerSize, 'color', 'k');
        
        linHan(1)= plot(BF_kHz(file_var,3), TCdata(dsearchn(TCdata(:,1), BF_kHz(file_var,3)), rawTCdata_point),'bd' ,'markersize',MarkerSize2, 'linew', lwIndicators);
        
        linHan(2)= plot(BF_kHz(file_var,4), thresh_org_upd_man(file_var,1),'x', 'color', get_color('g') ,'markersize',MarkerSize2, 'linew', lwIndicators);
        [Q10_org_upd_man(file_var,1), frhi_org, frlo_org, Q10lev_org] = findQ10(TCdata(:, 1), TCdata(:, calib_corr_TCData_point), BF_kHz(file_var,4));
        linHan(3)= plot( [frhi_org, frlo_org], [Q10lev_org Q10lev_org], '-.', 'color', get_color('g'), 'linew', lwData);
        linHan(4)= text(frlo_org, Q10lev_org+5, sprintf('Q_1_0 (org)=%.1f', Q10_org_upd_man(file_var,1)), 'Color', get_color('g'), 'FontSize', fSize_est);
        
        
        linHan(5)= plot(BF_kHz(file_var,5), thresh_org_upd_man(file_var,2),'+r' ,'markersize',MarkerSize2, 'linew', lwIndicators);
        [Q10_org_upd_man(file_var,2), frhi_upd, frlo_upd, Q10lev_upd] = findQ10(TCdata(:, 1), TCdata(:, calib_corr_TCData_point), BF_kHz(file_var,5));
        linHan(6)= plot( [frhi_upd, frlo_upd], [Q10lev_upd Q10lev_upd],'r--', 'linew', lwData);
        linHan(7)= text(frhi_upd, Q10lev_upd-5, sprintf('Q_1_0 (upd)=%.1f', Q10_org_upd_man(file_var,2)), 'Color', 'r', 'FontSize', fSize_est);
        
        set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xtickVals);
        xlim([min(.9*min(TCdata(:,1)), .2) max(11, 1.05*max(TCdata(:,1)))]);
        ylim([-20 120]);
        
        TCfigName2Save= strrep(allUnitfiles(file_var).name, '.mat', '');
        x=load(allUnitfiles(file_var).name);
        data=x.data;
        
        title([chinDirStr '  |  ' allTCfiles(file_var).name(1:end-4)],'Interpreter','none');
        set(gcf,'visible','on');
        xlabel('Frequncy (kHz)');
        ylabel('Threshold (dB SPL)');
        set(gca, 'xscale', 'log');
        drawnow;
%         grid on;
        
        if isfield(data, 'Thresh_dB_mod') && (~forceRedo) % means already been analyzed
            delete(linHan);
            linHan(1)= plot(data.BFmod,data.Thresh_dB_mod, 'r+', 'LINEWIDTH',lwLines, 'markersize', MarkerSize);
            [~, frhi, frlo, Q10lev] = findQ10(TCdata(:, 1),TCdata(:, calib_corr_TCData_point),data.BFmod);
            linHan(2)= plot( [frhi, frlo], [Q10lev Q10lev],'r', 'linew', lwLines);
            %             title(strcat(strrep(allTCfiles(file_var).name(1:end-4), '_', '|'), sprintf('|Q10=%.1f', data.Q10_mod)));
            
            if ~isfield(data, 'Q10_mod') % means already been analyzed
                % TC data is there, already done, compute Q10
                [data.Q10_mod, frhi, frlo, Q10lev] = findQ10(TCdata(:, 1),TCdata(:, calib_corr_TCData_point),data.BFmod);
                plot( [frhi, frlo], [Q10lev Q10lev],'r', 'linew', lwLines);
                %  save(allUnitfiles(file_var).name,'data');
                % fprintf('Updated Q10 for %s\n', allUnitfiles(file_var).name);
                pause(.3);
            end
            
            %             resp_ThisUnit= questdlg('Already done, redo?', 'BF selection', 'no', 'yes', 'stop', 'no');
            resp_ThisUnit= 'yes';
            if ~ismember([data.BFmod data.Thresh_dB_mod], TCdata(:, [1 calib_corr_TCData_point]), 'rows')
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
                    data.Thresh_dB_mod= thresh_org_upd_man(file_var,1);
                    %                     [data.Q10_mod, ~, ~, ~] = findQ10(TCdata(:, 1),TCdata(:, calib_corr_TCData_point),data.BFmod);
                    data.Q10_mod= Q10_org_upd_man(file_var,1);
                    temp_data.frhi= frhi_org;
                    temp_data.frlo= frlo_org;
                    temp_data.Q10lev= Q10lev_org;
                    %                 questdlg('ok', 'ok', 'ok', 'ok');
%                     save(allUnitfiles(file_var).name,'data');
%                     fprintf('Saving %s with old values, old BF= %.1f, thresh= %.1f \n', allUnitfiles(file_var).name, data.BFmod, data.Thresh_dB_mod);
%                     axis([.15 max([10; TCdata(:, 1)]) -20 120]);
%                     saveas(gcf, [TCoutputDir TCfigName2Save], 'png');
                case 'update'
                    data.BFmod=BF_kHz(file_var,5);
                    data.Thresh_dB_mod= thresh_org_upd_man(file_var, 2);
                    %                     [data.Q10_mod, ~, ~, ~] = findQ10(TCdata(:, 1),TCdata(:, calib_corr_TCData_point),data.BFmod);
                    data.Q10_mod= Q10_org_upd_man(file_var,2);
                    temp_data.frhi= frhi_upd;
                    temp_data.frlo= frlo_upd;
                    temp_data.Q10lev= Q10lev_upd;
%                     save(allUnitfiles(file_var).name,'data');
%                     fprintf('Updated %s, new BF= %.1f, thresh= %.1f \n', allUnitfiles(file_var).name, data.BFmod, data.Thresh_dB_mod);
%                     axis([.15 max([10; TCdata(:, 1)]) -20 120]);
%                     saveas(gcf, [TCoutputDir TCfigName2Save], 'png');
                case 'manual'
                    checkFlag= true;
                    
                    while checkFlag
                        zoom on;
                        hanMSG=msgbox('first zoom in and then hit ok');
                        uiwait(hanMSG);
                        
                        clickPoint= ginput(1);
                        ind= dsearchn(TCdata(:, 1), clickPoint(1));
                        thresh_org_upd_man(file_var, 3)= TCdata(ind,calib_corr_TCData_point);
                        delete(linHan);
                        linHan(1)= plot(TCdata(ind,1),thresh_org_upd_man(file_var, 3), 'rs', 'LINEWIDTH',lwLines, 'markersize', MarkerSize);
                        
                        [Q10_org_upd_man(file_var,3), frhi_man, frlo_man, Q10lev_man] = findQ10(TCdata(:, 1),TCdata(:, calib_corr_TCData_point), TCdata(ind,1));
                        linHan(2)= plot( [frhi_man, frlo_man], [Q10lev_man Q10lev_man],'r', 'linew', lwLines);
                        linHan(3)= text(frhi_man, Q10lev_man+10, sprintf('Q_1_0 (man)=%.1f', Q10_org_upd_man(file_var,3)), 'Color', 'c', 'FontSize', fSize_est);
                        
                        %                         title(strcat(strrep(allTCfiles(file_var).name(1:end-4), '_', '|'), sprintf('|Q10=%.1f', Q10)));
                        
                        resp2= questdlg('Accept?', 'Choose BF', 'yes' ,'no', 'yes');
                        switch resp2
                            case 'yes'
                                checkFlag= false;
                                data.BFmod= TCdata(ind,1);
                                data.Thresh_dB_mod= thresh_org_upd_man(file_var, 3);
                                %                                 [data.Q10_mod, ~, ~, ~] = findQ10(TCdata(:, 1),TCdata(:, calib_corr_TCData_point),data.BFmod);
                                data.Q10_mod= Q10_org_upd_man(file_var,3);
                                temp_data.frhi= frhi_man;
                                temp_data.frlo= frlo_man;
                                temp_data.Q10lev= Q10lev_man;
                                %                                 save(allUnitfiles(file_var).name,'data');
%                                 fprintf('Updated %s, new BF= %.1f, thresh= %.1f \n', allUnitfiles(file_var).name, data.BFmod, data.Thresh_dB_mod);
%                                 axis([.15 max([10; TCdata(:, 1)]) -20 120]);
%                                 saveas(gcf, [TCoutputDir TCfigName2Save], 'png');
                            case 'no'
                                % keep going
                        end
                    end
            end
            
            save(allUnitfiles(file_var).name,'data');
            fprintf('Updated %s, new BF= %.1f, thresh= %.1f , Q_1_0 = %.1f \n', allUnitfiles(file_var).name, data.BFmod, data.Thresh_dB_mod, data.Q10_mod);
            axis([.15 max([10; TCdata(:, 1)]) -20 120]);
            delete(linHan);
            text(.2, -15, sprintf('CF = %.1f kHz | Thresh= %.1f', data.BFmod, data.Thresh_dB_mod), 'FontSize', fSize_est);
            plot(data.BFmod, data.Thresh_dB_mod,'rx' ,'markersize',MarkerSize2, 'linew', lwIndicators);
            plot( [temp_data.frhi, temp_data.frlo], [temp_data.Q10lev temp_data.Q10lev],'r-.', 'linew', lwData);
            text(temp_data.frhi, temp_data.Q10lev-5, sprintf('Q_1_0 = %.1f', data.Q10_mod), 'Color', 'r', 'FontSize', fSize_est);
            saveas(gcf, [TCoutputDir TCfigName2Save], 'png');

        end
    end
end

cd(CodesDir);
fprintf('All done for Q%d! \n', ChinNum);
close(hanTC);