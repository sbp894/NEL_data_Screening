function [Thresh_dBSPL_ret,BF_kHz_ret,Q10_ret] = getTCparams(PIClist,CALIBpic)
% FILE: plotTCs
% Modified from : verifyBFQ10.m
% Usgae: [Thresh_dBSPL_ret,BF_kHz_ret,Q10_ret] =
% plotTCs(PIClist,CALIBpic,PLOTyes)
% Just a simple way to plot TCs from a given list of TC pics
%
% Modified 29Oct2016 S. Parida 
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



%%% READ in Calib Data
xCAL=loadPic(CALIBpic);
CalibData = xCAL.CalibData(:,1:2);

numTCs=length(PIClist);
TFiltWidthTC=5;


x=cell(numTCs,1);
TCdata=cell(numTCs,1);
BF_kHz=cell(numTCs,1);
Thresh_dBSPL=cell(numTCs,1);
Q10=cell(numTCs,1);
Q10fhi=cell(numTCs,1);
Q10flo=cell(numTCs,1);
Q10lev=cell(numTCs,1);
Thresh_dBSPL_ret=nan(numTCs,1);
BF_kHz_ret=nan(numTCs,1);
Q10_ret=nan(numTCs,1);

for ind=1:numTCs
    PICind=PIClist(ind);
    x{ind}=loadPic(PICind);
    TCdata{ind}=x{ind}.TcData;
    TCdata{ind}=TCdata{ind}(TCdata{ind}(:,1)~=0,:);  % Get rid of all 0 freqs
    TCdata{ind}=TCdata{ind}(TCdata{ind}(:,2)~=x{ind}.Stimuli.file_attlo,:);  % Get rid of all 'upper atten limit points'
    %% TCdata:
    %     col 1: freq;
    %     col 2: raw ATTENS;
    %     col 3: raw dB SPL;
    %     col 4: smoothed SPLS
    for i=1:size(TCdata{ind},1)
        TCdata{ind}(i,3)=CalibInterp(TCdata{ind}(i,1),CalibData)-TCdata{ind}(i,2);
    end
    TCdata{ind}(:,4)=trifilt(TCdata{ind}(:,3)',TFiltWidthTC)';
    
    % Set unit BF/Threshold to picked BF/Threshold
%     BF_kHz{ind}=x{ind}.Thresh.BF;
    BF_kHz{ind}=TCdata{ind}(TCdata{ind}(:,4)==min(TCdata{ind}(:,4)),1);
%     Thresh_dBSPL{ind}=TCdata{ind}(TCdata{ind}(:,1)==BF_kHz{ind},3);
    
    % % %% Generate smoothed TC, but avoiding upward bias at BF (tip)
    % % % Fits each side separately, and then sets equal to actual data point at BF
    % % % i.e., smoothes sides (e.g., 10 dB up) without biasing threshold at BF upward
    % % TCdata(1:loc,4)=trifilt(TCdata(1:loc,3)',TFiltWidthTC)';
    % % TCdata(loc:end,4)=trifilt(TCdata(loc:end,3)',TFiltWidthTC)';
    % % TCdata(loc,4)=TCdata(loc,3);
    
    % pass smoothed tcdata for q10 calculation (based on actual data point at BF, and smoothed TC otherwise
    % This avoids the bias in smoothing at the tip, i.e., raising threshold at BF
%     [Q10{ind},Q10fhi{ind},Q10flo{ind},Q10lev{ind}] = findQ10(TCdata{ind}(:,1),TCdata{ind}(:,4),BF_kHz{ind});
        
%     Thresh_dBSPL_ret(ind) = Thresh_dBSPL{ind};
%     BF_kHz_ret(ind) = BF_kHz{ind};
%     Q10_ret(ind) = Q10{ind};
    
end
hold off


return;
