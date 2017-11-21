%% Example 9: change the colour of a rectangle based on keyboard presses

% Clear the workspace and close screens
sca;         % closes all screens
clear all;   % clear all variables

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

% define keys that we want
escapeKey = KbName('ESCAPE');
greenKey = KbName('LeftShift');
redKey = KbName('RightShift');

while KbCheck; end % Call it here so we don't waste time later (it's a little slow the first time).  
  
%% DRAW SHAPES
% First lets define our rectangle
rectSize         = [0 0 scr_rect(3)/3 scr_rect(4)/2]; % size of the rectangle
rectPosition     = CenterRectOnPointd(rectSize,centerX,centerY); % centers the rectangle on the screen

% Now lets draw and flip it to the screen
Screen('FillRect',w,white,rectPosition); 
Screen('Flip',w);

% Now we are going to continuously check to see if a key has been pressed,
% if either shift key is pressed, we will change the colour of the
% rectangle accordingly.

while 1 
    [keyIsDown,secs,keyCode] = KbCheck; %continuously checks the state of the keyboard 
    if keyIsDown % if it detects a key has been pressed
        if keyCode(greenKey) % if it's the green key (Left Shift key, as we defined earlier)
            Screen('FillRect',w,[0 255 0],rectPosition); %draw a green rect
            Screen('Flip',w);
        elseif keyCode(redKey) % if it's the red key
            Screen('FillRect',w,[255 0 0],rectPosition); %draw a red rect
            Screen('Flip',w);
        elseif keyCode(escapeKey) % if the escape key is pressed exit out of this loop
            break;
        end
    end
end

sca;

    
catch
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end

