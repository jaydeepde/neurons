function R = trkSmoothAndCleanRun(R)


x = -3:1:3;
sigma = 1.0;
filt = exp(-x.*x/(2*sigma*sigma))/sqrt(2*pi*sigma*sigma);
%totalCableLengthFilt = imfilter(TotalCableLength, filt, 'same', 'replicate');

numTracks = length(R.trkSeq);
for t = 1:numTracks

    seq = R.trkSeq{t};
    
    if ~isempty(seq)
        
        
        %% smoothing of D
        sArea = imfilter( [R.D(seq).Area], filt, 'same', 'replicate');
        sMajorAxisLength = imfilter( [R.D(seq).MajorAxisLength], filt, 'same', 'replicate');
        sMinorAxisLength = imfilter( [R.D(seq).MinorAxisLength], filt, 'same', 'replicate');
        sEccentricity = imfilter( [R.D(seq).Eccentricity], filt, 'same', 'replicate');
        sPerimeter = imfilter( [R.D(seq).Perimeter], filt, 'same', 'replicate');
        sMeanGreenIntensity = imfilter( [R.D(seq).MeanGreenIntensity], filt, 'same', 'replicate');
        sMeanRedIntensity = imfilter( [R.D(seq).MeanRedIntensity], filt, 'same', 'replicate');
        
        R.D(seq(1)).deltaArea = R.D(seq(2)).deltaArea;
        sdeltaArea = imfilter( [R.D(seq).deltaArea], filt, 'same', 'replicate');
        R.D(seq(1)).deltaPerimeter = R.D(seq(2)).deltaPerimeter;
        sdeltaPerimeter = imfilter( [R.D(seq).deltaPerimeter], filt, 'same', 'replicate');
        R.D(seq(1)).deltaMeanGreenIntensity = R.D(seq(2)).deltaMeanGreenIntensity;
        sdeltaMeanGreenIntensity = imfilter( [R.D(seq).deltaMeanGreenIntensity], filt, 'same', 'replicate');
        R.D(seq(1)).deltaEccentricity = R.D(seq(2)).deltaEccentricity;
        sdeltaEccentricity = imfilter( [R.D(seq).deltaEccentricity], filt, 'same', 'replicate');
        sSpeed = imfilter( [R.D(seq).Speed], filt, 'same', 'replicate');
        sAcc = imfilter( [R.D(seq).Acc], filt, 'same', 'replicate');
         
        
        for i = 1:length(seq)
            d = seq(i);
            R.D(d).Area = sArea(i);  
            R.D(d).MajorAxisLength  = sMajorAxisLength(i);
            R.D(d).MinorAxisLength  = sMinorAxisLength(i);
            R.D(d).Eccentricity  = sEccentricity(i);
            R.D(d).Perimeter  = sPerimeter(i);
            R.D(d).MeanGreenIntensity  = sMeanGreenIntensity(i);
            R.D(d).MeanRedIntensity  = sMeanRedIntensity(i);
            R.D(d).deltaArea  = sdeltaArea(i);
            R.D(d).deltaPerimeter  = sdeltaPerimeter(i);
            R.D(d).deltaMeanGreenIntensity  = sdeltaMeanGreenIntensity(i);
            R.D(d).deltaEccentricity  = sdeltaEccentricity(i);
            R.D(d).Speed  = sSpeed(i);
            R.D(d).Acc  = sAcc(i);
        end
           
        
        
        %% smoothing of Soma
        sArea = imfilter( [R.D(seq).Area], filt, 'same', 'replicate');
        sMajorAxisLength = imfilter( [R.D(seq).MajorAxisLength], filt, 'same', 'replicate');
        sMinorAxisLength = imfilter( [R.D(seq).MinorAxisLength], filt, 'same', 'replicate');
        sEccentricity = imfilter( [R.D(seq).Eccentricity], filt, 'same', 'replicate');
        sPerimeter = imfilter( [R.D(seq).Perimeter], filt, 'same', 'replicate');
        sMeanGreenIntensity = imfilter( [R.D(seq).MeanGreenIntensity], filt, 'same', 'replicate');
       
        R.D(seq(1)).deltaArea = R.D(seq(2)).deltaArea;
        sdeltaArea = imfilter( [R.D(seq).deltaArea], filt, 'same', 'replicate');
        R.D(seq(1)).deltaPerimeter = R.D(seq(2)).deltaPerimeter;
        sdeltaPerimeter = imfilter( [R.D(seq).deltaPerimeter], filt, 'same', 'replicate');
        R.D(seq(1)).deltaMeanGreenIntensity = R.D(seq(2)).deltaMeanGreenIntensity;
        sdeltaMeanGreenIntensity = imfilter( [R.D(seq).deltaMeanGreenIntensity], filt, 'same', 'replicate');
        R.D(seq(1)).deltaEccentricity = R.D(seq(2)).deltaEccentricity;
        sdeltaEccentricity = imfilter( [R.D(seq).deltaEccentricity], filt, 'same', 'replicate');
        sSpeed = imfilter( [R.D(seq).Speed], filt, 'same', 'replicate');
        sAcc = imfilter( [R.D(seq).Acc], filt, 'same', 'replicate');
         
        
        for i = 1:length(seq)
            d = seq(i);
            R.D(d).Area = sArea(i);  
            R.D(d).MajorAxisLength  = sMajorAxisLength(i);
            R.D(d).MinorAxisLength  = sMinorAxisLength(i);
            R.D(d).Eccentricity  = sEccentricity(i);
            R.D(d).Perimeter  = sPerimeter(i);
            R.D(d).MeanGreenIntensity  = sMeanGreenIntensity(i);
            R.D(d).deltaArea  = sdeltaArea(i);
            R.D(d).deltaPerimeter  = sdeltaPerimeter(i);
            R.D(d).deltaMeanGreenIntensity  = sdeltaMeanGreenIntensity(i);
            R.D(d).deltaEccentricity  = sdeltaEccentricity(i);
            R.D(d).Speed  = sSpeed(i);
            R.D(d).Acc  = sAcc(i);
        end
        
    end
