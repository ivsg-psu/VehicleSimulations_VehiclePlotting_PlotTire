function cellArrayOfPlotHandles = fcn_PlotTire_plotTireXYZ(cellArrayOfPoints, varargin)
%fcn_PlotTire_plotTireXYZ - plots the tire's XY coordinate view
% FORMAT:
%
%      cellArrayOfPlotHandles = fcn_PlotTire_plotTireXYZ(cellArrayOfPoints, (views), (tirePosition), (tireNameString), (vehicleNameString), (figNum));
%
% INPUTS:
%
%      cellArrayOfPoints - a cell array containing layers of points, with
%      additional complexity depending on the method used
%
%      (OPTIONAL INPUTS)
%
%      views - an array of which views to use, e.g. [3], or [1 3], etc.
%
%      tirePosition - a structure array containing values as follows
%      (defaults are shown)
%
%           tirePosition.position_x = 0;
%           tirePosition.position_y = 0;
%           tirePosition.position_z = 0;
%           tirePosition.orientation_angle = 0;
%           tirePosition.rolling_angle = 0;
%
%      tireNameString - a string used to store handles (in current axis)
%      for this particular tire. Each tire model type will have the model
%      number appended to the end of the string.
%
%      vehicleNameString - a string used to store handles (in current axis)
%      for this particular vehicle.
%
%      figNum - a figure number to plot results. If set to -1,
%      skips any input checking or debugging, no figures will be generated,
%      and sets up code to maximize speed.
%
% OUTPUTS:
%
%      cellArrayOfPlotHandles - a cell array of figure handles, one for each
%      cellArrayOfPoints being plotted
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_PlotTire_plotTireXY
%     for a full test suite.
%
% This function was written on 2026_02_10 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% REVISION HISTORY:
%
% 2026_02_19 by Sean Brennan, sbrennan@psu.edu
% - In fcn_PlotTire_plotTireXYZ
%   % * Wrote function using fcn_PlotTire_plotTireXY as starter

% TO-DO:
%
% 2026_02_19 by Sean Brennan, sbrennan@psu.edu
% - (fill in items here)


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 5; % The largest Number of argument inputs to the function
flag_max_speed = 0; % The default. This runs code with all error checking
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
	flag_do_debug = 0; % Flag to plot the results for debugging
	flag_check_inputs = 0; % Flag to perform input checking
	flag_max_speed = 1;
else
	% Check to see if we are externally setting debug mode to be "on"
	flag_do_debug = 0; % Flag to plot the results for debugging
	flag_check_inputs = 1; % Flag to perform input checking
	MATLABFLAG_PLOTTIRE_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_PLOTTIRE_FLAG_CHECK_INPUTS");
	MATLABFLAG_PLOTTIRE_FLAG_DO_DEBUG = getenv("MATLABFLAG_PLOTTIRE_FLAG_DO_DEBUG");
	if ~isempty(MATLABFLAG_PLOTTIRE_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_PLOTTIRE_FLAG_DO_DEBUG)
		flag_do_debug = str2double(MATLABFLAG_PLOTTIRE_FLAG_DO_DEBUG);
		flag_check_inputs  = str2double(MATLABFLAG_PLOTTIRE_FLAG_CHECK_INPUTS);
	end
end

% flag_do_debug = 1;

if flag_do_debug % If debugging is on, print on entry/exit to the function
	st = dbstack; %#ok<*UNRCH>
	fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
	debug_figNum = 999978; %#ok<NASGU>
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
		narginchk(1,MAX_NARGIN);

	end
end

% Does the user want to specify the tire structure?
tirePosition.position_x = 0;
tirePosition.position_y = 0;
tirePosition.position_z = 0;
tirePosition.orientation_angle = 0;
tirePosition.rolling_angle = 0;

% Check for user input
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
		tirePosition = temp;        
    end
end

% Does the user want to specify the tireNameString?
tireNameString = ''; % Default case
% Check for user input
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
		tireNameString = temp;        
    end
end

% Does the user want to specify the vehicleNameString?
vehicleNameString = ''; % Default case
% Check for user input
if 4 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
		vehicleNameString = temp;        
    end
end

% Does user want to show the plots?
flag_do_plots = 1; % Default is to show plots
figNum = [];
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
	temp = varargin{end};
	if ~isempty(temp) % Did the user NOT give an empty figure number?
		figNum = temp; 
		flag_do_plots = 1;
	end
end

