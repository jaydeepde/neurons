function responses = p_get_feature_responses(SET, learners, varargin)
%P_GET_FEATURE_RESPONSES
%
%   TODO: documentation
%
%   Examples:
%   ----------------------
%
%   See also P_TRAIN, P_SETTINGS

%   Copyright © 2009 Computer Vision Lab, 
%   École Polytechnique Fédérale de Lausanne (EPFL), Switzerland.
%   All rights reserved.
%
%   Authors:    Kevin Smith         http://cvlab.epfl.ch/~ksmith/
%               Aurelien Lucchi     http://cvlab.epfl.ch/~lucchi/
%
%   This program is free software; you can redistribute it and/or modify it 
%   under the terms of the GNU General Public License version 2 (or higher) 
%   as published by the Free Software Foundation.
%                                                                     
% 	This program is distributed WITHOUT ANY WARRANTY; without even the 
%   implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
%   PURPOSE.  See the GNU General Public License for more details.

%keyboard;

% if we have precomputed the feature values, recall them from memdaemon
if SET.precomputed && (nargin > 2)
    
    row = varargin{1};
    responses = mexLoadResponse('row',row,'HA')';
    %disp('precomputed');
    
% if not, calculate them on the fly
else
    switch learners{1}(1:2)

        case 'HA'
            responses = mexRectangleFeature(SET.IntImages, learners);
            %disp('online computation');

        case 'SV'
            responses = rand([length(SET.Images) length(learners)]);
            
        otherwise
            error('could not find appropriate function for learner');
            keyboard;
    end
end

%keyboard;