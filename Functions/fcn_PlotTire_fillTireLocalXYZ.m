function cellArrayOfPoints = fcn_PlotTire_fillTireLocalXYZ(tireParameters, varargin)
%fcn_PlotTire_fillTireLocalXYZ - fills in the tire's XYZ coordinate view points
%
% FORMAT:
%
%      cellArrayOfPoints = fcn_PlotTire_fillTireLocalXYZ(tireParameters, (displayModel), (figNum));
%
% INPUTS:
%
%      tireParameters - a structure containing key measurements of the tire
%      as specified by the tireCodeCharacters.
%
%      (OPTIONAL INPUTS)
%
%      displayModel - an integer representing the display model to use
%
%          1: (default) wire frame cylinder, saved in cell array 1
%
%          2: elliptical cornered sidewall donut, saved in cell array 2
%             (uses fcn_PlotTire_roundedRectangle)
%          3: elliptical cornered sidewall donut with tread
%
%
%      figNum - a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% OUTPUTS:
%
%      cellArrayOfPoints - a cell array containing layers of points, with
%      additional complexity depending on the method used
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_PlotTire_fillTireLocalXYZ
%     for a full test suite.
%
% This function was written on 2026_02_18 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_02_18 by Sean Brennan, sbrennan@psu.edu
% - In fcn_PlotTire_fillTireLocalXYZ
%   % * Wrote the code originally, using fcn_PlotTire_fillTireLocalXY
%   %   % as starter


% TO-DO:
%
% 2026_02_18 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 3; % The largest Number of argument inputs to the function
flag_max_speed = 0; % The default. This runs code with all error checking
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
	flag_do_debug = 0; %#ok<NASGU> % Flag to plot the results for debugging
	flag_check_inputs = 0; % Flag to perform input checking
	flag_max_speed = 1;
else
	% Check to see if we are externally setting debug mode to be "on"
	flag_do_debug = 0; %#ok<NASGU> % Flag to plot the results for debugging
	flag_check_inputs = 1; % Flag to perform input checking
	MATLABFLAG_PLOTTIRE_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_PLOTTIRE_FLAG_CHECK_INPUTS");
	MATLABFLAG_PLOTTIRE_FLAG_DO_DEBUG = getenv("MATLABFLAG_PLOTTIRE_FLAG_DO_DEBUG");
	if ~isempty(MATLABFLAG_PLOTTIRE_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_PLOTTIRE_FLAG_DO_DEBUG)
		flag_do_debug = str2double(MATLABFLAG_PLOTTIRE_FLAG_DO_DEBUG); %#ok<NASGU>
		flag_check_inputs  = str2double(MATLABFLAG_PLOTTIRE_FLAG_CHECK_INPUTS);
	end
end

flag_do_debug = 0;

if flag_do_debug % If debugging is on, print on entry/exit to the function
	st = dbstack; %#ok<*UNRCH>
	fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
	debug_figNum = 999978; 
else
	debug_figNum = []; %#ok<NASGU>
end

%% check input arguments?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0==flag_max_speed
	if flag_check_inputs
		% Are there the right number of inputs?
		narginchk(MAX_NARGIN-2,MAX_NARGIN);

		% Validate tireParameters that it is characters or string
		% fcn_DebugTools_checkInputsToFunctions(tireParameters, '_of_char_strings');
		% Required fields check (minimal)
		reqFields = ["sectionWidth_m","radius_m"];
		for fth_field = reqFields
			if ~isfield(tireParameters, fth_field)
				error('Missing field %s in input struct.', fth_field);
			end
		end
	end
end

% Does the user want to specify the displayModel?
% Set defaults first:
displayModel = 1; % Default case

% Check for user input
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
		displayModel = temp;        
    end
end

