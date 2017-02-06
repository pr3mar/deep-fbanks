function clean_MSRC(msrcDir)

    classes = {'building', 'grass', 'tree', 'cow', ...
      'horse', 'sheep', 'sky', 'mountain', 'aeroplane', 'water', 'face', ...
      'car', 'bicycle', 'flower', 'sign', 'bird', 'book', 'chair', 'road', ...
      'cat', 'dog', 'body', 'boat', 'other'};
  
    classColours = [
      0     0	0
      128	0	0
      0     128	0
      128	128	0
      0     0	128
      128	0	128
      0     128	128
      128	128	128
      64	0	0
      192	0	0
      64	128	0
      192	128	0
      64	0	128
      192	0	128
      64	128	128
      192	128	128
      0     64	0
      128	64	0
      0     192	0
      128	64	128
      0     192	128
      128	192	128
      64	64	0
      192	64	0
      255 255 255] ;

    inUse = true(1, numel(classes));
    inUse([1, 2, 3, 7, 8, 10, 11, 14, 15, 17, 19, 22]) = 0;

    numClass = length(classes);
    gtDir = fullfile(msrcDir, 'gt');
    gt_img_names = dir(fullfile(gtDir, '*.bmp'));
    gt_img_names = {gt_img_names.name};
    
    imDir = fullfile(msrcDir, 'images');
    img_names = dir(fullfile(imDir, '*.bmp'));
    img_names = {img_names.name};
    
    segmDir = fullfile(msrcDir, 'segm', 'mcg');
    segm_names = dir(fullfile(segmDir, '*.png'));
    segm_names = {segm_names.name};
    
    keep_pure = {};

    for i = 1:numel(gt_img_names)
        gt_fname = gt_img_names{i};
        mask = imread(fullfile(gtDir, gt_fname));
        [~, labels] = ismember(reshape(mask, [], 3), classColours, 'rows') ;
        labels = uint16(reshape(labels, size(mask,1), size(mask,2))) - 1 ;
        diff = setdiff(unique(labels(:))', [0 find(~ inUse)]);
        if isempty(diff)
            delete(fullfile(gtDir, gt_fname));
        else
            [~, pure_name, ~] = fileparts(gt_fname);
            keep_pure{end + 1} = pure_name(1:end-3);
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
        pure_fname = pure_fname(1:end - 4);
        member = ismember(keep_pure, pure_fname);
        id_member = find(member);
        if isempty(id_member)
            delete(fullfile(segmDir, segm_fname));
        end
    end
end