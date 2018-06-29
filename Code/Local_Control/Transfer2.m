disp('Running Transfer2');
path2code = pwd;
path2code = path2code(1: length(path2code) - 13);
cd(path2code);

%% Collect information from configuration files
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(7) = 49;
fileJunc2 = memmapfile('Junction2.txt', 'Writable', true);
fileJunc3 = memmapfile('Junction3.txt', 'Writable', true);
fileConfig = fopen('Configurations.txt', 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Transfer2', out{1}, 'exact');

%% Open NXT and wait for the ready sign
nxtT2Addr = char(out{2}(ind));
nxtT2 = COM_OpenNXTEx('USB', nxtT2Addr);
OpenLight(SENSOR_3, 'ACTIVE', nxtT2);
OpenSwitch(SENSOR_2, nxtT2);
OpenLight(SENSOR_1, 'ACTIVE', nxtT2);
resetTransferArm(MOTOR_B, SENSOR_2, nxtT2, 13);
fileInit.Data(7) = 50;
while fileInit.Data(1) == 48
    pause(0.25);
end

if fileInit.Data(1) ~= 50
    %Needs to stop in this case either because the user chooses to shut
    %down or the configuration file is corrupted
    clear fileJunc2;
    clear fileJunc3;
    CloseSensor(SENSOR_1, nxtT2);
    CloseSensor(SENSOR_2, nxtT2);
    CloseSensor(SENSOR_3, nxtT2);
    COM_CloseNXT(nxtT2);
    if fileInit.Data(1) ~= 49
        disp('Error reading initialization data');
        pause(5);
    end
    clear fileInit;
    quit;
end

%% Start the main loop
disp('Started!');
currentLight1 = GetLight(SENSOR_1, nxtT2);
currentLight3 = GetLight(SENSOR_3, nxtT2);
cd([pwd filesep 'Local_Control']);%CRUCIAL
clearPalletT = [timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);
                timer('TimerFcn', 'fileJunc3.Data(1) = fileJunc3.Data(1) - 1', 'StartDelay', 3.6);];
currentTimer = 0;
for i=1:1:11
    if (fileInit.Data(1) == 53) %Needs to shutdown in this case according to the user
        break;
    end
    while (abs(GetLight(SENSOR_1, nxtT2) - currentLight1) < 11)
        pause(0.05);
    end
    if (fileInit.Data(1) == 53) %Needs to shutdown in this case according to the user
        break;
    end
    movePalletToLightSensor(MOTOR_A, -60, nxtT2, SENSOR_3, currentLight3, 4);
    if (fileInit.Data(1) == 53) %Needs to shutdown in this case according to the user
        break;
    end
    while fileJunc2.Data(1) > 48 %Wait until the mainline is clear
        if (fileInit.Data(1) == 53)
            clear fileInit;
            clear fileJunc2;
            clear fileJunc3;
            delete(timerfind);
            CloseSensor(SENSOR_1, nxtT2);
            CloseSensor(SENSOR_2, nxtT2);
            CloseSensor(SENSOR_3, nxtT2);
            COM_CloseNXT(nxtT2);
            quit
        end
        pause(0.25);
    end
    fileJunc3.Data(1) = fileJunc3.Data(1) + 1;
    runTransferArm(MOTOR_B, nxtT2, 112);
    currentTimer = currentTimer + 1;
    %{
    if currentTimer == 9
        currentTimer = 1;
    end
    %}
    start(clearPalletT(currentTimer));
    if (fileInit.Data(1) == 53) %Needs to shutdown in this case according to the user
        break;
    end
    pause(1);
    if (fileInit.Data(1) == 53) %Needs to shutdown in this case according to the user
        break;
    end
    resetTransferArm(MOTOR_B, SENSOR_2, nxtT2, 13);%10
end

while fileInit.Data(1) ~= 53 %Wait for the finish button to be pressed
    pause(0.25);
end

%% Terminate this session
clear fileInit;
clear fileJunc2;
clear fileJunc3;
delete(timerfind);
CloseSensor(SENSOR_1, nxtT2);
CloseSensor(SENSOR_2, nxtT2);
CloseSensor(SENSOR_3, nxtT2);
COM_CloseNXT(nxtT2);
quit