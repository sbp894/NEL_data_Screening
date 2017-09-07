function picnums = ParseInputString2Num(picst)

% Takes the input number string (eg, '5-7,9') and turns it into an array
% of picture numbers, picnums=[5,6,7,9]


picst=regexprep(picst, ' ', ',');
commaInds=strfind(picst, ',,');

for commaVar=1:length(commaInds)
    ind1=commaInds(length(commaInds)-commaVar+1);
    picst(ind1+1)='';
end

c='0';
i=0;j=1;numpics=1;dashflag=0;
while i<length(picst)
   while c~='-' && c~=',' && i+j~=length(picst)+1
      b(j)=picst(i+j);
      c=b(j);
      j=j+1;
   end
   if c=='-' || c==','
      b=b(1:end-1);
   end
   if dashflag==1
      try
         upto=str2double(b);
      catch
         error('Can''t parse picture numbers.');
      end
      numdash=upto-picnums(numpics-1);
      for k=1:numdash
         picnums(k+numpics-1)=picnums(numpics-1)+k;
      end
      numpics=length(picnums);
   else  % if dashflag==1
      try
         picnums(numpics)=str2double(b);
      catch
         error('Can''t parse picture numbers!\n');
      end
   end
   clear b;
   i=i+j-1;
   j=1;
   if c=='-'
      dashflag=1;
   else
      dashflag=0;
   end
   c='0';
   numpics=numpics+1;
end  