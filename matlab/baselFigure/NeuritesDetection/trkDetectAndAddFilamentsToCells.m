function [Cells, P, U, Regions ] = trkDetectAndAddFilamentsToCells(Green, Cells, Somata, FrangiOpt, IntensityAjustmentGreen, NeuriteDetectionParams)

%% First apply Frangi filter to all the images

[Tubularity, J] = trkComputeTubularity(Green, FrangiOpt);

%% find the proper sigmoid parameters to convert Frangi to probabilities

[Asig Bsig] = trkSetSigmoid(Tubularity, J, Somata,  IntensityAjustmentGreen.STD, IntensityAjustmentGreen.MAX);
clear J;

%% Get the tracked somata

[SomataTracked] = trkGetTrackedSomata(Cells, Somata);

%% apply sigmoid fitting to the tubularity, and attenuate on detected but not tracked somata

P = cell(size(Tubularity));
for t = 1:length(Tubularity)
    Tubularity{t}   = 0.001 + .998./(1+exp(Asig*log(Tubularity{t})+Bsig));
    P{t}            = -log(Tubularity{t});
    % generqate the mask of detected but not tracked somata 
    SomataMask = (Somata{t} > 0) & not(SomataTracked{t} > 0);
    SomataMask = bwmorph(SomataMask, 'dilate', 3);
    P{t}( SomataMask ) = max(P{t}(:)); % todo
end

%% Compute the geodesic maps from tracked somata

[Regions, U, Length] = trkDetectFilamentsGlobalThresh(SomataTracked, P);
% in what follows, exp(-U{t}) act like a probability of being a neurite.


%% pre-allocate data for neurites in cells so that the parfor runs well
for i =1:length(Cells)
    Cells(i).Neurites = [];
    if Cells(i).ID > 0
        Cells(i).Neurites                   = false(size(Tubularity{1}));
        Cells(i).NumberOfNeurites           = 0;
        Cells(i).NeuritesList               = [];
        Cells(i).RR                         = [];
        Cells(i).CandidateEndPoints         = [];
    end
end

EmptyTree.Parents    = [];
EmptyTree.NumKids    = [];
EmptyTree.NumKids    = [];
EmptyTree.Complexity = [];

%% Some basic parameters

% don't change those
NeuriteConnectivity  = 8;
RECURSIONLIMIT = 5000;
set(0,'RecursionLimit',RECURSIONLIMIT);

% Get the neurites detection and prining params
minimalSizeOfNeurite             = NeuriteDetectionParams.minimalSizeOfNeurite;
GEODESIC_DISTANCE_NEURITE_THRESH = NeuriteDetectionParams.GEODESIC_DISTANCE_NEURITE_THRESH;
pad                              = NeuriteDetectionParams.KeyPointDetectionParam;
ProbThresh                       = NeuriteDetectionParams.NeuriteProbabilityThreshold;
PruningThreshold                 = NeuriteDetectionParams.NeuritePruningLengthThreshold;

sz = size(Green{1});

%%
parfor dd = 1:length(Cells)
% for dd = 1:length(Cells)
    if Cells(dd).ID > 0
        t = Cells(dd).Time;
        RR = (U{t} < -log(GEODESIC_DISTANCE_NEURITE_THRESH)) & (U{t} > 0) & (Regions{t} == Cells(dd).ID);%#ok
        [B,~,~,A] = bwboundaries(RR, 'noholes');
        
        listOfCandidateEndPoints = [];
        for k=1:length(B),
            if(~sum(A(k,:)))
                boundary = B{k};
                Idx = sub2ind(size(U{t}), boundary(:, 1), boundary(:, 2));
                if(length(Idx) > pad)
                    Idx(end+1:end+pad) = Idx(1:pad);
                    LL = Length{t}(Idx);%#ok
                    LL = smooth(LL, pad);
                    if(max(LL) > pad)
