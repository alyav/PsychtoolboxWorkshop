%% Example 9: present a rectangle either on the left or right of the screen and collect responses and RTs to present feedback

% Clear the workspace and close screens
sca;         % closes all screens
clear all;   % clear all variables

input ('start>>>','s'); % prints to command window


showDebugText = true;

try
    %% SETUP TRIALS %%
    % First we are going to setup our trial structure.
    % We will be presenting rectangles on either the left or right of the
    % screen, and we want equal numbers of each but in a shuffled order
    
    nTrials = 4; % how many trials there will be
    trial = []; % make a struct array, we will put all the trial info and responses in here
    trial.position = repmat(1:2,1,nTrials/2); % fill a vector with 1s and 2s, representing the left and right side of the screen respectively
    trial.position = Shuffle(trial.position); % shuffle the order of the 1s and 2s
    
    %% SETUP SCREEN %%
    PsychDefaultSetup(2); % Executes the AssertOpenGL command & KbName('UnifyKeyNames') & normalizes colour range
    Screen('Preference', 'SkipSyncTests', 2); % DO NOT KEEP THIS IN EXPERIMENTAL SCRIPTS!
    PsychDebugWindowConfiguration([],.5);
    
    Screen('Preference', 'Verbosity', 3);
    %0 - No output at all.
    %1 - Only severe error messages.
    %2 - Errors and warnings.
    %3 - Additional information, e.g., startup output when opening an onscreen window.
    %4 - Very verbose output, mostly useful for debugging PTB itself.
    %5 - Even more information and hints. Usually not what you want.
    
    
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
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    
    %set the font size
    Screen('TextSize',w,30);
    
    %% SETUP RECTANGLES %%
    rectSize         = [0 0 200 200]; % size of the rectangle
    rectColour       = [0 255 0]; % green
    % we won't define the position yet, as this will change on each trial...
    
    %% BEGIN EXPERIMENT %%
    while KbCheck; end % Call it here so we don't waste time later (it's a little slow the first time).
    
    DrawFormattedText(w,'Press any key to start','center','center',white); %draw some text
    Screen('Flip',w);
    KbWait; %wait for any key press to begin trial loop
    
    for n = 1:nTrials %for each trial
        
        %____ get position ____%
        if trial.position(n) == 1 % if this is a LEFT trial
            if showDebugText,fprintf('\n\n Left'), end    %lets print to the command window to see
            rectPosition    = CenterRectOnPointd(rectSize,centerX-200,centerY); %center it a bit left of center
        elseif trial.position(n) == 2 % if this is a RIGHT trial
            if showDebugText,fprintf('\n\n Right'), end
            rectPosition    = CenterRectOnPointd(rectSize,centerX+200,centerY); %center it a bit right of center
        end
        
        %____ present the stimulus ____%
        % now lets present the rectangle for 500ms
        Screen('FillRect',w,white,rectPosition); % draw the rect
        vbl = Screen('Flip',w);
        WaitSecs(.5); %leave it on the screen for 500ms
        stimOffset = Screen('Flip',w); %flip back to the blank screen and get offset timestamp
        
        
        %____ get response and RT ____%
        resp = 0; %we will update this in the response loop
        
        while resp == 0 %while there is no logged response
            [keyIsDown,secs,keyCode] = KbCheck; %continuously checks the state of the keyboard
            if keyIsDown % if it detects a key has been pressed
                if keyCode(leftKey) % if left is pressed
                    trial.RT(n) = GetSecs - stimOffset; %get the current time and subtract offset time to get the RT
                    trial.response(n) = 1; %record a left response
                    resp=1; %exit loop
                elseif keyCode(rightKey) %  if right is pressed
                    trial.RT(n) = GetSecs - stimOffset; %get the current time and subtract offset time to get the RT
                    trial.response(n) = 2; %record a right response
                    resp=1; %exit loop
                end
            end
        end
        
        %____ give feedback ____%
        if trial.response(n) == trial.position(n) %if it's a correct response
            DrawFormattedText(w,'correct!','center','center',[0 255 0]); % draw feedback response
            trial.correct(n) = 1; %lets also note if that trial was correct
        else
            DrawFormattedText(w,'oops!','center','center',[255 0 0]); % draw feedback response
            trial.correct(n) = 0; %and if it was wrong we'll put a 0
        end
        Screen('Flip',w);
        WaitSecs(1); %leave it on the screen for a sec
        
        Screen('Flip',w); %and lets put the blank screen back up
        WaitSecs(1); %wait a second before starting the next trial
        FlushEvents;
    end
    
    % Now the experiment is finished, but lets quickly tally up the score
    % and display the total amount that they got correct and the mean RT
    totalCorrect = sum(trial.correct==1); %how many did they get correct across all trials?
    percentCorrect = round(totalCorrect/length(trial.correct)*100); %calculate the percent correct and round it to a whole number
    meanRT = mean(trial.RT);
    
    feedbackText = sprintf('Congrats, you got %02d%% correct with an average RT of %0.2f seconds!',percentCorrect,meanRT); %generate a text string using the percent correct we calculated earlier
    % for help on how to do this with different types of input, look at "help
    % sprintf" and "doc sprintf".
    
    Screen('DrawText',w,feedbackText,centerX-500,centerY,white); % draw the feedback text
    Screen('Flip',w);
    WaitSecs(3); %wait 3 secs before closing the screen
    sca; %close the screen
    
catch
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end

