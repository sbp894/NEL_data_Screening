function autorun_screenDataMAT(chinID)


screenDataMAT(chinID);

stop_flag=0;

while ~stop_flag
   stop_flag=auto_screenDataMAT('NextPic_PBcallback');
end