%                       if the signal processing toolbox is available, use
%                       this:
%                       [~,imax] = findpeaks( LL, 'MINPEAKHEIGHT', pad, 'MINPEAKDISTANCE', min(pad, floor(length(Idx)/2)));
%                       listOfCandidateEndPoints = vertcat(listOfCandidateEndPoints, Idx(imax));%ok
%                       otherwise:
                        imax = imregionalmax(LL);
                        listOfCandidateEndPoints = vertcat(listOfCandidateEndPoints, Idx(imax));
                    end
                end
            end
        end
        neurites = Cells(dd).Neurites;
        if(~isempty(listOfCandidateEndPoints))
            [r c] =ind2sub(size(neurites), listOfCandidateEndPoints);
            UU = U{t};
            UU(  Regions{t} ~= Cells(dd).ID ) = 1e9;% to garentee that the back propagation searches only in the region of interest
            neurites = BackPropagateThreshold([r c]', UU, -log(ProbThresh)) ;
            Cells(dd).RR = double(RR);
            Cells(dd).CandidateEndPoints = [r c];
        else
            neurites = false(size(neurites));
        end
        neurites  = neurites & (Regions{t} == Cells(dd).ID) ;
        [LL, numberOfNeurites] = bwlabel(neurites, NeuriteConnectivity);
        for j = 1:numberOfNeurites
            if(sum(sum(LL == j)) < minimalSizeOfNeurite)
                neurites(LL == j) = 0;
            end
        end
        Cells(dd).Neurites = neurites;

        %% extract tree topology and start measurments
        [LL, numberOfNeurites] = bwlabel(Cells(dd).Neurites, NeuriteConnectivity);
        % do neurite pruning by removing short end branches
        for j =1:numberOfNeurites
            set(0,'RecursionLimit',RECURSIONLIMIT);
            listOfNeurites{j} = find(LL==j);
            [parents, numkids] = trkTreeStructureFromBinaryFilament(listOfNeurites{j}, Cells(dd).SomaPixelIdxList, size(Cells(dd).Neurites));
            currentTree                     = EmptyTree;
            currentTree.Parents             = parents;
            currentTree.NumKids             = numkids;
            currentTree.NeuritePixelIdxList = listOfNeurites{j};
            PixelIndicesOfPrunedBranches    = trkPruneShortBranches( currentTree, size(Cells(dd).Neurites), PruningThreshold );
            Cells(dd).Neurites(PixelIndicesOfPrunedBranches) = false;
        end

        [LL, numberOfNeurites] = bwlabel(Cells(dd).Neurites, NeuriteConnectivity);
        for j =1:numberOfNeurites
            if(numel(find(LL==j)) < PruningThreshold)
                Cells(dd).Neurites(LL==j) = false;
            end
        end
        
        [LL, numberOfNeurites] = bwlabel(Cells(dd).Neurites, NeuriteConnectivity);
        listOfNeurites = cell(1, numberOfNeurites);
        filam   = [];
        for j =1:numberOfNeurites
            set(0,'RecursionLimit',RECURSIONLIMIT);
            listOfNeurites{j} = find(LL==j);
            [parents, numkids] = trkTreeStructureFromBinaryFilament(listOfNeurites{j}, Cells(dd).SomaPixelIdxList, size(Cells(dd).Neurites));
            
            currentTree                     = EmptyTree;
            currentTree.Parents             = parents;
            currentTree.NumKids             = numkids;
            currentTree.NeuritePixelIdxList = listOfNeurites{j};
            currentTree                     = trkFindBranches(currentTree, size(Cells(dd).Neurites));
            % now fill the neurite with its base informations
            currentTree.isTracked            = false;
            currentTree.NeuriteTrackId       = -1;
            currentTree.Time                 = t;
            currentTree.CellTrackId          = Cells(dd).ID;
            currentTree.NeuriteIdx           = j;
            currentTree.CellIdx              = dd;
            
            [r,c]                            = ind2sub(sz, currentTree.NeuritePixelIdxList);
            Centroid                         = mean([c, r]);
            currentTree.Centroid             = Centroid;
            currentTree.MeanGreenIntensities = mean(Green{currentTree.Time}(currentTree.NeuritePixelIdxList)); %#ok
            currentTree.CentroidOffset       = Centroid - Cells(dd).NucleusCentroid;
            
            idxSomaContact                   = currentTree.NeuritePixelIdxList(currentTree.Parents == -1);
            if(numel(idxSomaContact) ~= 1)      keyboard; end;%#ok
            [r, c]                              = ind2sub(sz, idxSomaContact);
            currentTree.SomaContact          = [c, r];
            %done
            filam = [filam currentTree];
        end
        Cells(dd).NumberOfNeurites          = numberOfNeurites;
        Cells(dd).NeuritesList              = filam;
    end
end