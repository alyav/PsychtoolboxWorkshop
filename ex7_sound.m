%% Example 7: generate tones and play different sounds
% Clear the workspace and close screens
sca;         % closes all screens
clear all;   % clear all variables

input ('start>>>','s'); % prints to command window

try
    PsychDefaultSetup(1); % Executes the AssertOpenGL command & KbName('UnifyKeyNames')
    InitializePsychSound; % loads PsychPortAudio sound driver, with a flag
    %set to 1 for really low latency and high precision. This works on OSX and
    %Linux. Windows is more complicated and you will need a good ASIO sound
    %card and drivers if you're wanting to do an experiment where audio timing
    %is important. Or just use Linux... Type "help InitializePsychSound" in the
    %command window to learn more.
     
    
    %% GENERATE A TONE
    % First we define the specs for the tone
    duration = .5; %tone duration in seconds
    tone     = 1000; %Hz
    freq     = 44100; %sample rate
    beepWave = MakeBeep(tone,duration,freq); 
    beepWave = [beepWave; beepWave]; %duplicate it (one for each channel for stereo sound) 
   
    audioBuff = PsychPortAudio('Open',[],1,0,[],2); % Like with the buffer screen window,
    %we create an audio buffer.
    
    PsychPortAudio('FillBuffer',audioBuff,beepWave); % Place our tone in the buffer
    
    for reps = 1:3 %we do this instead of issuing reps to 'Start' so we can pause between them properly
        PsychPortAudio('Start',audioBuff); %This works like the Screen('Flip')
        %and flips the audio from the backbuffer to the front (i.e. plays the
        %sound)
        WaitSecs(1); % give the sound time to play
    end
    
    PsychPortAudio('Close', audioBuff); % Close the audio device
    WaitSecs(1);
    
    %% PLAY A SOUND FILE 
    cd ./sounds
    [soundCorrect,freq] = psychwavread('correct.wav'); %read in the sound files, gives us the sampled data and sample rate
    wave = soundCorrect';
    nrchannels = size(wave,1); % Check how many channels in the sound file
    
    if nrchannels <2 %if there are less than 2 channels, then we want to duplicate the wave for stereo output
        wave = [wave ; wave];
        nrchannels = 2;
    end
    audioBuff = PsychPortAudio('Open', [], [], 0, freq, nrchannels); % Open the buffer again
    PsychPortAudio('FillBuffer',audioBuff,wave); % Place our tone in the buffer
    PsychPortAudio('Start',audioBuff); % Flip i.e. play the wave
    WaitSecs(2.5); % Give it enough time to finish playing
    PsychPortAudio('Close', audioBuff); % Close the audio device
    
catch
    sca;
    ShowCursor;
    PsychPortAudio('Close');
    psychrethrow(psychlasterror);
end
