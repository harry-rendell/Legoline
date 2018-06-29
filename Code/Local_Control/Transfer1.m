disp('Running Transfer1');
path2code = pwd; %Identify working directory
path2code = path2code(1: length(path2code) - 13);
cd(path2code);

%% Collect information from configuration files
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(4) = 49;
fileJunc1 = memmapfile('Junction1.txt', 'Writable', true);
fileJunc2 = memmapfile('Junction2.txt', 'Writable', true);
fileConfig = fopen('Configurations.txt', 'rt'); 
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Transfer1', out{1}, 'exact');

%% Open NXT and wait for the ready sign
nxtT1Addr = char(out{2}(ind)); %Identify address of NXT Transfer1
nxtT1 = COM_OpenNXTEx('USB', nxtT1Addr); %Establish connection
OpenLight(SENSOR_3, 'ACTIVE', nxtT1); %turn on sensors
OpenSwitch(SENSOR_2, nxtT1);
OpenLight(SENSOR_1, 'ACTIVE', nxtT1); 
resetTransferArm(MOTOR_B, SENSOR_2, nxtT1, 15); %Calibrate arm, set angle to 15deg from touch sensor
fileInit.Data(4) = 50;
while fileInit.Data(1) == 48
    pause(0.25);
end

if fileInit.Data(1) ~= 50
    %Needs to stop in this case either because the user chooses to shut
    %down or the configuration file is corrupted
    clear fileJunc1;
    clear fileJunc2;
    CloseSensor(SENSOR_1, nxtT1);
    CloseSensor(SENSOR_2, nxtT1);
    CloseSensor(SENSOR_3, nxtT1);
    COM_CloseNXT(nxtT1);
    if fileInit.Data(1) ~= 49
        disp('Error reading initialization data');
        pause(5);
    end
    clear fileInit;
    quit;
end

%% Start the main loop
disp('Started!');
currentLight1 = GetLight(SENSOR_1, nxtT1);
currentLight3 = GetLight(SENSOR_3, nxtT1);
cd([pwd filesep 'Local_Control']); %CRUCIAL
clearPalletT = [timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);
                timer('TimerFcn', 'fileJunc2.Data(1) = fileJunc2.Data(1) - 1', 'StartDelay', 3.3);];
currentTimer = 0;
for i=1:1:11
    if (fileInit.Data(1) == 53) %Needs to shutdown in this case according to the user
        break;
    end
    while abs(GetLight(SENSOR_1, nxtT1) - currentLight1) < 11
        pause(0.05);
    end
    if (fileInit.Data(1) == 53)
        break;
    end
    movePalletToLightSensor(MOTOR_A, -60, nxtT1, SENSOR_3, currentLight3, 4);
    if (fileInit.Data(1) == 53)
        break;
    end
    while fileJunc1.Data(1) > 48 %Wait until the mainline is clear
        if (fileInit.Data(1) == 53)
            clear fileInit;
            clear fileJunc1;
            clear fileJunc2;
            delete(timerfind);
            CloseSensor(SENSOR_1, nxtT1);
            CloseSensor(SENSOR_2, nxtT1);
            CloseSensor(SENSOR_3, nxtT1);
            COM_CloseNXT(nxtT1);
            quit
        end
        pause(0.25);
    end
    %Don't know if the following code is necessary
    %{
    NoOfPallets = fileJunc2.Data(1) + 1;
    for j = 1:5 %Make sure our modification is successful
        fileJunc2.Data(1) = NoOfPallets;
        pause(0.04);
    end
    %}
    fileJunc2.Data(1) = fileJunc2.Data(1) + 1;
    runTransferArm(MOTOR_B, nxtT1, 105);
    currentTimer = currentTimer + 1;
    %{
    if currentTimer == 9
        currentTimer = 1;
    end
    %}
    start(clearPalletT(currentTimer));
    if fileInit.Data(1) == 53
        break;
    end
    pause(1);
    if fileInit.Data(1) == 53
        break;
    end
    resetTransferArm(MOTOR_B, SENSOR_2, nxtT1, 15);
end

while fileInit.Data(1) ~= 53 %Wait for the finish button to be pressed
    pause(0.25);
end

%% Terminate this session
clear fileInit;
clear fileJunc1;
clear fileJunc2;
delete(timerfind);
CloseSensor(SENSOR_1, nxtT1);
CloseSensor(SENSOR_2, nxtT1);
CloseSensor(SENSOR_3, nxtT1);
COM_CloseNXT(nxtT1);
quit