function score = anomalyScore(eigenvectors,eigenvalues) 
% Calculate anomaly score f_N from paper:
% Cheng, Xiuyuan, Gal Mishne, and Stefan Steinerberger. 
% "The Geometry of Nodal Sets and Outlier Detection." 
% arXiv preprint arXiv:1706.01362 (2017).
%
% using eigendecomposition of the Laplacian:
% eigenvectors is M X d matrix
% eigenvalues is d X 1 vector
% Output:
% score is M X 1 vector
% 
%
% Gal Mishne 2017

if size(eigenvalues,2) > 1
    error('eigenvalues is d X 1 vector');
end

eigenvalues(eigenvalues>=1) = 1 - eps;

inf_norm = (max(abs(eigenvectors))' .* sqrt(1-eigenvalues));
temp = bsxfun(@rdivide,abs(eigenvectors),inf_norm');
score = sum(temp,2);
