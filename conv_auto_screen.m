clear;

for chinID= [start_to_end]
    convert_mfiles_to_matfiles(chinID);
    autorun_screenDataMAT(chinID);
end