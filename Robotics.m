%Bouncing on a discretized surface and reorientation parallel to the
%tangent of the boundary

clear variables; close all; tic;

%This final version of the code makes use of bitmaps created in subfolders
%located in the "Bitmaps_n" folders (from local path)
%All units are in so called "pixels"

%Notes:
%The spatial separation is 1 pixel
%The time seperation dt should be as small as possible thus it is logical
%to make it equal to dl. However, this is not strictly speaking required
%here (the value for dt can be changed)

%Conventions used in namings:
%No capital letter: simple (1x1) variable or 1D vector
%First letter capitalized: 2D matrix
%All capitalized: 3D matrix

%Exceptions to the above are listed below:
%c_sol is (*,5) 2D matrix | notation is consistent with that of t_sol


%% Part one: Loading the necessary data into matrices, from the folders
%Select main folder:
Bitmaps_directories = dir('*Bitmaps*');
str = {Bitmaps_directories.name};
prompt = {'Select main folder to load surface, walls, and/or workspace from'};
[selection_main,OK] = listdlg('PromptString',prompt,...
                         'SelectionMode','single',...
                         'ListSize',[500 150],...
                         'ListString',str);
if(~OK); return; end; %Make sure something was selected
Bitmaps_dir = str(selection_main);

f = fopen([char(Bitmaps_dir) '/n.txt'],'r'); n = fscanf(f,'%i'); fclose(f);   %size of the workspace (in pixels)
f = fopen([char(Bitmaps_dir) '/rho.txt'],'r'); r = fscanf(f,'%i'); fclose(f); %radius of the sphere/robot (in pixels)
mainDirectory = dir(char(Bitmaps_dir));
subDirectories = find(vertcat(mainDirectory.isdir));
str = {mainDirectory(subDirectories).name};
%Remove the '.', '..' and 'Sphere_robot directories
good_str_index = (~strcmp(str,'.') & ~strcmp(str,'..') & ~strcmp(str,'Sphere_robot'));
str = str(good_str_index);
%Choose to enter the surface and two walls separately or all at once in a
%workspace:
choice = {'Enter surface, and walls separately', 'Enter full workspace'};
[selection,OK] = listdlg('PromptString','Make a selection',...
                         'SelectionMode','single',...
                         'ListSize',[500 100],...
                         'ListString',choice);
if(~OK); return; end; %Make sure something was selected
if(selection == 1)
    % Getting the surface matrix:
    [selection_S,OK] = listdlg('PromptString','Select a surface:',...
                             'SelectionMode','single',...
                             'ListSize',[500 500],...
                             'ListString',str);
    if(~OK); return; end; %Make sure something was selected
    surf_str = str(selection_S); %Store the name of the selected surface
    SURF=false(n,n,n);
    for i=1:n
        filename=[char(Bitmaps_dir) '/' char(surf_str) '/' int2str(i) '.png'];
        SURF(:,:,i)=imread(filename);
    end
    WORKSPACE = (SURF);
    clear('SURF');
    % Getting the 1st wall matrix:
    [selection_W1,OK] = listdlg('PromptString','Select the first wall:',...
                             'SelectionMode','single',...
                             'ListSize',[500 500],...
                             'ListString',str);
    if(~OK); return; end; %Make sure something was selected
    wall1_str = str(selection_W1); %Store the name of the selected wall 1
    WALL1=false(n,n,n);
    for i=1:n
        filename=[char(Bitmaps_dir) '/' char(wall1_str) '/' int2str(i) '.png'];
        WALL1(:,:,i)=imread(filename);
    end
    WORKSPACE = (WORKSPACE | WALL1);
    clear('WALL1');
    % Getting the 2nd wall matrix:
    [selection_W2,OK] = listdlg('PromptString','Select the second wall:',...
                             'SelectionMode','single',...
                             'ListSize',[500 500],...
                             'ListString',str);
    if(~OK); return; end; %Make sure something was selected
    wall2_str = str(selection_W2); %Store the name of the selected wall 2
    WALL2=false(n,n,n);
    for i=1:n
        filename=[char(Bitmaps_dir) '/' char(wall2_str) '/' int2str(i) '.png'];
        WALL2(:,:,i)=imread(filename);
    end
    % Creating the complete WORKSPACE matrix which includes both walls and the
    % surface.
    % Note: such a matrix could potentially have a corresponding image that
    % would be loaded (similarly to the above), in which case the above 3
    % matrices could be ignored
    WORKSPACE = (WORKSPACE | WALL2);
    clear('WALL2'); %Cleaning up for memory space and speed
