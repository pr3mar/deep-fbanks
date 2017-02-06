function [ imdb ] = msrc_voc_get_database_nobg( msrcVocDir, varargin )
    vl_xmkdir(fullfile(msrcVocDir, 'masks')) ;

    msrc_imdb = msrc_c_get_database_nobg(msrcVocDir);
    voc_imdb = sample_voc_get_database_nobg(msrcVocDir, ...
            'labelDir', fullfile(msrcVocDir, 'labels_voc'), ...
            'imageDir', 'images', ...
            'maskDir', 'masks', ...
            'beginImId', numel(msrc_imdb.images.id) + 1, ...
            'endImId', numel(msrc_imdb.images.id), ...
            'segIdOffset', numel(msrc_imdb.segments.id) + 1);
    
    msrc_imdb
    voc_imdb
    
    % mapping from voc to msrc dataset
    msrc_classes = find(msrc_imdb.meta.inUse) ;
    voc_classes  = find(voc_imdb.meta.inUse) ;
%     msrc_voc_classes = zeros(1, numel(msrc_classes));
    voc_msrc_classes = zeros(1, numel(voc_classes));
    for i = 1:numel(msrc_classes)
%         id = ismember(msrc_imdb.meta.classes, voc_imdb.meta.classes(msrc_classes(i)));
%         msrc_voc_classes(i) = find(id);
        id = ismember(voc_imdb.meta.classes, msrc_imdb.meta.classes(msrc_classes(i)));
        voc_msrc_classes(i) = find(id);
    end
    msrc_seg_labels = msrc_imdb.segments.label;
    % remap msrc dataset classes to voc dataset classes
    for i = 1 : numel(msrc_classes)
%         msrc_imdb.images.label(msrc_imdb.images.label == msrc_classes(i)) = msrc_voc_classes(i);
        msrc_seg_labels(msrc_seg_labels == msrc_classes(i)) = voc_msrc_classes(i) + 1000;
    end
    msrc_seg_labels = msrc_seg_labels - 1000;
    msrc_imdb.segments.label = msrc_seg_labels;
    % building the merged imdb object
    imdb = {};
    imdb.imageDir = msrc_imdb.imageDir;
    imdb.gtDir = msrc_imdb.gtDir;
    imdb.maskDir = msrc_imdb.maskDir;
    imdb.segmDir = msrc_imdb.segmDir;
    imdb.meta = voc_imdb.meta;

    imdb.images = {};
    imdb.images.name = [msrc_imdb.images.name voc_imdb.images.name];
    imdb.images.gt_name = [msrc_imdb.images.gt_name voc_imdb.images.gt_name];
    imdb.images.id = [msrc_imdb.images.id voc_imdb.images.id];
    imdb.images.set = [msrc_imdb.images.set voc_imdb.images.set];
    
    imdb.segments = {};
    imdb.segments.id = [msrc_imdb.segments.id voc_imdb.segments.id];
    imdb.segments.imageId = [msrc_imdb.segments.imageId voc_imdb.segments.imageId];
    imdb.segments.set = [msrc_imdb.segments.set voc_imdb.segments.set];
    imdb.segments.label = [msrc_imdb.segments.label voc_imdb.segments.label];
    imdb.segments.mask = [msrc_imdb.segments.mask voc_imdb.segments.mask];
    imdb.segments.difficult = false(1, numel(imdb.segments.imageId));
    
end

