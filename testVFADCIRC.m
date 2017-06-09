close all; clear; clc; format compact

tic()
[inputFolder outputFolder] = addLocalPaths();


modelConfig                    = ModelConfig; % Create an object of type ModelConfig
modelConfig.model              = 'adcirc'
modelConfig.lat                =  19.1965;
modelConfig.lon                = -96.08;
modelConfig.startDate          = datetime(2010,04,26); % Year, month, day
modelConfig.endDate            = datetime(2010,04,27); % Year, month, day
modelConfig.timeStep           = 6;    % 6 Hours time step
modelConfig.barrelsPerParticle = 10; % How many barrels of oil are we goin to simulate one particle.
%modelConfig.depths             = [0 3 350 700 1100]; % First index MUST be 0 (surface)
modelConfig.depths             = [0,100,1000]; % First index MUST be 0 (surface)
modelConfig.depths             = [0]; % First index MUST be 0 (surface)

modelConfig.components         = [[.1 .1 .1 .1 .1 .1 .1 .3]; ...
                                  [0 0 0 .1 .1 .1 .2 .5]; ...
                                  [0 0 0 0 .1 .1 .2 .6]; ...
                                  [0 0 0 0 .1 .1 .2 .6]; ...
                                  [0 0 0 0 0 .1 .2 .7]];

modelConfig.totComponents      = length(modelConfig.components(1,:)); 

modelConfig.visualize          = true; % Indicates if we want to visualize the results as the model runs.
modelConfig.saveImages         = false; % Indicate if we want to save the generated images
%modelConfig.colorByComponent   = colorGradient([1 1 1],[0 0 .7],modelConfig.totComponents)% Creates the colors of the oil
modelConfig.colorByComponent   = [ [1 0 0]; [.89 .69 .17]; [1 1 0]; [0 0 1]; [0 1 0]; [0 1 1]; [0 0 1]; [1 0 1];[.7 0 .7]];
modelConfig.colorByDepth       = [ [0 0 1]; [1 0 0]; [1 1 0]; [0 1 0]; [0 1 1]];
modelConfig.outputFolder       = outputFolder;


modelConfig.windcontrib        = 0.035;   % Wind contribution
modelConfig.turbulentDiff      = [1,1,1,1,1]; % Turbulent diffusion (surface and each depth)
modelConfig.diffusion          = [.05,.05,.05,.05,.05];% (2 STD)(in km) for random diffusion when initializing particles

%modelConfig.subSurfaceFraction = [1/5,1/5,1/5,1/5,1/5];
modelConfig.subSurfaceFraction = [1/2,1/2];
modelConfig.decay.evaporate    = 1;
modelConfig.decay.exp_degradation = 1; % Exponential degradation
modelConfig.decay.burned       = 1;
modelConfig.decay.burned_radius = 3; % Radius where we are going tu burn particles (in km)
modelConfig.decay.collected    = 1;

% TODO validate the sizes of turbulentDiff, diffusion and subSurfaceFraction with number of subsurface

modelConfig.decay.exp_deg.byComponent  = threshold(95,[15, 30, 45, 60, 75, 90,120, 180],modelConfig.timeStep);
% This is just for memory allacation  (TODO make something smarter)
modelConfig.initPartSize = 10*(24/modelConfig.timeStep); % Initial size of particles vector array of lats, lons, etc.

atmFilePrefix  = '../OilSpillDataADCIRC/caso_01/fort.74.'; % File prefix for the atmospheric netcdf files
oceanFilePrefix  = '../OilSpillDataADCIRC/caso_01/fort.64.'; % File prefix for the ocean netcdf files
% atmFilePrefix2  = '/home/esli/Dropbox/particle_tracking/OilSpillData/Dia_'; % File prefix for the atmospheric netcdf files
% oceanFilePrefix2  = '/home/esli/Dropbox/particle_tracking/OilSpillData/archv.2010_';
%oceanFilePrefix  = 'hycom_2019_'; % File prefix for the ocean netcdf files
uvar = 'u-vel';
vvar = 'v-vel';
% uvar2 = 'U';
% vvar2 = 'V';
visualize = false; % Indicates if we want to visualize the results as the model runs.
visualize2d = true; %For 2D plots instead of 3D.

% La funcion cantidades_por_dia determina las distintas cantidades de petroleo
% a partir de los datos del derrame en el archivo "datos_derrame.csv"
% FechasDerrame      = Dias julianos en los que hubo derrame de petroleo
% SurfaceOil1        = Cantidad de petroleo en superficie
% VBU                = Cantidad de petroleo quemado
% VE                 = Cantidad de petroleo evaporado
% VNW                = Cantidad de petroleo recuperado en agua
% VDB                = Cantidad de petroleo dispersado en la sub-superficie
[FechasDerrame,SurfaceOil,VBU,VE,VNW,VDB] = cantidades_por_dia;
spillData          = OilSpillData(FechasDerrame,SurfaceOil,VBU,VE,VNW,VDB);


global VF;
VF                 = VectorFieldsADCIRC(0, atmFilePrefix, oceanFilePrefix, uvar, vvar);

VF = VF.readUV(22, 114, modelConfig);
VF                 = VF.readLists();
%VF                 = VectorFields(0, atmFilePrefix2, oceanFilePrefix2, uvar2, vvar2);
Particles          = Particle.empty; % Start the array of particles empty

if any(FechasDerrame == 116)
    advectingParticles = true; % We should start to reading vector fields and advecting particles
    % Read from Fechas derrame and init proper number of particles. In a function
    spillData = spillData.splitByTimeStep(modelConfig, 116);
end


Particles = initParticles(Particles, spillData, modelConfig, 116, 5);
%Find pele of particle
for ii=1:length(Particles)
    Particles(ii).pele = findTRIParticleIni2(Particles(ii).lastLon,Particles(ii).lastLat);
end
% VF = VF.readUV(1, 116, modelConfig);

lat = -96.08;
lon = 19.2023;
peletmp = findTRIParticleIni2(lat,lon)
