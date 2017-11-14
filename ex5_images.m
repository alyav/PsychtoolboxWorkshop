%% Example 5: get some images from a folder and display them

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
    
    %% GET IMAGES AND CONVERT THEM TO TEXTURES
    folderPath  = '/Users/alya/Dropbox/DOCS/WORKSHOPS/PsychtoolboxWorkshop/sample_scripts/images/'; % set the dir for where you are keeping the images
    getImage    = dir(fullfile(folderPath, '*.jpg')); %gets a list of names for all the jpg files in the folder
    choseImage  = 1:length(getImage); % how many images do we have?
    choseImage  = Shuffle(choseImage); % make a vector the length of the number of images and then shuffle the order
    
    for numImages = 1:length(choseImage) %for each image...
        chosenImage = getImage(numImages).name; % get the name for the chosen image
        imagePath   = [folderPath chosenImage]; % get the full path for the chosen image
        imageTex{numImages} = Screen('MakeTexture',w,imread(imagePath)); % make the image into a texture
    end
    
    % Remember that when we draw things, we move from top-left-X
    % to top-Left-Y to bottom-Right-X to bottom-right-Y.
    imageLength   = scr_rect(3)/4;
    imageHeight   = scr_rect(3)/6;
    imageDims   = [centerX-imageLength centerY-imageHeight centerX+imageLength centerY+imageHeight];
    
    %% DRAW IMAGES
    for loopImages = 1:length(choseImage)
        Screen('DrawTexture',w, imageTex{loopImages}, [], imageDims, 0);
        Screen('Flip',w);
        WaitSecs(2);
    end
    %  Lets clear the screen and take a second pause before continuing
    Screen('Flip',w);
    WaitSecs(1);
    
    %% DRAW IMAGES FADING IN AND OUT
    % Now lets draw the same images again but have them fade in and out
    % We will do this by modulating the global alpha transparency value
    % specified in the Screen('DrawTexture') options. The range is 0 = fully
    % transparent to 1 = fully opaque.
    
    alphaMod = 0; % we will slowly adjust this each frame until it reaches 1, and then adjust it back down
    
    for loopImages = 1:length(choseImage) % loop the length of the number of images we found in the folder
        while alphaMod < 1 %while the alpha is less than 1, we will keep flipping and slowly adjusting the transparency
            alphaMod = alphaMod+.01;
            Screen('DrawTexture',w, imageTex{loopImages}, [], imageDims, 0,[],alphaMod); % draw a new image each loop
            Screen('Flip',w);
        end
        
        WaitSecs(1); % Lets leave it for a second at full contrast
        
        while alphaMod > 0 %now we do the same, but in reverse, slowly reducing the alpha back down to 0
            alphaMod = alphaMod-.01;
            Screen('DrawTexture',w, imageTex{loopImages}, [], imageDims, 0,[],alphaMod); % draw a new image each loop
            Screen('Flip',w);
        end
    end
    
    sca;
    
catch
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end



