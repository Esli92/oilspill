function [Uout] = interpTRI1(lon, lat, Uin, xp, yp)

% Create the interpolant.    
    F = scatteredInterpolant(lon,lat,Uin);
    F.ExtrapolationMethod = 'none';

% Evaluate the interpolant at query locations (xp,yp).

    Uout = F(xp,yp);

    clear F
end