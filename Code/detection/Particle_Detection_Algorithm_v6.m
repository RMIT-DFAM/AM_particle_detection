%% Part 0 - Startup - Clear Workspace and Command Window
% clear;clc;fclose all;close all;

%% Part 0.1 - Setup

% Results of Algorithm dependant on Quality of image data,
%   thresholding / binarization applied to image data and dbscan grouping

% PRE_01 - Define if useDefault is True or False

% PRE_02 - Define Folder location of Reconstructed Slice Data, File Format
% PRE_02 - NB: Matlab Current Folder should be same Folder

% PRE_03 - Rename Reconstruction .log file to "NRecon_Output.log"
% PRE_03 - NB: Log file should be in Folder Path from PRE_01

% PRE_04 - Thresholding - Select Path (Automatic or Iterative) [Part 1.2]
% PRE_04 - Thresholding - If iterative, update name of chosen image.

% PRE_05a - Important Variables to Save Out per Data Set
% PRE_05a - At minimum: 

% PRE_05a - mmPerPixelFinal, densityThresholdLow, densityThresholdHigh, 
%           imgStack,imgStackInfo, CC, 

% PRE_05b - If entire algorithm is to be run through, include the following:

% PRE_05b - maxNCB_DiamPerClusterArray
% PRE_05b - distribution_num_minorBounds_per_ncbCluster
% PRE_05b - distribution_height_per_ncbCluster
% PRE_05b - diamArrayNCB_Polyshape2
% PRE_05b - maxEMB_DiamPerClusterArray
% PRE_05b - distribution_num_minorBounds_per_embCluster
% PRE_05b - distribution_height_per_embCluster
% PRE_05b - diamArrayEMB_Polyshape2

% Save in unique folders per input image data name
% Now Saves out variables in PRE_05a automatically

%% Part 1 - Run for first time or import from ZZ_PreAnalysisData_ZZ.mat

prompt = 'How do you want to run this program? \n1 = Get Pre-Run Data from Reconstructed Stack?  \n2 = Get Pre-Run Data from ZZ_PreAnalysisData_ZZ.mat? \n3 = From Generated Test Data Set \n';
prt1_prompt = input(prompt);

if prt1_prompt == 1
    
%% Part 1.1 - Create Image Stack, Extract Scaled Image Pixel Size, Select Representative Image

% Set up useDefault (PRE_01)
prompt = 'Is useDefault true or false? \ntrue = run with Pre-Chosen Outputs\nfalse = manually select values\n';
useDefault = input(prompt);

if useDefault
% Create Image Stack (PRE_02)

% if end-user is running with useDefault as true, below filepath to be updated accordingly

% [imgStack,imgStackInfo]=readBinaryImgStack('FILEPATH to dataset folder','image format');
[imgStack,imgStackInfo]=readBinaryImgStack('C:\Users\USER\Documents\MATLAB\Particle_Detection_Algorithm','bmp');

else
    % extact folder information and file type information for insertion
    % UPDATE? Extract extension from most common file type in folder
    currentFolder = pwd;
    prompt = 'What is the file extension of the reconstructed Data Set?\nDo not include period and type between two apostrophes?\n';
    fileEXT = input(prompt);
    
    [imgStack,imgStackInfo]=readBinaryImgStack(currentFolder,fileEXT);
    
end
    prompt = 'Select (Micro) CT Stack Reconstruction Log File'; %(PRE_03)
    if useDefault
    
    % if end-user is running with useDefault as true, below filename to be updated accordingly
        
%         textFileToExtractFrom = '../ReconstructionSoftware_Output.log'; %Must have MATLAB in Current Folder if using useDefault
        textFileToExtractFrom = '../NRecon_Output.log'; %Must have MATLAB in Current Folder if using useDefault
    else
        textFileToExtractFrom = uigetfile({'*.log','*.txt'});
    end
    
% Extract the scaled image size per pixel from the reconstruction log file

str1 = extractFileText(textFileToExtractFrom);
start = 'Image Pixel Size (um)=';
fin = newline + 'Scaled Image Pixel Size (um)=';
mmPerPixel = extractBetween(str1,start,fin);
mmPerPixel = strtrim(mmPerPixel);
mmPerPixel = str2num(mmPerPixel);
mmPerPixel = mmPerPixel/1000;

mmPerPixelFinal = mmPerPixel;

%% Part 1.2 - Define Pixel Intensity Range (PRE_03)

% Use 1.2.1, Branches into either 1.2.2 or 1.2.3

%% Part 1.2.1 - Select Random/Representative Image from Stack

baseFileName = 1; %Needs to be in MATLAB Path
    prompt = 'Select a random image for Threshold comparisons';
    if useDefault
    
        % if end-user is running with useDefault as true, below filename to be updated accordingly

        % baseFileName = 'randomImageFromReconstructedSliceData.bmp'; % (PRE_04)
        baseFileName = '600_600_10_30deg_rec00000512.bmp';
        % baseFileName = '';
    else
        baseFileName = uigetfile({'*.*'});
    end
    
    [filepath,name,ext] = fileparts(baseFileName);
    
    if strcmp(ext,'.dcm') % DICOM requires dicomeread
    baseFileData = dicomread(baseFileName);
    else
    baseFileData = imread(baseFileName);
    end
    
    [numRows_xAxis,numCols_yAxis, numSlices_zAxis] = size(imgStack);

%% Part 1.2.2 - Thresholding - Binarize Image Stack - Original

if useDefault
    
imgStack = imgStack>=70 & imgStack<=255; % Original Setup // (PRE_04)
    
%% Part 1.2.3 - Thresholding

else
    
    % Thresholding is conducted between an Upper and Lower bounded point
    % The intent behind thresholding is to remove noise and deliver a
    % resultant binarized image that is as close as possible to the 
    % original image.
    
    % For the test datasets, a lower bound of 70, and upper bound of 255
    % were selected

%% Part 1.2.3.1 - Thresholding - Lower Bound

    fig = figure;
    set(fig, 'Position', get(0, 'Screensize'))
    ax1 = axes(fig);
    axesLayout = {
        1;
        2;
        3;
        4;
        5;
        6;
        };
    for inc = 1:length(axesLayout)
        ax(inc) = subplot(2,3,axesLayout{inc});
    end
    ax(3).Visible = 'off';
    ax(6).Visible = 'off';   

    axes(ax(1)); % Select the axes
    imshow(baseFileData);
    a = baseFileData;
    title('Representative Image Slice from Stack') %Show selected slice.

    prompt = 'What is the value of the threshold sensitivity from 0 to 255? \nRHS must be as close to LHS as possible. ';
    if useDefault
        s1 = 70;
        lb = s1;
    else
        s1 = input(prompt);
    end
    
    lb = s1;
    s2 = s1/255;
    b = imbinarize(baseFileData, s2);
    lowerBinary = b;
    axes(ax(2));
    imshow(b);
    title('Lower Thresholded Image')

    prompt = 'Is the thresholded image accurate to the input image? Yes or No? ';
    if useDefault
        str1 = 'Yes';
    else
        str1 = input(prompt,'s');
        while strcmp(str1,'No')
            prompt = 'What is the value of the threshold sensitivity from 0 to 255? ';
            s1 = input(prompt);
            lb = s1;
            % clear s2;
            s2 = s1/255;
            b = imbinarize(a, s2);
            lowerBinary = b;
            % imshowpair(a,b,'montage')
            axes(ax(3));
            imshow(b);
            title('Lower Thresholded Image')

            prompt = 'Is the thresholded image accurate to the input image? Yes or No? ';
            str1= input(prompt,'s');
        end
    end

    densityThresholdLow = s1;

%% Part 1.2.3.2 - Thresholding - Upper Bound
    
    axes(ax(4)); % Select the axes
    imshow(baseFileData);
    % title('Representative Image Slice from Stack') %Show selected slice.

