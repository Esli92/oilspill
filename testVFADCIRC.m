%script to test VectorFieldsADCIRC.m class

close all; clear; clc; format compact

%tic()
addLocalPaths()


modelConfig                    = ModelConfig;
modelConfig.lat                =  28.738;
modelConfig.lon                = -88.366;
modelConfig.startDate          = datetime(2010,04,22); % Year, month, day
modelConfig.endDate            = datetime(2010,04,25); % Year, month, day
% modelConfig.endDate            = datetime(2010,08,26); % Year, month, day
modelConfig.timeStep           = 0.5;    % 6 Hours time step
modelConfig.barrelsPerParticle = 50; % How many barrels of oil are we goin to simulate one particle.
modelConfig.depths             = [0];

modelConfig.totComponents      = 8;
modelConfig.components         = [0.05 0.20 0.30 0.20 0.10 0.05 0.05 0.05];
%modelConfig.colorByComponent   = colorGradient([1 0 0],[0 0 1],modelConfig.totComponents)% Creates the colors of the oil
modelConfig.colorByComponent   = colorGradient([0 1 0],[0 0 1],modelConfig.totComponents);% Creates the colors of the oil


modelConfig.windcontrib        = 0.035;   % Wind contribution
modelConfig.turbulentDiff      = 1;       % Turbulent diffusion
modelConfig.diffusion          = .005;    % Variance (in degrees) for random diffusion when initializing particles

modelConfig.subSurfaceFraction = [ ];
modelConfig.decay.evaporate    = 1;
modelConfig.decay.biodeg       = 1;
modelConfig.decay.burned       = 1;
modelConfig.decay.collected    = 1;
modelConfig.decay.byComponent  = threshold(95,[3, 6, 9, 12, 15, 18, 21, 24],modelConfig.timeStep);
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
VAD                 = VectorFieldsADCIRC(0, atmFilePrefix, oceanFilePrefix, uvar, vvar);

VAD = VAD.readUV(5, 116, modelConfig);
VAD                 = VAD.readLists(); 
% VF                 = VectorFields(0, atmFilePrefix2, oceanFilePrefix2, uvar2, vvar2);

% VF = VF.readUV(1, 116, modelConfig);