% % Does the user want to specify excursion_definition?
% flag_use_excursion_definition = 0; % Default case
% flag_excursion_is_a_point_type = 1; % Default case
% if 4 <= nargin
%     temp = varargin{2};
%     if ~isempty(temp)
%         % Set the excursion values
%         [flag_excursion_is_a_point_type, excursion_definition] = fcn_Laps_checkZoneType(temp, 'excursion_definition',-1);
%         flag_use_excursion_definition = 1;
%     end
% end

% Does user want to show the plots?
flag_do_plots = 0; % Default is to show plots
figNum = [];
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
	temp = varargin{end};
	if ~isempty(temp) % Did the user NOT give an empty figure number?
		figNum = temp; 
		flag_do_plots = 1;
	end
end


%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cellArrayOfPoints = cell(displayModel,1);


if displayModel>=1

	tire_radius = tireParameters.radius_m;
	
    spoke_interval = 20*pi/180;
    tire_spoke_angles = (0:spoke_interval:2*pi)'; %  - tire.rolling_angle;
    N_spokes = length(tire_spoke_angles);
    tire_spoke_y = tire_radius*cos(tire_spoke_angles);
    tire_spoke_z = tire_radius*sin(tire_spoke_angles);
    
    % The spokes are set up as [x_start y_start z_start x_end y_end z_end]
    tire_spoke_start = ...
        [(-tireParameters.sectionWidth_m /2)*ones(N_spokes,1), tire_spoke_y, tire_spoke_z];
    tire_spoke_end = ...
        [(+tireParameters.sectionWidth_m /2)*ones(N_spokes,1), tire_spoke_y, tire_spoke_z];
    tire_spokes = [tire_spoke_start, tire_spoke_end, ones(N_spokes,1)*[nan nan nan]];

	% Redistribute the data so that it is [XYZstart; XYZend; nan]
	tireSpokesXYZ = reshape(tire_spokes',3,[])';

	XYZpoints = [tireSpokesXYZ; tire_spoke_start; nan nan nan; tire_spoke_end];




	% For debugging
	if flag_do_debug
		figure(debug_figNum);
		clf;
		plot3(XYZpoints(:,1),XYZpoints(:,2),XYZpoints(:,3));
		axis equal;
		xlabel('X');
		ylabel('Y');
		zlabel('Z');
		view(3)
	end

	cellArrayOfPoints{1,1} = XYZpoints;
end

if displayModel>=2
	% Fill parameters
	L = tireParameters.sectionWidth_m;
	W = tireParameters.sidewallHeight_m;
	cornerShape = 'ellipse';
	cornerParams = [L/4 W/20];
	NcornerPoints = 24;

	% Call the fcn_PlotTire_roundedRectangle function
	rawCrossSection = fcn_PlotTire_roundedRectangle(L, W, ...
		(cornerShape), (cornerParams), (NcornerPoints), (-1));

	offsetY = tireParameters.sidewallHeight_m/2 + tireParameters.rimDiameter_m/2;
	rawCrossSection = [rawCrossSection; rawCrossSection(1,:)];
	Ncross = size(rawCrossSection,1);
	tireCrossSection = rawCrossSection + ones(Ncross,1)*[0 offsetY];
	

	if 1==0
		% Load template squre with rounded corners
		% see: script_test_fcn_PlotWZ_fillPolygonBase.m
		Nsides = 4;
		Npoints_per_half_edge = 1;
		radius_of_round = 0.3;
		Npoints_per_half_round = 2;
		points = fcn_PlotWZ_fillPolygonBase(Nsides,Npoints_per_half_edge,radius_of_round, Npoints_per_half_round, debug_fig);
		points_normalized = points/max(max(points)); % Normalize to 1

		inner_radius = 0.7; % How far the inner radius is, as percentage of outer radius
		shift_up = (1+inner_radius)/2;
		resizing = (1-shift_up);
		tireCrossSection = (points_normalized*[1 0;0 resizing])+[0 shift_up];
	end

	if flag_do_debug
		figure(387383); plot(tireCrossSection(:,1),tireCrossSection(:,2),'k.-');
	end



    N_cross_sections = length(tireCrossSection(:,1));
    
    %     % Find the ones greater than zero, use these as radii
    %     first_negative_y = find(points(:,2)<0,1);
    %     positive_radii = points(1:(first_negative_y-1),:);
    %     figure(2222);
    %     plot(positive_radii(:,1),positive_radii(:,2),'k.-');
    
    % Define a base circle
    Npoints = 72;
    base_vertex_angles_in_degrees = linspace(0,360,Npoints)';
    circular_XZ_points_normalized = [cos(base_vertex_angles_in_degrees*pi/180) sin(base_vertex_angles_in_degrees*pi/180)];
    
    
    % Stack the circles with radii to make 3D mesh   
    ones_lens = ones(length(circular_XZ_points_normalized(:,1)),1);    
    tire_cross_sections(N_cross_sections).data = []; % Initialize the array
    for ith_cross_section = 1:N_cross_sections
        % Assume a circular cross section, and use the x value to get the
        % height
        y_height = tireCrossSection(ith_cross_section,1);
        
        % Use the y value to get the radius of the tire
        radius =  tireCrossSection(ith_cross_section,2);
        cross_section_xz = circular_XZ_points_normalized*radius;
        
        tire_cross_sections(ith_cross_section).data = [cross_section_xz(:,1) y_height*ones_lens cross_section_xz(:,2)];
        tire_cross_sections(ith_cross_section).color = [0.5 0.5 0.5];
    end
    
    % plot the final result?
    if flag_do_debug
        
        figure(454545);
        clf;
        hold on;
        grid on
        axis equal
        
        lightangle(gca,45,30)
        lighting flat
        shading flat
    end
    
    h_tire_data = fcn_PlotWZ_createPatchesFromNSegments(tire_cross_sections,[]);

	if 1==0
		% Plot the tire
		h_tire = patch(h_tire_data);
		set(h_tire,'FaceColor','flat','FaceAlpha','0.8','EdgeColor',[1 1 1]*0.2, 'EdgeAlpha',0.1);
		axis equal;
		view(3);
	end

	cellArrayOfPoints{2,1} = h_tire_data;
end

if displayModel>=3

	% Create a repeating pattern from -1 to 0 in X, and -1 to 1 in Y. This
	% pattern will be flipped in X and then repeated at many angles to
	% define the tire tread
	halfTreadPattern = [
		0.2000   -1
		0.2000    1
		NaN       NaN
		0.2000   -1
		0.7000    0
		NaN       NaN
		0.7000   -1
		0.7000    1
		NaN       NaN
		0.7000    0
		0.9000    0
		];

	fullTreadPattern = fcn_INTERNAL_flipNegateAndAppend(halfTreadPattern, 0);
	if 1==0
		figure(48484);
		clf;
		plot(fullTreadPattern(:,1),fullTreadPattern(:,2),'-');
		axis equal;
	end

	treadPattern = [fullTreadPattern; nan nan];

	% Find the radius versus X-posiiton for this tire
	rawCrossSectionXnormalized = rawCrossSection(:,1)./max(rawCrossSection(:,1));
	rawCrossSectionYnormalized = rawCrossSection(:,2)./max(rawCrossSection(:,2));
	XYpointsNormalized = [rawCrossSectionXnormalized rawCrossSectionYnormalized]/2;

	if 1==0
		figure(979797);
		clf;
		plot(XYpointsNormalized(:,1),XYpointsNormalized(:,2),'-');
		axis equal;
	end

	firstNegativeValue = find(XYpointsNormalized(:,2)<0,1);
	positiveNormalizedHalfProfile = [0 0.5; XYpointsNormalized(1:firstNegativeValue-1,:)];
	positiveNormalizedProfile = 2*positiveNormalizedHalfProfile;
	fullNormalizedProfile = fcn_INTERNAL_flipNegateAndAppend(positiveNormalizedProfile, 1);

	if 1==0
		figure(56565);
		clf;
		plot(fullNormalizedProfile(:,1),fullNormalizedProfile(:,2),'-');
		axis equal;
	end

	% Find the radius multiplier for the tread pattern. This is how much
	% (percentage) the radius is at each x-value
	radiusMultiplier = 1.02*interp1(fullNormalizedProfile(:,1),fullNormalizedProfile(:,2),treadPattern(:,1));


	% Across many angles in the tire, from 0 to 180, calculate what the
	% pattern looks like from the top
	Nangles = 32;

	allTread = [];
	allAngles = linspace(0,2*pi,Nangles+1)';
	deltaAngle = allAngles(2)-allAngles(1);


	% Loop through the angles from 0 to 360 degrees (not repeated the
	% ends). Each y value in the tread pattern is an angle, and each x
	% value is a radius. Use these to calculate the XYZ positions of all
	% the points.

	% Find the x pattern and radii for the treadPattern. These don't change
	% with angle
	xPattern = treadPattern(:,1).*tireParameters.sectionWidth_m/2;
	radii = radiusMultiplier*tireParameters.radius_m;

	for ith_angle = 1:Nangles

		% Find the angles for this specific section of tire
		angleStart = allAngles(ith_angle);
		angleEnd = angleStart+deltaAngle;
		angles = interp1([-1 1],[angleStart angleEnd],treadPattern(:,2));


		% Calculate XYZ values
		XYZtread = [xPattern radii.*cos(angles) radii.*sin(angles)];

		% Append results into growing array
		allTread = [allTread; XYZtread; nan nan nan]; %#ok<AGROW>

		% For debugging
		if 1==0 %flag_do_debug
			figure(23432);clf;
			plot(allTread(:,1),allTread(:,2),'k-','Linewidth',2);
			axis equal
		end
	end

	% % Shift tread upward
	% allTread(:,3) = allTread(:,3)+tireParameters.radius_m;


	% tempCellArray = cell(2,1);
	% for ith_cell = 1:2
	% 	tempCellArray{ith_cell,1} = cellArrayOfPoints{ith_cell,1};
	% end
	% 
	% % Call the plot function
	% tireNameString = [];
	% vehicleNameString = [];
	% fcn_PlotTire_plotTireXYZ(tempCellArray, (tireNameString), (vehicleNameString), (figNum));
	% 
	% % % Plot the tire
	% % fcn_PlotTire_fillTireLocalXYZ(tireParameters, (2), (-1));
	% 
	% plot3(allTread(:,1),allTread(:,2),allTread(:,3),'k-','Linewidth',2);

	cellArrayOfPoints{3,1} = allTread;
end

%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots
	tireNameString = [];
	vehicleNameString = [];
	fcn_PlotTire_plotTireXYZ(cellArrayOfPoints, (tireNameString), (vehicleNameString), (figNum));
end

if flag_do_debug
	fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function

%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

function fullPattern = fcn_INTERNAL_flipNegateAndAppend(inputHalfPattern, flagKeepOnlyUnique)
% Flips the pattern, change the negative x to positive, and append to
% the end to define the entire pattern from -1 to 1 in x, -1 to 1 in y

Npatterns = size(inputHalfPattern,1);
flippedHalfPattern = flipud(inputHalfPattern.*(ones(Npatterns,1)*[-1 1]));
fullPatternWithRepeats = [flippedHalfPattern; inputHalfPattern];

% Keep only the unique values
if 1==flagKeepOnlyUnique
	[~, indicesUnique] = unique(fullPatternWithRepeats(:,1));
	fullPattern = fullPatternWithRepeats(indicesUnique,:);
else
	fullPattern = fullPatternWithRepeats;
end


% For debugging - plot the pattern?
if 1==0
	figure(38383);clf;
	plot(fullPattern(:,1),fullPattern(:,2),'k-','Linewidth',2);
end
end