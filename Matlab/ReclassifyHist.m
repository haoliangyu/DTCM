% This function is used to reclassify histogram with the specific interval.

function [ reHist] = ReclassifyHist( histogram,interval )
    % New bar count
    classCount=floor((max(histogram(2,:))-min(histogram(2,:)))/interval);
    reHist=zeros(2,classCount);
    reHist(1,:)=sum(reshape(histogram(1,1:interval*classCount),interval,...
        classCount));
    reHist(2,:)=histogram(2,1):interval:(classCount-1)*interval+histogram(2,1);
    
    % The DN of ecah bar is (upper limit + lower limit) / 2
    reHist(2,:)=reHist(2,:)+fix(interval/2);
end

