% In this new version, the objective is to make the code as efficient as possible
close all; clear; clc; format compact

tic()
%===============ADCIRC EXCLUSIVE==============
addLocalPathsADCIRC()

modelConfig                    = ModelConfig;
% Coordenadas del derrame de BP
% modelConfig.lat                =  28.738;
% modelConfig.lon                = -88.366;
% Coordenadas del derrame en el SAV
modelConfig.lat                =  19.1965;
modelConfig.lon                = -96.0800;
modelConfig.startDate          = datetime(2010,04,23); % Year, month, day
modelConfig.endDate            = datetime(2010,04,28); % Year, month, day
% modelConfig.endDate            = datetime(2010,08,26); % Year, month, day
modelConfig.timeStep           = 6;    % 6 Hours time step
modelConfig.barrelsPerParticle = 50; % How many barrels of oil are we goin to simulate one particle.
modelConfig.depths             = [0];

modelConfig.totComponents      = 8;
modelConfig.components         = [0.05 0.20 0.30 0.20 0.10 0.05 0.05 0.05];
%modelConfig.colorByComponent   = colorGradient([1 0 0],[0 0 1],modelConfig.totComponents)% Creates the colors of the oil
modelConfig.colorByComponent   = colorGradient([0 1 0],[0 0 1],modelConfig.totComponents);% Creates the colors of the oil


modelConfig.windcontrib        = 0.035;   % Wind contribution
% modelConfig.windcontrib        = 10;   % Wind contribution
modelConfig.turbulentDiff      = 1;       % Turbulent diffusion
modelConfig.diffusion          = .005;    % Variance (in degrees) for random diffusion when initializing particles

modelConfig.subSurfaceFraction = [ ];
modelConfig.decay.evaporate    = 1;
modelConfig.decay.biodeg       = 1;
modelConfig.decay.burned       = 1;
modelConfig.decay.collected    = 1;
modelConfig.decay.byComponent  = threshold(95,[3, 6, 9, 12, 15, 18, 21, 24],modelConfig.timeStep);
modelConfig.initPartSize = 10*(24/modelConfig.timeStep); % Initial size of particles vector array of lats, lons, etc.

%===============ADCIRC EXCLUSIVE==============
atmFilePrefix  = 'fort.74.'; % File prefix for the atmospheric netcdf files
oceanFilePrefix  = 'fort.64.'; % File prefix for the ocean netcdf files
%oceanFilePrefix  = 'hycom_2019_'; % File prefix for the ocean netcdf files
uvar = 'u-vel';
vvar = 'v-vel';
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

%===============ADCIRC EXCLUSIVE==============
global VF;
VF                 = VectorFieldsADCIRC(0, atmFilePrefix, oceanFilePrefix, uvar, vvar);
VF                 = VF.readLists(); 
advectingParticles = false;          % Indicate when should we start reading the UV fields
Particles          = Particle.empty; % Start the array of particles empty

%  Initialize the figure for visualization of the particles
if visualize
    f=figure
    DrawGulfOfMexico();
    %% Animating particles
    view(-10.5,28) % Define the angle of view
    zoom(2)
    axis tight;
    set(gca,'BoxStyle','full','Box','on')
end

if visualize2d
    f=figure
    DrawGulfOfMexico2D();
    PartIndx2D = 1;
    %% Animating particles
    set(gca,'BoxStyle','full','Box','on')
end

