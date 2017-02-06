function clean_VOC(vocDir)

    classes ={...
        'aeroplane' % !
        'bicycle' % !
        'bird' % !
        'boat' % !
        'bottle' % 5
        'bus' % 6
        'car' % !
        'cat' % !
        'chair' % !
        'cow' % !
        'diningtable' % 11
        'dog' % !
        'horse' % !
        'motorbike' % 14
        'person' % 15
        'pottedplant' % 16
        'sheep' % !
        'sofa' % 18
        'train' % 19
        'tvmonitor' % 20
        'other' %!
    };
    inUse = true(1,numel(classes));
    inUse([5, 6, 11, 14, 15, 16, 18, 19, 20]) = false;

    numClass = length(classes);
    gtDir = fullfile(vocDir, 'gt');
    gt_img_names = dir(fullfile(gtDir, '*.png'));
    gt_img_names = {gt_img_names.name};
    
    imDir = fullfile(vocDir, 'JPEGImages');
    img_names = dir(fullfile(imDir, '*.jpg'));
    img_names = {img_names.name};
    
    segmDir = fullfile(vocDir, 'segm', 'mcg');
    segm_names = dir(fullfile(segmDir, '*.png'));
    segm_names = {segm_names.name};
    
    keep_pure = {};

    for i = 1:numel(gt_img_names)
        gt_fname = gt_img_names{i};
        labels = imread(fullfile(gtDir, gt_fname));
        diff = setdiff(unique(labels(:))', [0, 255, find(~inUse)]);
        if isempty(diff)
            delete(fullfile(gtDir, gt_fname));
        else
            [~, pure_name, ~] = fileparts(gt_fname);
            keep_pure{end + 1} = pure_name;
        end
       
    end
    
    for i = 1:numel(img_names)
        im_fname = img_names{i};
        [~, pure_fname] = fileparts(im_fname);
        member = ismember(keep_pure, pure_fname);
        id_member = find(member);
        if isempty(id_member)
            delete(fullfile(imDir, im_fname));
        end
    end
    
    for i = 1:numel(segm_names)
        segm_fname = segm_names{i};
        [~, pure_fname] = fileparts(segm_fname);
        pure_fname = strsplit(pure_fname, '_');
        member = ismember(keep_pure, pure_fname{1});
        id_member = find(member);
        if isempty(id_member)
            delete(fullfile(segmDir, segm_fname));
        end
    end
end