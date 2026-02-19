% script_test_fcn_3DVehPlot_drawTire.m - a script to test the function which
% draws a tire,
% fcn_3DVehPlot_drawTire

% Revisions:
% 2022_08_25 - sbrennan@psu.edu
% -- Added fig number explicitly
% -- Made the script verbose


st = dbstack;
fprintf(1,'\nRunning test script:  %s\n',st(1).name);

%%
% Clean  up workspace
close all
clc;

%% Test 1 - plain tire
% Set up the tire information
figNum = 1;
figure(figNum); clf;

tire = fcn_3DVehPlot_initTire;
fcn_3DVehPlot_drawTire(tire,figNum);


sgtitle('Showing a plain tire.');
fprintf(1,'Figure %.0d shows a plain tire.\n',figNum);

%% Test 2 - Change the orientation angle
figNum = 2;
figure(figNum); clf;

% Set up the tire information
tire = fcn_3DVehPlot_initTire;

tire.orientation_angle = 45;
fcn_3DVehPlot_drawTire(tire,figNum);
drawnow;



for angle = 0:5:180
    tire.orientation_angle = angle*pi/180; % the angle of the tire [rad]
    fcn_3DVehPlot_drawTire(tire,figNum);
    sgtitle('Showing changing rotation.');
    drawnow;
end

fprintf(1,'Figure %.0d shows changing rotation.\n',figNum);

%% Test 3 - Change the rolling angle (only works for tire type = 2 or higher)
% Tire type is hard coded inside fcn_3DVehPlot_drawTire

figNum = 3; 
figure(figNum); clf;

% Set up the tire information
tire = fcn_3DVehPlot_initTire;

for angle = 0:2:180
    tire.rolling_angle = angle*pi/180; % the angle of the tire [rad]
    fcn_3DVehPlot_drawTire(tire,figNum);
    xlabel('x');
    ylabel('y');
    sgtitle('Showing tire rolling.');
    drawnow;
end

fprintf(1,'Figure %.0d shows tire rolling.\n',figNum);

% %% Test 4 - Change the tire color via direct color call
% 
% fig_num = 4;
% 
% % Set up the tire information
% tire = fcn_3DVehPlot_initTire;
% color_map = jet(256);
% 
% 
% for color_ind = 1:256
%     plot_color = color_map(color_ind,:);
%     fcn_3DVehPlot_drawTire(tire,plot_color,fig_num);
%     sgtitle('Showing tire coloring from cold to hot.');
%     drawnow;
% end
% 
% fprintf(1,'Figure %.0d shows tire coloring from cold to hot.\n',fig_num);
% 
% %% Test 5 - Change the tire color via percentage force
% 
% fig_num = 5;
% 
% for percentage = 0:0.01:1
%     fcn_3DVehPlot_drawTire(tire,percentage,fig_num);
%     sgtitle('Showing tire coloring as function of percentage usage, direct function call.');
%     drawnow;
% end
% 
% fprintf(1,'Figure %.0d shows tire coloring as function of percentage usage, direct function call.\n',fig_num);
% 
% 
% %% Test 6 - Change the tire color via usage
% fig_num = 6;
% 
% 
% for percentage = 0:0.01:1
%     tire.usage = percentage;
%     fcn_3DVehPlot_drawTire(tire,fig_num);
%     sgtitle('Showing tire coloring as function of percentage usage, as tire structure property.');
%     drawnow;
% end
% 
% fprintf(1,'Figure %.0d shows tire coloring as function of percentage usage, as tire structure property.\n',fig_num);