if isempty(figNum)
	temp = figure;
	figNum = get(temp,'Number');
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
% Initialize output
Nmodels = size(cellArrayOfPoints,1);
cellArrayOfPlotHandles = cell(Nmodels,1);

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

	outer_diameter = max(cellArrayOfPoints{1,1}(:,2)) - min(cellArrayOfPoints{1,1}(:,2));
	outer_r = outer_diameter/2; %#ok<NASGU>
	
	% Create figure
	h_fig = figure(figNum);
	set(h_fig,'Name','Tire Top View','Color','w');


	
	% Does user want to try to load the vehicle handle?
	h_vehicle = []; % Default value
	if ~isempty(vehicleNameString)
		h_vehicle = getappdata(gca,vehicleNameString);
	end


	for ith_modelType = 1:Nmodels
		% subplot(1,Ncolumns,ith_plot)
		axis equal; hold on; box on;
		xlabel('meters'); ylabel('meters');




		h_thisTire = []; % Default value

		% Does user want to try to load the tire handle?
		if ~isempty(tireNameString)
			h_thisTire = getappdata(gca,cat(2,tireNameString,sprintf('%.0f',ith_modelType)));
		else
			% Generate a random name
			% rng(0);               % optional for reproducibility
			len = 12;
			alphabet = ['A':'Z' 'a':'z'];
			idx = randi(numel(alphabet), 1, len);
			tireNameString = alphabet(idx);
		end

		% Associate the transform with this handle
		if isempty(h_vehicle)
			ax = gca; % Grab current axes;
			tire_body_transform_object = hgtransform('Parent',ax);
			tire_hub_transform_object = hgtransform('Parent',tire_body_transform_object);
			tire_spokes_transform_object = hgtransform('Parent',tire_hub_transform_object);
		else
			tire_body_transform_object = hgtransform('Parent',h_vehicle);
			tire_hub_transform_object = hgtransform('Parent',tire_body_transform_object);
			tire_spokes_transform_object = hgtransform('Parent',tire_hub_transform_object);
		end


		if ith_modelType ==1

			XYZpoints = cellArrayOfPoints{ith_modelType,1};

			% If data is not there, plot nan values so that plot handle is
			% populated anyway
			if isempty(XYZpoints)
				XYZpoints = [nan nan];
			end

			if isempty(h_thisTire)
				% Plot the tire's contact shadow
				minX = min(XYZpoints(:,1));
				maxX = max(XYZpoints(:,1));
				minY = min(XYZpoints(:,2));
				maxY = max(XYZpoints(:,2));

				tire_box = [...
					minX  maxY;
					maxX  maxY;
					maxX minY;
					minX minY];

				h_contactShadow   = fcn_INTERNAL_plotBox(0,0,tire_box,'k');  % Tire body
				hold on;

				% Associate the plots with the transform object
				set(h_contactShadow,'Parent',tire_body_transform_object);

				% Plot the spoke model
				% FORMAT:
				% h_spokes = fcn_INTERNAL_plot3Dspoke(flag_plot_exists, h_spokes_old, spoke, spoke_angle, varargin)    				
				h_spokePlot = fcn_INTERNAL_plot3Dspoke(0,0,XYZpoints,'b'); % Tire spokes

				% Associate the plots with the transform object
				set(h_spokePlot,'Parent',tire_spokes_transform_object);

				% Save the handles
				h_thisTire.h_spokePlot = h_spokePlot;



				% Rotate and translate the tire body to current orientation angle (e.g.
				% like steering)
				M = makehgtform('translate',[tirePosition.position_x tirePosition.position_y 0],'zrotate',tirePosition.orientation_angle);
				set(tire_body_transform_object,'Matrix',M);

				% Move the hub to the height above the body
				% tire.position_z = max(XYZpoints(:,3));
				M = makehgtform('translate',[0 0 tirePosition.position_z]);
				set(tire_hub_transform_object,'Matrix',M);

				% Rotate the spokes to current theta about the hub
				M = makehgtform('xrotate',-tirePosition.rolling_angle);
				set(tire_spokes_transform_object,'Matrix',M);

				% Save the transforms
				h_thisTire.body_transform_object = tire_body_transform_object;
				h_thisTire.hub_transform_object = tire_hub_transform_object;
				h_thisTire.spokes_transform_object = tire_spokes_transform_object;
				setappdata(gca,tireNameString, h_thisTire);


				view(3);

			else % Update the line positions
				% Move the body of the tire
				M = makehgtform('translate',[tirePosition.position_x tirePosition.position_y tirePosition.position_z],'zrotate',tirePosition.orientation_angle);
				set(h_thisTire.body_transform_object,'Matrix',M);

				% Rotate the spokes around the hub
				M = makehgtform('xrotate',-tirePosition.rolling_angle);
				set(h_thisTire.spokes_transform_object,'Matrix',M);


				% Plot the tire usage?
				if isfield(tirePosition,'usage') && ~isempty(tirePosition.usage)
					if isnumeric(tirePosition.usage)
						plot_str = convertToColor(tirePosition.usage);
						set(h_thisTire.body,'Color',plot_str);
					end
				end
			end

			cellArrayOfPlotHandles{1} = h_thisTire;
		elseif ith_modelType == 2

			if isempty(h_thisTire)

				h_tire_data = cellArrayOfPoints{2,1};
				
				% Plot the tire
				h_tire = patch(h_tire_data);
				set(h_tire,'FaceColor','flat','FaceAlpha','0.9','EdgeColor',[1 1 1]*0.1, 'EdgeAlpha',0.1);
				axis equal;
				view(3);

				% Associate the plots with the transform object
				set(h_tire,'Parent',tire_body_transform_object);

				% Save the handles
				h_thisTire.h_tire = h_tire;



				% Rotate and translate the tire body to current orientation angle (e.g.
				% like steering)
				tirePosition.orientation_angle = tirePosition.orientation_angle + pi/2;
				M = makehgtform('translate',[tirePosition.position_x tirePosition.position_y tirePosition.position_z],'zrotate',tirePosition.orientation_angle);
				set(tire_body_transform_object,'Matrix',M);

				% % Move the hub to the height above the body
				% tire.position_z = max(XYZpoints(:,3));
				% M = makehgtform('translate',[0 0 0]);
				% set(tire_hub_transform_object,'Matrix',M);

				% Rotate the spokes to current theta about the hub
				M = makehgtform('xrotate',-tirePosition.rolling_angle);
				set(tire_spokes_transform_object,'Matrix',M);

				% Save the transforms
				h_thisTire.body_transform_object = tire_body_transform_object;
				h_thisTire.hub_transform_object = tire_hub_transform_object;
				h_thisTire.spokes_transform_object = tire_spokes_transform_object;
				setappdata(gca,tireNameString, h_thisTire);


				view(3);

			else % Update the line positions
				% Move the body of the tire
				M = makehgtform('translate',[tirePosition.position_x tirePosition.position_y tirePosition.position_z],'zrotate',tirePosition.orientation_angle);
				set(h_thisTire.body_transform_object,'Matrix',M);

				% Rotate the spokes around the hub
				M = makehgtform('xrotate',-tirePosition.rolling_angle);
				set(h_thisTire.spokes_transform_object,'Matrix',M);


				% Plot the tire usage?
				if isfield(tirePosition,'usage') && ~isempty(tirePosition.usage)
					if isnumeric(tirePosition.usage)
						plot_str = convertToColor(tirePosition.usage);
						set(h_thisTire.body,'Color',plot_str);
					end
				end
			end

		elseif ith_modelType == 3
			% Draw tread
			if isempty(h_thisTire)

				tempCellArray = cell(2,1);
				for ith_cell = 1:2
					tempCellArray{ith_cell,1} = cellArrayOfPoints{ith_cell,1};
				end

				% Call the plot function
				fcn_PlotTire_plotTireXYZ(tempCellArray, ([]), ([]), ([]), (figNum));

				allTread = cellArrayOfPoints{3,1};
				h_tire = plot3(allTread(:,1),allTread(:,2),allTread(:,3),'k-','Linewidth',2);
			
				% Associate the plots with the transform object
				set(h_tire,'Parent',tire_body_transform_object);

				% Save the handles
				h_thisTire.h_tire = h_tire;



				% Rotate and translate the tire body to current orientation angle (e.g.
				% like steering)
				tirePosition.orientation_angle = tirePosition.orientation_angle + pi/2;
				M = makehgtform('translate',[tirePosition.position_x tirePosition.position_y tirePosition.position_z],'zrotate',tirePosition.orientation_angle);
				set(tire_body_transform_object,'Matrix',M);

				% % Move the hub to the height above the body
				% tire.position_z = max(XYZpoints(:,3));
				% M = makehgtform('translate',[0 0 0]);
				% set(tire_hub_transform_object,'Matrix',M);

				% Rotate the spokes to current theta about the hub
				M = makehgtform('xrotate',-tirePosition.rolling_angle);
				set(tire_spokes_transform_object,'Matrix',M);

				% Save the transforms
				h_thisTire.body_transform_object = tire_body_transform_object;
				h_thisTire.hub_transform_object = tire_hub_transform_object;
				h_thisTire.spokes_transform_object = tire_spokes_transform_object;
				setappdata(gca,tireNameString, h_thisTire);


				view(3);

			else % Update the line positions
				% Move the body of the tire
				M = makehgtform('translate',[tirePosition.position_x tirePosition.position_y tirePosition.position_z],'zrotate',tirePosition.orientation_angle);
				set(h_thisTire.body_transform_object,'Matrix',M);

				% Rotate the spokes around the hub
				M = makehgtform('xrotate',-tirePosition.rolling_angle);
				set(h_thisTire.spokes_transform_object,'Matrix',M);


				% Plot the tire usage?
				if isfield(tirePosition,'usage') && ~isempty(tirePosition.usage)
					if isnumeric(tirePosition.usage)
						plot_str = convertToColor(tirePosition.usage);
						set(h_thisTire.body,'Color',plot_str);
					end
				end
			end

		end

		% % Limits and styling
		% pad = outer_r*0.15;
		% xlim([-outer_r-pad, outer_r+pad]);
		% ylim([-outer_r-pad, outer_r+pad]);
		% set(gca,'FontSize',11);


		xlabel('X');
		ylabel('Y');
		zlabel('Z');
	end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         _       _   ____  _____   _____             _             
