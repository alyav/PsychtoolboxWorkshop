%% Example 1: draw a green rectangle on the center of the screen
 
% Clear the workspace and close screens
sca;         % closes all screens  
clear all;   % clear all variables

input ('start>>>','s'); % prints to command window

try
% Call defaults
PsychDefaultSetup(1); % Executes the AssertOpenGL command & KbName('UnifyKeyNames')
Screen('Preference', 'SkipSyncTests', 2); % DO NOT KEEP THIS IN EXPERIMENTAL SCRIPTS!

% Setup screens
getScreens   = Screen('Screens'); % Gets the screen numbers, typically 0 = primary and 1 = external
chosenScreen = max(getScreens);   % Chose which screen to display on (here we chose the external)
rect         = [];                % Full screen

% Get luminance values
white = WhiteIndex(chosenScreen); % 255
black = BlackIndex(chosenScreen); % 0
grey  = white/2; 

% Open a psychtoolbox screen
[w, scr_rect] = PsychImaging('OpenWindow',chosenScreen,grey,rect); % here scr_rect gives us the size of the screen in pixels  
[centerX, centerY] = RectCenter(scr_rect); % get the coordinates of the center of the screen

% Get flip and refresh rates
ifi = Screen('GetFlipInterval', w); % the inter-frame interval (minimum time between two frames)
hertz = FrameRate(w); % check the refresh rate of the screen

%% DRAW A RECTANGLE
% First we will define the size of the rectangle as a proportion of the
% screen size. Remember that when we draw things, we move from top-left-X
% to top-Left-Y to bottom-Right-X to bottom-right-Y. 
rectangle         = [0 0 scr_rect(3)/3 scr_rect(4)/2]; % dimensions of the rectangle
rectangleColour   = [0 255 0]; % The fill colour (RGB)
rectanglePosition = CenterRectOnPointd(rectangle,centerX,centerY); % centers the rectangle on the XY coord we specify

% Draw the rectangle to the buffer
Screen('FillRect',w,rectangleColour,rectanglePosition);
  
% We now need to 'flip' the Screen, which will flip what we drew to the buffer
% to the screen:
Screen('Flip',w); 
 
KbWait; % waits for a keyboard press before continuing
sca; % close all screens


catch  
    sca; % closes the screens
    ShowCursor; % shows the mouse cursor
    psychrethrow(psychlasterror) %prints error message to command window 
end
    

