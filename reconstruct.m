function reconstruct(scandir,filename) 
%scandir = directory to read files from
%filename = filename to save results as


%
% load in calibration data
%
load('camL.mat');
load('camR.mat');
%set threshold
thresh = 0.03;

%find goodpoints
[L_h,L_h_good] = decode([scandir 'frame_C1_'],0,19,thresh);
[L_v,L_v_good] = decode([scandir 'frame_C1_'],20,39,thresh);
[R_h,R_h_good] = decode([scandir 'frame_C0_'],0,19,thresh);
[R_v,R_v_good] = decode([scandir 'frame_C0_'],20,39,thresh);

%
% combine horizontal and vertical codes
% into a single code and a single mask.
%
Rmask = R_h_good & R_v_good;
R_code = R_h + 1024*R_v;
Lmask = L_h_good & L_v_good;
L_code = L_h + 1024*L_v;

%
% now find those pixels which had matching codes
% and were visible in both the left and right images
%
% only consider good pixels
Rsub = find(Rmask(:));
Lsub = find(Lmask(:));

% find matching pixels 
[matched,iR,iL] = intersect(R_code(Rsub),L_code(Lsub));
indR = Rsub(iR);
indL = Lsub(iL);

% indR,indL now contain the indices of the pixels whose 
% code value matched

% pull out the pixel coordinates of the matched pixels
[h,w] = size(Rmask);
[xx,yy] = meshgrid(1:w,1:h);
xL = []; xR = [];
xR(1,:) = xx(indR);
xR(2,:) = yy(indR);
xL(1,:) = xx(indL);
xL(2,:) = yy(indL);


%get color images
left_color = imread(sprintf('%scolor_C1_01.png',scandir));
right_color = imread(sprintf('%scolor_C0_01.png',scandir));
%convert to double
left_color = im2double(left_color);
right_color = im2double(right_color);
%initialize xL_color
xL_color = ones(3,size(xL,2));

%iterate over xL, finding corresponding rgb value in xL_color
for i=1:size(xL,2)
    x = xL(1,i);
    y = xL(2,i);
    colorvalue = left_color(y,x,:);
    xL_color(:,i) = colorvalue;
end

%iterate over xR, finding corresponding rgb value in xR_color
xR_color = ones(3,size(xR,2));
for i=1:size(xR,2)
    x = xR(1,i);
    y = xR(2,i);
    colorvalue = right_color(y,x,:);
    xR_color(:,i) = colorvalue;
end
%average
xColor = (xR_color +xL_color)/2;


% now triangulate the matching pixels using the calibrated cameras
%

X = triangulate(xL,xR,camL,camR);
%plot 2D overhead view
clf; plot(X(1,:),X(3,:),'.');
axis image; axis vis3d; grid on;
hold on;
plot(camL.t(1),camL.t(3),'ro')
plot(camR.t(1),camR.t(3),'ro')
xlabel('X-axis');
ylabel('Z-axis');


% plot 3D view
clf; plot3(X(1,:),X(2,:),X(3,:),'.');
axis image; axis vis3d; grid on;
hold on;
plot3(camL.t(1),camL.t(2),camL.t(3),'ro')
plot3(camR.t(1),camR.t(2),camR.t(3),'ro')
axis([0 220 0 300 -300 0])
set(gca,'projection','perspective')
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');

%find xColor


%
% save the results (including xColor)
%
save(filename,'X','xL','xR','camL','camR','Lmask','Rmask','xColor');
end

