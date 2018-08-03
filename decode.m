
function [C,goodpixels] = decode(imageprefix,start,stop,threshold)
%function [C,goodpixels] = decode(imageprefix,cameraprefix,start,stop,threshold)

% function [C,goodpixels] = decode(imageprefix,start,stop,threshold)
%
%
% Input:
%
% imageprefix : a string which is the prefix common to all the images.
%
%                  for example, pass in the prefix '/home/fowlkes/left/left_'  
%
%                  to load the image sequence   '/home/fowlkes/left/left_01.png' 
%                                               '/home/fowlkes/left/left_02.png'
%                                               '/home/fowlkes/left/left_03.png'
%                                                          etc.
%
%  start : the first image # to load
%  stop  : the last image # to load
% 
%  threshold : the pixel brightness should vary more than this threshold between the positive
%             and negative images.  if the absolute difference doesn't exceed this value, the 
%             pixel is marked as undecodeable.
%
% Output:
%
%  C : an array containing the decoded values (0..1023)  for 10bit values
%
%  goodpixels : a binary image in which pixels that were decodedable across all images are marked with a 1.

% some error checking
if (stop<=start)
  error('stop frame number should be greater than start frame number');
end

nbits = ((stop-start)+1)/2;
fprintf('decoding %d bit code\n',nbits);

% read in one of the images to get dimensions
I = imread(sprintf('%s%2.2d.png',imageprefix,start));
[h,w,d] = size(I);

G = zeros(h,w,nbits);   %array to store gray code from image
goodpixels = ones(h,w); %mask indicating which pixels are good

bit = 1;
for i = start:2:stop

  % you may need to modify this depending on how your images are named
  I = imread(sprintf('%s%2.2d.png',imageprefix,i));
  In = imread(sprintf('%s%2.2d.png',imageprefix,i+1));

  if (size(I,3) > 1)
    I = im2double(rgb2gray(I));
    In = im2double(rgb2gray(In));
  else
    I = im2double(I);
    In = im2double(In);
  end

  G(:,:,bit) = I > In;  %store the bits of the gray code
  goodpixels = goodpixels.*(abs(I-In) > threshold);  %remove any bad pixels from the mask
  bit = bit + 1;
end

% convert from gray to bcd
%   remember that MSB is bit #1
BCD = zeros(h,w,nbits); %array to store BCD after gray->bcd conversion
BCD(:,:,1) = G(:,:,1);
for b = 2:nbits
  BCD(:,:,b) = xor(BCD(:,:,b-1),G(:,:,b));
end

% convert from BCD to standard decimal
C = zeros(h,w);         %array to store resulting decimal decoding
for b = 1:nbits
  C = C + 2^(nbits-b)*BCD(:,:,b);  
end


