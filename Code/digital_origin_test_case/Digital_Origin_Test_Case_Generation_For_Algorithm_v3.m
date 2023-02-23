%% Digital_Origin_TestCaseGenerationForAlgorithm [v3]

%{
This codebase is used to generate a basic, thresholded, microCT test
dataset equivalent. Using cylinders and spheres, the intent is to generate
a 3D model of a circle intersecting a cyclinder, rotate the view to be
looking from a birds eye view and record the result within a black and white image.
This works recursively based on you chosen parameters.

Cyclinder (C)
Sphere (S)
D1 = C Diameter
D2 = S Diameter

P1 = C Diameter StepSize
P2 = S Diameter StepSize
P3 = S Offset StepSize

Cylinder has constant height
Sphere has constant Z height (half of cylinder height)

Variables are 
    cylinder diameter
    slice offset
    
    Sphere Diameter
    Sphere offset
    
Need
    MinCylinder Diameter
    MaxCylinder Diameter
    C Diameter Step Size
    
    MinSlice >  offset
    MaxSlice > offset
    Slice Offset
    
    
    
    C Diameter range = 


%}

%% Setup

clear
clc

format short

%% Important Variables, could be set by user ahead of time for loop conditions

% VARIABLE ONE for manual input
radius = 300;
% VARIABLE TWO for manual input
cylinderHeight = 500;

% VARIABLE THREE for manual input
sphereOffset = 325; %IMPORTANT 

% VARIABLE FOUR for manual input; 
% change all instances of radii, including radii, initial, initialUp, initialDown and 'start of "FOR" loop'

radii = 50; % initial set condition
initialRadii = 50;
initialRadiiUp = 50;
initialRadiiDown = 50;

for radii = (50:-1:0) 
    if radii > -1
    
I = figure;
[X, Y, Z] = cylinder(radius,100);
Z(2,:) = cylinderHeight-1;

mapC = [1 1 1
    1 1 1
    1 1 1
    1 1 1
    1 1 1
    1 1 1];


surfplot1 = surf(X,Y,Z);
surfplot1.EdgeColor = [1 1 1];
colormap(mapC)

axis([-500 500 -500 500 0 499])

hold on;

A = X;
B = Y;
C = Z;

% radii = 50;

[X, Y, Z] = sphere;
X = X*radii;
Y = Y*radii;
Z = Z*radii;

mapS = [1 1 1
    1 1 1
    1 1 1
    1 1 1
    1 1 1
    1 1 1];

surfplot2 = surf(X+sphereOffset,Y,Z+((cylinderHeight/2)-1));
surfplot2.EdgeColor = [1 1 1];
colormap(mapS)

grid off
view(0,90)

%cylinder cap

xc = 0;
yc = 0;
theta = linspace(0,2*pi);
x = (radius)*cos(theta) + xc;
y = (radius)*sin(theta) + yc;

circlePlot = plot(x,y,'-','Color','w');

set(gca, 'Layer', 'top')
set(circlePlot,'LineStyle', 'none')

set(gca,'visible','off');

fill(x,y,'w','EdgeColor','w')
% axis equal
% axis off

set(gcf,'color',[0 0 0])

%% save figure as image (bmp) and iterate loop

% saveas(I,'MyFigure_saveAs.bmp');

% print('printTrial','-dbmpmono','-r0');

F= getframe(I);
frameRemoved = F.cdata;

% BW = imbinarize(frameRemoved);
% figure;
% imshow(BW);
BW_v2 = rgb2gray(frameRemoved); % from true colour to grayscale
BW = imbinarize(BW_v2);

formatSpec = "CH_%d_CD_%d_SO_%d_SD_%d.bmp";
FS1 = cylinderHeight;
FS2 = radius;
FS3 = sphereOffset;
FS4 = radii;

str = sprintf(formatSpec,FS1,FS2,FS3,radii);
str2 = sprintf(formatSpec,FS1,FS2,FS3,initialRadiiUp);
str3 = sprintf(formatSpec,FS1,FS2,FS3,initialRadiiDown);

if initialRadii == radii   
imwrite(BW, str, 'bmp')
close(I);

initialRadiiUp = initialRadiiUp + 1;
initialRadiiDown = initialRadiiDown - 1;

else
    
imwrite(BW, str2, 'bmp')
imwrite(BW, str3, 'bmp')
close(I);

initialRadiiUp = initialRadiiUp + 1;
initialRadiiDown = initialRadiiDown - 1;

end
end
end