if useDefault
        s1 = 255;
    else
        prompt = 'What is the value of the threshold sensitivity from 0 to 255? \nRHS must be as close to black as possible. ';
        s1 = input(prompt);
    end
    s2 = s1/255;
    b = imbinarize(baseFileData, s2);
    upperBinary = b;

    axes(ax(5));
    imshow(b);
    title('Higher Thresholded Image - Original')

    if useDefault
        % do nothing
    else
        prompt = 'Is the thresholded image accurate to the input image? Yes or No? ';
        str1= input(prompt,'s');
        while strcmp(str1,'No')
            prompt = 'What is the value of the threshold sensitivity from 0 to 255? ';
            s1 = input(prompt);
            % clear s2;
            s2 = s1/255;
            b = imbinarize(a, s2);
            upperBinary = b;
            % imshowpair(a,b,'montage')
            axes(ax(6));
            imshow(b);
            title('Higher Thresholded Image - New')

            prompt = 'Is the thresholded image accurate to the input image? Yes or No? ';
            str1= input(prompt,'s');
        end

    end
    densityThresholdHigh = s1;

%% Part 1.2.3.3 - Thresholding - Binarize Image Stack

% %Update Image Stack based on thresholding values

imgStack=imgStack>=densityThresholdLow & imgStack<=densityThresholdHigh;

end

%% Part 1.2.3.4 - Thresholding - Binarize Image Stack

%for getting Dist. values, update imgStack here, and run from Part 1.3

% prompt = 'What is the updated value of densityThresholdLow?';
% densityThresholdLowUpdated = input(prompt);
% prompt = 'What is the updated value of densityThresholdHigh?';
% densityThresholdHighUpdated = input(prompt);
% imgStack=imgStack>=densityThresholdLowUpdated & imgStack<=densityThresholdHighUpdated;

%% Part 1.3 - Find Connections
CC = bwconncomp(imgStack);% Get connected components // (PRE_04)
[numVoxelslargestConnComp,largestConnCompID]=max(cellfun(@(x) length(x),CC.PixelIdxList));
imgStack_Adjusted=zeros(CC.ImageSize);
imgStack_Adjusted(CC.PixelIdxList{largestConnCompID})=1;

imgStack_Adjusted_saveOut = imgStack_Adjusted;

imgStack_Adjusted=imgStack;
% volshow(imgStack_Adjusted_saveOut,'Renderer','VolumeRendering');

