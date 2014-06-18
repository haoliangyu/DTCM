% Classic DTCM algorithm, modification needed
% Configuration

% These are the source images. There are two because I originally had two
% band categories.
imageAPath='D:\文档\毕业设计\卫星图像\L1_20120708_0300 Clipped\L1 0300 B1 Clipped.tif';
imageBPath='D:\文档\毕业设计\卫星图像\L1_20120708_0300 Clipped\L1 0300 B2 Clipped.tif';

% Cloud mask used to calcuate the accuracy of processing.
CTMPath='D:\文档\毕业设计\卫星图像\L1_20120708_0300 Clipped\CLM Clipped.tif';

% Path at which the result is saved
savePath='D:\文档\毕业设计\DTCM 1.0\CloudMask_Classic\L1 0300 Clipped\';

% Read image bands
disp('Start reading imagess...');

% ****************** %
% The GetData() function is designed for my own dataset. For yours, please
% redesign it or just remove it.
data=GetData(imageAPath,imageBPath);
data=data{1};
% ****************** %

% Band count
availableDataCount=length(data);
[row,col]=size(data{1}); % Remeber to modify the data{1} if necessary
cloudMask=cell(availableDataCount,1);

% Process each band in the dataset
disp('Start processing images...');
tic;
for i=1:availableDataCount
    % To divide image into subregions. Here I vertically divide the image
    % into four part following th method of FY-3 A/B VIRR. Modify it for
    % your purpose.
    blocks=GetImageBlock(data{i});
    count=length(blocks);
    
    % Here is the bar intervals for the histograms. I have two interaval A,
    % B for two categories of bands and interval A should be larger than B.
    % Considering the difference of DNs distribution of different image, 
    % it should be modified too.
    [histIntervalA,histIntervalB]=GetHistInterval(i);
    
    % The maskBlocks should be created according to the separation mode of 
    % the image.
    maskBlocks=cell(1,count);
    
    % Process each image block
    for j=1:count        
        % generate the histogram
        hist=GetHistogram(blocks{j});
        % Reclassify or Resample, whatever, I would like to generate new
        % histogram with interval A.
        reHist=ReclassifyHist(hist,histIntervalA);
        
        % The visible band and the near infared band should be processed
        % separatedly.
        % The FindPeak() function returns the column number of the peak!
        if(i<8)        
            peakCol=FindPeak(reHist,'first');
        else
            peakCol=FindPeak(reHist,'last');
        end
        
        % Reclassify the original histogram with interal B
        reHist=ReclassifyHist(hist,histIntervalB);
        % The second paremeter is the peak value, not column. It also
        % returns a more accurate peak location. 
        peakCol=FindPeakNearby(reHist,reHist(2,peakCol),histIntervalA,...
                                                        histIntervalB);
         
        % derivate the histogram twice
        deHist=DerivateHist(reHist);
        deHist=DerivateHist(deHist);
        [row,col]=size(deHist);    
         
        % The name of FindMaxPeak() is a mistake, but I have remove this bug.
        % The actual function of FindMaxPeak is to find the zero point of
        % second derivated histogram after or before starting position,
        % given search mode 'first' or 'last'. The names are a bit 
        % misleading because they are the prototypes.
        if(i<8&&peakCol+2<=col)
            thresholdCol=FindMaxPeak(deHist,'first',peakCol+2);
            threshold=reHist(2,thresholdCol);
        elseif(i>=8&&peakCol-2>1)
            thresholdCol=FindMaxPeak(deHist,'last',peakCol-2);
            threshold=reHist(2,thresholdCol);
        else
            % If we fail to get a vaild peakCol, we would use dichotomy to
            % separate the image.
            threshold=DichotomySeparate(blocks{j});
        end

        % Cloud DNs are higher than the others at visible band, while the
        % others are higher than Cloud DNs. Just remember 1 means cloud and
        % 0 means the others.
        if(i<8)
            maskBlocks{1,j}=blocks{j}>threshold;
        else
            maskBlocks{1,j}=blocks{j}<=threshold;
        end
    end
    
    disp([num2str(i),'/',num2str(availableDataCount),' Complete!']);
    % Merge the four blocks into a entire mask
    cloudMask{i}=cell2mat(maskBlocks);
end
toc;

% Save the cloudMasks
disp('Save the masks...');
for i=1:availableDataCount
    imwrite(cloudMask{i},[savePath,'cloudMask ',num2str(i),'.tif']);
end

% Merge the results of different bands, I use a conservative method.
finalMask=GetCloudMask(cloudMask);
imwrite(finalMask,[savePath,'finalMask.tif']);

disp('All complete!')

% Two kind of accuracy is calculated: 1) cloud accuracy is the dividation
% of cloud pixels count of the processing result and the actual cloud mask
% product, 2) land accuracy is similar but for the land pixels.
ctmProduct=imread(CTMPath);
[cloudAccuracy,landAccuracy]=GetAccuracy(finalMask,ctmProduct);

disp(['cloudAccuracy:',num2str(cloudAccuracy)]);
disp(['landAccuracy:',num2str(landAccuracy)]);




