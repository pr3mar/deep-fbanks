% with a lot of background images.
function imdb = sample_voc_get_database(vocSampleDir, varargin)
opts.seed = 1 ;
opts = vl_argparse(opts, varargin) ;

assert(opts.seed == 1) ; % there is only one split

imdb.imageDir = fullfile(vocSampleDir, 'JPEGImages') ;
imdb.maskDir = fullfile(vocSampleDir, 'Masks'); % doesn't exist
imdb.segmDir = fullfile(vocSampleDir, 'segm');
imdb.gtDir = fullfile(vocSampleDir, 'gt');
imdb.classes.name={...
  'cat'
  'bird'
  'aeroplane'
  'car'
  'cow'
  'horse'
  'bicycle'
  'dog'
  'chair'
  'boat'
  'sheep'
  'other'
 };
imdb.classes.colors = [
    0 0 0
    64 0 0 % cat
    128 128 0 % bird
    128 0 0 % aeroplane
    128 128 128 % car
    64 128 0 % cow
    192 0 128 % horse
    0 128 0 % bicycle
    64 0 128 % dog
    192 0 0 % chair
    0 0 128 % boat
    128 64 0 % sheep
    255 255 255 % other
];
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

% source images
imageFiles = dir(fullfile(imdb.imageDir, '*.jpg'));
imdb.images.name = {imageFiles.name};
gtFiles = dir(fullfile(imdb.gtDir, '*.png'));
imdb.images.gt_name = {gtFiles.name};
numImages = length(imdb.images.name);

imdb.images.label = 1:numImages;
imdb.images.set = ones(1, numImages);
imdb.images.id = 1:numImages;
imdb.images.vocid = cellfun(@(S) S(1:end-4), imdb.images.name, 'UniformOutput', false);
imageSets = {'train', 'val', 'test'};

% Loop over images and record the image sets
for c = 1:(numClass - 1)
  for s = 1:length(imageSets)
    imageSetPath = fullfile(vocSampleDir, 'ImageSets', 'Main', sprintf('%s_%s.txt', imdb.classes.name{c}, imageSets{s}));
    [gtids,gt] = textread(imageSetPath,'%s %d');
    [membership, loc] = ismember(gtids, imdb.images.vocid);
    assert(all(membership));
    imdb.images.label_bin(c, loc) = gt ;
  end
end

% imdb.images.label_bin
% for i = 1:size(imdb.images.label_bin, 2)
%     find(imdb.images.label_bin(:, i) > 0)
% end

for s = 1:length(imageSets),
  imageSetPath = fullfile(vocSampleDir, 'ImageSets', 'Main', sprintf('%s.txt',imageSets{s}));
  gtids = textread(imageSetPath,'%s');
  [membership, loc] = ismember(gtids, imdb.images.vocid);
  assert(all(membership));
  imdb.images.set(loc) = s;
end

% Write out the segments
% imdb.segments = imdb.images;
imdb.segments.id = [];
imdb.segments.imageId = [];
imdb.segments.label = [];
imdb.segments.mask = {};
imdb.segments.name = {};
imdb.segments.difficult = false(1, numel(imdb.segments.id)) ;

% make this compatible with the OS imdb
imdb.meta.classes = imdb.classes.name;
imdb.meta.inUse = true(1,numel(imdb.meta.classes));
imdb.meta.inUse([5, 6, 11, 14, 15, 16, 18, 19, 20]) = false;

[~, id_other] = ismember(imdb.meta.classes, 'other');
id_other = find(id_other);

for ii = 1 : numel(imdb.images.name)
    [~, seg_fname, ~] = fileparts(imdb.images.name{ii});
    seg_fname = fullfile(imdb.gtDir, sprintf('%s.png', seg_fname));
    im_fname = fullfile(imdb.imageDir, imdb.images.name{ii});
    if (exist(seg_fname, 'file') ~= 2)
        im_size = size(imread(im_fname));
        other = ones(im_size(1), im_size(2));
%         curr_classes = find(imdb.images.label_bin(:, ii) > 0);
%         intersection = setdiff(curr_classes, [0, 255, find(~imdb.meta.inUse)]);
%         if ~isempty(intersection)
%             for c = 1:numel(intersection)
%                 imdb.images.label(ii) = intersection(c);
%                 imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id);
%                 imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
%                 imdb.segments.label(end + 1) = intersection(c) ;
%                 [~, imName, ~] = fileparts(imdb.images.name{ii});
%                 crtSegName = sprintf('%s_%d.png', imName, intersection(c));
%                 imdb.segments.mask{end + 1} = crtSegName ;
%     %             other = other | (labels == c);
%                 labels = ones(im_size(1), im_size(2));
%                 imwrite(labels, fullfile(imdb.maskDir, crtSegName));
%             end
%         else
            imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id);
            imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
            imdb.segments.label(end + 1) = id_other ;
            imdb.images.label(ii) = id_other ;
            [~, imName, ~] = fileparts(imdb.images.name{ii});
            crtSegName = sprintf('%s_%d.png', imName, id_other);
            imdb.segments.mask{end + 1} = crtSegName ;
            imwrite(other, fullfile(imdb.maskDir, crtSegName));
%         end
        continue;
    end
    labels = imread(seg_fname);
    if 0
        figure(1) ; clf ;
        subplot(1,2,1) ; imagesc(imread(fullfile(imdb.imageDir, imdb.images.name{ii}))) ; axis equal ;
        subplot(1,2,2) ; image(labels) ; colormap(imdb.classes.colors/255) ; axis equal ;
        drawnow ;
    end
    other = zeros(size(labels));
    for c = setdiff(unique(labels(:))', [0, 255, find(~imdb.meta.inUse)])
        imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id);
        imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
        imdb.segments.label(end + 1) = c ;
        [~, imName, ~] = fileparts(imdb.images.name{ii});
        crtSegName = sprintf('%s_%d.png', imName, c);
        imdb.segments.mask{end + 1} = crtSegName ;
        imdb.segments.name{end + 1} = crtSegName;
        other = other | (labels == c);
        imwrite(labels == c, fullfile(imdb.maskDir, crtSegName));
    end
    imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id);
    imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
    imdb.segments.label(end + 1) = id_other ;
    [~, imName, ~] = fileparts(imdb.images.name{ii});
    crtSegName = sprintf('%s_%d.png', imName, id_other);
    imdb.segments.mask{end + 1} = crtSegName ;
    imdb.segments.name{end + 1} = crtSegName;
    imwrite(~other, fullfile(imdb.maskDir, crtSegName));
end

imdb.segments.set = ones(1, numel(imdb.segments.id));

