function CLASSIFIER = ada_adaboost(varargin)
%% ADA_ADABOOST trains a strong classifier from weak classifiers & training data.
%
%   CLASSIFIER = ada_adaboost(PRE, TRAIN, WEAK, T) trains a strong
%   classifier CLASSIFIER from T hypotheses generated from weighted weak
%   classifiers WEAK on training examples from data stored in 
%   struct TRAIN.  T defines the number of hypotheses make up the strong 
%   classifier.  PRE is a bigmatrix containing precomputed feature responses 
%   to the training set.  You may resume training an existing classifier by
%   calling CLASSIFIER = ada_adaboost(PRE, TRAIN, WEAK, T, CLASSIFIER);.
%
%
%   Copyright © 2008 Kevin Smith
%   See also ADA_COLLECT_DATA, ADA_DEFINE_CLASSIFIERS

%% set parameters and handle input arguments
PRE = varargin{1}; TRAIN = varargin{2}; WEAK = varargin{3}; T = varargin{4};

if nargin == 4
    % start new adaboost:  init training data weight vector.
    w = ones(1,length(TRAIN)) ./ length(TRAIN); 
    % Init a struct for the strong classifier, CLASSIFIER
    CLASSIFIER = ada_classifier_init(T, WEAK);
    tmin = 1;
else
    CLASSIFIER = varargin{5};  
    tmin = length(CLASSIFIER.feature_index) + 1;
    w = CLASSIFIER.w;
end


%% train the strong classifier as a series of T weak classifiers
for t = tmin:T
    %% 1. Normalize the weights
    w = w ./sum(w);
    
    %% 2. train weak learners for optimal class separation
    [WEAK, PRE] = ada_train_weak_learners(WEAK, TRAIN, PRE, w);
        
    
    %% 3. Use the best WEAK learner as the t-th CLASSIFIER hypothesis 
    [BEST_err, BEST_learner] = min(WEAK.error);
    
    CLASSIFIER.feature_index(t) = BEST_learner; 
    CLASSIFIER.alpha(t)         = log( (1 - BEST_err) / BEST_err );
    weak_classifier             = WEAK.(WEAK.list{BEST_learner,1})(WEAK.list{BEST_learner,2});
    learner_ind                 = WEAK.list{BEST_learner,3};
    field                       = WEAK.learners{learner_ind}{1};
    %response_function           = WEAK.learners{learner_ind}{5};
    classification_function     = WEAK.learners{learner_ind}{6};
    CLASSIFIER.learner_type{t}  = field;
    
    % add the weak classification function to the list of classification functions
    if isempty(CLASSIFIER.functions)
        CLASSIFIER.functions    = {field classification_function};
    elseif ~ismember(field, CLASSIFIER.functions(:,1))
        CLASSIFIER.functions    = [CLASSIFIER.functions ; {field classification_function}];
    end
    
    
    
    if ~isfield(CLASSIFIER, field)
        % this is the first weak_classifier of its type in CLASSIFIER
        CLASSIFIER.(field)(1) = weak_classifier;
    else
        % append the weak_classifier to existing list of this type
        CLASSIFIER.(field)(length(CLASSIFIER.(field))+1) = weak_classifier;
    end
        
    beta = BEST_err/ (1 - BEST_err);      % beta is between [0, 1]
    %disp(['...selected ' field ' learner ' num2str(BEST_learner) ' as t=' num2str(t)  '  [polarity = ' num2str(CLASSIFIER.polarity(t)) ' theta = ' num2str(CLASSIFIER.theta(t))  ']' ]);
    disp(['...selected learner ' num2str(BEST_learner) ' (' field ') as t=' num2str(t) ]);
    
    %% 4. Update the training weight vector according to misclassifications
    IIs = [TRAIN(:).II];                    % vectorize the integral images
    h = classification_function(weak_classifier, IIs);
    e = abs( h - [TRAIN(:).class] );
    w = w .* (beta * ones(size(w))).^(1 - e);
    CLASSIFIER.w = w;   
    clear IIs beta e f h    
end






% %% 3. Use the best WEAK classifier as the t-th CLASSIFIER hypothesis 
%     [BEST_err, BEST_feature] = min(WEAK.error);
%     
%     CLASSIFIER.feature_index(t)         = BEST_feature; 
%     CLASSIFIER.feature_descriptor(t,:)  = WEAK.descriptor(BEST_feature, :); 
%     CLASSIFIER.fast(t,:)                = WEAK.fast(BEST_feature,:);
%     CLASSIFIER.polarity(t)              = WEAK.polarity(BEST_feature); 
%     CLASSIFIER.theta(t)                 = WEAK.theta(BEST_feature); 
%     CLASSIFIER.alpha(t)                 = log( (1 - BEST_err) / BEST_err );
%     beta = BEST_err/ (1 - BEST_err);      % beta is between [0, 1]
%     disp(['...selected weak classifier ' num2str(BEST_feature) ' as t=' num2str(t)  '  [polarity = ' num2str(CLASSIFIER.polarity(t)) ' theta = ' num2str(CLASSIFIER.theta(t))  ']' ]);
%     
%     %% 4. Update the training weight vector according to misclassifications
%     IIs = [TRAIN(:).II];                    % vectorize the integral images
%     f = ada_fast_haar_response(CLASSIFIER.fast(t,:), IIs);
%     h = (CLASSIFIER.polarity(t)*ones(size(f)) .* f) <  ((CLASSIFIER.polarity(t)*ones(size(f))) .* (CLASSIFIER.theta(t)*ones(size(f))));
%     e = abs( h - [TRAIN(:).class] );
%     w = w .* (beta * ones(size(w))).^(1 - e);
%     CLASSIFIER.w = w;   
%     clear IIs beta e f h    
% end