%% Part 1.4 - Get Polygonal Boundaries
polyBounds=getAllboundaries(imgStack_Adjusted,CC.ImageSize(end));
polyBoundsLength = length(polyBounds);
%% Part 1.5 - Determine types of bounds (Int / Ext // Major / Minor)

%% Part 1.5.1 - Get "bounds"

bounds=getBoundaryVals(polyBounds,CC,largestConnCompID);

elseif prt1_prompt == 2
  
%      PreAnalysisData = uigetfile({'*.mat'});
%      load(PreAnalysisData);
       load('ZZ_PreAnalysisData_ZZ.mat')
    
imgStack                      = cellToSaveOut{1,1};
imgStackInfo                  = cellToSaveOut{1,2};
mmPerPixelFinal               = cellToSaveOut{1,3};
densityThresholdLow           = cellToSaveOut{1,4};
densityThresholdHigh          = cellToSaveOut{1,5};
CC                            = cellToSaveOut{1,6};
imgStack_Adjusted_saveOut     = cellToSaveOut{1,7};
polyBounds                    = cellToSaveOut{1,8};  
polyBoundsLength              = cellToSaveOut{1,9};
bounds                        = cellToSaveOut{1,10};
    
[numRows_xAxis,numCols_yAxis, numSlices_zAxis] = size(imgStack);

%flip x & y data, due to bwboundaries

% //

% Isosurface model rendering 
% True option for GPU usage, false option for integrated graphics

% ax = axes(figure);
% iptsetpref('VolumeViewerUseHardware',true)
% volshow(imgStack_Adjusted_saveOut,'Renderer','VolumeRendering');
% ax.View = [90,15];

iptsetpref('VolumeViewerUseHardware',false); 
V = squeeze(imgStack_Adjusted_saveOut);
ax = axes(figure);
fv = volshow(V,'Renderer','VolumeRendering');
ax.View = [90,15];

% iptsetpref('VolumeViewerUseHardware',false); 
% volumeViewer; 
% iptsetpref('VolumeViewerUseHardware',true)


elseif prt1_prompt == 3
    
currentFolder = pwd;
prompt = 'What is the file extension of the reconstructed Data Set?\nDo not include period and type between two apostrophes?\n';
fileEXT = input(prompt);
    
[imgStack,imgStackInfo]=readBinaryImgStack(currentFolder,fileEXT);  

baseFileName = uigetfile({'*.*'});
    
[filepath,name,ext] = fileparts(baseFileName);
    
if strcmp(ext,'.dcm')
baseFileData = dicomread(baseFileName);
else
baseFileData = imread(baseFileName);
end
    
    [numRows_xAxis,numCols_yAxis, numSlices_zAxis] = size(imgStack);



CC = bwconncomp(imgStack);% Get connected components // (PRE_04)
[numVoxelslargestConnComp,largestConnCompID]=max(cellfun(@(x) length(x),CC.PixelIdxList));
imgStack_Adjusted=zeros(CC.ImageSize);
imgStack_Adjusted(CC.PixelIdxList{largestConnCompID})=1;
imgStack_Adjusted_saveOut = imgStack_Adjusted;
imgStack_Adjusted=imgStack;
polyBounds=getAllboundaries(imgStack_Adjusted,CC.ImageSize(end));
polyBoundsLength = length(polyBounds);
bounds=getBoundaryVals(polyBounds,CC,largestConnCompID);

mmPerPixelFinal = 0;
densityThresholdLow = 0;
densityThresholdHigh = 0;
end


%% Part 1.5.2 - Get other Bounds (Major / Minor / Floating)

majorBounds=cell2mat(bounds.MajorBound);
externalMinorBounds=cell2mat(bounds.MinorBoundsExternal);
minorBoundsInternal=cell2mat(bounds.MinorBoundsInternal);
nonConnectedBounds=cell2mat(bounds.NonConnectedBound);

% - majorBounds             =   Largest Boundary(s) from Data Set

% - externalMinorBounds     =   Attaching Minor Boundaries

% - minorBoundsInternal     =   Internal Pores, not relevant for analysis

% - nonConnectedBounds      =   Non-Attaching (Floating) Minor Boundaries

if isfile('ZZ_PreAnalysisData_ZZ.mat')

else
    
cellToSaveOut       = cell(1,10);
cellToSaveOut{1,1}  = imgStack;
cellToSaveOut{1,2}  = imgStackInfo;
cellToSaveOut{1,3}  = mmPerPixelFinal;
cellToSaveOut{1,4}  = densityThresholdLow;
cellToSaveOut{1,5}  = densityThresholdHigh;
cellToSaveOut{1,6}  = CC;
cellToSaveOut{1,7}  = imgStack_Adjusted_saveOut;
cellToSaveOut{1,8}  = polyBounds;
cellToSaveOut{1,9}  = polyBoundsLength;
cellToSaveOut{1,10} = bounds;

% save('ZZ_PreAnalysisData_ZZ.mat', 'cellToSaveOut');
save('ZZ_PreAnalysisData_ZZ.mat', 'cellToSaveOut', '-v7.3');
    
end

%% Part 2 - externalMinorBounds (EMB) Preparation
% Conduct Density-Based Scan to group connected bounds into Clusters

abcd=externalMinorBounds;
check_abcd = isempty(abcd);
if check_abcd == 1
    
else

idx1 = dbscan(abcd,3,5); % (X,epsilon,minpts)
% Potential to change density parameters to group specific clusters

%% Part 2.1 - For EMB: Add grouping (Col. 4) NaN Cap at bottom, count of NaNs
externalMinorBounds_v2 = [externalMinorBounds, idx1];
externalMinorBounds_v2((length(externalMinorBounds_v2)+1),1:3) = NaN;
externalMinorBounds_v2((length(externalMinorBounds_v2)),4) = -1;

embV2Sum = length(externalMinorBounds_v2);
embSplitCol = zeros(embV2Sum,1);
embNaNSum = sum(isnan(externalMinorBounds_v2(:,1)));
externalMinorBounds_v2 = [externalMinorBounds_v2, embSplitCol];

embLengthTracker = 1;
embSplit = 1;

for embLengthTracker = 1:embV2Sum
    if isnan(externalMinorBounds_v2(embLengthTracker,1))
        externalMinorBounds_v2(embLengthTracker,5) = embSplit;
        embSplit = embSplit+1;
    end
end
    
%% Part 2.2 - For EMB: Find number of Pixels per cluster
externalMinorBoundsNoNaNs = externalMinorBounds_v2;
embNaN1 = isnan(externalMinorBoundsNoNaNs(:,1)) ;
embNaN2 = isnan(externalMinorBoundsNoNaNs(:,2)) ;
embNaN3 = isnan(externalMinorBoundsNoNaNs(:,3)) ;
embNaN_All = embNaN1 & embNaN2 & embNaN3;   
externalMinorBoundsNoNaNs(embNaN_All,:) = [];

numEMB_Clusters = max(externalMinorBoundsNoNaNs(:,4)); %number of minor boundary clusters

%for each cluster, count the number of minor boundaries

embClusterMB_Count = zeros(1,numEMB_Clusters);
for embMB_Counter = 1:numEMB_Clusters
    embMB_Num = (sum(externalMinorBoundsNoNaNs(:,4) == embMB_Counter));
    embClusterMB_Count(1,embMB_Counter) = embMB_Num;
end

%% Part 2.3 - For EMB: Create Array for each Cluster of bounds

for Cluster_Array_Creation_Count = 1:numEMB_Clusters
    str = strcat('embClusterArray_',' ', num2str(Cluster_Array_Creation_Count));
    embClusterArray{Cluster_Array_Creation_Count} = str;
end
for Cluster_Array_Creation_Count2 = 1:numEMB_Clusters
    embClusterArray{1,Cluster_Array_Creation_Count2} = externalMinorBounds_v2;
end

for Cluster_Array_Creation_Count3 = 1:numEMB_Clusters
embClusterNum1 = embClusterArray{1,Cluster_Array_Creation_Count3}(:,4) ~= Cluster_Array_Creation_Count3;
embClusterNum2 = embClusterArray{1,Cluster_Array_Creation_Count3}(:,4) ~= -1;
embClusterAll = embClusterNum1 & embClusterNum2;
embClusterArray{1,Cluster_Array_Creation_Count3}(embClusterAll,:) = [];
end   

%embClusterArray is now used for anlysing clusters

% Remove Nonsense values
for Cluster_Array_Count = 1:numEMB_Clusters
embCluster1 = ~isnan(embClusterArray{1,Cluster_Array_Count}(:,3)) ;
embCluster2 = embClusterArray{1,Cluster_Array_Count}(:,4) == -1 ;
embClusterAll2 = embCluster1 & embCluster2;   
embClusterArray{1,Cluster_Array_Count}(embClusterAll2,:) = [];
end 


%% Part 2.4 - For EMB: Add Unique ID for each Boundary of Cluster

for Cluster_Array_Creation_Count2 = 1:numEMB_Clusters
str2 = strcat('embClusterAray_r',' ', num2str(Cluster_Array_Creation_Count2));
embClusterArray2{Cluster_Array_Creation_Count2} = str2;
end

for Cluster_Array_Creation_Count3 = 1:numEMB_Clusters
X=embClusterArray{1,Cluster_Array_Creation_Count3};
nanRowID=find(isnan(X(:,1)));
cntr=1;
for i=1:length(nanRowID)-1
               if nanRowID(i)==nanRowID(i+1)-1
                              X(nanRowID(i),6)=-1; % Whatever you want to indicate not a cluster bound
                              X(nanRowID(i+1),6)=-1;% Whatever you want to indicate not a cluster bound
               else
                              X(nanRowID(i)+1:nanRowID(i+1)-1,6)=cntr;
                              cntr=cntr+1;
                              X(nanRowID(i),6)=-1; % Whatever you want to indicate not a cluster bound
                              X(nanRowID(i+1),6)=-1;% Whatever you want to indicate not a cluster bound
               end
               embClusterArray2{1,Cluster_Array_Creation_Count3} = X;
end
end

%embClusterArray2 has ID for minor boundaries in internal column 6

distribution_num_minorBounds_per_embCluster = zeros(1,numEMB_Clusters); %number of minor boundaries per cluster
for embMB_NUM_Counter = 1:numEMB_Clusters
    embMB_Num2 = max(embClusterArray2{1,embMB_NUM_Counter}(:,6));
    distribution_num_minorBounds_per_embCluster(1,embMB_NUM_Counter) = embMB_Num2;
end

distribution_height_per_embCluster = zeros(1,numEMB_Clusters); %number of minor boundaries per cluster
for embMB_NUM_Counter = 1:numEMB_Clusters
    embMB_Num2 = (max(embClusterArray2{1,embMB_NUM_Counter}(:,3))-min(embClusterArray2{1,embMB_NUM_Counter}(:,3))+1);
    distribution_height_per_embCluster(1,embMB_NUM_Counter) = embMB_Num2;
end

end

%% Part 3 - nonConnectedBounds (NCB) Preparation
% Conduct Density-Based Scan to group connected bounds into Clusters

efgh=nonConnectedBounds;
check_efgh = isempty(efgh);
if check_efgh == 1
    
else

idx2 = dbscan(efgh,3,5); % (X,epsilon,minpts)
% Potential to change density parameters to group specific clusters

%% Part 3.1 - For NCB: Add grouping (Col. 4) NaN Cap at bottom, count of NaNs
nonConnectedBounds_v2 =[nonConnectedBounds, idx2];
nonConnectedBounds_v2((length(nonConnectedBounds_v2)+1),1:3) = NaN;
nonConnectedBounds_v2((length(nonConnectedBounds_v2)),4) = -1;

ncbV2Sum = length(nonConnectedBounds_v2);
ncbSplitCol = zeros(ncbV2Sum,1);
ncbNaNSum = sum(isnan(nonConnectedBounds_v2(:,1)));
nonConnectedBounds_v2 = [nonConnectedBounds_v2, ncbSplitCol];

ncbLengthTracker = 1;
ncbSplit = 1;

for ncbLengthTracker = 1:ncbV2Sum
    if isnan(nonConnectedBounds_v2(ncbLengthTracker,1))
        nonConnectedBounds_v2(ncbLengthTracker,5) = ncbSplit;
        ncbSplit = ncbSplit+1;
    end
end

%% Part 3.2 - For NCB: Find number of Pixels per cluster
nonConnectedBoundsNoNaNs = nonConnectedBounds_v2;
ncbNaN1 = isnan(nonConnectedBoundsNoNaNs(:,1)) ;
ncbNaN2 = isnan(nonConnectedBoundsNoNaNs(:,2)) ;
ncbNaN3 = isnan(nonConnectedBoundsNoNaNs(:,3)) ;
ncbNaN_All = ncbNaN1 & ncbNaN2 & ncbNaN3;   
nonConnectedBoundsNoNaNs(ncbNaN_All,:) = [];

numNCB_Clusters = max(nonConnectedBoundsNoNaNs(:,4)); %number of minor boundary clusters

%for each cluster, count the number of minor boundaries

ncbClusterMB_Count = zeros(1,numNCB_Clusters);
for ncbMB_Counter = 1:numNCB_Clusters
    ncbMB_Num = (sum(nonConnectedBoundsNoNaNs(:,4) == ncbMB_Counter));
    ncbClusterMB_Count(1,ncbMB_Counter) = ncbMB_Num;
end

%% Part 3.3 - For NCB: Create Array for each Cluster of bounds

for Cluster_Array_Creation_Count = 1:numNCB_Clusters
    str = strcat('ncbClusterArray_',' ', num2str(Cluster_Array_Creation_Count));
    ncbClusterArray{Cluster_Array_Creation_Count} = str;
end
for Cluster_Array_Creation_Count2 = 1:numNCB_Clusters
    ncbClusterArray{1,Cluster_Array_Creation_Count2} = nonConnectedBounds_v2;
end

for Cluster_Array_Creation_Count3 = 1:numNCB_Clusters
ncbClusterNum1 = ncbClusterArray{1,Cluster_Array_Creation_Count3}(:,4) ~= Cluster_Array_Creation_Count3;
ncbClusterNum2 = ncbClusterArray{1,Cluster_Array_Creation_Count3}(:,4) ~= -1;
ncbClusterAll = ncbClusterNum1 & ncbClusterNum2;
ncbClusterArray{1,Cluster_Array_Creation_Count3}(ncbClusterAll,:) = [];
end   

%ncbClusterArray is now used for anlysing clusters

% Remove Nonsense values
for Cluster_Array_Count = 1:numNCB_Clusters
ncbCluster1 = ~isnan(ncbClusterArray{1,Cluster_Array_Count}(:,3)) ;
ncbCluster2 = ncbClusterArray{1,Cluster_Array_Count}(:,4) == -1 ;
ncbClusterAll2 = ncbCluster1 & ncbCluster2;   
ncbClusterArray{1,Cluster_Array_Count}(ncbClusterAll2,:) = [];
end 


%% Part 3.4 - For NCB: Add Unique ID for each Boundary of Cluster

for Cluster_Array_Creation_Count2 = 1:numNCB_Clusters
str2 = strcat('ncbClusterAray_r',' ', num2str(Cluster_Array_Creation_Count2));
ncbClusterArray2{Cluster_Array_Creation_Count2} = str2;
end

for Cluster_Array_Creation_Count3 = 1:numNCB_Clusters
X=ncbClusterArray{1,Cluster_Array_Creation_Count3};
nanRowID=find(isnan(X(:,1)));
cntr=1;
for i=1:length(nanRowID)-1
               if nanRowID(i)==nanRowID(i+1)-1
                              X(nanRowID(i),6)=-1; % Whatever you want to indicate not a cluster bound
                              X(nanRowID(i+1),6)=-1;% Whatever you want to indicate not a cluster bound
               else
                              X(nanRowID(i)+1:nanRowID(i+1)-1,6)=cntr;
                              cntr=cntr+1;
                              X(nanRowID(i),6)=-1; % Whatever you want to indicate not a cluster bound
                              X(nanRowID(i+1),6)=-1;% Whatever you want to indicate not a cluster bound
               end
               ncbClusterArray2{1,Cluster_Array_Creation_Count3} = X;
end
end

%ncbClusterArray2 has ID for minor boundaries in internal column 6

distribution_num_minorBounds_per_ncbCluster = zeros(1,numNCB_Clusters); %number of minor boundaries per cluster
for ncbMB_NUM_Counter = 1:numNCB_Clusters
    ncbMB_Num2 = max(ncbClusterArray2{1,ncbMB_NUM_Counter}(:,6));
    distribution_num_minorBounds_per_ncbCluster(1,ncbMB_NUM_Counter) = ncbMB_Num2;
end

distribution_height_per_ncbCluster = zeros(1,numNCB_Clusters); %number of minor boundaries per cluster
for ncbMB_NUM_Counter = 1:numNCB_Clusters
    ncbMB_Num2 = (max(ncbClusterArray2{1,ncbMB_NUM_Counter}(:,3))-min(ncbClusterArray2{1,ncbMB_NUM_Counter}(:,3))+1);
    distribution_height_per_ncbCluster(1,ncbMB_NUM_Counter) = ncbMB_Num2;
end

end

%% Part 4 - Polyshape / Equiv. Circle Analysis - Split into NCB and EMB

%% Part 4.1 - EMB Analysis - Setup

if check_abcd == 1
    
else

% Using externalMinorBounds_v2 // embClusterArray2

polyEMB0=1; %row of cell array with diameter value - polyshape
polyEMB1=1; %polyshape - centroid - x co-ordinate
polyEMB2=2; %polyshape - centroid - y co-ordinate
polyEMB3=3; %polyshape - perimeter
polyEMB4=4; %polyshape - area
polyEMB5=5; %slice ID
polyEMB6=6; %cluster ID

diamArrayEMB_Polyshape = zeros((sum(distribution_num_minorBounds_per_embCluster)),6);
for embPolyshape_Count1 = 1:numEMB_Clusters %num clusters
for embPolyshape_Count2 = 1:max(embClusterArray2{1,embPolyshape_Count1}(:,6)) %num minor boundaries in cluster
                    
embRowID=find(embClusterArray2{1,embPolyshape_Count1}(:,6)==embPolyshape_Count2);         
tempArray = embClusterArray2{1,embPolyshape_Count1}(embRowID,1:2);
tempSliceValue = embClusterArray2{1,embPolyshape_Count1}(max(embRowID),3);

pgonVals = tempArray;
pgon=polyshape(pgonVals);
[xc,yc] = centroid(pgon);
diamArrayEMB_Polyshape(polyEMB0,polyEMB1) = xc; %x centroid of polygon
diamArrayEMB_Polyshape(polyEMB0,polyEMB2) = yc; %y centroid of polygon
diamArrayEMB_Polyshape(polyEMB0,polyEMB3) = pgon.perimeter; %perimeter of polygon
diamArrayEMB_Polyshape(polyEMB0,polyEMB4) = pgon.area;  %area of polygon
diamArrayEMB_Polyshape(polyEMB0,polyEMB5) = tempSliceValue; %slice ID
diamArrayEMB_Polyshape(polyEMB0,polyEMB6) = embPolyshape_Count1; %Cluster ID

polyEMB0=polyEMB0+1;
end
end 


%% Part 4.2 - EMB Analysis - Circular Equivalencies

embCountForCircEquiv = size(diamArrayEMB_Polyshape(:,:));
circleEquivVals = zeros(embCountForCircEquiv);
circleEquivVals(:,1) = diamArrayEMB_Polyshape(:,4);

for countforEquivCirle = 1:embCountForCircEquiv(:,1)
radiusOfEquivCircle = (sqrt((circleEquivVals(countforEquivCirle,1))/pi));
diameterOfEquivCircle = radiusOfEquivCircle * 2;
circumferenceOfEquivCircle = (2 * pi * radiusOfEquivCircle);
circleEquivVals(countforEquivCirle,2) = radiusOfEquivCircle;
circleEquivVals(countforEquivCirle,3) = diameterOfEquivCircle;
circleEquivVals(countforEquivCirle,4) = circumferenceOfEquivCircle;
end

diamArrayEMB_Polyshape2 = [diamArrayEMB_Polyshape,circleEquivVals];
diamArrayEMB_Polyshape2(:,7) = [];

for perimeterRatioCount = 1:embCountForCircEquiv(:,1)
    perimeterRatio = ((diamArrayEMB_Polyshape2(perimeterRatioCount,9))/(diamArrayEMB_Polyshape2(perimeterRatioCount,3)));
    diamArrayEMB_Polyshape2(perimeterRatioCount,10) = perimeterRatio;
end

diamArrayEMB_Polyshape2(:,11) = [];

%% Part 4.2.1 - Bounding Box

EMB_BB_Temp_Array = zeros((sum(distribution_num_minorBounds_per_embCluster)),6);
polyEMB_BB = 1;
polyEMB_BB1_1=1;
polyEMB_BB1_2=2;
polyEMB_BB2_1=3;
polyEMB_BB2_2=4;
polyEMB_BB1_3=5;
polyEMB_BB2_3=6;

for embPolyshape_Count1 = 1:numEMB_Clusters %num clusters
for embPolyshape_Count2 = 1:max(embClusterArray2{1,embPolyshape_Count1}(:,6)) %num minor boundaries in cluster
                    
embRowID=find(embClusterArray2{1,embPolyshape_Count1}(:,6)==embPolyshape_Count2);         
tempArray = embClusterArray2{1,embPolyshape_Count1}(embRowID,1:2);
tempSliceValue = embClusterArray2{1,embPolyshape_Count1}(max(embRowID),3);

pgonVals = tempArray;
pgon=polyshape(pgonVals);

[xlimBB,ylimBB] = boundingbox(pgon);

if isempty(xlimBB)==1
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB1_1) = 0;
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB1_2) = 0;
elseif isempty(xlimBB)==0
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB1_1) = xlimBB(1);
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB1_2) = xlimBB(2);
end