else
    % Getting the full workspace matrix:
    [selection_W,OK] = listdlg('PromptString','Select a full workspace:',...
                             'SelectionMode','single',...
                             'ListSize',[500 500],...
                             'ListString',str);
    if(~OK); return; end; %Make sure something was selected
    workspace_str = str(selection_W); %Store the name of the selected wall 2
    WORKSPACE=false(n,n,n);
    for i=1:n
        filename=[char(Bitmaps_dir) '/' char(workspace_str) '/' int2str(i) '.png'];
        WORKSPACE(:,:,i)=imread(filename);
    end
end

% Getting the robot matrix!
ROBOT=false(n,n,n);
for i=1:n
    filename=[char(Bitmaps_dir) '/' 'Sphere_robot/' int2str(i) '.png'];
    ROBOT(:,:,i)=imread(filename);
end

% "Positionning" the robot on the surface
% This step is not necessary if the loaded ROBOT matrix is properly
% positioned. However, in our case we use a single sphere always located at
% the bottom center of the workspace, which can then easily be shifted around
% i.e. the default position of the bottom of the sphere with respect to the
% workspace is [n/2,n/2,0]
if(strcmp(surf_str,'Flat_surf'))
    xshift = 0; yshift = 0; zshift = n/2;
elseif(strcmp(surf_str,'Flat_Surf'))
    xshift = 0; yshift = 0; zshift = n/2;
elseif(strcmp(surf_str,'Tilted_x_Surf')); 
    alpha = pi/4; h = floor(r*((1/cos(alpha))-1));
    xshift = 0; yshift = 0; zshift = n/2+h;
elseif(strcmp(surf_str,'Tilted_y_Surf'));
    alpha = pi/4; h = floor(r*((1/cos(alpha))-1));
    xshift = 0; yshift = 0; zshift = n/2+h;
elseif(strcmp(surf_str,'Tilted_xy_Surf'));
    alpha = pi/4; h = floor(r*((1/cos(alpha))-1));
    xshift = 0; yshift = 0; zshift = n/2+h;
elseif(strcmp(surf_str,'Sine_x_Surf'));
    xshift = round(pi*r*2-n/2)-r/5; yshift = 0; zshift = 2*r;
elseif(strcmp(surf_str,'Sine_y_Surf'));
    xshift = 0; yshift = round(pi*r*2-n/2); zshift = 2*r;
elseif(strcmp(surf_str,'Sine_xy_Surf'));
    xshift = round(pi*r*2-n/2); yshift = round(pi*r*2-n/2); zshift = 2*r; 
elseif(strcmp(surf_str,'Gaussian_dome_Surf'));
    xshift = 0; yshift = 0; zshift = floor(r^1.5)-1-ceil((r*(sqrt(r)-7.8)+abs(r*(sqrt(r)-7.8)))/2);
elseif(strcmp(surf_str,'PhotoShop_FlatSurf'));
    xshift = 0; yshift = 0; zshift = 0;
else
    fprintf('ERROR: The selection is not a known surface\n');
    fprintf('The code might need to be updated\n');
    return
end
ROBOT=circshift(ROBOT,[xshift,yshift,zshift]);
%So, we now have 2 matching (in size) 3D matrices: ROBOT and WORKSPACE

%% Part 2: Setting up the initial conditions:
%The ROBOT has it's own coordinate system which does not necessarily match
%that of the WORKSPACE. This allows us to keep the initial conditions for
%the robot fixed, and not have to worry about strange behaviors when
%rotating since those do occur especially when x0_robot is not close to
%-pi/2
x0_robot = -pi/2 + 1e-4;
y0_robot = 0;
psi0 = 0;
%Definition of the robot/sphere in it's own reference frame
robot = @(x,y) r*[cos(x).*cos(y); cos(x).*sin(y); sin(x)+1];

%The other initial conditions:
%Everything is pixelized (even time)
dl = 1;                 %Spatial separation (1 pixel)
dt = input('Enter dt (in units of 1/r): ');
dt = dt/r;              %Time step: normalized by r so that shift=dl when rolling
t_start = 0;            %Initial time for the robot to begin moving
t_final = input('Enter final time: ');
%Adjust t_final to make sure it is an integer value time dt:
delta = (t_final-t_start)*r-floor((t_final-t_start)*r);
t_final = t_final - delta/r;
current_time = t_start; %The current time
bounces = 0;            %Number of bounces
break_val = 0;          %Used to break out of loops

