%% PATH INFO
EXPNAME = 'heathrowEdge7';

addpath('/osshare/Work/neurons/matlab/features/spedges/');
imgpath = '/osshare/DropBox/Dropbox/aurelien/airplanes/heathrow/';
superpixelpath = '/osshare/DropBox/Dropbox/aurelien/airplanes/labels/';
% superpixelpath = '/osshare/airplanes/Superpixel_airplanes/labels/';
annotationFolder = '/osshare/DropBox/Dropbox/aurelien/airplanes/heathrowAnnotations/';
% annotationpath = '/osshare/DropBox/Dropbox/aurelien/airplanes/annotations/';
% annotationFolder = '/osshare/DropBox/Dropbox/aurelien/airplanes/annotations/';
%dropboxresultpath = ['/osshare/DropBox/Dropbox/aurelien/shapeFeatureVectors/' EXPNAME '/'];
localresultpath = ['./featurevectors/' EXPNAME '/'];
%if ~isdir(dropboxresultpath);mkdir(dropboxresultpath);end
if ~isdir(localresultpath);mkdir(localresultpath);end

d = dir([annotationFolder '*.png']);
libsvmFileName = 'feature_vectors';

%% PARAMETERS
angles = 0:30:330;
combos = combnk(angles, 2);
stride = 1;
eta = 1;


for f = 1:length(d)
    clear RAY1 RAY2 RAY3 RAY4 G;
    
    FILEROOT = regexp(d(f).name, '(\w*)[^\.]', 'match');
    FILEROOT = FILEROOT{1};
    disp(['reading ' FILEROOT]);
    I = imread([imgpath FILEROOT '.jpg']);
    A = imread([annotationFolder FILEROOT '.png']); A = A(:,:,2) > 200;
    disp('getting the superpixel labels');
    L = readRKLabel([superpixelpath FILEROOT '.dat'], [size(I,1) size(I,2)]);
 	L = L';
    superpixels = unique(L(:))';
    STATS = regionprops(L, 'PixelIdxlist', 'Centroid', 'Area');
    labels = zeros(size(superpixels));
    C = imread([annotationFolder FILEROOT '.png' ]); C0 = C(:,:,3) < 200; C1 = C(:,:,1) > 200; C2 = (C(:,:,1) <200 & C(:,:,3) >200); C = zeros(size(C0)) + C1 + 2.*C2;
        
    I = rgb2gray(I);
%     keyboard; EDGE = edge(I, 'canny', .1, 2);
    
    
    gh = imfilter(I,fspecial('sobel')' /8,'replicate');
    gv = imfilter(I,fspecial('sobel')/8,'replicate');
    G(:,:,1) = gv;
    G(:,:,2) = gh;
    
   
    RAYFEATUREVECTOR = zeros(length(superpixels), 3*length(angles) + size(combos,1) + 2);

    for l = superpixels
        RAYFEATUREVECTOR(l, 1) = mean(I(STATS(l).PixelIdxList));
        RAYFEATUREVECTOR(l, 2) = var(double(I(STATS(l).PixelIdxList)));
    end

    % RAY 1 is the basic ray, the distance RAY
    RAY1 = zeros([size(I) length(angles)]);
    RAY3 = zeros([size(I) length(angles)]);
    RAY4 = zeros([size(I) length(angles)]);


    EDGE = niceEdge7(I);  
    %if f == 1; 
        imwrite(imoverlay(I, EDGE), [localresultpath FILEROOT '.png'], 'PNG');
    %end; 

    
    for i = 1:length(angles)
        disp(['computing R1 R3 R4 for angle = ' num2str(angles(i))]);
        [R1 R3 R4] = rays(EDGE, G, angles(i), stride);
        RAY1(:,:,i) = R1;
        RAY3(:,:,i) = R3;
        RAY4(:,:,i) = R4;
    end


    % re-orient the rays to be rotationally invariant
    disp('shifting Rays to be rotation invariant');
    for r = 1:size(RAY1,1)
        for c = 1:size(RAY1,2)
            
            shift_places = -find(RAY1(r,c,:) == max(RAY1(r,c,:)),1)+1;
            a = 1:size(RAY1,3);
            a = circshift(a, [0 shift_places]);
            
            RAY1(r,c,:) = RAY1(r,c,a);
            RAY3(r,c,:) = RAY3(r,c,a);
            RAY4(r,c,:) = RAY4(r,c,a);
        end
    end
    
    disp('storing R1 R3 R4 into RAYFEATUREVECTOR');
    for i = 1:length(angles)
        R1 = RAY1(:,:,i);
        R3 = RAY3(:,:,i);
        R4 = RAY4(:,:,i);
        for l = superpixels
            
            % store the median ray in the superpixel
            RAYFEATUREVECTOR(l, i+2) =  median(R1(STATS(l).PixelIdxList));
            RAYFEATUREVECTOR(l, length(angles) + i+2) = median(R3(STATS(l).PixelIdxList));
            RAYFEATUREVECTOR(l, 2*length(angles) + i+2) = median(R4(STATS(l).PixelIdxList));
%             % store the centroid ray in the superpixel
%             RAYFEATUREVECTOR(l, i+2) = R1(STATS(l).Centroid(2), STATS(l).Centroid(1));
%             RAYFEATUREVECTOR(l, length(angles) + i+2) = R3(STATS(l).Centroid(2), STATS(l).Centroid(1));
%             RAYFEATUREVECTOR(l, 2*length(angles) + i+2) = R4(STATS(l).Centroid(2), STATS(l).Centroid(1));
        end
    end
            
    
   
    
    % RAY2
    disp('computing difference ray feature');
    pause(0.001);
    for c = 1:size(combos,1);
        disp([' raydiff ' num2str(combos(c,1)) ' ' num2str(combos(c,2))]);
        angle1 = angles == combos(c,1);
        angle2 = angles == combos(c,2);
        RAY2 = (RAY1(:,:,angle1) - RAY1(:,:,angle2)) ./ (RAY1(:,:,angle1)+eta);
        RAY2 = exp(RAY2);
        
        
        for l = superpixels           
            % store the median ray in the superpixel
            RAYFEATUREVECTOR(l, 3*length(angles) + c+2) = median(RAY2(STATS(l).PixelIdxList));
%             % store the centroid ray in the superpixel
%             RAYFEATUREVECTOR(l, 3*length(angles) + c+2) = RAY2(STATS(l).Centroid(2), STATS(l).Centroid(1));
        end
    end

    save([localresultpath FILEROOT '.mat'], 'RAYFEATUREVECTOR', 'L', 'superpixels', 'labels');
    
    %% Write to a LIBSVM file a random sampling of the feature vector
%     N = 200;
%     writeLIBSVMfeaturevector(RAYFEATUREVECTOR, L, superpixels, mito,libsvmFileName, dropboxresultpath, N);
end
