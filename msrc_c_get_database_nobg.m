function imdb = msrc_c_get_database_nobg(msrcDirNOBG, argin)

vl_xmkdir(fullfile(msrcDirNOBG, 'masks')) ;

imdb.imageDir = fullfile(msrcDirNOBG, 'images');
imdb.gtDir = fullfile(msrcDirNOBG, 'gt');
imdb.maskDir = fullfile(msrcDirNOBG, 'masks');
imdb.segmDir = fullfile(msrcDirNOBG, 'segm');
imdb.meta.classes = {'building', 'grass', 'tree', 'cow', ...
  'horse', 'sheep', 'sky', 'mountain', 'aeroplane', 'water', 'face', ...
  'car', 'bicycle', 'flower', 'sign', 'bird', 'book', 'chair', 'road', ...
  'cat', 'dog', 'body', 'boat', 'other'};
imdb.meta.classColours = [
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

imdb.meta.inUse = true(1, numel(imdb.meta.classes));
imdb.meta.inUse([1, 2, 3, 7, 8, 10, 11, 14, 15, 17, 19, 22]) = 0;

imNames = dir(fullfile(imdb.imageDir, '*.bmp'));
imdb.images.name = {imNames.name};
imdb.images.id = 1:numel(imdb.images.name);

imNames = dir(fullfile(imdb.gtDir, '*.bmp'));
imdb.images.gt_name = {imNames.name};

% imdb.images.vocid = cellfun(@(S) S(1:end-4), imdb.images.name, 'UniformOutput', false);

imdb.segments.id = [];
imdb.segments.imageId = [];
imdb.segments.set = [];
imdb.segments.label = [];
imdb.segments.mask = {};

[~, id_other] = ismember(imdb.meta.classes, 'other');
id_other = find(id_other);

for ii = 1 : numel(imdb.images.name)
  mask = imread(fullfile(imdb.gtDir, imdb.images.gt_name{ii}));
  [~, labels] = ismember(reshape(mask, [], 3), imdb.meta.classColours, 'rows') ;
  labels = uint16(reshape(labels, size(mask,1), size(mask,2))) - 1 ;
  if 0
    figure(1) ; clf ;
    subplot(1,2,1) ; imagesc(imread(fullfile(imdb.imageDir, imdb.images.name{ii}))) ; axis equal ;
    subplot(1,2,2) ; image(labels) ; colormap(imdb.meta.classColours/256) ; axis equal ;
    drawnow ;
  end
  [~, imName, ~] = fileparts(imdb.images.name{ii});
  other = zeros(size(labels));
  for c = setdiff(unique(labels(:))', [0 find(~imdb.meta.inUse)])
    imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id);
    imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
    imdb.segments.label(end + 1) = c ;
    crtSegName = sprintf('%s_%d.png', imName, c);
    imdb.segments.mask{end + 1} = crtSegName ;
    other = other | (labels == c);
    imwrite(labels == c, fullfile(imdb.maskDir, crtSegName));
  end
  imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id);
  imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
  imdb.segments.label(end + 1) = id_other ;
  crtSegName = sprintf('%s_%d.png', imName, id_other);
  imdb.segments.mask{end + 1} = crtSegName ;
  imwrite(~other, fullfile(imdb.maskDir, crtSegName));
%   imwrite(labels, fullfile(imdb.maskDir, [imName '.png']));
end

% split images in train, val, test
imdb.meta.sets = {'train', 'val', 'test'};
imdb.images.set = ones(1, numel(imdb.images.name));
imdb.segments.set = ones(1, numel(imdb.segments.id));

for ii = 1 : numel(imdb.meta.sets)
  fid = fopen(fullfile(msrcDirNOBG, 'labels', [imdb.meta.sets{ii} '.txt']));
  if (fid > 0)
    lines = textscan(fid, '%s');
    fclose(fid);
    [lia, ~] = ismember(imdb.images.name, lines{1});
    imdb.images.set(lia) = ii;
    [lia, ~] = ismember(imdb.segments.imageId, imdb.images.id(lia));
    imdb.segments.set(lia) = ii;
  end
end


% imdb.segments.set = ones(1, numel(imdb.segments.id)) * 3;

imdb.segments.difficult = false(1, numel(imdb.segments.id)) ;
