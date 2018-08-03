%modifies parameters of stereoParams to meet the format required by
%reconstruct
%makes two separate cameras for each of the CameraParameter objects
cam2 = stereoParams.CameraParameters2
cam1 = stereoParams.CameraParameters1;
%creates the camR and camL structures expected by reconstruct
camR = struct;
camL = struct;

%finds the mean of the two values for focal length
camR.f = mean(cam1.FocalLength);

camR.c = cam1.PrincipalPoint;
%select the first rotation and translation matrix
camR.R = cam1.RotationMatrices(:,:,1);
camR.t = -camR.R * cam1.TranslationVectors(1,:)';

camL.f = mean(cam2.FocalLength);
camL.c = cam2.PrincipalPoint;
camL.R = cam2.RotationMatrices(:,:,1);
camL.t = -camL.R * cam2.TranslationVectors(1,:)';

%save to matlab
save camL;
save camR;