end
      

numTracks = length(R.trkNSeq);
for t = 1:numTracks

    seq = R.trkNSeq{t};
    
    if ~isempty(seq)
        %% smoothing of N
        sBranchCount = imfilter( [R.N(seq).BranchCount], filt, 'same', 'replicate');
        sDistToSomaExtreme = imfilter( [R.N(seq).DistToSomaExtreme], filt, 'same', 'replicate');
        sDistToSomaMean = imfilter( [R.N(seq).DistToSomaMean], filt, 'same', 'replicate');
        sDistToSomaMedian = imfilter( [R.N(seq).DistToSomaMedian], filt, 'same', 'replicate');
        sDistToSomaStandDev = imfilter( [R.N(seq).DistToSomaStandDev], filt, 'same', 'replicate');
        sEccentricity = imfilter( [R.N(seq).Eccentricity], filt, 'same', 'replicate');
        sFiloCount = imfilter( [R.N(seq).FiloCount], filt, 'same', 'replicate');
        sFiloCableLength = imfilter( [R.N(seq).FiloCableLength], filt, 'same', 'replicate');
        sFiloPercent = imfilter( [R.N(seq).FiloPercent], filt, 'same', 'replicate');
        sMajorAxisLength = imfilter( [R.N(seq).MajorAxisLength], filt, 'same', 'replicate');
        sMinorAxisLength = imfilter( [R.N(seq).MinorAxisLength], filt, 'same', 'replicate');
        sRadialDotProd = imfilter( [R.N(seq).RadialDotProd], filt, 'same', 'replicate');
        sTotalCableLength = imfilter( [R.N(seq).TotalCableLength], filt, 'same', 'replicate');
       
        sdeltaBranchCount = imfilter( [R.N(seq).deltaBranchCount], filt, 'same', 'replicate');
        sdeltaDistToSomaExtreme = imfilter( [R.N(seq).deltaDistToSomaExtreme], filt, 'same', 'replicate');
        sdeltaDistToSomaStandDev = imfilter( [R.N(seq).deltaDistToSomaStandDev], filt, 'same', 'replicate');
        sdeltaEccentricity = imfilter( [R.N(seq).deltaEccentricity], filt, 'same', 'replicate');
        sdeltaFiloCableLength = imfilter( [R.N(seq).deltaFiloCableLength], filt, 'same', 'replicate');
        sdeltaFiloCount = imfilter( [R.N(seq).deltaFiloCount], filt, 'same', 'replicate');
        sdeltaFiloPercent = imfilter( [R.N(seq).deltaFiloPercent], filt, 'same', 'replicate');
        sdeltaMajorAxisLength = imfilter( [R.N(seq).deltaMajorAxisLength], filt, 'same', 'replicate');
        sdeltaRadialDotProd = imfilter( [R.N(seq).deltaRadialDotProd], filt, 'same', 'replicate');
        sdeltaTotalCableLength = imfilter( [R.N(seq).deltaTotalCableLength], filt, 'same', 'replicate');
        
        for i = 1:length(seq)
            n = seq(i);
            R.N(n).BranchCount = sBranchCount(i);
            R.N(n).DistToSomaExtreme = sDistToSomaExtreme(i);
            R.N(n).DistToSomaMean = sDistToSomaMean(i);
            R.N(n).DistToSomaMedian = sDistToSomaMedian(i);
            R.N(n).DistToSomaStandDev = sDistToSomaStandDev(i);
            R.N(n).Eccentricity = sEccentricity(i);
            R.N(n).FiloCount = sFiloCount(i);
            R.N(n).FiloCableLength = sFiloCableLength(i);
            R.N(n).FiloPercent = sFiloPercent(i);
            R.N(n).MajorAxisLength = sMajorAxisLength(i);
            R.N(n).MinorAxisLength = sMinorAxisLength(i);
            R.N(n).RadialDotProd = sRadialDotProd(i);
            R.N(n).TotalCableLength = sTotalCableLength(i);
            
            R.N(n).deltaBranchCount = sdeltaBranchCount(i);
            R.N(n).deltaDistToSomaExtreme = sdeltaDistToSomaExtreme(i);
            R.N(n).deltaDistToSomaStandDev = sdeltaDistToSomaStandDev(i);
            R.N(n).deltaEccentricity = sdeltaEccentricity(i);
            R.N(n).deltaFiloCableLength = sdeltaFiloCableLength(i);
            R.N(n).deltaFiloCount = sdeltaFiloCount(i);
            R.N(n).deltaFiloPercent = sdeltaFiloPercent(i);
            R.N(n).deltaMajorAxisLength = sdeltaMajorAxisLength(i);
            R.N(n).deltaRadialDotProd = sdeltaRadialDotProd(i);
            R.N(n).deltaTotalCableLength = sdeltaTotalCableLength(i);
        end
        
    end    
