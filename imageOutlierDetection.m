function [detIm ] = imageOutlierDetection(im, configParams)
% apply outlier detection to image
% Inputs:
% im - 2D or 3D image
% configParams - paramters of algorithm, see defaults in function
% 'setAnomalyDetParams' below
%
% Cheng, Xiuyuan, Gal Mishne, and Stefan Steinerberger. 
% "The Geometry of Nodal Sets and Outlier Detection." 
% arXiv preprint arXiv:1706.01362 (2017).
%
% Gal Mishne 2017
%
% download diffusion map utils from
addpath('../utils');
%% 
if nargin < 2
    configParams = setAnomalyDetParams;
else
    configParams = setAnomalyDetParams(configParams);
end
%%
% for controlled random input
s = RandStream('mt19937ar');
RandStream.setGlobalStream(s);
%% preprocessing
maxval = max(im(:));
minval = min(im(:));
im     = (im - minval) / (maxval - minval);
%% extract overlapping square patches from image
% feature used is patches of image, if other feature is desirable replace
% this block of code
% X - matrix of size patchdim^2*num_patches, patches of the images organized as coloumns
[X, topleftOrigin] = im2patch(im, configParams.patchDim);
featuresLoc = topleftOrigin + floor(configParams.patchDim/2); % return center of each patch
idxPatches = sub2ind(size(im), featuresLoc(:,2), featuresLoc(:,1));

%% dimensionality reduction
configParams.normalization = 'lp';
[K] = calcAffinityMat(X, configParams);
[~, Lambda, Psi, ~] = calcDiffusionMap(K,configParams);
%% 
diffusionCoordIm = getDiffusionCoordIm(im, idxPatches, Psi(:,2:end)');
figure;
imagesc(diffusionCoordIm);
axis image
title('Image in Diffusion Coordinates')

M = length(idxPatches);
C = plotDiffusionMapinColor(diffusionCoordIm, idxPatches, Psi(:,2:end)', 1:M, [],'Diffusion Map',10);

%% display anomaly score
i = 20;
results.detection = anomalyScore(Psi(:,2:i),Lambda(2:i));

detIm = nan(size(im,1),size(im,2));
detIm(idxPatches) = results.detection(:);
   
figure;
ax = subplot(121);
imagesc(im,[0 1]);axis image;axis off
colormap(ax,'gray')
ax = subplot(122);
imagesc(detIm);axis image;axis off
colormap(ax,'jet')


function configParams = setAnomalyDetParams(configParams)
dParams.verbose         = false; % display waitbars and messages
dParams.kNN             = 16;   % number of nearest neighbors used in calculation of affinity matrix
dParams.self_tune       = 7;    % index of neighbor used for self-tuning
dParams.patchDim        = 8;    % size of patch at full-size level of the pyramid
dParams.maxInd          = min(dParams.patchDim^2, 51);
dParams.t = 1;
dParams.normalization = 'markov';

if exist('configParams','var')
    configParams = setParams(dParams, configParams);
else
    configParams = dParams;
end

