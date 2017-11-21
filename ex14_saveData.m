%% Example 14: we're going to use ex10 for the experiment (where the rectangles appear on either side)
% Only now we will collect subject info, use it to set the condition (in
% one condition the feedback we give will be correct and in the other it
% won't) and we will save and export the data.

% Clear the workspace and close screens
sca;         % closes all screens
clear all;   % clear all variables

input ('start>>>','s'); % prints to command window

%% GET SUB INFO %%
% First lets open a dialog box and ask for the subject number
getSub = inputdlg({'Subject Number'});
subject.number = str2double(getSub{1}); % convert the string to a number

% Now we only want more details if this is an actual participant and not
% just us testing something, so we will use sub=99 as the testing value
if subject.number ~=99 %if it's not a test run, lets get more info about the sub
    getMoreInfo = inputdlg({'Run','Condition'},'Run parameters'); 
    run = str2double(getMoreInfo{1}); %get the run number
    condition = str2double(getMoreInfo{2}); %which condition are they in? 1 = correct feedback, 2 = incorrect
    saveData = 1; % if it's not a test run, we also want to save the data
else
    saveData = 0; % we don't need to save if it's not a real sub
end

% If it's the first run, lets get some demographics from the sub
if run == 1
    getDemos = inputdlg({'Subject Initials','Age','Gender'},'Subject Info');
    subject.initials = getDemos{1}; %get the subject initials 
    subject.age      = str2double(getDemos{2}); %get age
    subject.gender   = getDemos{3}; %get gender
end
  
% Let's also save the current date and time into our subject structure
subject.date = datestr(now,1); %type "help datestr" to see all the formatting options
subject.time = datestr(now,16); %type "help datestr" to see all the formatting options
 

% Lets set some setting for saving later
save_directory   = './data';  % where to save?
if ~exist(save_directory, 'dir'), mkdir(save_directory); end %if the directory we specified doesn't exist, make it
save_prefix = 'rectExp_'; % the prefix we want to give all our save files so we know they belong to this experiment
 
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
            rectPosition    = CenterRectOnPointd(rectSize,centerX-200,centerY); %center it a bit left of center
        elseif trial.position(n) == 2 % if this is a RIGHT trial
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
            if condition == 1 % if we are giving correct feedback
                DrawFormattedText(w,'correct!','center','center',[0 255 0]); % draw feedback response
            else
                DrawFormattedText(w,'oops!','center','center',[255 0 0]); % draw feedback response
            end
            trial.correct(n) = 1; %lets also note if that trial was correct
        else
            if condition == 1 % if we are giving correct feedback
                DrawFormattedText(w,'oops!','center','center',[255 0 0]); % draw feedback response
            else
                DrawFormattedText(w,'correct!','center','center',[0 255 0]); % draw feedback response
            end
            trial.correct(n) = 0; %and if it was wrong we'll put a 0
        end
        
        Screen('Flip',w);
        WaitSecs(1); %leave it on the screen for a sec
        
        Screen('Flip',w); %and lets put the blank screen back up 
        WaitSecs(1); %wait a second before starting the next trial 
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
    
    
    %% SAVE OUT %% 
    if saveData==1
        outfilename = [save_directory filesep save_prefix...
            sprintf('SUB%02d_RUN%01d_COND%01d',subject.number,run,condition)...
            '__' datestr(now,'DD_mmm_YY')]; %lets also add the date at the end of the filename
        aa=num2str(outfilename);
        save(aa); % saves everything to a mat file
    end
    
    % lets make our trial parameters and responses into a matrix and then
    % save it as a csv file
    dataMatrix = [trial.position; trial.response; trial.RT]';
    csvwrite([outfilename '.csv'],dataMatrix);
     
    % now lets save it in a format where we have table headings for easy
    % export to R or whatever else you might want to use. You need to
    % download a function by Keith Brady called "csvwrite_with_headers" -
    % you can find it on mathworks or in the repo you got this from
    headings = [{'Subject'},{'Correct'},{'mean RT'}];
    meansMatrix = [subject.number percentCorrect meanRT];
    csvwrite_with_headers([outfilename '_withHeaders.csv'],meansMatrix,headings);
     
    sca; %close the screen
     
catch
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end

