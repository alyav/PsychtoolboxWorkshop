%% Example 12: Getting subject/block/run information
  
% Clear the workspace and close screens
sca;         % closes all screens
clear all;   % clear all variables 

input ('start>>>','s'); % prints to command window

% First lets open a dialog box and ask for the subject number
getSub = inputdlg({'Subject Number'});
subject.number = str2double(getSub{1}); % convert the string to a number

% Now we only want more details if this is an actual participant and not
% just us testing something, so we will use sub=99 as the testing value
if subject.number ~=99 %if it's not a test run, lets get more info about the sub
    getMoreInfo = inputdlg({'Run','Condition'},'Run parameters'); 
    run = str2double(getMoreInfo{1}); %get the run number
    condition = str2double(getMoreInfo{2}); %which condition are they in?
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
