function [ imdb ] = coco_get_database( cocoDir )
%GET_COCO_DATABASE Summary of this function goes here
%   Detailed explanation goes here
    imdb = {};
    imdb.imageDir = fullfile(cocoDir, 'images');
    imdb.gtDir = fullfile(cocoDir, 'gt');
    imdb.maskDir = fullfile(cocoDir, 'masks');
    imdb.segmDir = fullfile(cocoDir, 'segm');
    imdb.meta.classes = {'person', 'bicycle', 'car', 'motorcycle', 'airplane', ...
        'bus', 'train', 'truck', 'boat', 'traffic light', 'fire hydrant', ...
        'stop sign', 'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse', ...
        'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', 'backpack', 'umbrella', ...
        'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball', 'kite', ...
        'baseball bat', 'baseball glove', 'skateboard', 'surfboard', 'tennis racket', 'bottle', ...
        'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple', 'sandwich', 'orange', ...
        'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch', 'potted plant', 'bed', ...
        'dining table', 'toilet', 'tv', 'laptop', 'mouse', 'remote', 'keyboard', 'cell phone', 'microwave', 'oven', ...
        'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier', 'toothbrush'};
    imdb.meta.superclasses = {'food', 'kitchen', 'electronic', 'accessory', 'indoor', 'sports', 'appliance', 'vehicle', 'outdoor', 'furniture', 'person', 'animal'};
    imdb.meta.classID = [1 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 27 28 31 32 33 34 35 36 37 38 39 40 41 42 43 44 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 67 70 72 73 74 75 76 77 78 79 80 81 82 84 85 86 87 88 89 90];
    % NOTE: access real class as: 
    % imdb.meta.classes(find(imdb.meta.classID == 16))
%     numel(imdb.classes)
%     numel(imdb.superclasses)
    imdb.meta.inUse = true(1, numel(imdb.meta.classes));
    imNames = dir(fullfile(imdb.imageDir, '*.jpg'));
    imdb.images.name = {imNames.name};
    imdb.images.id = 1:numel(imdb.images.name);
    imNames = dir(fullfile(imdb.maskDir, '*.png'));
    imdb.segments.seg_name = {imNames.name};
    imdb.segments.mask = imdb.segments.seg_name;
    imdb.segments.id = [];
    imdb.segments.imageId = [];
    imdb.segments.label = [];
    imNames = [imdb.images.name];
    for ii = 1 : numel(imdb.segments.seg_name)
        [~, imName, ~] = fileparts(imdb.segments.seg_name{ii});
        splitted = strsplit(imName, '_');
        im_name = strcat(splitted{1}, '.jpg');
        imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id);
        imdb.segments.imageId(end + 1) = find(strcmp(imNames, im_name));
        imdb.segments.label(end + 1) = find(imdb.meta.classID == str2double(splitted{2}));
    end
    
    imdb.meta.sets = {'train', 'val', 'test'};
    imdb.images.set = ones(1, numel(imdb.images.name));
    imdb.segments.set = ones(1, numel(imdb.segments.id));
    imdb.segments.difficult = false(1, numel(imdb.segments.id));
end

