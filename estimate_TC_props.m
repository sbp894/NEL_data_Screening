function estimate_TC_props(tc_data, freq)

[~, inds]= sort(freq);
freq= freq(inds);
tc_data= tc_data(inds);

tx.x=min(freq);
tx.y=140;

maxMisMatch= 25; % in dB
nearMismatchThresh=10;
MinPeakDistance= 10; % 10 points
MinPeakProminence= maxMisMatch/3;
MinPeakWidth= 3;
freqSeparationThresh=1.25;
slopeRatioThresh= 1.5;
threshNForSlopeFitting=5;


[~, locs]= min(tc_data);
[~, temp_locs]= findpeaks(-tc_data, 'MinPeakDistance', MinPeakDistance, 'MinPeakProminence', MinPeakProminence, 'MinPeakWidth', MinPeakWidth); % compute candidate bfs
locs= [locs; temp_locs];
%check low and high freq edges
if min(tc_data(1:MinPeakDistance))<min(tc_data(locs))
    [~, lower_loc]= min(tc_data(1:MinPeakDistance));
    locs= [lower_loc; locs];
end
locs= unique(locs);

% plotting props
lw2=1.5;
lw3=2;
lw4= 2.5;
lw5= 3;

mrkSize= 8;
mrkSize2= 10;
mrkSize3= 12;
mrkSize4= 14;

hold on;
plot(freq, tc_data, '-', 'linew', lw2, 'markersize', mrkSize);
plot(freq(locs), tc_data(locs), '*r', 'linew', lw4, 'markersize', mrkSize2);

locs(tc_data(locs)>min(tc_data(locs))+maxMisMatch)=[];

for candVar= 1:length(locs)-1
    if sum(tc_data(locs(candVar+1:end)) < tc_data(locs(candVar)))
        locs(candVar)= nan;
    end
end

locs(isnan(locs))=[];
plot(freq(locs), tc_data(locs), 'oc', 'linew', lw4, 'markersize', mrkSize3);
slopesVals= nan(length(locs),1);
nPointsForHFslope= nan(length(locs),1);
for candVar=1:length(locs)
    inds2use= locs(candVar):length(freq);
    
    
    [theta, yFit, numPointsSlope1]= tc_piecewise_lin_interp_mod_cost(freq(inds2use), tc_data(inds2use));
    
    slopesVals(candVar)= theta(3);
    nPointsForHFslope(candVar)= numPointsSlope1;
    
    plot(freq(inds2use), tc_data(inds2use), 'k--', 'linew', lw2);
    plot(freq(inds2use), yFit, 'linew', lw3);
end

% check if the highest slope, highest freq match
if numel(locs)>1
    if slopesVals(end)/max([0; slopesVals(1:end-1)])>slopeRatioThresh && freq(locs(end))/max(freq(locs(1:end-1)))>freqSeparationThresh ...
            && min(tc_data(locs(1:end-1)))-tc_data(locs(end))>-nearMismatchThresh && nPointsForHFslope(end)>threshNForSlopeFitting
        % means freqs are apart and the last candidate slope is bigger,
        % pick the last one
        plot(freq(locs(end)), tc_data(locs(end)), 'dg', 'linew', lw5, 'markersize', mrkSize4);
        text(freq(locs(end))+.2, 1, sprintf('CF=%.1f kHz', freq(locs(end))));
        text(min(freq), tc_data(locs(end))-1, sprintf('Thresh=%.1f dB', tc_data(locs(end))));
        text(tx.x, tx.y,'reason: clear', 'fontsize', 8);
    elseif freq(locs(end))/max(freq(locs(1:end-1)))>freqSeparationThresh && abs(tc_data(locs(end))-min(tc_data(locs(1:end-1))))<nearMismatchThresh ...
            && nPointsForHFslope(end)>threshNForSlopeFitting
        % means frequencies are decenyly apart, thresholds are similar, so
        % pick the second one
        plot(freq(locs(end)), tc_data(locs(end)), 'dg', 'linew', lw5, 'markersize', mrkSize4);
        text(freq(locs(end))+.2, 1, sprintf('CF=%.1f kHz', freq(locs(end))));
        text(min(freq), tc_data(locs(end))-1, sprintf('Thresh=%.1f dB', tc_data(locs(end))));
        text(tx.x, tx.y,'reason: simThresh and apartFreq', 'fontsize', 8);
    elseif slopesVals(end)/max([0; slopesVals(1:end-1)])>slopeRatioThresh && freq(locs(end))/max(freq(locs(1:end-1)))>freqSeparationThresh ...
            && nPointsForHFslope(end)>threshNForSlopeFitting
        % means freqs are apart and the last candidate slope is bigger,
        % pick the last one
        plot(freq(locs(end)), tc_data(locs(end)), 'dg', 'linew', lw5, 'markersize', mrkSize4);
        text(freq(locs(end))+.2, 1, sprintf('CF=%.1f kHz', freq(locs(end))));
        text(min(freq), tc_data(locs(end))-1, sprintf('Thresh=%.1f dB', tc_data(locs(end))));
        text(tx.x, tx.y,'reason: betterSlope (not noisy), apartFreq', 'fontsize', 8);
    else
        txHan= text(tx.x, tx.y, 'I am confused right now.');
    end
elseif numel(locs)==1
    plot(freq(locs(end)), tc_data(locs(end)), 'dg', 'linew', lw5, 'markersize', mrkSize4);
    text(freq(locs(end))+.2, 1, sprintf('CF=%.1f kHz', freq(locs(end))));
    text(min(freq), tc_data(locs(end))-1, sprintf('Thresh=%.1f dB', tc_data(locs(end))));
    text(tx.x, tx.y,'reason: clear', 'fontsize', 8);
end