%        | |     | | |___ \|  __ \ / ____|           | |            
%   _ __ | | ___ | |_  __) | |  | | (___  _ __   ___ | | _____  ___ 
%  | '_ \| |/ _ \| __||__ <| |  | |\___ \| '_ \ / _ \| |/ / _ \/ __|
%  | |_) | | (_) | |_ ___) | |__| |____) | |_) | (_) |   <  __/\__ \
%  | .__/|_|\___/ \__|____/|_____/|_____/| .__/ \___/|_|\_\___||___/
%  | |                                   | |                        
%  |_|                                   |_|                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% fcn_INTERNAL_plot3Dspoke
function h_spokes = fcn_INTERNAL_plot3Dspoke(flag_plot_exists, h_spokes_old, spokeXYZ, varargin)    % plot all the spokes

plot_str = 'b-';
plot_type = 1;

if 5 == nargin
    plot_str = varargin{1};
    if isnumeric(plot_str)
        plot_type = 2;
        plot_str = convertToColor(plot_str);
    end
end


% % Tag hidden angles to hide them
% spoke_angle = mod(spoke_angle,2*pi);
% spoke(spoke_angle>pi,:) = NaN;


xdata = spokeXYZ(:,1); 
ydata = spokeXYZ(:,2); 
zdata = spokeXYZ(:,3);