if isempty(ylimBB)==1
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB2_1) = 0;
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB2_2) = 0;
elseif isempty(ylimBB)==0
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB2_1) = ylimBB(1);
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB2_2) = ylimBB(2);
end

if isempty(xlimBB)==1
xlimBB_dist = 0;
elseif isempty(xlimBB)==0
xlimBB_dist = xlimBB(2)-xlimBB(1);
end
if isempty(ylimBB)==1
ylimBB_dist = 0;
elseif isempty(ylimBB)==0
ylimBB_dist = ylimBB(2)-ylimBB(1);
end

if isempty(xlimBB)==1
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB1_3) = 0;
elseif isempty(xlimBB)==0
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB1_3) = xlimBB_dist;
end

if isempty(ylimBB)==1
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB2_3) = 0;
elseif isempty(ylimBB)==0
EMB_BB_Temp_Array(polyEMB_BB,polyEMB_BB2_3) = ylimBB_dist;
end

polyEMB_BB = polyEMB_BB + 1;
end
end

%% Part 4.3 - EMB Analysis - Find biggest Diameter per Cluster

maxEMB_DiamPerClusterArray = zeros(1,max(diamArrayEMB_Polyshape2(:,6)));

for maxDiamPerCluster_Count = 1:max(diamArrayEMB_Polyshape2(:,6))
    embRowID2=find(diamArrayEMB_Polyshape2(:,6) == maxDiamPerCluster_Count);         
    maxEMB_DiamVal = max(diamArrayEMB_Polyshape2(embRowID2,9));
    maxEMB_DiamPerClusterArray(1,maxDiamPerCluster_Count) = maxEMB_DiamVal;
