% exclude the images with only background class!
function imdb = sample_voc_get_database_nobg(vocSampleNoBGDir, varargin)
opts.seed = 1 ;
opts.labelDir = fullfile(vocSampleNoBGDir, 'ImageSets', 'Segmentation');
opts.imageDir = 'JPEGImages';
opts.maskDir = 'Masks';
opts.beginImId = 1;
opts.endImId = 0;
opts.segIdOffset = 0;
opts = vl_argparse(opts, varargin) ;

assert(opts.seed == 1) ; % there is only one split

imdb.imageDir = fullfile(vocSampleNoBGDir, opts.imageDir) ;
imdb.maskDir = fullfile(vocSampleNoBGDir, opts.maskDir); % doesn't exist
imdb.segmDir = fullfile(vocSampleNoBGDir, 'segm');
imdb.gtDir = fullfile(vocSampleNoBGDir, 'gt');
imdb.classes.name={...
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
numClass = length(imdb.classes.name);

% make this compatible with the OS imdb
imdb.meta.classes = imdb.classes.name;
imdb.meta.inUse = true(1,numel(imdb.meta.classes));
imdb.meta.inUse([5, 6, 11, 14, 15, 16, 18, 19, 20]) = false;

% source images
imageFiles = dir(fullfile(imdb.imageDir, '*.jpg'));
imdb.images.name = {imageFiles.name};
gtFiles = dir(fullfile(imdb.gtDir, '*.png'));
imdb.images.gt_name = {gtFiles.name};
numImages = length(imdb.images.name);

imdb.images.label = 1:numImages;
imdb.images.set = ones(1, numImages);
imdb.images.id = opts.beginImId:numImages + opts.endImId;
imdb.images.vocid = cellfun(@(S) S(1:end-4), imdb.images.name, 'UniformOutput', false);
imageSets = {'train', 'val', 'test'};

for s = 1:length(imageSets)
  imageSetPath = fullfile(opts.labelDir, sprintf('%s.txt',imageSets{s}));
  gtids = textread(imageSetPath,'%s');
  [membership, loc] = ismember(gtids, imdb.images.vocid);
  loc = loc(membership);
  imdb.images.set(loc) = s;
end

% Write out the segments
% imdb.segments = imdb.images;
imdb.segments.id = [];
imdb.segments.imageId = [];
imdb.segments.label = [];
imdb.segments.mask = {};
imdb.segments.name = {};
imdb.segments.set = [];

[~, id_other] = ismember(imdb.meta.classes, 'other');
id_other = find(id_other);

for ii = 1 : numel(imdb.images.gt_name)
    gt_fname = imdb.images.gt_name{ii};
    gt_fname = fullfile(imdb.gtDir, gt_fname);
    labels = imread(gt_fname);
    if 0
        figure(1) ; clf ;
        subplot(1,2,1) ; imagesc(imread(fullfile(imdb.imageDir, imdb.images.name{ii}))) ; axis equal ;
        subplot(1,2,2) ; imagesc(labels) ; axis equal ;
        drawnow ;
    end
%     all_classes = zeros(size(labels));
    other = zeros(size(labels));
    for c = setdiff(unique(labels(:))', [0, 255, find(~imdb.meta.inUse)])
        imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id) + opts.segIdOffset;
        imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
        imdb.segments.set(end + 1) = imdb.images.set(ii);
        imdb.segments.label(end + 1) = c ;
        [~, imName, ~] = fileparts(imdb.images.name{ii});
        crtSegName = sprintf('%s_%d.png', imName, c);
        imdb.segments.mask{end + 1} = crtSegName ;
        imdb.segments.name{end + 1} = crtSegName;
        other = other | (labels == c);
%         all_classes(labels == c) = c;
        imwrite(labels == c, fullfile(imdb.maskDir, crtSegName));
    end
    imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id) + opts.segIdOffset;
    imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
    imdb.segments.label(end + 1) = id_other ;
    imdb.segments.set(end + 1) = imdb.images.set(ii);
    [~, imName, ~] = fileparts(imdb.images.name{ii});
    crtSegName = sprintf('%s_%d.png', imName, id_other);
    imdb.segments.mask{end + 1} = crtSegName ;
    imdb.segments.name{end + 1} = crtSegName;
    imwrite(~other, fullfile(imdb.maskDir, crtSegName));
%     all_classes(~other) = id_other;
%     imwrite(all_classes, fullfile(imdb.maskDir, imdb.images.gt_name{ii}));
end

imdb.segments.difficult = false(1, numel(imdb.segments.id)) ;

