% Find peak at a subregion of a histogram. Four parameters is need: 1)
% hist, the new histogram with interval B, 2) peakValue of histogram with
% interval A (not the peak column), 3) interval A and 4) interval B. 

function [ peakCol ] = FindPeakNearby( hist, peakValue, intervalA,intervalB )
    colCount=length(hist);
   
%     [peakRow,peakCol]=size(hist(1,:)==max(hist(1,:),1));
%     rawPeak=peakCol;
%     for i=1:colCount
%         if(hist(2,i)>peakValue)
%             rawPeak=i;
%             break;
%         end
%     end

    rawPeak=1+ceil((peakValue-hist(2,1))/intervalB);

    intervalRatio=ceil(intervalB/intervalA);
    
    % The search range is peakCol +- 2
    startCol=rawPeak-intervalRatio*2;
    if(startCol<1)
        startCol=1;
    end
    
    endCol=rawPeak+intervalRatio*2;
    if(endCol>colCount)
        endCol=colCount;
    end
    
    region=hist(1,startCol:endCol);    
    [temp,peakCol]=find(region==max(region),1,'first');
    peakCol=peakCol(1)+startCol-1;
end

