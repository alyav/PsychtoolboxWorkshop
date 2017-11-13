%% Example 3: draw box with fixation point in the center
 
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
    
    
    %% MAKE A BOX OUTLINE WITH A FIXATION CROSS IN THE CENTER
    % We will first specify the box outline
    rectangle         = [0 0 scr_rect(3)/3 scr_rect(4)/2]; % dimensions of the rectangle
    rectangleColour   = white; % outline colour
    rectanglePosition = CenterRectOnPointd(rectangle,centerX,centerY); % centers the rectangle on the XY coord we specify
    rectangleWidth    = 10; % the line thickness in pixels
    
    % And now the fixation cross
    fixation          = rectangle(3)/10; % size of the lines relative to the size of the rectangle
    fixationColour    = black; % cross colour
    fixationWidth     = 3; % the line thickness in pixels
    fixationPosition  = [-fixation fixation 0 0; 0 0 -fixation fixation]; % coordinates for drawing relative to 0
    
    
    %% DRAW THE RECTANGLE & FIXATION
    % Note that the order in which we call the Screen functions is important,
    % but nothing will actually be drawn to the screen until we call the Flip
    
    Screen('FrameRect',w,rectangleColour,rectanglePosition,rectangleWidth); % Draw the rectangle to the buffer
    Screen('DrawLines',w,fixationPosition,fixationWidth,fixationColour,[centerX, centerY]); % Draws the fixation cross to the screen center
    Screen('Flip',w);
    
    KbWait; % wait for a key press
    sca; % close all screens
   
catch  
    sca;
    ShowCursor;
    psychrethrow(psychlasterror)
end
    
