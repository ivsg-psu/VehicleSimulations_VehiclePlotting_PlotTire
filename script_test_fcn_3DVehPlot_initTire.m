% script_test_fcn_3DVehPlot_initTire.m - a script to test the function which
% draws a tire

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
fig_num = 1;
tire = fcn_3DVehPlot_initTire;
fcn_drawTire(tire,fig_num);


sgtitle('Showing a plain tire.');
fprintf(1,'Figure %.0d shows a plain tire.\n',fig_num);