end

% Create arrays for ratio between cluster boundary total and cluster height
ratio_EMB_for_boundaries_slices = distribution_num_minorBounds_per_embCluster ./ distribution_height_per_embCluster;

end
%% Part 4.4 - NCB Analysis - Polyshape

if check_efgh == 1
    
else

% Using nonConnectedBounds_v2 // ncbClusterArray2

polyNCB0=1; %row of cell array with diameter value - polyshape
polyNCB1=1; %polyshape - centroid - x co-ordinate
polyNCB2=2; %polyshape - centroid - y co-ordinate
polyNCB3=3; %polyshape - perimeter
polyNCB4=4; %polyshape - area
polyNCB5=5; %slice ID
polyNCB6=6; %cluster ID

diamArrayNCB_Polyshape = zeros((sum(distribution_num_minorBounds_per_ncbCluster)),6);
for ncbPolyshape_Count1 = 1:numNCB_Clusters %num clusters
for ncbPolyshape_Count2 = 1:max(ncbClusterArray2{1,ncbPolyshape_Count1}(:,6)) %num minor boundaries in cluster
                    
ncbRowID=find(ncbClusterArray2{1,ncbPolyshape_Count1}(:,6)==ncbPolyshape_Count2);         
tempArray = ncbClusterArray2{1,ncbPolyshape_Count1}(ncbRowID,1:2);
tempSliceValue = ncbClusterArray2{1,ncbPolyshape_Count1}(max(ncbRowID),3);

pgonVals = tempArray;
pgon=polyshape(pgonVals);
[xc,yc] = centroid(pgon);
diamArrayNCB_Polyshape(polyNCB0,polyNCB1) = xc; %x centroid of polygon
diamArrayNCB_Polyshape(polyNCB0,polyNCB2) = yc; %y centroid of polygon
diamArrayNCB_Polyshape(polyNCB0,polyNCB3) = pgon.perimeter; %perimeter of polygon
diamArrayNCB_Polyshape(polyNCB0,polyNCB4) = pgon.area;  %area of polygon
diamArrayNCB_Polyshape(polyNCB0,polyNCB5) = tempSliceValue; %slice ID
diamArrayNCB_Polyshape(polyNCB0,polyNCB6) = ncbPolyshape_Count1; %Cluster ID
polyNCB0=polyNCB0+1;
end
end   

%% Part 4.5 - NCB Analysis - Circular Equivalencies

ncbCountForCircEquiv = size(diamArrayNCB_Polyshape(:,:));
circleEquivVals = zeros(ncbCountForCircEquiv);
circleEquivVals(:,1) = diamArrayNCB_Polyshape(:,4);

for countforEquivCirle = 1:ncbCountForCircEquiv(:,1)
radiusOfEquivCircle = (sqrt((circleEquivVals(countforEquivCirle,1))/pi));
diameterOfEquivCircle = radiusOfEquivCircle * 2;
circumferenceOfEquivCircle = (2 * pi * radiusOfEquivCircle);
circleEquivVals(countforEquivCirle,2) = radiusOfEquivCircle;
circleEquivVals(countforEquivCirle,3) = diameterOfEquivCircle;
circleEquivVals(countforEquivCirle,4) = circumferenceOfEquivCircle;
end

diamArrayNCB_Polyshape2 = [diamArrayNCB_Polyshape,circleEquivVals];
diamArrayNCB_Polyshape2(:,7) = [];

for perimeterRatioCount = 1:ncbCountForCircEquiv(:,1)
    perimeterRatio = ((diamArrayNCB_Polyshape2(perimeterRatioCount,9))/(diamArrayNCB_Polyshape2(perimeterRatioCount,3)));
    diamArrayNCB_Polyshape2(perimeterRatioCount,10) = perimeterRatio;
end

diamArrayNCB_Polyshape2(:,11) = [];


%% Part 4.6 - NCB Analysis - Find biggest Diameter per Cluster

maxNCB_DiamPerClusterArray = zeros(1,max(diamArrayNCB_Polyshape2(:,6)));

for maxDiamPerCluster_Count = 1:max(diamArrayNCB_Polyshape2(:,6))
    ncbRowID2=find(diamArrayNCB_Polyshape2(:,6) == maxDiamPerCluster_Count);         
    maxNCB_DiamVal = max(diamArrayNCB_Polyshape2(ncbRowID2,9));
    maxNCB_DiamPerClusterArray(1,maxDiamPerCluster_Count) = maxNCB_DiamVal;
end

% Create arrays for ratio between cluster boundary total and cluster height
ratio_NCB_for_boundaries_slices = distribution_num_minorBounds_per_ncbCluster ./ distribution_height_per_ncbCluster;

end

%% Part 5 - 3D Plot Boundaries

%% Part 5.0 - Update majorBounds.

