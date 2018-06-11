function change_metadata(PicNum, TrueTrackNum, TrueUnitNum, CALIBpic)

%% Change file name
fNameString= 'p%04d_u%01d_%02d_%s';

oldfName=getFileName(PicNum);
OldTrackUnitNum=getTrackUnit(oldfName);
newfName=sprintf(fNameString ,PicNum,TrueTrackNum,TrueUnitNum,oldfName(12:end));
movefile(oldfName,newfName);

%% Change Unit_x_xx data (new is blank and old is overwritten)
newTCPicNum=getPicNum(filename);
[Thresh_dBSPL_ret,BF_kHz_ret,Q10_ret] = getTCparams(newTCPicNum,CALIBpic);
new_tc_fName=sprintf(fNameString, PicNum, TrueTrackNum, TrueUnitNum, 'tc');