end

numTracks = length(R.trkSeq);
for t = 1:numTracks
    seq = R.trkSeq{t};
    
    if ~isempty(seq)
        R.CellTimeInfo(t).TotalCableLengthTracked = imfilter(R.CellTimeInfo(t).TotalCableLengthTracked, filt, 'same', 'replicate');
        R.CellTimeInfo(t).TotalCableLengthFilopodiaTracked = imfilter(R.CellTimeInfo(t).TotalCableLengthFilopodiaTracked, filt, 'same', 'replicate');
        R.CellTimeInfo(t).TotalCableLengthAll = imfilter(R.CellTimeInfo(t).TotalCableLengthAll, filt, 'same', 'replicate');
        R.CellTimeInfo(t).TotalCableLengthFilopodiaAll = imfilter(R.CellTimeInfo(t).TotalCableLengthFilopodiaAll, filt, 'same', 'replicate');
        
        %R.CellTimeInfo(t).TotalF_Actin = imfilter(R.CellTimeInfo(t).TotalF_Actin , filt, 'same', 'replicate');
        
        R.CellTimeInfo(t).TotalCableLength2 = imfilter(R.CellTimeInfo(t).TotalCableLength2 , filt, 'same', 'replicate');
        R.CellTimeInfo(t).TotalCableLengthNoFilopodia2 = imfilter(R.CellTimeInfo(t).TotalCableLengthNoFilopodia2 , filt, 'same', 'replicate');
        
        
        
        
        % does it make sense to smooth averaged measures ? 
        R.CellTimeInfo(t).NormalizedMeanF_Actin = imfilter(R.CellTimeInfo(t).NormalizedMeanF_Actin , filt, 'same', 'replicate');
        R.CellTimeInfo(t).MeanFiloLength = imfilter(R.CellTimeInfo(t).MeanFiloLength , filt, 'same', 'replicate');

        
        
        % Question, does it make sense to smooth a count ?
        R.CellTimeInfo(t).NumNeuritesAll = imfilter(R.CellTimeInfo(t).NumNeuritesAll, filt, 'same', 'replicate');
        R.CellTimeInfo(t).NumTrackedNeurites = imfilter(R.CellTimeInfo(t).NumTrackedNeurites, filt, 'same', 'replicate');
        R.CellTimeInfo(t).FiloCountTracked = imfilter(R.CellTimeInfo(t).FiloCountTracked, filt, 'same', 'replicate');
        R.CellTimeInfo(t).BranchCountTracked = imfilter(R.CellTimeInfo(t).BranchCountTracked, filt, 'same', 'replicate');
        
        R.CellTimeInfo(t).BranchCountAll = imfilter(R.CellTimeInfo(t).BranchCountAll, filt, 'same', 'replicate');
        R.CellTimeInfo(t).FiloCountAll = imfilter(R.CellTimeInfo(t).FiloCountAll, filt, 'same', 'replicate');
        
    end
end

