function [Rblur,  J, D, Dlist, M, f, branches, count] = preprocessImagesMSER(R, G, sigma_red, minArea, maxArea, D, Dlist, count)


TMAX = length(R);
J = cell(size(R));
M = cell(size(R));
Rblur = cell(size(R));
f = cell(size(R));
branches = cell(size(R));
EightBitsImages = cell(size(R));
% some parameters for Kosevi's symtetry ridge detector
numOfScales = 4;
numOrientations = 4;
minWaveLength = 2.0;
mult = 1.8;
sigmaOnf = 0.55;
k = 2;
polarity = 1;



% frangi parameters
opt.FrangiScaleRange = [1 2];
opt.FrangiScaleRatio = 1;
opt.FrangiBetaOne = .5;
opt.FrangiBetaTwo = 15;
opt.BlackWhite = false;
opt.verbose = false;
%%
H = fspecial('log', [8, 8], 2);
parfor  t = 1:TMAX
    Rt = mat2gray(double(R{t}));
    J{t} = mat2gray(double(G{t}));
%     Rblur{t} = BM3DSHARP(Rt, sigma_red, 1.3, 'lc', 0);
    Rblur{t} = imgaussian(Rt, sigma_red);
    I = Rblur{t};
    I = uint8(255*(I-min(I(:)))/(max(I(:)) - min(I(:))));
    EightBitsImages{t} = I;
    M{t} = vl_mser(I, 'MinDiversity', minArea/maxArea,...
        'MaxVariation', 0.25,...
        'MinArea', minArea/numel(I), ...
        'MaxArea', maxArea/numel(I), ...
        'BrightOnDark', 1, ...
        'Delta',2) ;
    f{t} = FrangiFilter2D(J{t}, opt);
%     Jblur = imgaussian(J{t}, 1);
%     TT = zeros(size(Jblur, 1), size(Jblur, 2), 2, 2);
%     UsedScale = 2;
%     spacing = [1;1];
%     epsilon = 10;
%     sigma0 = 0.51;
%     TT(:, :, 1, 1) = WLV_OFxx(sigma0, UsedScale , spacing, J{t}, epsilon);
%     TT(:, :, 2, 2) = WLV_OFyy(sigma0, UsedScale , spacing, J{t}, epsilon);
%     TT(:, :, 1, 2) = WLV_OFxy(sigma0, UsedScale , spacing, J{t}, epsilon);
%     TT(:, :, 2, 1) = TT(:, :, 1, 2);
%     [~, ~, l1, l2] = perform_tensor_decomp(TT);
%     f{t} = 1-mat2gray(min(l2, 0));
%     f{t} = phasesym(Jblur, numOfScales, numOrientations, minWaveLength, mult, sigmaOnf, k, polarity);
    
%     level = graythresh(f{t});
%     BW = im2bw(f{t}, level);
%     BW = bwmorph(BW, 'thin');
%     detections = regionprops(BW, 'Eccentricity', 'PixelIdxList');
%     if(~isempty(detections))
%        for i =1:length(detections) 
%           if length(detections(i).PixelIdxList) < 5
%               BW(detections(i).PixelIdxList) = 0;
%           elseif length(detections(i).PixelIdxList) > 30
%               if detections(i).Eccentricity < 0.90
%                   BW(detections(i).PixelIdxList) = 0;
%               end
%           end
%        end
%        branches{t} = BW;
%     end
    pad = 7;
    Mask = ones(size(f{t}));
    Mask(pad:end-pad, pad:end-pad) = 0;
    f{t}(Mask > 0.5) = min(f{t}(Mask <= 0.5));
%     branches{t}(Mask > 0.5) = 0;
      branches{t} = zeros(size(R{t}));
end
%%
for t = 1:TMAX
    
    mm = zeros(size(R{1}));
    for x = M{t}'
        s = vl_erfill(EightBitsImages{t}, x);
        mm(s) = mm(s)+1;
    end
    M{t} = mm;
    M{t}  	= imfill(M{t} > 0, 'holes');
    M{t} = bwlabel(M{t});
    detections_t = regionprops(M{t}, 'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Perimeter', 'PixelIdxList');  %#ok<*MRPBW>
    % add some measurements, create a list of detections
    if ~isempty(detections_t)
        for i = 1:length(detections_t)
            detections_t(i).MeanGreenIntensity = sum(G{t}(detections_t(i).PixelIdxList))/detections_t(i).Area;
            detections_t(i).MeanRedIntensity = sum(R{t}(detections_t(i).PixelIdxList))/detections_t(i).Area;

            detections_t(i).Time = t;
            if count == 1
                D = detections_t(i);
            else
                D(count) = detections_t(i);
            end
            Dlist{t} = [Dlist{t} count];
            count = count + 1;
        end
    end
    
%     if ~isempty(detections_t)
%         for i = 1:length(detections_t)
%             if detections_t(i).Eccentricity >= 0.90
%                 M{t}(detections_t(i).PixelIdxList) = 0;
%             end
%         end
%     end
%     M{t} = bwlabel(M{t});
%     detections_t = regionprops(M{t}, 'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Perimeter', 'PixelIdxList');  %#ok<*MRPBW>
%     if ~isempty(detections_t)
%         for i = 1:length(detections_t)
%             if detections_t(i).Eccentricity < 0.90
%                 detections_t(i).MeanGreenIntensity = sum(G{t}(detections_t(i).PixelIdxList))/detections_t(i).Area;
%                 detections_t(i).MeanRedIntensity = sum(R{t}(detections_t(i).PixelIdxList))/detections_t(i).Area;
%             
%                 detections_t(i).Time = t;
%                 if count == 1
%                     D = detections_t(i);
%                 else
%                     D(count) = detections_t(i);
%                 end
%                 Dlist{t} = [Dlist{t} count];
%                 count = count + 1;
%             
%             else
%                  M{t}(detections_t(i).PixelIdxList) = 0;
%             end
%         end
%     end
end