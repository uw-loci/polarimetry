
function AddROIparent(image_name, image_path, child_ROI,parent_ROI)

% add ROI parent field
% create sub ROI files for parent ROI
% Input:
% image_name: name of the original image
% image_path: path to the orignian image
% child_ROI: child_ROI list, ROI has to be rectangle with
% parent_ROI: parent_ROI list  % all parent ROIs are separate rectangles
%%
clc,home,clear
image_name = 'C2-MAX_Paired WP2.tif';
image_path = 'D:\data\Adam and Machael\ROIs for Yuming';
child_ROI = 1:20;
parent_ROI = 21:30;
[~,image_name_NE] = fileparts(image_name);      % name without extension information
ROI_mat_orignal = [image_name_NE '_ROIs.mat'];  % original ROI mat file
ROI_folder = fullfile(image_path,'ROI_management');
parent_ROI_folder = fullfile(image_path,'ROI_management','Cropped');
parent_ROI_management = fullfile(parent_ROI_folder,'ROI_management');

if ~exist(parent_ROI_management,'dir')
    mkdir(parent_ROI_management)
    fprintf('Folder created: %s \n',parent_ROI_management)
else
    fprintf ('Folder exists: %s \n',parent_ROI_management)
end

%% crop the parent ROI
if exist(fullfile(ROI_folder,ROI_mat_orignal),'file')
    load(fullfile(ROI_folder,ROI_mat_orignal),'separate_rois');
    if isempty(separate_rois)
        error(sprintf('No ROI defined in the %s',ROI_mat_orignal));
    end
    ROInames = fieldnames(separate_rois);
    s_roi_num = length(ROInames);
    IMGnamefull = fullfile(image_path,image_name);
    IMGinfo = imfinfo(IMGnamefull);
    numSections = numel(IMGinfo); % number of sections
    if numSections == 1
        IMG = imread(IMGnamefull);
        fprintf('%s is loaded \n',IMGnamefull');
    elseif numSections > 1
        IMG = imread(IMGnamefull,1);
        fprintf('only the first slice of the stack is loaded \n')
    end
    i = 0;
    xmin_parent = nan(length(parent_ROI),1);
    ymin_parent = nan(length(parent_ROI),1);
    xmax_parent = nan(length(parent_ROI),1);
    ymax_parent = nan(length(parent_ROI),1);
    for k = parent_ROI
        i = i + 1;
        ROIshape_ind = separate_rois.(ROInames{k}).shape;
        if ROIshape_ind == 1   % use cropped ROI image
            ROIcoords=separate_rois.(ROInames{k}).roi;
            a=ROIcoords(1);b=ROIcoords(2);c=ROIcoords(3);d=ROIcoords(4);
            xmin_parent(i) = a;
            ymin_parent(i) = b;
            xmax_parent(i) = a+c-1;
            ymax_parent(i) = b+d-1;
            % add exception handling
            if a< 1 || a+c-1> size(IMG,2)||b < 1 || b+d-1 > size(IMG,1)
                disp(sprintf('%s of %s is out of range, and is skipped',ROInames{k},fileName{i}))
                break
            end
            ROIimg = [];
            if size(IMG,3) == 1
                ROIimg = IMG(b:b+d-1,a:a+c-1);
            else
                ROIimg = IMG(b:b+d-1,a:a+c-1,:);
            end
            xc = round(a+c/2); yc = round(b+d/2);
            imagename_crop = fullfile(parent_ROI_folder,sprintf('%s_%s.tif',image_name_NE,ROInames{k}));
            parent_ROI_mat{i} = fullfile(parent_ROI_management,[image_name_NE '_' ROInames{k} '_ROIs.mat']);
            imwrite(ROIimg,imagename_crop);
            fprintf('%2d/%2d, %s is cropped \n',i,length(parent_ROI),ROInames{k})
            
        else
            error('Cropped image ROI analysis for shapes other than rectangle is not availabe so far')
        end
    end
    if s_roi_num ==1
        fprintf(' %d ROI was cropped amd saved in %s \n', i,parent_ROI_folder);
    elseif  s_roi_num > 1
        fprintf(' %d ROIs were cropped and saved in %s \n', i,parent_ROI_folder)
    end
end

%% find the parent_ROI for each child_ROI
child_parent_table = nan(length(child_ROI),2);
i = 0;
for k = child_ROI
    match_flag = 0;
    i = i + 1;
    child_ROI_name = ROInames{k};
    ROI_bounding = separate_rois.(ROInames{k}).enclosing_rect;
    xmin_child = ROI_bounding(1);
    ymin_child = ROI_bounding(2);
    xmax_child = ROI_bounding(3)-1;
    ymax_child = ROI_bounding(4)-1;
    % if the bounding rectangle of a child_ROI is within a parent ROI, then
    % the parent ROI is found
    % if none of the cmp_corner values is less than 0, then the parent ROI is found
    for j = 1:length(parent_ROI)
        cmp_corner = [xmin_child ymin_child xmax_parent(j) ymax_parent(j)]-[xmin_parent(j) ymin_parent(j) xmax_child ymax_child];
        if isempty(find(cmp_corner < 0))
            parent_ROI_name = ROInames{parent_ROI(j)};
            child_parent_table(k,1) = k;
            child_parent_table(k,2) = parent_ROI(j);
            match_flag = 1;
            fprintf('%5d: %s has a parent named %s  \n',i, child_ROI_name,parent_ROI_name)
            break
        end
    end
    if match_flag == 0
        fprintf('%5d: No parent ROI is found for %s \n',i, child_ROI_name)
    end
end

%% convert the globle ROI coordinate to sub-ROI coordinates
% rename the original ROI mat data
 separate_rois_ORI = separate_rois;
 clear separate_rois;
 i = 0;
 for j = parent_ROI
     i = i + 1;
     if exist(parent_ROI_mat{i},'file')
         load(parent_ROI_mat{i},'separate_rois')
     else
         separate_rois = [];
         save(parent_ROI_mat{i},'separate_rois')
     end
     
     childID = find(child_parent_table(:,2) == j);
     if isempty (childID)
         fprintf('%2d/%2d: %s does not have any child ROI \n', i,length(parent_ROI),ROInames{j})
     else
         child_number = length(childID);
         fprintf('%2d/%2d: %s has %2d child ROI(s) \n', i,length(parent_ROI),ROInames{j},child_number)
         for k = 1:child_number
             fieldname  = ROInames{childID(k)};
             roi_shape = separate_rois_ORI.(fieldname).shape;
             if roi_shape == 1
                 % convert roi
                 convert_roi = separate_rois_ORI.(fieldname).roi;
                 convert_roi(1) = convert_roi(1)-xmin_parent(i);
                 convert_roi(2) = convert_roi(2)-ymin_parent(i);
                 separate_rois.(fieldname).roi = convert_roi;
                 % covert bounding rectangle
                 convert_boundingRECT = separate_rois_ORI.(fieldname).enclosing_rect;
                 convert_boundingRECT([1 3]) = convert_boundingRECT([1 3])- xmin_parent(i);
                 convert_boundingRECT([2 4]) = convert_boundingRECT([2 4])- ymin_parent(i);
                 separate_rois.(fieldname).enclosing_rect = convert_boundingRECT;
                 % convert the center point
                 separate_rois.(fieldname).xm = separate_rois_ORI.(fieldname).xm - ymin_parent(i); % x y flip
                 separate_rois.(fieldname).ym = separate_rois_ORI.(fieldname).ym - xmin_parent(i); % x y flip
                 %convert boundary coordinates
                 convert_boundary = separate_rois_ORI.(fieldname).boundary{1};
                 convert_boundary(:,1) = convert_boundary(:,1) - ymin_parent(i);
                 convert_boundary(:,2) = convert_boundary(:,2) - xmin_parent(i);
                 separate_rois.(fieldname).boundary{1} = convert_boundary;
                 date_time = fix(clock);
                 date_now = [num2str(date_time(2)) '-' num2str(date_time(3)) '-' num2str(date_time(1))] ;% saves 20 dec 2014 as 12-20-2014
                 separate_rois.(fieldname).date=date;
                 time_now = [num2str(date_time(4)) ':' num2str(date_time(5)) ':' num2str(uint8(date_time(6)))]; % saves 11:50:32 for 1150 hrs and 32 seconds
                 separate_rois.(fieldname).time = time_now;
                 separate_rois.(fieldname).shape = roi_shape;
             else
                 error('Child ROI must be rectangular shape')
             end
         end % child_number
     end % childID
     save(parent_ROI_mat{i},'separate_rois','-append');
 end

