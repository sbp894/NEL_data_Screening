% Need to add a continue button
% also, of you are continuing, plot the updated BF/Thresh

function update_tc_per_unit(FIG)

if ~strcmp(FIG.DataDir, [pwd filesep])
   error('Wut!! '); 
end

trackNum= FIG.TrackNum;
unitNum= FIG.UnitNum;
hanTC= FIG.handles.TC;
TCdata= FIG.TCdata;

axis(hanTC);
clickPoint= ginput(1);
ind= dsearchn(TCdata.all_freq_kHz, clickPoint(1));

% load unit data
trackUnit_fName= sprintf('Unit_%d_%02d.mat', trackNum, unitNum);
unitData= load(trackUnit_fName);
data= unitData.data;


data.BFmod=TCdata.all_freq_kHz(ind);
data.Thresh_dB=TCdata.all_thresh_dB(ind);
[data.Q10_mod, ~, ~, ~] = findQ10(TCdata.all_freq_kHz, TCdata.all_thresh_dB, data.BFmod);

save(trackUnit_fName,'data');
fprintf('Updated %s, new BF= %.1f, thresh= %.1f \n', trackUnit_fName, data.BFmod, data.Thresh_dB);
