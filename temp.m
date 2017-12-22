close all
nHist=150;
xx(1)=subplot(311);h=histogram(x212, nHist); title(['Q212|| mean=' num2str(nanmean(x212))]);
xx(2)=subplot(312);histogram(x87, h.BinEdges); title(['x87|| mean=' num2str(nanmean(x87))]);
xx(3)=subplot(313);histogram(x210, h.BinEdges); title(['Q210|| mean=' num2str(nanmean(x210))]);
figure
axsp(1)=subplot(221);
histogram(x210, h.BinEdges)
title(['Q210|| mean=' num2str(nanmean(x210))]);
axsp(2)=subplot(222);
histogram(x87, h.BinEdges)
title(['x87|| mean=' num2str(nanmean(x87))]);
axsp(3)=subplot(223);
histogram(x9998, h.BinEdges)
title(['x9998|| mean=' num2str(nanmean(x9998))]);
axsp(4)=subplot(224);
histogram(x9999, h.BinEdges)
title(['x9999|| mean=' num2str(nanmean(x9999))]);
linkaxes(axsp, 'xy')