% majorBounds=majorBounds-[mean(majorBounds(~isnan(majorBounds(:,1)),1:2)) 0];
% From BILL, centres 3d view?

%% Part 5.1 - Plot
%figure;
ax = axes(figure);
%ax.View = [90,15];
majorBounds_v2=majorBounds-[mean(majorBounds(~isnan(majorBounds(:,1)),1:2)) 0]; % Centering
plot3(majorBounds_v2(:,2),majorBounds_v2(:,1),majorBounds_v2(:,3),'b')
hold on;

if check_abcd == 1
    
else
cent_MB = mean(majorBounds(~isnan(majorBounds(:,1)),1:3));
externalMinorBounds_v2=externalMinorBounds-[mean(majorBounds(~isnan(majorBounds(:,1)),1:2)) 0];
plot3(externalMinorBounds_v2(:,2),externalMinorBounds_v2(:,1),externalMinorBounds_v2(:,3),'g');

end

%hold on;
%plot3(minorBoundsInternal(:,1),minorBoundsInternal(:,2),minorBoundsInternal(:,3),'g');

if check_efgh == 1
    
else

hold on;
nonConnectedBounds_v2 = nonConnectedBounds-[mean(majorBounds(~isnan(majorBounds(:,1)),1:2)) 0];
plot3(nonConnectedBounds_v2(:,2),nonConnectedBounds_v2(:,1),nonConnectedBounds_v2(:,3),'r');
hold on;

%% Part 5.2 - Update Colours for nonConnected bounds where a cluster exists in the first or last slice

EdgeBottom = 1;
EdgeTop = polyBoundsLength;

for ncbColourChange_Count1 = 1:numNCB_Clusters
    checkForEdgeBottom = ismember(1,ncbClusterArray2{1,ncbColourChange_Count1}(:,3));
    checkForEdgeTop = ismember(polyBoundsLength,ncbClusterArray2{1,ncbColourChange_Count1}(:,3));
    
    if checkForEdgeBottom == 1 || checkForEdgeTop == 1   
    plot3(ncbClusterArray2{1,ncbColourChange_Count1}(:,1),ncbClusterArray2{1,ncbColourChange_Count1}(:,2),ncbClusterArray2{1,ncbColourChange_Count1}(:,3),'m');    
    hold on;
    
end
end

end

%xlim([1,numRows_xAxis]); %full size
%ylim([1,numCols_yAxis]); %full size
%zlim([1,numSlices_zAxis]); %iterate for intended section
%ax = axes(figure);

%express centre of image as centroid of strut.
%ax.DataAspectRatio=[1 1 10];
axis equal
ax.View = [90,0];
axis off
set(gcf,'color','w');


%% Part 5.3 - Plotting via dbScan - Scatter

