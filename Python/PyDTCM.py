# Dynamic Threshold Cloud-Masking Algorithm
# Proposed by Alan V. Vittorio and Willian J. Emery
# At "An Automated, Dynamic Threshold Cloud-Masking Alogrithm for Daytime
# AVHRR Images Over Land"
# 
# To better understand and use the script, it is strongly recommended to read 
# Dr. Vittorio and Dr. Emery`s paper before using the script.
#
# Scripted by Haoliang Yu, June 2013
# Email: njkon@foxmail.com

import numpy

# Excuting the module as script
# for unit test and quick use 
if __name__ == "__main__":
    print('Module of dynamic threshold cloud-masking algorithm, please use the \
           dtcm() for cloud detection.')

imagetype=('REF', 'INF')

def dtcm(imagedata, sinterval, binterval, imagetype):    
    '''
        To mask cloud pixels on remote sensing image using DTCM algorithm
        
        Parameter:
            array        - The array of pixel values
            sinterval    - The small smooth interval
            binterval    - The large smooth interval
            imagetype    - The image type most be reflection image - 'REF' or \
                           thermal infrared image - 'INF'
                           
        Return：
            mask         - The cloud mask, a binary array with 1 presenting 
                           cloudy pixel and 0 presenting clear sky pixel
    '''
    
    def gethistogram(array):
        '''
            To Create the histogram of input image.
    
            Parameter:
                array - The two dimension data array of image
                
            Return:
                hist  - An array with two dimensions. The first dimension stores 
                        the frequency of each pixel value. The second dimension is 
                        a continuous sequence of pixel values. 
        '''
        (max,min)=(array.max(),array.min())
        hist=numpy.array([[0 for x in range(min, max + 1)], range(min, max + 1)])
        for pix in numpy.nditer(array):
                hist[0][pix - min] += 1
        return hist
    
    
    def smooth(hist,interval):
        '''
            Smooth the Histogram with specific interval
    
            Parameters:
                hist     - The histgram of the image
                interval - The specific interval
                
            Return:
                hist     - Reclassified histogram
                
            Note:
            1. If the interval is larger than the pixel range, return the input 
               histogram without any modification.
            2. The intervals count from the minmum pixel value. For those whose 
               values cannot make up a whole interval(usually occur at the larger
               side of the range), the data will be discarded.
            3. In the reclassified histogram, the interval value will be the 
               average of the two border values.
        '''
        (max,min)=(hist[1][len(hist[1]) - 1],hist[1][0])
        classCount=numpy.floor((max - min + 1) / interval).astype(numpy.int)
        
        if classCount < 1:
            return hist
            
        if classCount * interval < max:
            hist=numpy.resize(hist, (2, classCount * interval))
        
        newHist=hist[0].reshape(interval,classCount).sum(axis=0)
        newHist.resize(2,classCount)
        newHist[1]=numpy.array(range(min, min + classCount * interval, interval)) + \
                   numpy.floor(interval/2)
        return newHist
    
    def findregionalfirstpeak(hist, rangeStart, rangeEnd, searchFrom):
        '''
            Locate the column index of the first peak at the histogram region with 
            specific order.
            
            Parameter:
                hist         - The histogram to be processed
                searchFrom   - The position where the search starts, it can be 
                               either 'start' or 'end'
                rangeStart   - The start position of searching
                rangeEnd     - The end position of searching
                
            Return:
                value        - The column index of the peak
        '''
        if rangeStart < 0:
            raise IndexError('The start position ' + str(rangeStart) + \
                             ' is invalid.')
    
        if rangeEnd > len(hist[0]):
            raise IndexError('The end position ' + str(rangeEnd) + ' is invalid.')
            
        if rangeStart > rangeEnd:
            raise IndexError('The search range is invalid.')
            
        if rangeStart == rangeEnd:
            return rangeStart
        
        if searchFrom == 'start':
            for index in range(rangeStart + 1, rangeEnd - 1):
                if (hist[0][index] > hist[0][index + 1]) & \
                   (hist[0][index - 1] < hist[0][index]):
                    return index
        elif searchFrom == 'end':
            for index in range(rangeEnd - 1,rangeStart + 1,-1):
                if (hist[0][index] < hist[0][index + 1]) & \
                   (hist[0][index] > hist[0][index - 1]):
                    return index
        else:
            raise ValueError('The search order is invalid, please use either \
                             \'start\' or `end` to indicate the start position.')
                        
        return -1
    
    def findfirstpeak(hist, searchFrom):
        '''
            Locate the column index of the first peak at the whole histogram with 
            specific order.
            
            Parameter:
                hist         - The histogram to be processed
                searchFrom   - The position where the search starts, it can be 
                               either 'start' or 'end'
                               
            Return:
                value        - The column index of the peak 
        '''
        return findregionalfirstpeak(hist, 0, len(hist[0]), searchFrom)
    
    def findpeaknearby(hist, value, searchRange = 4):
        '''
            Locate the column of maximun peak near the specific value.
            
            Parameter:
                hist         - The histogram to be search
                value        - The value that is near the peak
                searchRange  - The range of searching area(column index), the
                               default value is 4
                
            Return:
                index        - The column index of the maximum peak
        '''
        (row, col)=hist.shape
        result=[index for index in range(col - 1) \
                if hist[1][index] <= value < hist[1][index + 1]]
                    
        if(len(result) > 0):
            index=result[0]
        else:
            return col - 1
            
        searchRange=searchRange / 2       
            
        start=index - searchRange
        if start < 0:
            start=0
    
        end=index + searchRange
        if end >= col:
            end=col        
        
        region=hist[0][start:end]
        return region.tolist().index(region.max())
    
    def findthresholdpeak(hist, searchFrom, pos):
        '''
            To locate the column index of threshold value
            
            ParameterL
                hist         - The histogram to be search
                pos          - The position where the searching starts or ends
                searchFrom   - Indicate the order of searching using either \
                               \'start\' or \'end\'.
        '''
        if searchFrom == 'start':
            return findregionalfirstpeak(hist, pos, len(hist[0]) - 1, searchFrom)
        elif searchFrom == 'end':
            return findregionalfirstpeak(hist, 0, pos, searchFrom)
        else:
            raise ValueError('The search order is invalid, please use either \
                             \'start\' or `end` to indicate the start position.')
    
    def derivatehist(hist):
        '''
            To derivate the histogram curve
            
            Parameter:
                hist         - The histogram to be processed
        '''
        interval=hist[1][1]-hist[1][0]
        hist[0][1:]=[(hist[0][i + 1] - hist[0][i]) / interval \
                     for i in range(len(hist[0]) - 1)]
        hist[0][0]=0
        return hist
        
    def dichotomy(image, mean):
        '''
           To separate the image pixel values using dichotomy recursively
           
           Parameter:
               image         - Image array
               mean          - Mean of pixel values
        '''
        print('a')
        sBlock=[]
        lBlock=[]
        for pix in numpy.nditer(image):
            if pix > mean:
                lBlock.append(pix)
            else:
                sBlock.append(pix)
    
        sBlock=numpy.array(sBlock)
        lBlock=numpy.array(lBlock)
        tMean=(numpy.mean(sBlock) + numpy.mean(lBlock)) / 2
        if numpy.abs(tMean-mean) / mean < 0.1:
            return tMean
        else:
            return dichotomy(image, tMean)    
            
    if imagetype == 'REF':
        searchFrom='start'
    elif imagetype == 'INF':
        searchFrom='end'
    else:
        raise Exception('imagetype invalid. It should be either \'REF\' or \'INF\'.')
        
    if sinterval >= binterval:
        raise Exception('The binterval must be larger than the sinterval.')
        
    hist=gethistogram(imagedata)
    reHist=smooth(hist, binterval)
    peakCol=findfirstpeak(hist, searchFrom)
    peakValue=hist[1][peakCol]
    reHist=smooth(reHist, sinterval)
    peakCol=findpeaknearby(reHist, peakValue)
    
    # Because the secondary derivation is also applied for locating the slope
    # change point of the original histogram curve. I think it is not necessary
    # really and I directly search the change point with the first-time
    # derivation result.
    deHist=derivatehist(reHist)
    (row,col)=deHist.shape
    
    if (searchFrom == 'start') & (peakCol + 2 <= col):
        thresholdCol=findthresholdpeak(deHist, searchFrom, peakCol + 2)
        threshold=reHist[1][thresholdCol]
    elif (searchFrom == 'end') & (peakCol - 2 >= 1):
        thresholdCol=findthresholdpeak(deHist, searchFrom, peakCol - 2)
        threshold=reHist[1][thresholdCol]
    else:
        threshold=dichotomy(imagedata, numpy.mean(imagedata))
        
    if searchFrom == 'start':
        mask = imagedata >= threshold
    else:
        mask = imagedata <= threshold
        
    return mask.astype(numpy.int)

