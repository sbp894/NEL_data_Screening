function [Thresh_dBSPL_ret,BF_kHz_ret,Q10_ret, textHan, allTCdata] = plotTCs(PIClist,CALIBpic,PLOTyes)
% FILE: plotTCs
% Modified from : verifyBFQ10.m
% Usgae: [Thresh_dBSPL_ret,BF_kHz_ret,Q10_ret] =
% plotTCs(PIClist,CALIBpic,PLOTyes)
% Just a simple way to plot TCs from a given list of TC pics
%
% Modified on: 10May2007 M. Heinz for SAC_XAC Analysis
%
% Modified 11Feb2005 M. Heinz for NOHR Data
%
% Created 7/31/02: for choosing BF and verofying Q10
%
% 1) Picks BF & Threshold from actual data points
% 2) Generates a smoothed TC (without bias at BF) and saves as unit.tcdata(:,3)
% 3) Finds Q10 based on smoothed TC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('PIClist','var')
    error('atleast one input needed\n')
end

if ~exist('CALIBpic','var')
    calibFile=dir('*calib*');
    all_calib_picNums=cellfun(@(x) getPicNum(x), {calibFile.name});
    CALIBpic=all_calib_picNums(find(all_calib_picNums < min(PIClist), 1, 'last'));
    fprintf('Using %s as calib file now\n', getFileName(CALIBpic));
end

if ~exist('PLOTyes','var')
    PLOTyes=1;
end

%%% READ in Calib Data
xCAL=loadPic(CALIBpic);
CalibData = xCAL.CalibData(:,1:2);

numTCs=length(PIClist);
TrackUnit=getTrackUnit(getFileName(PIClist(1)));
TRACK=TrackUnit(1);
UNIT=TrackUnit(2);

TFiltWidthTC=5;

if PLOTyes
    %set(0,'DefaultTextInterpreter','none');
    set(0,'DefaultTextUnits','data')
    
    colors= get(gca, 'colororder');
    nColors=size(colors, 1);
    
    DataMarkerSize=12;
    DataMarkStyle='.';
    DataFitStyle='-';
    
    xmin=0.03; xmax=39; ymin=-21; ymax=110;
    normt=load('normema.mat');
    normt=normt.normt;
    legtext='';
end

allTCdata=repmat(struct('freqkHz', []), numTCs, 1);
Thresh_dBSPL_ret=nan(numTCs, 1);
BF_kHz_ret=nan(numTCs, 1);
Q10_ret=nan(numTCs, 1);

for ind=1:numTCs
    PICind=PIClist(ind);
    tempTCdata=loadPic(PICind);
    curTCdata=tempTCdata.TcData;
    curTCdata=curTCdata(curTCdata(:,1)~=0,:);  % Get rid of all 0 freqs
    curTCdata=curTCdata(curTCdata(:,2)~=tempTCdata.Stimuli.file_attlo,:);  % Get rid of all 'upper atten limit points'
    %% TCdata:
    %     col 1: freq;
    %     col 2: raw ATTENS;
    %     col 3: raw dB SPL;
    %     col 4: smoothed SPLS
    for i=1:size(curTCdata,1)
        curTCdata(i,3)=CalibInterp(curTCdata(i,1),CalibData)-curTCdata(i,2);
    end
    curTCdata(:,4)=trifilt(curTCdata(:,3)',TFiltWidthTC)';
    
    % Set unit BF/Threshold to picked BF/Threshold
    track_unit_vals= getTrackUnit(getFileName(PIClist));
    trackUnit_fName= sprintf('Unit_%d_%02d.mat', track_unit_vals);
    
    if exist(trackUnit_fName, 'file')
        unitData= load(trackUnit_fName);
        unitData= unitData.data;
        BF_kHz=unitData.BFmod;
        Thresh_dBSPL=unitData.Thresh_dB;
    else
        BF_kHz=tempTCdata.Thresh.BF;
        Thresh_dBSPL=curTCdata(curTCdata(:,1)==BF_kHz,3);
    end
    
    % % %% Generate smoothed TC, but avoiding upward bias at BF (tip)
    % % % Fits each side separately, and then sets equal to actual data point at BF
    % % % i.e., smoothes sides (e.g., 10 dB up) without biasing threshold at BF upward
    % % TCdata(1:loc,4)=trifilt(TCdata(1:loc,3)',TFiltWidthTC)';
    % % TCdata(loc:end,4)=trifilt(TCdata(loc:end,3)',TFiltWidthTC)';
    % % TCdata(loc,4)=TCdata(loc,3);
    
    % pass smoothed tcdata for q10 calculation (based on actual data point at BF, and smoothed TC otherwise
    % This avoids the bias in smoothing at the tip, i.e., raising threshold at BF
    [Q10,Q10fhi,Q10flo,Q10lev] = findQ10(curTCdata(:,1),curTCdata(:,3),BF_kHz);
    
    
    if PLOTyes
        colorVal= colors(mod(ind,nColors), :);
        %%%%% PLOT TUNING CURVE
        semilogx(curTCdata(:,1),curTCdata(:,3),DataMarkStyle,'MarkerSize',DataMarkerSize,'Color', colorVal);
        hold on
        semilogx(curTCdata(:,1),curTCdata(:,4),DataFitStyle,'Color', colorVal);
        semilogx(BF_kHz,Thresh_dBSPL,'x','Color', colorVal, 'MarkerSize',14);
        if ind == 1
            semilogx(normt(1,:),normt(2,:),'k')
            ylabel('dB SPL'); xlabel('Frequency (kHz)');
            axis([xmin xmax ymin ymax]);
            set(gca,'YTick',[0 20 40 60 80 100])
            set(gca,'XTick',[.1 1 10],'XTickLabel',[.1 1 10])
            title(sprintf('Unit: %d.%d; (Cal: P%d)',TRACK,UNIT,CALIBpic))
            if geomean(curTCdata(:,1)) < 1
                Xtext=.55;
            else
                Xtext=.05;
            end
        end
        
        semilogx([Q10flo Q10fhi],Q10lev*ones(1,2),'-','linewidth',2,'Color', colorVal);
        legtext{ind} = sprintf('P%d:  \nBF=%.3f kHz; \nThr=%.1f dB SPL; \nQ10=%.1f',PICind,BF_kHz,Thresh_dBSPL,Q10);
        
        textHan=text(Xtext,.8*max(curTCdata(:,3)),legtext{ind},'Units','norm','Color', colorVal);
    else
        textHan=nan;
    end
    
    
    Thresh_dBSPL_ret(ind) = Thresh_dBSPL;
    BF_kHz_ret(ind) = BF_kHz;
    Q10_ret(ind) = Q10;
    
    allTCdata(ind).freqkHz=curTCdata(:,1);
    allTCdata(ind).TCdata=curTCdata(:,3);
    allTCdata(ind).TCfit=curTCdata(:,4);
end
% hold off;
return;