FinalParticles = {};
startDay = datevec2doy(datevec(modelConfig.startDate));
endDay = datevec2doy(datevec(modelConfig.endDate))
for currDay = startDay:endDay
    sprintf('---- Day %d -----', (currDay - startDay))
    
    % Verify we have some data in this day
    if any(FechasDerrame == currDay)
        advectingParticles = true; % We should start to reading vector fields and advecting particles
        % Read from Fechas derrame and init proper number of particles. In a function
        spillData = spillData.splitByTimeStep(modelConfig, currDay);
    end
    
    for currHour = 0:modelConfig.timeStep:24-modelConfig.timeStep
        currTime = toSerialDate(modelConfig.startDate.Year, currHour, currDay);
        nextTime = toSerialDate(modelConfig.startDate.Year, currHour+modelConfig.timeStep, currDay);
        if advectingParticles
            % Add the proper number of particles for this time step
            Particles = initParticles(Particles, spillData, modelConfig, currDay, currHour);

            % Read winds and currents
            VF = VF.readUV(currHour, currDay, modelConfig);

            % Advect particles
            
            %===============ADCIRC EXCLUSIVE==============
            Particles = advectParticlesADCIRC(VF, modelConfig, Particles, nextTime);
            
            % Degrading particles
            Particles = oilDegradation(Particles, modelConfig, spillData);
        end
        %  Visualize the current step
        if visualize
            %plotParticlesSingleTime(Particles, modelConfig, f, currDay - startDay)
            LiveParticles = findobj(Particles, 'isAlive',true);
            DeadParticles = findobj(Particles, 'isAlive',false);
            if  currDay - startDay == 0
                hold on
                f = scatter3([LiveParticles.lastLon], [LiveParticles.lastLat], ...
                    -[LiveParticles.lastDepth],9,modelConfig.colorByComponent([LiveParticles.component],:),'filled');
                
                %h = scatter3([DeadParticles.lastLon], [DeadParticles.lastLat], ...
                %-[DeadParticles.lastDepth],9,'r','filled');
                f.XDataMode = 'manual';
                h.XDataMode = 'manual';
                drawnow
            else
                f.XData = [LiveParticles.lastLon];
                f.YData = [LiveParticles.lastLat];
                f.ZData = -[LiveParticles.lastDepth];
                f.CData = modelConfig.colorByComponent([LiveParticles.component],:);
                
                %h.XData = [DeadParticles.lastLon];
                %h.YData = [DeadParticles.lastLat];
                %h.ZData = -[DeadParticles.lastDepth];
                refreshdata
                drawnow
            end
            
        end

	if visualize2d
            %plotParticlesSingleTime(Particles, modelConfig, f, currDay - startDay)
            LiveParticles = findobj(Particles, 'isAlive',true);
            DeadParticles = findobj(Particles, 'isAlive',false);
            if PartIndx2D == 1
                latlim = [min([LiveParticles.lastLat])-1.5 max([LiveParticles.lastLat])+1.5];
                lonlim= [min([LiveParticles.lastLon])-1.5 max([LiveParticles.lastLon])+1.5];
                axis([lonlim(1) lonlim(2) latlim(1) latlim(2)]);
%                 axis([-100 -92 17 22]);              
%                 axis([-96.2 -96 19.10 19.26]); 
                PartIndx2D = 2;
            end
            if  currDay - startDay == 0
                hold on
                f = scatter([LiveParticles.lastLon], [LiveParticles.lastLat], ...
                    9,modelConfig.colorByComponent([LiveParticles.component],:),'filled');
                
                %h = scatter3([DeadParticles.lastLon], [DeadParticles.lastLat], ...
                %-[DeadParticles.lastDepth],9,'r','filled');
                f.XDataMode = 'manual';
                h.XDataMode = 'manual';
                drawnow
            else
                f.XData = [LiveParticles.lastLon];
                f.YData = [LiveParticles.lastLat];
                %f.ZData = -[LiveParticles.lastDepth];
                f.CData = modelConfig.colorByComponent([LiveParticles.component],:);
                
                %h.XData = [DeadParticles.lastLon];
                %h.YData = [DeadParticles.lastLat];
                %h.ZData = -[DeadParticles.lastDepth];
                refreshdata
                drawnow
            end
	end

        %pause(10)
    end
    
    % Every 5 days we move away the non active particles.
    if mod(currDay,5) == 0
        NonLiveParticles = findobj(Particles, 'isAlive',false);
        FinalParticles = {FinalParticles,NonLiveParticles};
        Particles = findobj(Particles, 'isAlive',true);
    end
    
    sprintf('---- Tot Particles %d -----',length(Particles))
end
toc()

%% Plotting the results
%plotParticles(Particles, modelConfig.startDate, modelConfig.endDate, modelConfig.timeStep)
