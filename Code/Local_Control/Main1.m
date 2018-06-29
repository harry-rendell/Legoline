disp('Running Main1 continuously');
path2code = pwd;
path2code = path2code(1: length(path2code) - 13);
cd(path2code);

%% Collect information from configuration files
fileJunc2 = memmapfile('Junction2.txt', 'Writable', true);
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(3) = 49;
fileConfig = fopen('Configurations.txt', 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Main1', out{1}, 'exact');

%% Open NXT and wait for the ready sign
nxtM1Addr = char(out{2}(ind));
nxtM1 = COM_OpenNXTEx('USB', nxtM1Addr);
OpenLight(SENSOR_1, 'ACTIVE', nxtM1);
OpenLight(SENSOR_2, 'ACTIVE', nxtM1);
fileInit.Data(3) = 50;
while fileInit.Data(1) == 48
    pause(0.25);
end

if fileInit.Data(1) ~= 50
    %Needs to stop in this case either because the user chooses to shut
    %down or the configuration file is corrupted
    clear fileJunc2;
    CloseSensor(SENSOR_1, nxtM1);
    CloseSensor(SENSOR_2, nxtM1);
    COM_CloseNXT(nxtM1);
    if fileInit.Data(1) ~= 49
        disp('Error reading initialization data');
        pause(5);
    end
    clear fileInit;
    quit;
end

%% Start the main loop
disp('Started!');
ambientLight1 = GetLight(SENSOR_1, nxtM1);
keepMainlineRunning = NXTMotor(MOTOR_A);
keepMainLineRunning.SpeedRegulation = false;
keepMainlineRunning.Power = -40;
keepMainlineRunning.SendToNXT(nxtM1);
clearPalletM = [timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.8);];
currentTimer = 0;
while fileInit.Data(1) ~= 53
    while abs(GetLight(SENSOR_1, nxtM1) - ambientLight1) < 11
        if fileInit.Data(1) == 53
            clear fileJunc2;
            clear fileInit;
            delete(timerfind);
            keepMainlineRunning.Stop('off', nxtM1);
            CloseSensor(SENSOR_1, nxtM1);
            CloseSensor(SENSOR_2, nxtM1);
            COM_CloseNXT(nxtM1);
            quit;
        end
        pause(0.05);
    end
    fileJunc2.Data(1) = fileJunc2.Data(1) + 1;
    if waitForPalletExit(nxtM1, SENSOR_1, ambientLight1, 5) == false
        disp('Error');
    end
    currentTimer = currentTimer + 1;
    %{
    if currentTimer == 9
        currentTimer = 1;
    end
    %}
    waitForPalletExit(nxtM1, SENSOR_1, ambientLight1, 4);
    start(clearPalletM(currentTimer));
    %{
    fileJunc2.Data(1) = fileJunc2.Da
    pause(1.8);
    fileJunc1.Data(1) = 48;%Allows Transfer1 to transfer the pallet.
    %}
    disp('Main1 clear');
end

%% Terminate this session
clear fileJunc2;
clear fileInit;
delete(timerfind);%Remove all timers from memory
keepMainlineRunning.Stop('off', nxtM1);
CloseSensor(SENSOR_1, nxtM1);
CloseSensor(SENSOR_2, nxtM1);
COM_CloseNXT(nxtM1);
quit;