% Check if plot already exists
if ~flag_plot_exists  % It does not exist, create it then
    if plot_type==1
        h_spokes = plot3(xdata,ydata,zdata,plot_str);
    elseif plot_type==2
        h_spokes = plot3(xdata,ydata,zdata,'Color',plot_str);
    end
else % It exists already
    set(h_spokes_old,'XData',xdata);
    set(h_spokes_old,'YData',ydata);
    if plot_type==2
        set(h_spokes_old,'Color',plot_str);
    end
    h_spokes = h_spokes_old;
end


end % Ends fcn_INTERNAL_plot3Dspoke



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____  _       _   ____
%  |  __ \| |     | | |  _ \           
%  | |__) | | ___ | |_| |_) | _____  __
%  |  ___/| |/ _ \| __|  _ < / _ \ \/ /
%  | |    | | (_) | |_| |_) | (_) >  < 
%  |_|    |_|\___/ \__|____/ \___/_/\_\
%                                      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% fcn_INTERNAL_plotBox
function h_box = fcn_INTERNAL_plotBox(flag_plot_exists, h_box_old, corners, varargin)    % plot all the boxes

plot_str = 'k-';
plot_type = 1;

if 4 == nargin
    plot_str = varargin{1};
    if isnumeric(plot_str)
        plot_type = 2;
        plot_str = convertToColor(plot_str);
    end
end

% Close the box back into itself
xdata = [corners(:,1); corners(1,1)];
ydata = [corners(:,2); corners(1,2)];


% Check if plot already exists
if ~flag_plot_exists  % It does not exist, create it then
    if plot_type==1
        h_box = plot(xdata,ydata,plot_str);
    elseif plot_type==2
        h_box = plot(xdata,ydata,'Color',plot_str);
    end
else % It exists already
    set(h_box_old,'XData',xdata);
    set(h_box_old,'YData',ydata);
    if plot_type==2
        set(h_box_old,'Color',plot_str);
    end
    h_box = h_box_old;
end


end % Ends fcn_INTERNAL_plotBox function