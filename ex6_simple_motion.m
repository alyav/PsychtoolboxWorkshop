%% Example 5: draw a circle moving across the screen
 
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
[w, scr_rect] = PsychImaging('OpenWindow',chosenScreen,black,rect); % here scr_rect gives us the size of the screen in pixels
[centerX, centerY] = RectCenter(scr_rect); % get the coordinates of the center of the screen
Screen('BlendFunction',w,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA'); % alpha-blending for smooth lines

% Get flip and refresh rates
ifi = Screen('GetFlipInterval', w); % the inter-frame interval (minimum time between two frames)
hertz = FrameRate(w); % check the refresh rate of the screen

%% DRAW A CIRCLE
% set the circle parameters
radius   = scr_rect(3)/20; % circle radius relative to screen size
velocity = 15; % speed at which the circle will move along the x axis in terms of pixels per frame
Xpos     = centerX;

while ~KbCheck
    Xpos = Xpos + velocity; % change the X position of the circle by 5 pixels every flip
    if Xpos - radius > scr_rect(3) % if the circle moves outside the right side of the screen
        Xpos = -radius; % then we will reposition it ready to come out on the left side
    end
    
    % now we draw the circle using the changing position location
    Screen('FillOval',w, white, [Xpos-radius centerY-radius Xpos+radius centerY+radius]);
    Screen('Flip',w); 
end 
 


sca;

catch  
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end
    
