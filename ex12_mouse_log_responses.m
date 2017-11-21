%% Example 12: Mouse responses
% We are going to do a similar thing to example 10, only here rectangles
% can be either on the left or right of the screen and can be either red or
% green. We will use the mouse to collect responses.

% Clear the workspace and close screens
sca;         % closes all screens
clear all;   % clear all variables
HideCursor;  % hides the mouse cursor

input ('start>>>','s'); % prints to command window

try
    %% SETUP TRIALS %%
    % First we are going to setup our trial structure.
    % We will be presenting rectangles on either the left or right of the
    % screen, and we want equal numbers of each but in a shuffled order
    
    nTrials = 4; % how many trials there will be
    
    % we want equal numbers of green and red when it is on the left, and
    % same on the right
    trial = []; % make a struct array, we will put all the trial info and responses in here
    trial.position = repmat(1:2,1,nTrials/2); % fill a vector with alternating 1s and 2s, representing the left and right side of the screen respectively
    trial.colour   = [ones(1,nTrials/2) repmat(2,1,nTrials/2)]; % fill the first half of the vector with 1s (red) and the second half with 2s (green)
    
    trialParams    = [ trial.position; trial.colour ]; %combine them so we can shuffle
    trialParams    = trialParams(:,randperm(size(trialParams,2))); %shuffle columnwise so that we preserve balance
    
    % lets put it back in the struct.. we would normally condense this all
    % down but I'm leaving it as multiple steps so it's easier to see
    % what's going on
    
    trial.position = trialParams(1,:);
    trial.colour   = trialParams(2,:);
    
    
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
    
    %set the font size
    Screen('TextSize',w,40);
    
    %% SETUP STIMS %%
    % We will define our 4 responses boxes, 2 on each side and of each
    % colour. We will shift them on the y axis.
    
    boxColours = [255 0 0; 255 0 0; 0 255 0; 0 255 0]; %define the colours for our 4 boxes
    
    boxPositions = [centerX-100 centerY-100 centerX-50 centerY-50;... %top left box
        centerX+50 centerY-100 centerX+100 centerY-50;... %top right box
        centerX-100 centerY+50 centerX-50 centerY+100;... %bottom left box
        centerX+50 centerY+50 centerX+100 centerY+100]; %bottom right box
    
    
    %% BEGIN EXPERIMENT %%
    DrawFormattedText(w,'Press any key to start','center','center',white); %draw some text
    Screen('Flip',w);
    KbWait; %wait for any key press to begin trial loop
    
    for n = 1:nTrials
        %____ our inter-trial interval ____%
        Screen('Flip',w); %lets just show a blank screen for a second
        WaitSecs(1); %our inter-trial interval
         
        %____ get position ____%
        if trial.position(n) == 1 % if this is a LEFT trial
            rectPosition = [centerX-400 centerY-25 centerX-350 centerY+25]; %rect coordinates
        elseif trial.position(n) == 2 % if this is a RIGHT trial
            rectPosition = [centerX+350 centerY-25 centerX+400 centerY+25]; %rect coordinates
        end
        
        %____ get colour ____%
        if trial.colour(n) == 1 % if it is a red box
            rectColour = [255 0 0];
        elseif trial.colour(n) == 2 % if it is a green box
            rectColour = [0 255 0];
        end
        
        %____ present the stimulus ____%
        % now lets present the rectangle for 500ms, using the colour and
        % position we chose above
        Screen('FillRect',w,rectColour,rectPosition); % draw the rect
        vbl = Screen('Flip',w);
        WaitSecs(.5); %leave it on the screen for 500ms
        Screen('Flip',w); %flip back to the blank screen  
        WaitSecs(1); %wait for 1 second 
        
        %% GET RESPONSES %%
          
        resp=0; mouseMove = 0; %we will update this in the loop
        
        while resp==0
            
            %____ track mouse ____%
            %for the first frame, position mouse in the center of the screen
            if mouseMove == 0
                SetMouse(centerX, centerY, w); %put the mouse in the center
                Screen('DrawDots',w, [centerX centerY],10,white,[],2); %draw a dot in the center
                responseStart = Screen('Flip',w); %first flip to sync to retrace and get timestamp
                mouseMove = 1; %so that we don't try to put it back in the center after the first flip
            end
            
            [mx, my, buttons] = GetMouse(w); %Get the current coordinates of the mouse on the screen
            
            if mouseMove == 1 %redraw the mouse cursor to follow movement (but not on the first frame)
                Screen('DrawDots',w, [mx my],10,white,[],2); %draw a dot in the coords of the mouse
            end
              
            Screen('FillRect',w,boxColours',boxPositions'); % draw all the boxes again 
            
            %check if the mouse inside any of the rectangles
            insideBox(1)  = IsInRect(mx, my, boxPositions(1,:)); % is it inside the top left box?
            insideBox(2)  = IsInRect(mx, my, boxPositions(2,:)); % top right box?
            insideBox(3)  = IsInRect(mx, my, boxPositions(3,:)); % bottom left box?
            insideBox(4)  = IsInRect(mx, my, boxPositions(4,:)); % bottom right box?
            
            if insideBox(1)
                Screen('FrameRect',w,white,boxPositions(1,:),3); %draw a frame around the box
                if any(buttons) %if there is a mouse click
                    trial.respPosition(n) = 1; %record press as left
                    trial.respColour(n) = 1; %record press as red
                    trial.RT(n) = GetSecs-responseStart; %reaction time
                    resp = 1; %exit loop
                end
            elseif insideBox(2)
                Screen('FrameRect',w,white,boxPositions(2,:),3); %draw a frame around the box
                if any(buttons) %if there is a mouse click
                    trial.respPosition(n) = 2; %record press as right
                    trial.respColour(n) = 1; %record press as red
                    trial.RT(n) = GetSecs-responseStart; %reaction time
                    resp = 1; %exit loop
                end
            elseif insideBox(3)
                Screen('FrameRect',w,white,boxPositions(3,:),3); %draw a frame around the box
                if any(buttons) %if there is a mouse click
                    trial.respPosition(n) = 1; %record press as left
                    trial.respColour(n) = 2; %record press as green
                    trial.RT(n) = GetSecs-responseStart; %reaction time
                    resp = 1; %exit loop 
                end
            elseif insideBox(4)
                Screen('FrameRect',w,white,boxPositions(4,:),3); %draw a frame around the box
                if any(buttons) %if there is a mouse click
                    trial.respPosition(n) = 2; %record press as right
                    trial.respColour(n) = 2; %record press as green
                    trial.RT(n) = GetSecs-responseStart; %reaction time
                    resp = 1; %exit loop 
                end
            end
            
            vbl = Screen('Flip',w, vbl+ (waitframes - .05) * ifi);
            
        end
    end
    
    
    
    sca;
    
catch
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end