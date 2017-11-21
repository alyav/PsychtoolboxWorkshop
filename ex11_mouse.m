
%% Example 11: draw a mouse cursor on the screen, exit upon mouse click

% Clear the workspace and close screens
sca;         % closes all screens
clear all;   % clear all variables
HideCursor;  % hides the mouse cursor

input ('start>>>','s'); % prints to command window

try
%% SETUP SCREEN %%
PsychDefaultSetup(2); % Executes the AssertOpenGL command & KbName('UnifyKeyNames') & normalizes colour range
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

% Get flip and refresh rates
ifi = Screen('GetFlipInterval', w); % the inter-frame interval (minimum time between two frames)
hertz = FrameRate(w); % check the refresh rate of the screen
waitframes = 1; %how many frames to wait before flipping

% define keys that we want
escapeKey = KbName('ESCAPE');
greenKey = KbName('LeftShift');
redKey = KbName('RightShift');

%% TRACK AND UPDATE MOUSE %%
mouseMove=0; buttons=0; %will be updated in the loop
vbl = Screen('Flip',w); %initial flip

while ~any(buttons) %while no mouseclicks have been made
    
    %for the first frame, position mouse in the center of the screen
    if mouseMove == 0
        SetMouse(centerX, centerY, w); %put the mouse in the center
        Screen('DrawDots',w, [centerX centerY],40,white,[],2); %draw a dot in the center
        mouseMove = 1; %so that we don't try to put it back in the center after the first flip
    end
     
    [mx, my, buttons] = GetMouse(w); %Get the current coordinates of the mouse on the screen
     
    if mouseMove == 1 %redraw the mouse cursor to follow movement (but not on the first frame)
        Screen('DrawDots',w, [mx my],40,white,[],2); %draw a dot in the coords of the mouse
    end
     
    vbl = Screen('Flip',w,vbl+(waitframes-.05)*ifi);
     
end

sca;

catch
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end

