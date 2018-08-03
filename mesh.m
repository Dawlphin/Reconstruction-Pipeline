function reconstruct(input_file,output_file)
%input_file: filename for reconstruction results to be proccessed
%output_file: name we want to saved .ply file to have

% load results of reconstruction
%
load (input_file);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cleaning step 1: remove points outside known bounding box
%

xmin = -300;
xmax = 300;
ymin = -600;
ymax = 600;
zmin = -600;
zmax = 600;

goodpoints = find( (X(1,:)>xmin) & (X(1,:)<xmax) & (X(2,:)>ymin) & (X(2,:)<ymax) & (X(3,:)>zmin) & (X(3,:)<zmax) );
fprintf('dropping %2.2f %% of points from scan\n',100*(1 - (length(goodpoints)/size(X,2))));


%
% drop points from both 2D and 3D list
%
X = X(:,goodpoints);
xR = xR(:,goodpoints);
xL = xL(:,goodpoints);
%make sure to drop from xColor as well!
xColor = xColor(:,goodpoints);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cleaning step 2: remove triangles which have long edges
%

trithresh = 4.5;   %using 4.5 reduces the "noise" of the points, giving us a cleaner image

fprintf('triangulating from left view\n');
tri = delaunay(xL(1,:),xL(2,:));
ntri = size(tri,1);
npts = size(xL,2);
terr = zeros(ntri,1);
for i = 1:ntri
  %fprintf('\rtraversing triangles %d/%d',i,ntri);
  d1 = sum((X(:,tri(i,1)) - X(:,tri(i,2))).^2);
  d2 = sum((X(:,tri(i,1)) - X(:,tri(i,3))).^2);
  d3 = sum((X(:,tri(i,2)) - X(:,tri(i,3))).^2);
  terr(i) = max([d1 d2 d3]).^0.5;
end
fprintf('\n');
subt = find(terr<trithresh);

fprintf('dropping %2.2f %% of triangles from scan\n',100*(1 - (length(subt)/size(tri,1))));

tri = tri(subt,:);


%
% remove unreferenced points which don't appear in any triangle
%
allpoints = (1:size(X,2))';
refpoints = unique(tri(:)); %list of unique points mentioned in tri

% build a table describing how we reindex points
newid = -1*ones(size(allpoints));
newid(refpoints) = 1:length(refpoints);

%now newid(k) contains the new index for current point k
% apply this mapping to all the indicies in tri

tri = newid(tri);

% and drop un-referenced points
X = X(:,refpoints);
xR = xR(:,refpoints);
xL = xL(:,refpoints);
%make sure to apply this to xColor as well!
xColor = xColor(:,refpoints);

%save as .ply using mesh_2_ply
mesh_2_ply(X,xColor,tri,output_file);
end
