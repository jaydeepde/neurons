


%% ICFILER
%folder = '/net/cvlabfiler1/home/ksmith/Basel/14-11-2010/';
%resultsFolder = '/net/cvlabfiler1/home/ksmith/Basel/Results/';

%% kevin's laptop
%folder = '/home/ksmith/data/Sinergia/Basel/14-11-2010/';
folder = '/home/ksmith/data/basel/ControlScreen/Plate1_10-5-2010';
resultsFolder = '/home/ksmith/data/basel/ControlScreen/Results/';



d = dir(folder);


% -------------- paths -----------------------
if isempty( strfind(path, [pwd '/frangi_filter_version2a']) )
    addpath([pwd '/frangi_filter_version2a']);
end
if isempty( strfind(path, [pwd '/code']) )
    addpath([pwd '/code']);
end
if isempty( strfind(path, [pwd '/gaimc']) )
    addpath([pwd '/gaimc']);
end



count = 1;
for i = 86:140
    exp_num(count,:) = sprintf('%03d', i); %#ok<SAGROW>
    count = count + 1;
end

for i = 1:size(exp_num,1)
    matlabpool local
    tic
    folder_n = [folder exp_num(i,:) '/'];
    %trkTracking(folder_n, resultsFolder);
    toc
    matlabpool close
    disp('');
    disp('=============================================================')
    disp('');
end

% kill the matlab pool
%matlabpool close force
