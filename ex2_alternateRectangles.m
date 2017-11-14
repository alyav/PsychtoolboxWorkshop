%% Example 2: alternate presenting a green and red rectangle at the center of the screen
 
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
    
    
    %% MAKE RECTANGLES
    rectangle         = [0 0 scr_rect(3)/3 scr_rect(4)/2]; % dimensions of the rectangle
    rectangleColour   = [0 255 0; 255 0 0]; % The fill colours - one green and red
    rectanglePosition = CenterRectOnPointd(rectangle,centerX,centerY); % centers the rectangle on the XY coord we specify
    
    %% DRAW THE RECTANGLES
    % Here we want to have the rectangle change colour every second, and
    % continue to do so until we make a key press
    
    waitframes = 20; % number of frames to wait before flipping
    vbl = Screen('Flip', w); % initial flip to sync vbl
    
    while ~KbCheck % This will loop the code until there is a keyboard press
        for iRect = 1:2
            Screen('FillRect',w,rectangleColour(iRect,:),rectanglePosition); % Draw the rectangle to the buffer
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi); % flip the buffer to the screen
        end
    end
    
    sca; % close all screens
     

catch  
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end
    
