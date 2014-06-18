function [ peakCol ] = FindPeak( hist, searchMode )
    hist(1,:)=hist(1,:).*(hist(1,:)>mean(hist(1,:),2)/2);
    
    try
        switch searchMode
            case 'last'      
                peakCol=length(hist);
                start=peakCol-1;
                for i=start:-1:1
                    if(hist(1,i)<hist(1,peakCol))
                        break;
                    end
                    peakCol=i;
                end
            case 'first'
                peakCol=1;
                endCol=length(hist);
                for i=2:endCol
                    if(hist(1,i)<hist(1,peakCol))
                        break;
                    end
                    peakCol=i;
                end
            otherwise
                peakCol=-1;
        end
    catch
        peakCol=-1;
    end
end

