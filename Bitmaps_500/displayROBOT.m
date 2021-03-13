%Display the robot/sphere in the current Bitmaps director
tic
clear('variables'); close all;
f = fopen('n.txt','r');
n = fscanf(f,'%i');
fclose(f);
ROBOT=false(n,n,n);
for i=1:n
    filename=['Sphere_robot/' int2str(i) '.png'];
    ROBOT(:,:,i)=imread(filename);
end
[x_robot,y_robot,z_robot]=ind2sub(size(ROBOT), find(ROBOT));
plot3(x_robot,y_robot,z_robot,'b.','markersize',0.1);
xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis')
title('Mapping x_{robot} and y_{robot} back to the sphere rolling on the plane')
view(160,10); axis equal; box on; colormap cool;
hold off;
toc
clear('variables');