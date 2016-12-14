function imdb = sample_voc_get_database(vocSampleDir, varargin)
opts.seed = 1 ;
opts = vl_argparse(opts, varargin) ;

assert(opts.seed == 1) ; % there is only one split

imdb.imageDir = fullfile(vocSampleDir, 'imgs') ;
imdb.maskDir = fullfile(vocSampleDir, 'Masks'); % doesn't exist
imdb.segmDir = fullfile(vocSampleDir, 'segm');
imdb.gtDir = fullfile(vocSampleDir, 'gt');
imdb.classes.name={...
  'cat'
  'bird'
  'aeroplane'
  'car'
 };
imdb.classes.colors = [
    0 0 0
    64 0 0
    128 128 0
    128 0 0
    128 128 128
];
numClass = length(imdb.classes.name);

% source images
imageFiles = dir(fullfile(imdb.imageDir, '*.jpg'));
imdb.images.name = {imageFiles.name};
gtFiles = dir(fullfile(imdb.gtDir, '*.jpg'));
imdb.images.gt_name = {gtFiles.name};
numImages = length(imdb.images.name);

imdb.images.label = 1:numImages;
imdb.images.set = zeros(1, numImages);
imdb.images.id = 1:numImages;
imdb.images.vocid = cellfun(@(S) S(1:end-4), imdb.images.name, 'UniformOutput', false);
imageSets = {'train', 'val', 'test'};

% Loop over images and record the image sets
imageSetPath = fullfile(vocSampleDir, 'ImageSets', sprintf('%s.txt',imageSets{1}));
[gtids] = textread(imageSetPath,'%s');
[membership, loc] = ismember(gtids, imdb.images.vocid);
assert(all(membership));
imdb.images.set(loc) = 1;

% Write out the segments
imdb.segments = imdb.images;
imdb.segments.id = [];
imdb.segments.imageId = [];
imdb.segments.label = [];
imdb.segments.mask = {};
imdb.segments.difficult = false(1, numel(imdb.segments.id)) ;

% make this compatible with the OS imdb
imdb.meta.classes = imdb.classes.name ;
imdb.meta.inUse = true(1,numel(imdb.meta.classes)) ;

for ii = 1 : numel(imdb.images.name)
  mask = imread(fullfile(imdb.gtDir, imdb.images.gt_name{ii}));
  [~, labels] = ismember(reshape(mask, [], 3), imdb.classes.colors, 'rows') ;
  labels = uint16(reshape(labels, size(mask,1), size(mask,2))) - 1 ;
  if 1
    figure(1) ; clf ;
    subplot(1,2,1) ; imagesc(imread(fullfile(imdb.imageDir, imdb.images.name{ii}))) ; axis equal ;
    subplot(1,2,2) ; image(labels) ; colormap(imdb.classes.colors/256) ; axis equal ;
    drawnow ;
  end
  for c = setdiff(unique(labels(:))', [0 find(~imdb.meta.inUse)])
    imdb.segments.id(end + 1) = 1 + numel(imdb.segments.id);
    imdb.segments.imageId(end + 1) = imdb.images.id(ii) ;
    imdb.segments.label(end + 1) = c ;
    [~, imName, ~] = fileparts(imdb.images.name{ii});
    crtSegName = sprintf('%s_%d.png', imName, c);
    imdb.segments.mask{end + 1} = crtSegName ;
    imwrite(labels == c, fullfile(imdb.maskDir, crtSegName));
  end
  imwrite(labels, fullfile(imdb.maskDir, [imName '.png']));
end

