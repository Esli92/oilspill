function [Uout] = interpTRI1(lon, lat, Uin, xp, yp)
% INTERPTRI1   Interpolate to nonstructured mesh.
%   UOUT = INTERPTRI1(LON,LAT,UIN,X,Y) takes a nonstructured mesh node
%   positions in LON,LAT with values UIN in each node, and interpolates the
%   value to every X,Y desired point. LON,LAT,UIN must have the same
%   dimensions, which correspond to the number of nodes in the mesh (with
%   each line number corresponding to the node number in the mesh). XP and
%   YP are vectors with the same dimension with each other, but not
%   necessarily the same dimension as LON,LAT. 
%
%   This function uses the matlab built-in function 'scatteredInterpolant'
%
%   Example: lat = double(ncread(OceanFile,'y'));
%            lon = double(ncread(OceanFile,'x'));
%            UD = double(ncread(OceanFile,'uvel',[1, 1],[Inf, 1]))
%            xp = [-99.5,-99]
%            yp = [19,20]
%            [U_xp_yp] = interpTRI1(lon, lat, UD, xp, yp)
%
% Create the interpolant object.    
    F = scatteredInterpolant(lon,lat,Uin);
    F.ExtrapolationMethod = 'none';
    
%     F.Values = Uin;

% Evaluate the interpolant at query locations (xp,yp).
    Uout = F(xp,yp);

% Remove the interpolant object
    clear F
end