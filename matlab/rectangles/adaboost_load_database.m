if exist('DATASET', 'var')
    switch DATASET
        case 'D'
            if ~exist('D.mat', 'file')
                disp('   D.mat does not exist, collecting a new data set');
                % define the training data set
                [Lp,Dp] = collect_positive_examples(N_pos, IMSIZE, pos_train_folder); N_pos = length(Lp);

                % define the test data set
                [Ln,Dn] = collect_negative_examples(N_total-N_pos, IMSIZE, neg_train_folder);

                 D = [Dp;Dn];  clear Dp Dn;  % D contains all integral image data (each row contains a vectorized image)
                 L = [Lp;Ln];  clear Lp Ln;  % L contains all associated labels
                 save('D.mat', '-v7.3', 'D', 'L');  disp(['...storing ' num2str(sum(L==1)) ' (class +1) / ' num2str(sum(L==-1)) ' (class -1) examples to D.mat.']);
            elseif strcmp(RectMethod, 'Lienhart') || strcmp(RectMethod, 'LienhartNO3')
                disp('...loading the Lienhart data from D45.mat');
                load D_45.mat;
            else
                disp('...loading training data from D.mat');
                load D.mat;
            end
        case 'Dplus40'
                load Dplus40.mat
        otherwise
            error('Error: no valid DATASET specified.');
    end
else
    disp('...no DATASET specified, loading training data from D.mat');
	load D.mat;
end

%load D29011.mat