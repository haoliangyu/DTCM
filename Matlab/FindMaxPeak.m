% Actually, the name of this function is misleading. This function is used
% to locate the zero point of a input second deviation histogram.

function [ peakCol ] = FindMaxPeak( hist, searchMode, pos )
    peakCol=pos;

    switch searchMode
        case 'first'
            endCol=length(hist);
            for i=pos+1:endCol
                if(hist(1,i)==0||sign(hist(1,i-1))~=sign(hist(1,i)))
                    break;
                end
                if(abs(hist(1,i))>abs(hist(1,peakCol)))
                    peakCol=i;
                end
            end
        case 'last'
            for i=pos-1:-1:1
                if(hist(1,i)==0||sign(hist(1,i+1))~=sign(hist(1,i)))
                    break;
                end
                if(abs(hist(1,i))>abs(hist(1,peakCol)))
                    peakCol=i;
                end
            end
        otherwise
            peakCol=-1;
    end
end

