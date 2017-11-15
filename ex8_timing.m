%% Example 8: different ways to time presentations
% We've already seen the simple WaitSecs() which pauses execution of the
% next command, but that's not ideal in most cases. Here I'll give some
% other methods for timing presentation using the alternating rects example
% from earlier. I'll expand on this more next week. But for now, let's 
% look at some of the options. Before we do though, we're going to call  
% all the usual front matter code...

% Clear the workspace and close screens
sca;         % closes all screens
clear all;   % clear all variables

input ('start>>>','s'); % prints to command window

try
    % Call defaults
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
     
   %% MAKE RECTANGLES
    rectangle         = [0 0 scr_rect(3)/3 scr_rect(4)/2]; % dimensions of the rectangle
    rectangleColour   = [0 255 0; 255 0 0]; % The fill colours - one green and red
    rectanglePosition = CenterRectOnPointd(rectangle,centerX,centerY); % centers the rectangle on the XY coord we specify
    
    %% DRAW THE RECTANGLES
    % Here we want to have the rectangle change colour every second, and
    % continue to do so until we make a key press
    
    %Timing example 1 - this is not ideal because we aren't able to issue
    %other commands during the waitframes
    waitframes = 20; % number of frames to wait before flipping
    vbl = Screen('Flip', w); % initial flip to sync vbl
    
    while ~KbCheck % This will loop the code until there is a keyboard press
        for iRect = 1:2
            Screen('FillRect',w,rectangleColour(iRect,:),rectanglePosition); % Draw the rectangle to the buffer
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi); % flip the buffer to the screen
        end
    end
%     
%     %Timing example 2 - using the internal clock
    for reps = 1:5 %how many times do we want to alternate
        for iRect = 1:2
             startTime = GetSecs; % get the time right now for 0point
             currentTime = startTime; % we will update the currentTime in the loop
            while currentTime <= (startTime + 1) % while the current time is less than the start time + 1 second
                Screen('FillRect',w,rectangleColour(iRect,:),rectanglePosition); % Draw the rectangle to the buffer
                Screen('Flip',w); % flip the buffer to the screen
                currentTime = GetSecs; % update the time
            end
        end
    end
     
    %Timing example 3 - the best way!
    waitframes = 1; %draw every frame
    numFrames  = 1/ifi; %we want a display time of one second, so we find out how many frames can fit in one second by
    %dividing by the ifi. Here, since the refresh rate on my monitor is
    %60Hz, there are 60 frames drawn per second. Therefore, we need to flip
    %60 times at each VBL to present the stimulus for exactly 1 second.
    vbl = Screen('Flip',w); % sync to the VBL for a baseline timestamp
    for reps = 1:5 %how many times do we want to alternate
        for iRect = 1:2 
            for frames = 1:numFrames % loop through all the frames
                Screen('FillRect',w,rectangleColour(iRect,:),rectanglePosition); % Draw the rectangle to the buffer
                vbl = Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
            end
        end
    end 
    
    sca; % close all screens
     

% vbl gives us the timestamp for when the flip is executed. We can also pass an optional ?when? to tell it when we want it to execute the flip.

catch  
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end
    
