clear ('variables'); close all;

%The "size" of the workspace
%When dealing with a flat plane, this corresponds to the length of a square
%in which the sphere is located at the center
size_workspace = 10;
%The number of pixels used on one side of the square box defining the full
%workspace of the robot
n = 500; %1000; %1100; %1250;
%For the main program, n/2 needs to be an integer
%Thus, n should be even:
if(mod(n,2)); fprintf('ERROR: n is not even'); return; end
%For better readability of the main program the value n is saved to a file
f = fopen('n.txt','w'); fprintf(f,'%i',n); fclose(f);

%The robot (sphere):
tic
delete('Sphere_robot/*');
rho = n/size_workspace; %Radius of the sphere in pixels
%Again, for better readability of the main program the value of rho is
%saved to a file:
f = fopen('rho.txt','w'); fprintf(f,'%i',rho); fclose(f);
centerX = n/2;
centerY = n/2;
centerZ = rho;
v = (1:n);
v = int16(v);
[X,Y,Z] = meshgrid(v,v,v);
clear v
SPHERE = ((X-centerX).^2+(Y-centerY).^2+(Z-centerZ).^2<rho.^2);
clear X Y Z
[x,y,z]=ind2sub(size(SPHERE), find(SPHERE));

%Save the sphere:
for i = 1:n
    imwrite(SPHERE(:,:,i),['Sphere_robot/' int2str(i) '.png'], 'png');
end

% %Display the sphere:
% clear SPHERE
% figure(1); clf; hold on;
% plot3(x,y,z,'b.','markersize',0.1);
% xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis')
% title('Sphere')
% view(160,10); axis equal; box on; colormap cool;
% hold off;


toc