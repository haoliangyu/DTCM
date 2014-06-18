% This function is used to derivate the histogram.

function [ deHist ] = DerivateHist(histogram)
    deHist=histogram;
    deHist(1,1)=0;
    deHist(1,2:end)=diff(histogram(1,:))/(histogram(2,2)-histogram(2,1));
end

