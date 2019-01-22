function [fileName, dirName]=getFileName_inDir(FIG)

fileName= getFileName(FIG.PICnum, FIG.DataDir, FIG.verbose);
dirName= FIG.DataDir;
if isempty(fileName)
    fileName= getFileName(FIG.PICnum, FIG.NotUsedDIR, FIG.verbose);
    dirName= FIG.NotUsedDIR;
end