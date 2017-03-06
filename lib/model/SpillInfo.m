classdef SpillInfo
   properties
      startDate % Start date of the simulation in julian dates
      endDate   % End date of the simulation in julian dates
      lat       % Latitude of the spill
      lon        % Longitude of the spill
      depths    % Array of depths to be used
      components % Array of components for each depth
      subSurfaceFraction % Array with the fraction of oil spilled at each subsurface depth
      decay
      timeStep   % The time step is in hours and should be exactly divided by 24
   end
   % TODO constructor that initializes all these fields and validates the input
end