%{
% View 1

%figure;
ax = axes(figure);

plot3(majorBounds_v2(:,1),majorBounds_v2(:,2),majorBounds_v2(:,3),'b');
hold on;

if check_abcd == 1
   
else
gs1 = gscatter3b(externalMinorBounds_v2(:,1),externalMinorBounds_v2(:,2),externalMinorBounds_v2(:,3),idx1, 'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
end
hold on;

if check_efgh == 1
else
gs3b_2 = gscatter3b(nonConnectedBounds_v2(:,1),nonConnectedBounds_v2(:,2),nonConnectedBounds_v2(:,3),idx2, 'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
end

% xlim([-120 120]);
% ylim([-120 120]);
% zlim([0 1500]);
axis equal
ax.View = [0,0];
axis off
set(gcf,'color','w');
%zlim([0 1500]);

% xlim([1,numRows_xAxis]); %full size
% ylim([1,numCols_yAxis]); %full size
% zlim([1,numSlices_zAxis]); %iterate for intended section
% ax.View = [90,15];

% if check_efgh == 1
%     
% else
% hold on;
% gscatter3b(nonConnectedBounds(:,1),nonConnectedBounds(:,2),nonConnectedBounds(:,3),idx);
% end

% figure;
% plot3(majorBounds(:,1),majorBounds(:,2),majorBounds(:,3),'b');hold on;
% gscatter3b(externalMinorBounds(:,1),externalMinorBounds(:,2),externalMinorBounds(:,3),idx1);

% figure;
% idx = dbscan(nonConnectedBounds,3,5);
% plot3(majorBounds(:,1),majorBounds(:,2),majorBounds(:,3),'b');hold on;
% gscatter3b(nonConnectedBounds(:,1),nonConnectedBounds(:,2),nonConnectedBounds(:,3),idx);


% View 2

%figure;
ax = axes(figure);

plot3(majorBounds(:,1),majorBounds(:,2),majorBounds(:,3),'b');
hold on;

if check_abcd == 1
   
else
gscatter3b(externalMinorBounds(:,1),externalMinorBounds(:,2),externalMinorBounds(:,3),idx1);
end

xlim([1,numRows_xAxis]); %full size
ylim([1,numCols_yAxis]); %full size
zlim([1,numSlices_zAxis]); %iterate for intended section
ax.View = [-90,15];

% if check_efgh == 1
%     
% else
% hold on;
% gscatter3b(nonConnectedBounds(:,1),nonConnectedBounds(:,2),nonConnectedBounds(:,3),idx);
% end

% figure;
% plot3(majorBounds(:,1),majorBounds(:,2),majorBounds(:,3),'b');hold on;
% gscatter3b(externalMinorBounds(:,1),externalMinorBounds(:,2),externalMinorBounds(:,3),idx1);

% figure;
% idx = dbscan(nonConnectedBounds,3,5);
% plot3(majorBounds(:,1),majorBounds(:,2),majorBounds(:,3),'b');hold on;
% gscatter3b(nonConnectedBounds(:,1),nonConnectedBounds(:,2),nonConnectedBounds(:,3),idx);

%}

%% Part 6 - Histogram Generation (PRE_05)

%for both diamArrayEMB_Polyshape2 and diamArrayNCB_Polyshape2:

% For each boundary:

% 01 = X-Centroid for Polyshape
% 02 = Y-Centroid for Polyshape
% 03 = Perimeter for Polyshape
% 04 = Area for Polyshape
% 05 = Slice ID for each boundary
% 06 = Cluster ID for each boundary
% 07 = Radius for Circle (Derived from Polyshape Area)
% 08 = Diameter for Circle (Derived from Polyshape Area)
% 09 = Circumference for Circle (Derived from Polyshape Area)
% 10 = Ratio between Derived Circumference (8) and Calcualted Polyshape
%      Perimeter (4)


%set(gca, 'fontSize', 15)
%set figure size units to intended word output

%Limits
%grid on;
%xlim([0, 1]);

%A=gcf;

%A.Units='centimeters';
%A.Position=[10 10 5.1 2.2];


%% Need to multiply histogram data by mmPerPixelFinal, to get real world measurments
% Dot product for both visualisation outputs and generated histograms?

%% Part 6.1 - Histogram Generation - EMB (PRE_05)

if check_abcd == 1
    
else
 
    % sum(EMB_BB_Temp_Array2 == max(EMB_BB_Temp_Array2))
    
% figure;
% histogram(distribution_num_minorBounds_per_embCluster);
% set(gca, 'fontSize', 25)
% %title('externalMinorBounds - Distribution of Number of Minor Boundaries per Cluster')
% xlim([0,40]);
% xlabel('Number of Minor Boundaries per Cluster')
% ylabel('Number of Clusters')
% 
% % Pixel
% figure;
% histogram(distribution_height_per_embCluster)
% set(gca, 'fontSize', 25)
% %title('externalMinorBounds - Distribution of Height per Cluster')
% xlabel('Height of Cluster (Slice Layers)')
% ylabel('Number of Clusters')
% 
% % Millimeter
% distribution_height_per_embCluster_v2 = distribution_height_per_embCluster .* mmPerPixelFinal;
% figure;
% histogram(distribution_height_per_embCluster_v2)
% set(gca, 'fontSize', 25)
% %title('externalMinorBounds - Distribution of Height per Cluster')
% xlabel('Height of Cluster (mm)')
% ylabel('Number of Clusters')

% Micrometer
% //

% update scaling for histograms
umPerPixel = mmPerPixelFinal * 1000;
distribution_height_per_embCluster_v2 = distribution_height_per_embCluster .* umPerPixel;
edges = [(umPerPixel/2):umPerPixel:(umPerPixel * 100)];
figure;
histogram(distribution_height_per_embCluster_v2, edges)
xlim([0, (umPerPixel*12)])
ylim([0, (umPerPixel*20)])
%set(gca, 'fontSize', 25)
%title('externalMinorBounds - Distribution of Height per Cluster')
% xlabel('Height of Cluster (?m)')
% ylabel('Number of Clusters')
A=gcf;
A.Units='centimeters';
A.Position=[0 0 5 5];

figure;
% histogram(EMB_BB_Temp_Array(:,5))
% xlim([0, 85])
% ylim([0, 120])
% A=gcf;
% A.Units='centimeters';
% A.Position=[0 0 5 5];
% 
% figure;
% histogram(EMB_BB_Temp_Array(:,6))
% A=gcf;
% A.Units='centimeters';
% A.Position=[0 0 5 5];

figure;
umPerPixel = mmPerPixelFinal * 1000;
EMB_BB_Temp_Array2 = EMB_BB_Temp_Array(:,5) .* umPerPixel;
histogram(EMB_BB_Temp_Array2,edges)
xlim([0, (umPerPixel*40)])
ylim([0, (umPerPixel*20)])
A=gcf;
A.Units='centimeters';
A.Position=[0 0 5 5];

figure;
%umPerPixel = mmPerPixelFinal * 1000;
EMB_BB_Temp_Array3 = EMB_BB_Temp_Array(:,6) .* umPerPixel;
histogram(EMB_BB_Temp_Array3,edges)
xlim([0, (umPerPixel*40)])
ylim([0, (umPerPixel*20)])
A=gcf;
A.Units='centimeters';
A.Position=[0 0 5 5];


figure;
% histogram(ratio_EMB_for_boundaries_slices);
% set(gca, 'fontSize', 25)
% %title('nonConnectedBounds - Equiv/Polyshape Perimeter Ratio')
% xlim([0.85, 1.2]);
% xlabel('Ratio Between Cluster Boundary Total and Cluster Height')
% ylabel('Number of Clusters')
% 
% % Pixel
% figure;
% histogram(maxEMB_DiamPerClusterArray);
% set(gca, 'fontSize', 25)
% %title('externalMinorBounds - Max Diameter per Cluster')
% xlabel('Equivalent Circle Diameter (pixels) [Derived from Polyshape Area]')
% ylabel('Number of Clusters')

% Micrometer
umPerPixel = mmPerPixelFinal * 1000;
maxEMB_DiamPerClusterArray_v2 = maxEMB_DiamPerClusterArray .* umPerPixel;
figure;
histogram(maxEMB_DiamPerClusterArray_v2,edges);
% set(gca, 'fontSize', 25)
% %title('externalMinorBounds - Max Diameter per Cluster')
% xlabel('Equivalent Circle Diameter (mm) [Derived from Polyshape Area]')
% ylabel('Number of Clusters')
xlim([0, (umPerPixel * 100)])
ylim([0, (umPerPixel * 7)])
A=gcf;
A.Units='centimeters';
A.Position=[0 0 5 5];

figure;
histogram(diamArrayEMB_Polyshape2(:,10));
% set(gca, 'fontSize', 25)
% %title('externalMinorBounds - Equiv/Polyshape Perimeter Ratio')
% xlabel('Ratio Between Equivalent Circle Circumference and Polyshape Perimeter')
% ylabel('Number of Boundaries')
xlim([0.4, 1])
ylim([0, (umPerPixel * 22)])
A=gcf;
A.Units='centimeters';
A.Position=[0 0 5 5];

end

% //
%% Part 6.2 - Histogram Generation - NCB (PRE_05)

if check_efgh == 1
    
else

figure;
histogram(distribution_num_minorBounds_per_ncbCluster);
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Distribution of Number of Minor Boundaries per Cluster')
xlim([0, 12]);
xlabel('Number of Minor Boundaries per Cluster')
ylabel('Number of Clusters')

% Pixel
figure;
histogram(distribution_height_per_ncbCluster);
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Distribution of Height per Cluster')
xlim([0, 12]);
xlabel('Height of Cluster (Slice Layers)')
ylabel('Number of Clusters')

% Millimeter
distribution_height_per_ncbCluster_v2 = distribution_height_per_ncbCluster .* mmPerPixelFinal;
figure;
histogram(distribution_height_per_ncbCluster_v2);
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Distribution of Height per Cluster')
xlim([0, 12]);
xlabel('Height of Cluster (mm)')
ylabel('Number of Clusters')

figure;
histogram(ratio_NCB_for_boundaries_slices);
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Cluster Boundary/Height Ratio')
xlim([1, 1.2]);
xlabel('Ratio Between Cluster Boundary Total and Cluster Height')
ylabel('Number of Clusters')

% Pixel
figure;
histogram(maxNCB_DiamPerClusterArray);
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Max Diameter per Cluster')
xlabel('Equivalent Circle Diameter (pixels) [Derived from Polyshape Area]')
ylabel('Number of Clusters')

% Millimeter
maxNCB_DiamPerClusterArray_v2 = maxNCB_DiamPerClusterArray .* mmPerPixelFinal;
figure;
histogram(maxNCB_DiamPerClusterArray);
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Max Diameter per Cluster')
xlabel('Equivalent Circle Diameter (mm) [Derived from Polyshape Area]')
ylabel('Number of Clusters')

figure;
histogram(diamArrayNCB_Polyshape2(:,10));
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Equiv/Polyshape Perimeter Ratio')
xlabel('Ratio Between Equivalent Circle Circumference and Polyshape Perimeter')
ylabel('Number of Boundaries')

end

%% Part 6.3 - Volume and Density

cmPerPixel = mmPerPixelFinal / 10;
% Density for Titanium alloy (Ti6Al4V) = 4.43g/cm^3

umPerPixel = mmPerPixelFinal * 1000;

distribution_height_per_embCluster_cm = distribution_height_per_embCluster .* cmPerPixel;
distribution_height_per_ncbCluster_cm = distribution_height_per_ncbCluster .* cmPerPixel;

maxEMB_RadPerClusterArray = maxEMB_DiamPerClusterArray ./ 2;
maxNCB_RadPerClusterArray = maxNCB_DiamPerClusterArray ./ 2;

maxEMB_RadPerClusterArray_um = maxEMB_RadPerClusterArray .* umPerPixel;
maxNCB_RadPerClusterArray_um = maxNCB_RadPerClusterArray .* umPerPixel;

Calc_Vol_EMB_Cluster = ((4/3) .* pi .* (maxEMB_RadPerClusterArray_um .* maxEMB_RadPerClusterArray_um .* maxEMB_RadPerClusterArray_um));
Calc_Vol_NCB_Cluster = ((4/3) .* pi .* (maxNCB_RadPerClusterArray_um .* maxNCB_RadPerClusterArray_um .* maxNCB_RadPerClusterArray_um));

Calc_Mass_EMB_Cluster = Calc_Vol_EMB_Cluster .* 4.43;
Calc_Mass_NCB_Cluster = Calc_Vol_NCB_Cluster .* 4.43;


figure;
histogram(Calc_Vol_EMB_Cluster);
% set(gca, 'fontSize', 25)
% %title('nonConnectedBounds - Max Diameter per Cluster')
% xlabel('Equivalent Volume [Derived from Polyshape Area]')
% ylabel('Number of Clusters')

A=gcf;
A.Units='centimeters';
A.Position=[0 0 5 5];

figure;
histogram(Calc_Vol_NCB_Cluster);
% set(gca, 'fontSize', 25)
% %title('nonConnectedBounds - Max Diameter per Cluster')
% xlabel('Equivalent Volume [Derived from Polyshape Area]')
% ylabel('Number of Clusters')

figure;
histogram(Calc_Mass_EMB_Cluster);
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Max Diameter per Cluster')
xlabel('Calculated Mass [Derived from Polyshape Area]')
ylabel('Number of Clusters')

figure;
histogram(Calc_Mass_NCB_Cluster);
set(gca, 'fontSize', 25)
%title('nonConnectedBounds - Max Diameter per Cluster')
xlabel('Equivalent Volume [Derived from Polyshape Area]')
ylabel('Number of Clusters')


%% Part 6.4 - Extras...

% figure;
% plot(externalMinorBounds(139:160,1),externalMinorBounds(139:160,2),'k');
% xlim([130,140]);
% ylim([148,158]);
% figure;
% xlim([130,140]);
% ylim([148,158]);
% viscircles(circCent,2.95863513635160);

% valsForMax_NCB_Diam = zeros(1,3); % 5th, Mean, 95th
% valsForMax_EMB_Diam = zeros(1,3); % 5th, Mean, 95th
% 
% valsForMax_NCB_Diam(1,1) = prctile(maxNCB_DiamPerClusterArray,5);
% valsForMax_NCB_Diam(1,2) = mean(maxNCB_DiamPerClusterArray);
% valsForMax_NCB_Diam(1,3) = prctile(maxNCB_DiamPerClusterArray,95);
%     
% valsForMax_EMB_Diam(1,1) = prctile(maxEMB_DiamPerClusterArray,5);
% valsForMax_EMB_Diam(1,2) = mean(maxEMB_DiamPerClusterArray);
% valsForMax_EMB_Diam(1,3) = prctile(maxEMB_DiamPerClusterArray,95);
% 
% valsForMax_NCB_Diam_ = valsForMax_NCB_Diam; % 5th, Mean, 95th
% valsForMax_EMB_Diam_65 = valsForMax_EMB_Diam; % 5th, Mean, 95th

%The volume inside a spheroid (of any kind) is 
%{\displaystyle {\frac {4\pi }{3}}a^{2}c\approx 4.19a^{2}c}
%{\displaystyle {\frac {4\pi }{3}}a^{2}c\approx 4.19a^{2}c}. 
%If {\displaystyle A=2a}{\displaystyle A=2a} is the equatorial diameter, 
%and {\displaystyle C=2c}{\displaystyle C=2c} is the polar diameter, 
%the volume is {\displaystyle {\frac {\pi }{6}}A^{2}C\approx 0.523A^{2}C}
%{\displaystyle {\frac {\pi }{6}}A^{2}C\approx 0.523A^{2}C}.


%% Part 7 - Conduct based on z-limits defined in 4.2

% Step 1 - Remove NaNs

% diamArrayEMB_Polyshape3 = diamArrayEMB_Polyshape2;
% diamArrayNCB_Polyshape3 = diamArrayNCB_Polyshape2;
% 
% plyshp3_EMB_NaN1 = isnan(diamArrayEMB_Polyshape3(:,1)) ;
% plyshp3_NCB_NaN1 = isnan(diamArrayNCB_Polyshape3(:,1)) ;
% 
% plyshp3_EMB_NaN2 = isnan(diamArrayEMB_Polyshape3(:,10)) ;
% plyshp3_NCB_NaN2 = isnan(diamArrayNCB_Polyshape3(:,10)) ;
% 
% plyshp3_EMB_1 = plyshp3_EMB_NaN1 & plyshp3_EMB_NaN2;   
% plyshp3_NCB_1 = plyshp3_NCB_NaN1 & plyshp3_NCB_NaN2;
% 
% diamArrayEMB_Polyshape3(plyshp3_EMB_1,:) = [];
% diamArrayNCB_Polyshape3(plyshp3_NCB_1,:) = [];

% Step 2 - Define Lower and Upper Bounds

% plyshp3_EMB_NaN3 = (diamArrayEMB_Polyshape3(:,5) < 395);
% plyshp3_NCB_NaN3 = (diamArrayNCB_Polyshape3(:,5) < 395);
% 
% diamArrayEMB_Polyshape3(plyshp3_EMB_NaN3,:) = [];
% diamArrayNCB_Polyshape3(plyshp3_NCB_NaN3,:) = [];
% 
% plyshp3_EMB_NaN4 = (diamArrayEMB_Polyshape3(:,5) > 495);
% plyshp3_NCB_NaN4 = (diamArrayNCB_Polyshape3(:,5) > 495);
% 
% diamArrayEMB_Polyshape3(plyshp3_EMB_NaN4,:) = [];
% diamArrayNCB_Polyshape3(plyshp3_NCB_NaN4,:) = [];

%% Functions
function [imgStack,imgStackInfo]=readBinaryImgStack(fldr,imgType)
imgStackInfo=dir(fullfile(fldr,['*.',erase(imgType,'.')]));
% Get first image
firstImage=imread([imgStackInfo(1).folder,filesep,imgStackInfo(1).name]);
numImgs=length(imgStackInfo);
imgSize=size(firstImage);
imgStack=zeros(imgSize(1),imgSize(2),numImgs);

for i=1:numImgs
    imgStack(:,:,i)=imread(fullfile(imgStackInfo(i).folder,imgStackInfo(i).name));
end
end

function polyBounds=getAllboundaries(imageStack,sz)
polyBounds=cell(sz,4);
for j=1:sz
%parfor j=1:sz
    [B,L,n,A]=bwboundaries(imageStack(:,:,j));
    curPolyBounds={B,L,n,A};
    polyBounds(j,:)=curPolyBounds;
end
end

function bounds=getBoundaryVals(polyBounds,CC,largestConnCompID)
numSlices=size(polyBounds,1);
bounds=table('Size',[numSlices 4],'VariableNames',{'MajorBound','MinorBoundsInternal','MinorBoundsExternal','NonConnectedBound'},'VariableTypes',...
    {'cell','cell','cell','cell'});
%% Largest CC
[r,c,h] = ind2sub(CC.ImageSize,CC.PixelIdxList{largestConnCompID});
for i=1:numSlices
    % Find Largest Boundary
    [~,largestBoundaryID]=max(cellfun(@(x) length(x),polyBounds{i,1}));
    if ~isempty(largestBoundaryID)
    majBound=polyBounds{i,1}{largestBoundaryID};
    [in,on]=inpolygon(r(h==i),c(h==i),majBound(:,1),majBound(:,2));
    if sum(in)>1 || sum(on)>1
        bounds.MajorBound(i)={[majBound ones(size(majBound,1),1)*i; NaN NaN NaN]};
    end
    %% Minor Boundary Checks
    for j=find((1:length(polyBounds{i,1}))~=largestBoundaryID)
        %% Minor Bound
        minorBound=polyBounds{i,1}{j};
        %% Minor Bound Type
        in=inpolygon(minorBound(:,1),minorBound(:,2),majBound(:,1),majBound(:,2));
        if sum(in)>1
            bounds.MinorBoundsInternal(i)={[bounds.MinorBoundsInternal{i};NaN NaN NaN;[minorBound ones(size(minorBound,1),1)*i]]};
        else
            largestCompX=r(h==i);
            largestCompY=c(h==i);
            [in,on]=inpolygon(largestCompX,largestCompY,minorBound(:,1),minorBound(:,2));
            if sum(in)<1 || sum(on)<1
                 bounds.NonConnectedBound(i)={[boun