%The velocity vector
vx = 0; vy = 0; vz = 0; wz = 0;
fprintf('Enter initial rotation velocities:\n');
fprintf('Note that the velocities will be automatically normalized\n');
wx = input('Enter initial rotation velocity wx = ');
wy = input('Enter initial rotation velocity wy = ');
%Normalize the velocity vector
normalization = sqrt(wx*wx + wy*wy);
wx = wx/normalization; wy = wy/normalization;
V = [vx;vy;vz;wx;wy;wz];

%The progress bar:
handle = waitbar(0,'1','Name','Running...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(handle,'canceling',0);

t_sol = zeros(1,round((t_final-t_start)/dt+1));
t_sol(1) = current_time;  %Initialize total time vector

%Initializing the matrix of contact points (with the surface)
Contact_pts = zeros(length(t_sol),3);
%Getting the first contact points:
%Before even starting there is not any previous contact point, and there
%should not be any hit point (otherwise an error will be caused)
prev_contact_pt = 'NaN';
guess = 'NaN';
if getappdata(handle,'canceling'); delete(handle); return; end
[contact_pt,hit_pt,error] = ...
    Get_hit_cont_pts(ROBOT,WORKSPACE,prev_contact_pt,r,guess);
if(error); return; end %Checking for the error boolean value
Contact_pts(1,:) = contact_pt';

%The initial surface parameters:
x0_surf = contact_pt(1);
y0_surf = contact_pt(2);
z0_surf = contact_pt(3);

if getappdata(handle,'canceling'); delete(handle); return; end
%Getting the slopes z_x and z_y (del_z/del_x and del_z/del_y):
z_x_old = 0; z_y_old = 0; %Values to use if "inf" is reached
[z_x,z_y] = Get_slopes(WORKSPACE,contact_pt,r,z_x_old,z_y_old);
z_x_old = z_x; z_y_old = z_y; % update the "old" values.
%Initial contact coordinates all into the initial contacts vector:
contacts0 = [x0_robot, y0_robot, x0_surf, y0_surf, psi0];
c_sol = zeros(length(t_sol),5);
c_sol(1,:) = contacts0; %Initialize total contact coordinate vector
%% Part 3: Setting up the fixed parameters:
%Some parameters never need to be updated and should be taken care of now
%Locally, the surface is a plane:
K_surf = false(2,2); %Curvature tensor
T_surf = false(1,2); %Torsion form

%The robot is known to be a sphere:
M_robot = [r, 0; 0, cos(x0_robot)];  %Metric tensor
K_robot = [-1/r, 0; 0, -1/r];        %Curvature tensor
T_robot = [0, -1/r * tan(x0_robot)]; %Torsion form

%A few 'constants' that only need to be computed once:
%(Refer to the book for notations)
R = @(psi) [cos(psi), -sin(psi); -sin(psi), -cos(psi)];
K = false(2,2);
R_cocf = @(psi) [R(psi), [0;0]; [0,0],1];
p = [0;0;0];
p_hat = [ 0 -p(3) p(2); p(3) 0 -p(1); -p(2) p(1) 0 ];

fprintf('\n\t The program is about to loop around. \n')
fprintf('All parameters have been initialized\n');
fprintf('And the current time is: %g \n', current_time);

if getappdata(handle,'canceling'); delete(handle); return; end
toc
tic
%%-----------------------------------------------------------------------%%
%% The above are only about setting things up                            %%
%% Below is the part where things move                                   %%       
%%-----------------------------------------------------------------------%%

%%%%%%%%%%%%%%%%%%%%%%%%%Now we are looping around%%%%%%%%%%%%%%%%%%%%%%%%%
%**Loop #1: Loop until final allowed time:
index1 = 1; %Index for the main general loop (the "master" index)
            %Note: this index is used throughout the loops to update the
            %contacts and time matrices
while current_time < t_final
    %1
    %First, the robot is sent rolling straight into the x-direction
    %The robot only ever rolls about the wy-axis unless it is spinning to
    %reorientate, in which case it is rotating about the wz-axis
    %The orientation is only specified at the end of this comming loop by
    %the bouncing (after loop #2)
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Part four: Move-on and rotate until the orientation needs to    %%%
    %%%                         be reset                                %%%
    % I need to loop around: after each small step the sphere coordinates
    % need to be reset, but not those of the surface
    
    hit = false; %The sphere has not yet hit the boundary
    index2 = index1;  %Index of loop 2
    
    while(~hit) %Loop #2: Loop until a boundary is hit
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Part five: Getting bigZ and bigC                            %%%
        % To avoid passing heavy functions to the function it is easier to
        % directly compute p_hat here and pass it into the function
        % Again, R_psi is computed here and passed to the function
        % Same thing for R_cocf
        R_psi = R(psi0);
        R_cocf_psi = R_cocf(psi0);
        [bigZ, bigC] = Get_bigZ_bigC(z_x, z_y, ...
            x0_robot, y0_robot, p_hat, M_robot, K_robot, ...
            T_robot, R_psi, R_cocf_psi, V);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Part six: Now that we have bigZ and bigC we can roll:       %%%
        % The time and contacts needs to be updated
        t_sol(index2+1) = current_time + dt;
        c_sol(index2+1,:) = ((bigZ^(-1))*dt*bigC + contacts0')';
        contacts0(3) = c_sol(index2+1,3);
        contacts0(4) = c_sol(index2+1,4);
        % Do not update (so reset) the values for x0_robot, y0_robot, and
        % psi0:
        c_sol(index2+1,1) = contacts0(1);
        c_sol(index2+1,2) = contacts0(2);
        c_sol(index2+1,5) = contacts0(5);
        %Shift the robot to it's new position:
        prev_contact_pt = Contact_pts(index2,:);
        shift_x = round(c_sol(index2+1,3)) - round(prev_contact_pt(1));
        shift_y = round(c_sol(index2+1,4)) - round(prev_contact_pt(2));
        %Locally, everything is a plane. So we can use the equation of a
        %plane: z = z_x*x + z_y*y + c => dz = z_x*dx + z_y*dy
        shift_z = round(z_x*shift_x + z_y*shift_y);
        ROBOT = circshift(ROBOT,[shift_x, shift_y, shift_z]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Part seven: check whether a boundary was hit:               %%%
        guess = round([c_sol(index2+1,3),c_sol(index2+1,4),prev_contact_pt(3)+shift_z]);
        if getappdata(handle,'canceling'); delete(handle); return; end
        percentage = round(current_time/t_final*1e4)/100;
        waitbar((current_time-t_start)/t_final,handle,sprintf('%1.2f %%',percentage));
        [contact_pt,hit_pt,error] = ...
            Get_hit_cont_pts(ROBOT,WORKSPACE,prev_contact_pt,r,guess);
        if(error); return; end %Checking for the error boolean value
        Contact_pts(index2+1,:) = contact_pt';
        %Getting the slopes z_x and z_y (del_z/del_x and del_z/del_y):
        [z_x,z_y] = Get_slopes(WORKSPACE,contact_pt,r,z_x_old,z_y_old);
        z_x_old = z_x; z_y_old = z_y; % update the "old" values.
        if(shift_x>r/10 || shift_y>r/10 || shift_z>r/10)
            fprintf('shift values:\t %i \t %i \t %i\n', shift_x, shift_y, shift_z);
            fprintf('Loop 2, current time: %f \n', current_time);
            fprintf('The robot might be \"jumping\" around...\n');
        end
        
        %Making sure there is a hit point before trying to update it
        if(~strcmp(hit_pt,'NaN'))
            bounces = bounces + 1;
            Hit_pts(bounces,:) = hit_pt';
            hit = true;
            fprintf('\t The boundary was hit at time: %g\n',current_time);
        end
        %We need to reset a few values that are used throughout the loops
        x0_robot = contacts0(1);
        y0_robot = contacts0(2);
        x0_surf = contacts0(3);
        y0_surf = contacts0(4);
        psi0 = contacts0(5);
        % Update the index:
        index2 = index2 + 1;
        % Update the time:
        current_time = current_time + dt;
        %Break out if max time is reached
        if(current_time >= t_final); break; end
    end %End of loop #2 (loop until boundary is hit)
    
    if getappdata(handle,'canceling'); delete(handle); return; end
    %update index1:
    index1 = index2;
    %Again, break out if max time is reached:
    if(current_time >= t_final); break; end
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Part eight: figure out the angle of rotation:                   %%%
    prev_contact_pt = Contact_pts(index1-1,:);
    current_contact_pt = Contact_pts(index1,:);
    direction_vect = (current_contact_pt-prev_contact_pt)';
    x_hit = Hit_pts(end,1); y_hit = Hit_pts(end,2); z_hit = Hit_pts(end,3);
    
    %Getting the normal vector to the wall
    i = 0; done = false; tmp_found1 = false; need_break1 = false;
    for j=0:r/10
        for k=0:r/10
            if(k==0 && j==0)
                %Do nothing
            elseif(x_hit-i<1 || y_hit-j<1 || z_hit-k<1)
                need_break1 = true;
                break;
            elseif(WORKSPACE(x_hit,y_hit+j,z_hit+k))
                if(i*i+j*j+k*k >= r*r/100)
                    done = true;
                    break
                else
                    tmp_v1 = [i;j;k];
                    tmp_found1 = true;
                end
            elseif(WORKSPACE(x_hit,y_hit-j,z_hit+k))
                if(i*i+j*j+k*k >= r*r/100)
                    j = -j;
                    done = true;
                    break
                else
                    j = -j;
                    tmp_v1 = [i;j;k];
                    tmp_found1 = true;
                end
            elseif(WORKSPACE(x_hit,y_hit+j,z_hit-k))
                if(i*i+j*j+k*k >= r*r/100)
                    k = -k;
                    done = true;
                    break
                else
                    k = -k;
                    tmp_v1 = [i;j;k];
                    tmp_found1 = true;
                end
            elseif(WORKSPACE(x_hit,y_hit-j,z_hit-k))
                if(i*i+j*j+k*k >= r*r/100)
                    j = -j; k = -k;
                    done = true;
                    break
                else
                    j = -j; k = -k;
                    tmp_v1 = [i;j;k];
                    tmp_found1 = true;
                end
            end
        end
        if(need_break1); break; end;
        if(done); break; end;
    end
    if(done)
        v1 = [i;j;k];
    elseif(tmp_found1)
        v1 = tmp_v1;
    else
        v1 = 'NaN';
    end
    j = 0; done = false; tmp_found2 = false; need_break2 = false;
    for i=0:r/10
        for k=0:r/10
            if(k==0 && i==0)
                %Do nothing
            elseif(x_hit-i<1 || y_hit-j<1 || z_hit-k<1)
                need_break2 = true;
                break;
            elseif(WORKSPACE(x_hit+i,y_hit,z_hit+k))
                if(i*i+j*j+k*k >= r*r/100)
                    done = true;
                    break
                else
                    tmp_v2 = [i;j;k];
                    tmp_found2 = true;
                end
            elseif(WORKSPACE(x_hit-i,y_hit,z_hit+k))
                if(i*i+j*j+k*k >= r*r/100)
                    i = -i;
                    done = true;
                    break
                else
                    i = -i;
                    tmp_v2 = [i;j;k];
                    tmp_found2 = true;
                end
            elseif(WORKSPACE(x_hit+i,y_hit,z_hit-k))
                if(i*i+j*j+k*k >= r*r/100)
                    k = -k;
                    done = true;
                    break
                else
                    k = -k;
                    tmp_v2 = [i;j;k];
                    tmp_found2 = true;
                end
            elseif(WORKSPACE(x_hit-i,y_hit,z_hit-k))
                if(i*i+j*j+k*k >= r*r/100)
                    i = -i; k = -k;
                    done = true;
                    break
                else
                    i = -i; k = -k;
                    tmp_v2 = [i;j;k];
                    tmp_found2 = true;
                end
            end
        end
        if(need_break2); break; end;
        if(done); break; end;
    end
    if(done)
        v2 = [i;j;k];
    elseif(tmp_found2)
        v2 = tmp_v2;
    else
        v2 = 'NaN';
    end
    k = 0; done = false; tmp_found3 = false; need_break3 = false;
    for i=0:r/10
        for j=0:r/10
            if(j==0 && i==0)
                %Do nothing
            elseif(x_hit-i<1 || y_hit-j<1 || z_hit-k<1)
                need_break3 = true;
                break;
            elseif(WORKSPACE(x_hit+i,y_hit+j,z_hit))
                if(i*i+j*j+k*k >= r*r/100)
                    done = true;
                    break
                else
                    tmp_v3 = [i;j;k];
                    tmp_found3 = true;
                end
            elseif(WORKSPACE(x_hit-i,y_hit+j,z_hit))
                if(i*i+j*j+k*k >= r*r/100)
                    i = -i;
                    done = true;
                    break
                else
                    i = -i;
                    tmp_v3 = [i;j;k];
                    tmp_found3 = true;
                end
            elseif(WORKSPACE(x_hit+i,y_hit-j,z_hit))
                if(i*i+j*j+k*k >= r*r/100)
                    j = -j;
                    done = true;
                    break
                else
                    j = -j;
                    tmp_v3 = [i;j;k];
                    tmp_found3 = true;
                end
            elseif(WORKSPACE(x_hit-i,y_hit-j,z_hit))
                if(i*i+j*j+k*k >= r*r/100)
                    i = -i; j = -j;
                    done = true;
                    break
                else
                    i = -i; j = -j;
                    tmp_v3 = [i;j;k];
                    tmp_found3 = true;
                end
            end
        end
        if(need_break3); break; end;
        if(done); break; end;
    end
    if(done)
        v3 = [i;j;k];
    elseif(tmp_found3)
        v3 = tmp_v3;
    else
        v3 = 'NaN';
    end
    if(~strcmp(v1,'NaN')&&~strcmp(v2,'NaN')&&~strcmp(v3,'NaN'))
        norm_wall1 = cross(v1,v2);
        norm_wall2 = cross(v1,v3);
        norm_wall3 = cross(v2,v3);
        norm_walls = [norm_wall1,norm_wall2,norm_wall3];
        norms = [norm(norm_wall1),norm(norm_wall2),norm(norm_wall3)];
        index_norms = find(abs(norms - max(norms)) < 1e-5,1);
        norm_wall = norm_walls(:,index_norms);
    elseif(~strcmp(v1,'NaN')&&~strcmp(v2,'NaN'))
        norm_wall = cross(v1,v2);
    elseif(~strcmp(v1,'NaN')&&~strcmp(v3,'NaN'))
        norm_wall = cross(v1,v3);
    elseif(~strcmp(v2,'NaN')&&~strcmp(v3,'NaN'))
        norm_wall = cross(v2,v3);
    else
        fprintf('ERROR: The normal to the wall cannot be computed\n');
        return
    end
    if(norm(norm_wall)<1e-5);
        fprintf('ERROR: The normal to the wall is too close to (0,0,0)\n');
        return
    end
    %The normalizing the normal vector to the wall:
    norm_wall = norm_wall/norm(norm_wall);
    if(dot(direction_vect,norm_wall)<0); norm_wall = -norm_wall; end
    %The bouncing vector (the new direction):
    bounce_vector_0 = direction_vect-2*dot(direction_vect,norm_wall)*norm_wall;
    bounce_vector = bounce_vector_0;
    bounce_vector(3) = 0; %We don't want a z-direction
    bounce_vector = bounce_vector/norm(bounce_vector); %normalize
    %The reorientation vector (tangent to the surface):
    norm_wall = -norm_wall;
    reorientation_vector = bounce_vector_0-dot(bounce_vector_0,norm_wall)*norm_wall;
    reorientation_vector(3) = 0; %We don't want a z-direction
    if(reorientation_vector(1) == 0 && reorientation_vector(2) == 0)
        reorientation_vector(1) = norm_wall(2)*sign(wy);
        reorientation_vector(2) = -norm_wall(1)*sign(wy);
    end
    reorientation_vector = reorientation_vector/norm(reorientation_vector); %normalize
    if(isnan(reorientation_vector(1)) || isnan(reorientation_vector(2)))
        fprintf('ERROR: There was an issue computing the reorientation vector\n');
        return
    end
    wx = -bounce_vector(2);
    wy = bounce_vector(1);
    V = [0;0;0;wx;wy;0];
    
    %Check we are not going over time:
    if(current_time >= t_final); break; end
    
    if getappdata(handle,'canceling'); delete(handle); return; end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Part nine: move away from the boundary                          %%%
    move = 1/(5*dt);%r/5;
    for index3 = index1:index1+move %Loop #3: Loop a little to move away 
                                          %from boundary
        %Again we are rolling:
        R_psi = R(psi0);
        R_cocf_psi = R_cocf(psi0);
        [bigZ, bigC] = Get_bigZ_bigC(z_x, z_y, ...
            x0_robot, y0_robot, p_hat, M_robot, K_robot, ...
            T_robot, R_psi, R_cocf_psi, V);
        current_time = current_time + dt;
        t_sol(index3+1) = current_time;
        c_sol(index3+1,:) = ((bigZ^(-1))*dt*bigC + contacts0')';
        c_sol(index3+1,1) = contacts0(1);
        c_sol(index3+1,2) = contacts0(2);
        contacts0(3) = c_sol(index3+1,3);
        contacts0(4) = c_sol(index3+1,4);
        c_sol(index3+1,5) = contacts0(5);
        %Shift the robot to it's new position:
        prev_contact_pt = Contact_pts(index3,:);
        shift_x = round(c_sol(index3+1,3)) - round(prev_contact_pt(1));
        shift_y = round(c_sol(index3+1,4)) - round(prev_contact_pt(2));
        
        %Locally, everything is a plane. So we can use the equation of a
        %plane: z = z_x*x + z_y*y + c => dz = z_x*dx + z_y*dy
        shift_z = round(z_x*shift_x + z_y*shift_y);
        if(shift_x>r/10 || shift_y>r/10 || shift_z>r/10)
            fprintf('shift values:\t %i \t %i \t %i\n', shift_x, shift_y, shift_z);
            fprintf('Loop 3, current time: %f \n', current_time);
            fprintf('The robot might be \"jumping\" around...\n');
        end
        ROBOT = circshift(ROBOT,[shift_x, shift_y, shift_z]);
        %Check we are not going over time
        if(current_time >= t_final); break; end
        %Check whether a boundary was hit.
        %In theory there should be enough room so that it doesn't.
        %If a boundary is hit an error message will be displayed.
        guess = round([c_sol(index3+1,3),c_sol(index3+1,4),prev_contact_pt(3)+shift_z]);
        if getappdata(handle,'canceling'); delete(handle); return; end
        percentage = round(current_time/t_final*1e4)/100;
        waitbar((current_time-t_start)/t_final,handle,sprintf('%1.2f %%',percentage));
        [contact_pt,hit_pt,error] = ...
            Get_hit_cont_pts(ROBOT,WORKSPACE,prev_contact_pt,r,guess);
        if(error); return; end %Checking for the error boolean value
        Contact_pts(index3+1,:) = contact_pt';
        
        %Getting the slopes z_x and z_y (del_z/del_x and del_z/del_y):
        [z_x,z_y] = Get_slopes(WORKSPACE,contact_pt,r,z_x_old,z_y_old);
        z_x_old = z_x; z_y_old = z_y; % update the "old" values.
        %In the event where there is a hit point then an error message is
        %displayed and the program jumps to plotting
        if(~strcmp(hit_pt,'NaN'))
            fprintf('WARNING: The boundary was hit before reorientation\n');
            break_val = 0;
            %break;
        end
        %We need to reset a few values that are used throughout the loops
        x0_robot = contacts0(1);
        y0_robot = contacts0(2);
        x0_surf = contacts0(3);
        y0_surf = contacts0(4);
        psi0 = contacts0(5);
    end %End of loop #3 (moving away from the boundary)
    
    if(break_val); break; end
    %Updating index1:
    index1 = index3+1;
    %Check we are not going over time:
    if(current_time >= t_final); break; end
    
    if getappdata(handle,'canceling'); delete(handle); return; end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Part ten: Reorientating the robot                            %%%
    % The robot now has to reorientate to be in the direction of the
    % tangent line to the wall
    wx = -reorientation_vector(2);
    wy = reorientation_vector(1);
    V = [0; 0; 0; wx; wy; 0];
    
    % The code can now move back up to allow for the robot to roll in the
    % new direction
end %End of loop #1 (loop until final allowed time)

if getappdata(handle,'canceling'); delete(handle); return; end
percentage = round(current_time/t_final*1e4)/100;
waitbar((current_time-t_start)/t_final,handle,sprintf('%1.2f %%',percentage));
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Final part: Plot                                                    %%%
%The first plot is the contact coordinates
figure(1); clf;
%Make the psi angle between -pi and pi as well as y_robot
%contacts_total(:,2) = mod(contacts_total(:,2),2*pi) - pi;
%contacts_total(:,5) = mod(contacts_total(:,5),2*pi) - pi;
plot(t_sol, c_sol(:,1), 'b', ... %x_robot
     t_sol, c_sol(:,2), 'r', ... %y_robot
     t_sol, c_sol(:,3), 'g', ... %x_surf
     t_sol, c_sol(:,4), 'c', ... %y_surf
     t_sol, c_sol(:,5), 'm', ... %psi
     t_sol, 0);                           %The t-axis
minix = min(t_sol);                 %Minimum time value
maxix = max(t_sol);                 %Maximum time value
miniy = min(min(c_sol));        %Minimum contacts value
maxiy = max(max(c_sol));        %Maximum contacts value
%Note: the two min/max are necessary because contacts_total is a matrix
%and not just a vector
range = [minix*1.1, maxix*1.1, miniy*1.1, maxiy*1.1];
%Set the range of the y-axis:
axis(range)
legend('x_{robot}', 'y_{robot}', 'x_{surface}', 'y_{surface}', ...
    'angle \psi', 'Location', 'best');
title('Contact coordinates of rolling robot');
xlabel('time');

%Figure 1, but split in 2 to see better.
figure(2); clf; hold on;
subplot(2,1,1)
plot(t_sol, c_sol(:,1), 'b', ...
     t_sol, c_sol(:,2), 'r', ...
     t_sol, c_sol(:,5), 'm', ...
     t_sol, 0);
legend('x_{robot}', 'y_{robot}', 'angle \psi', 'Location', 'best');
title('Robot Contact coordinates of rolling robot');
xlabel('time');
subplot(2,1,2)
plot(t_sol, c_sol(:,3), 'g', ...
     t_sol, c_sol(:,4), 'c', ...
     t_sol, 0);
legend('x_{surface}', 'y_{surface}', 'Location', 'best');
title('Surface Contact coordinates of rolling robot');
xlabel('time');

%The third plot is the robot with the final "workspace" coordinates (not
%centered at 0)
%Since the robot is always a sphere, this plot is kind of useless, but just
%in case something goes wrong it is nice to have it.
figure(3); clf; hold on;
[x_robot,y_robot,z_robot]=ind2sub(size(ROBOT), find(ROBOT));
plot3(x_robot,y_robot,z_robot,'b.');
%Over plot the contact point:
contact_robot = robot(c_sol(:,1)', c_sol(:,2)');
contact_robot = contact_robot + (n/2+1)*ones(size(contact_robot));
%plot3(contact_robot(1), contact_robot(2), contact_robot(3), ...
    %'r.','markersize', 6);
xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis')
title('Mapping x_{robot} and y_{robot} back to the sphere rolling on the plane')
view(160,10); axis equal; box on; colormap cool;
hold off;

%The fourth plot is the surface with the two boundaries as well as the 
%contacts over plotted 
figure(4); clf; hold on;
[x_workspace,y_workspace,z_workspace]=ind2sub(size(WORKSPACE), find(WORKSPACE));
plot3(x_workspace,y_workspace,z_workspace,'b.','markersize',0.1);
xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis')
%Over plot the contact points:
x_contact_surf = Contact_pts(:,1);
y_contact_surf = Contact_pts(:,2);
z_contact_surf = Contact_pts(:,3);
plot3(x_contact_surf, y_contact_surf, z_contact_surf, ...
    'r.','markersize', 6);
title('Mapping x_{surface} and y_{surface} back to the surface')
view(-15,65); axis equal; box on; colormap cool;
hold off;

%The fifth plot is a nicer version of the fourth plot:
figure(5); clf; hold on;
clear('ROBOT'); clear('WORKSPACE');
if(selection == 1) %Surface and walls were selected separately
    %Plotting the surface:
    Surf=false(n,n);
    Z_surf = zeros(n,n);
    for i=1:n
        filename=[char(Bitmaps_dir) '/' char(surf_str) '/' int2str(i) '.png'];
        Surf(:,:)=imread(filename);
        Z_surf(Surf') = i;
    end
    [X_surf,Y_surf] = meshgrid((1:n),(1:n));
    mesh(X_surf,Y_surf,Z_surf);
    %Plotting the first wall:
    Wall1=false(n,n);
    Z_wall1 = zeros(n,n);
    for i=1:n
        filename=[char(Bitmaps_dir) '/' char(wall1_str) '/' int2str(i) '.png'];
        Wall1(:,:)=imread(filename);
        Z_wall1(Wall1') = i;
    end
    [X_wall1,Y_wall1] = meshgrid((1:n),(1:n));
    waterfall(X_wall1,Y_wall1,Z_wall1);
    %Plotting the second wall:
    Wall2=false(n,n);
    Z_wall2 = zeros(n,n);
    for i=1:n
        filename=[char(Bitmaps_dir) '/' char(wall2_str) '/' int2str(i) '.png'];
        Wall2(:,:)=imread(filename);
        Z_wall2(Wall2') = i;
    end
    [X_wall2,Y_wall2] = meshgrid((1:n),(1:n));
    waterfall(X_wall2,Y_wall2,Z_wall2);
    
else %The full workspace was entered at once
    Workspace = false(n,n);
    Z_workspace = zeros(n,n);
    for i=1:n
        filename=[char(Bitmaps_dir) '/' char(workspace_str) '/' int2str(i) '.png'];
        Workspace(:,:)=imread(filename);
        Z_workspace(Workspace') = i;
    end
    [X_workspace,Y_workspace] = meshgrid((1:n),(1:n));
    waterfall(X_workspace,Y_workspace,Z_workspace);
end

%Over plot the contact points:
plot3(x_contact_surf, y_contact_surf, z_contact_surf, ...
    'r.','markersize', 6);
title('Mapping x_{surface} and y_{surface} back to the surface')
view(-15,65); axis equal; box on; colormap cool;
xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis')
hold off;

fprintf('The robot bounced a total of %i times \n', bounces);
delete(handle);
clear variables;
toc
