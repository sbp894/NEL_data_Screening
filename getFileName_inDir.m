function filename=getFileName_inDir(FIG)

filename= getFileName(FIG.PICnum, FIG.DataDir, FIG.verbose);
if isempty(filename)
    filename= getFileName(FIG.PICnum, FIG.NotUsedDIR, FIG.verbose);
end