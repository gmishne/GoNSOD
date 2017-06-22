% Apply outlier detection to 3D mesh
% 
% Cheng, Xiuyuan, Gal Mishne, and Stefan Steinerberger. 
% "The Geometry of Nodal Sets and Outlier Detection." 
% arXiv preprint arXiv:1706.01362 (2017).
%
% Gal Mishne 2017
%
% download Gabriel Payne's Graph theory toolbox and add to path
% https://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph
% update to local path of toolbox:
% path_to_toolbox = '/toolbox_graph';
addpath([path_to_toolbox '/toolbox_graph']);
% download diffusion map utils from
% https://github.com/gmishne/diffusion_maps
addpath('../diffusion_maps');
%% load data
% stanford bunny from http://graphics.stanford.edu/data/3Dscanrep/ 
load('bunny.mat');
%%
K = triangulation2adjacency(trigs,Xc);
configParams.maxInd = 51;
configParams.normalization = 'lb';
configParams.plotResults = false;
[~, Lambda, Psi, ~] = calcDiffusionMap(K,configParams);
%% plot embedding on mesh
nb = configParams.maxInd;
ilist = round(linspace(3,configParams.maxInd-3, 8));
tau= 2.2; 
clf;
for i=1:length(ilist)
    v = real(Psi(:,ilist(i)));
    v = clamp( v/std(v),-tau,tau );
    options.face_vertex_color = v;
    subplot(2,4,i);
    plot_mesh(Xc,trigs,options);
    shading interp; camlight; axis tight; 
    colormap jet(256)
    title(['k = ' num2str(ilist(i))])
end
%%
figure;
% plot outlier score
subplot(121)
score = anomalyScore(Psi(:,2:30),Lambda(2:30));
options.face_vertex_color = score;
plot_mesh(Xc,trigs,options);
shading interp; camlight; axis tight; 
colormap jet(256)

subplot(122)
% plot quantized outlier score
[quants] = quantile(score, [0.1,0.9]);
vals = zeros(size(score));
vals(score>quants(1)) = 128;
vals(score>quants(2)) = 256;
options.face_vertex_color = vals;
plot_mesh(Xc,trigs,options);
shading interp; camlight; axis tight; 
colormap jet(256)

