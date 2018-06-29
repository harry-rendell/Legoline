disp('Running Main2 continuously');
path2code = pwd;
path2code = path2code(1: length(path2code) - 13);
cd(path2code);

%% Collect information from configuration files
fileJunc3 = memmapfile('Junction3.txt', 'Writable', true);
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(6) = 49;
fileConfig = fopen('Configurations.txt', 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Main2', out{1}, 'exact');

%% Open NXT and wait for the ready sign
nxtM2Addr = char(out{2}(ind));
nxtM2 = COM_OpenNXTEx('USB', nxtM2Addr);
OpenLight(SENSOR_1, 'ACTIVE', nxtM2);
OpenLight(SENSOR_2, 'ACTIVE', nxtM2);
fileInit.Data(6) = 50;
while fileInit.Data(1) == 48
    pause(0.25);
end

if fileInit.Data(1) ~= 50
    %Needs to stop in this case either because the user chooses to shut
    %down or the configuration file is corrupted
    clear fileJunc3;
    CloseSensor(SENSOR_1, nxtM2);
    CloseSensor(SENSOR_2, nxtM2);
    COM_CloseNXT(nxtM2);
    if fileInit.Data(1) ~= 49
        disp('Error reading initialization data');
        pause(5);
    end
    clear fileInit;
    quit;
end

%% Start the main loop
disp('Started!');
ambientLight1 = GetLight(SENSOR_1, nxtM2);
keepMainlineRunning = NXTMotor(MOTOR_A);
keepMainLineRunning.SpeedRegulation = false;
keepMainlineRunning.Power = -40;
keepMainlineRunning.SendToNXT(nxtM2);
timeToClearPallet = 3.8;
clearPalletM = [timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', timeToClearPallet);];
currentTimer = 0;
while fileInit.Data(1) ~= 53
    while abs(GetLight(SENSOR_1, nxtM2) - ambientLight1) < 11
        if fileInit.Data(1) == 53
            clear fileJunc3;
            clear fileInit;
            keepMainlineRunning.Stop('off', nxtM2);
            CloseSensor(SENSOR_1, nxtM2);
            CloseSensor(SENSOR_2, nxtM2);
            COM_CloseNXT(nxtM2);
            quit;
        end
        pause(0.05);
    end
    fileJunc3.Data(1) = fileJunc3.Data(1) + 1;
    if waitForPalletExit(nxtM2, SENSOR_1, ambientLight1, 5) == false
        disp('Error');
    end
    currentTimer = currentTimer + 1;
    %{
    if currentTimer == 9
        currentTimer = 1;
    end
    %}
    waitForPalletExit(nxtM2, SENSOR_1, ambientLight1, 4);
    start(clearPalletM(currentTimer));
    disp('Main2 clear');
end

%% Terminate this session
clear fileJunc3;
clear fileInit;
delete(timerfind);
keepMainlineRunning.Stop('off', nxtM2);
CloseSensor(SENSOR_1, nxtM2);
CloseSensor(SENSOR_2, nxtM2);
COM_CloseNXT(nxtM2);
quit;