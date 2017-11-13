%% Example 4: display some text and draw a gabor which changes orientations
 
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
    
    %% MAKE A BOX OUTLINE WITH A FIXATION CROSS IN THE CENTER
    % We will first specify the box outline
    rectangle         = [0 0 scr_rect(3)/3 scr_rect(4)/2]; % dimensions of the rectangle
    rectangleColour   = white; % outline colour
    rectanglePosition = CenterRectOnPointd(rectangle,centerX,centerY); % centers the rectangle on the XY coord we specify
    rectangleWidth    = 10; % the line thickness in pixels
    
    % And now the fixation cross
    fixation          = rectangle(3)/15; % size of the lines relative to the size of the rectangle
    fixationColour    = white; % cross colour
    fixationWidth     = 3; % the line thickness in pixels
    fixationPosition  = [-fixation fixation 0 0; 0 0 -fixation fixation]; % coordinates for drawing relative to 0
    
    %% MAKE GABORS
    gaborColour       = [0 255 0]; %green
    gaborSize         = rectangle(3)*.8; % dimension of the gabor relative to the rectangle
    phase             = 0;
    freq              = 12/gaborSize; % number of black-white cycles divided by the size gives us the spatial freq
    sigma             = gaborSize/5; %sigma of gaussian
    contrast          = 1;
    gaborSpec         = [phase;freq;sigma;contrast;1;0;0;0];
    
    orientation       = 0:45:180; % in degrees 
    gaborTex          = CreateProceduralGabor(w,gaborSize,gaborSize,[],[],0); % Make the gabor texture
    
    %% DRAW THE THINGS
    % First we will draw the box with some text in the center
    Screen('FrameRect',w,rectangleColour,rectanglePosition,rectangleWidth); % Draw the rectangle to the buffer
    Screen('TextSize',w,round(fixation)); % set text size to fixation length
    DrawFormattedText(w,'Press any key to start','center','center',white);
    Screen('Flip',w);
    KbWait; % wait for a key press
    
    % Now we draw the box with a fixation point in the center
    Screen('FrameRect',w,rectangleColour,rectanglePosition,rectangleWidth); % Draw the rectangle to the buffer
    Screen('DrawLines',w,fixationPosition,fixationWidth,fixationColour,[centerX, centerY]); % Draws the fixation cross to the screen center
    Screen('Flip',w);
    WaitSecs(.8); %wait 800ms before beginning the displaying
    
    for iSwitch = 1:5
        % Now we will draw the box and Gabor with fixation on top - note that order
        % matters so we want to draw the fixation point last
        Screen('FrameRect',w,rectangleColour,rectanglePosition,rectangleWidth); % Draw the rectangle to the buffer
        Screen('DrawTextures',w,gaborTex,[],[],orientation(iSwitch),[],[],gaborColour,[],kPsychDontDoRotation,gaborSpec);
        Screen('DrawLines',w,fixationPosition,fixationWidth,fixationColour,[centerX, centerY]); % Draws the fixation cross to the screen center
        Screen('Flip',w);
        WaitSecs(1); % display for 1sec and then switch orientations
    end
    
    % Draw the box with fixation again
    Screen('FrameRect',w,rectangleColour,rectanglePosition,rectangleWidth); % Draw the rectangle to the buffer
    Screen('DrawLines',w,fixationPosition,fixationWidth,fixationColour,[centerX, centerY]); % Draws the fixation cross to the screen center
    Screen('Flip',w);
    
    KbWait;
    sca; % close all screens
     

catch  
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end
    
