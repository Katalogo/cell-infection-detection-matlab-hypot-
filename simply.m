% to read any doc of function/Launch inbuilt apps
% select the "doc function" using curser right-click
% select "Evaluate Selection in command window" or press F9

%% Clean slate
clear; close all; clc;
%%
% whenever working with images imagine 
% every pixel as a element of 2D matrix
refImg = imread('dat\B_MO1_thin_giemsa6.jpg');
%% imageSegmenter(rgb2gray(refImg))
%% 1 Waretshed
% 1.1 
cellMask = segmentImageFcn(refImg);
togglefig('preSgMask',true)
% doc imshow
imshow(cellMask)
% doc title
title('Cell Mask','FontSize',14)
%% 1.2 
% doc bwareaopen
cellMask = bwareaopen(cellMask,30);
togglefig('AftSgMask',true)
imshow(cellMask)
title('Smoothed Cell Mask','FontSize',14)

%% 1.4 
% doc watershed
% doc rgb2gray
wsImg = watershed(rgb2gray(refImg));
%save only the pixel/matrix element == 0
wsEdges = wsImg == 0;
togglefig('WS_NO_imhmin',true)
imshow(wsEdges)
title('Watershed without supressing minima','FontSize',14)
%% 1.3 
% doc imhmin
newGray = imhmin(rgb2gray(refImg),13);
togglefig('norm',true)
imshow(newGray)
title('grayscale and supress minima','FontSize',14)
%% 1.4 
wsImg = watershed(newGray);
togglefig('WS',true)
imshow(wsImg)
title('Watershed after supressing minima','FontSize',14)
%% 1.5 
wsEdges = wsImg == 0;
togglefig('~WS',true)
imshow(wsEdges)
title('representing wherever watershed == 0','FontSize',14)
%% 1.6
wsEdges = bwareaopen(wsEdges,200,8);
togglefig('Sud~WS',true)
imshow(wsEdges)
title('removing unwanted river','FontSize',14)
%% 1.7 
% putting the Mask over the river
% and turning every pixel of river = 0
cellMask(wsEdges) = 0;
togglefig('Mask_Sud~WS',true)
imshow(cellMask)
title('putting Mask over river = 0','FontSize',14)

%% 2 Morphology
% 2.0
% doc imfindcircles
% circleFinder(newGray)
%% 2.1
detectCircles = @(x) imfindcircles(x,[18 32], ...
    'Sensitivity',0.89,'EdgeThreshold',0.04, ...
    'Method','TwoStage', 'ObjectPolarity','Dark');
[centers, radii] = detectCircles(refImg);
togglefig('Circle',true)
% doc viscircles
viscircles(centers,radii,'edgecolor','b');
title('Plotting detected circles','FontSize',20)
%% 2.2
%refImg = imread('dat\B_MO1_thin_giemsa6.jpg');  
%app.img4 = imhistmatch(app.img,refImg);
togglefig('ImgOcircle',true)
imshow(refImg);
viscircles(centers,radii,'edgecolor','b');
title('Plotting detected circles on image ','FontSize',14)
%% 3 Detection
clear; close all; clc;
refImg = imread('dat\B_MO1_thin_giemsa6.jpg');
infectionThreshold = 143;
%% 3.1
detectCircles = @(x) imfindcircles(x,[18 32], ...
'Sensitivity',0.89,'EdgeThreshold',0.04, ...
'Method','TwoStage', 'ObjectPolarity','Dark');
[centers,radii] = detectCircles(rgb2gray(refImg));

%% 3.2
% doc numel
% initially assuming non infected
isInfected = false(numel(radii),1);
gray = rgb2gray(refImg);

% doc size
x = 1:size(gray,2); %no. of column
y = 1:size(gray,1); %no. of rows

% doc meshgrid
[xx,yy] = meshgrid(x,y);
%%
% xx(1:5,1:5),yy(1:5,1:5)
togglefig('detect',true)
imshow(refImg)
%viscircles(centers,radii,'edgecolor','b');

infectionMask = false(size(gray));
for ii = 1:numel(radii)
    % doc hypot
	mask = hypot(xx - centers(ii,1), yy - centers(ii,2)) <= radii(ii);
	togglefig('figure',true)
    title(sprintf('%i %i %i',ii,xx,yy),"FontSize",14);
    imshow(mask)
    
    currentCellImage = gray;
	currentCellImage(~mask) = 0;
	infection = currentCellImage > 0 & currentCellImage < infectionThreshold;
	infectionMask = infectionMask | infection;
	isInfected(ii) = any(infection(:));
	if isInfected(ii)
		%break;
        showMaskAsOverlay(0.3,mask,'g',[],false);
	end
end

%togglefig('MATLAB App',true)
showMaskAsOverlay(0.5,infectionMask,'r',[],false);
%expandAxes(app.UIAxes_

%if sum(isInfected)>0
%    app.DetectionResultEditField.Value = "Infected";
%else
%    app.DetectionResultEditField.Value = "not Infected";
%end
%app.InfectedEditField.Value = sprintf( ...
%    '%i of %i (%0.1f%%)', sum(isInfected), ...
%numel(isInfected),100*sum(isInfected)/numel(isInfected));
