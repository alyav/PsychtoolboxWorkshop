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
folderPath  = '/Users/alya/Desktop/PsychtoolboxWorkshop/sample_scripts/images/'; % set the dir for where you are keeping the images
getImage    = dir(fullfile(folderPath, '*.jpg')); %gets a list of names for all the jpg files in the folder
choseImage  = 1:length(getImage);
choseImage  = Shuffle(choseImage); % make a vector the length of the number of images and then shuffle the order

for numImages = 1:length(choseImage)
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
 
sca;

catch  
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end
    


