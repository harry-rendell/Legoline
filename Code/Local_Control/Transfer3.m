disp('Running Transfer3');
path2code = pwd;
path2code = path2code(1: length(path2code) - 13);
cd(path2code);

%% Collect information from configuration files
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(10) = 49;
fileJunc3 = memmapfile('Junction3.txt', 'Writable', true);
fileConfig = fopen('Configurations.txt', 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Transfer3', out{1}, 'exact');

%% Open NXT and wait for the ready sign
nxtT3Addr = char(out{2}(ind));
nxtT3 = COM_OpenNXTEx('USB', nxtT3Addr);
OpenLight(SENSOR_3, 'ACTIVE', nxtT3);
OpenSwitch(SENSOR_2, nxtT3);
OpenLight(SENSOR_1, 'ACTIVE', nxtT3);
resetTransferArm(MOTOR_B, SENSOR_2, nxtT3, 14);%16
fileInit.Data(10) = 50;
while fileInit.Data(1) == 48
    pause(0.25);
end

if fileInit.Data(1) ~= 50
    %Needs to stop in this case either because the user chooses to shut
    %down or the configuration file is corrupted
    clear fileJunc3;
    CloseSensor(SENSOR_1, nxtT3);
    CloseSensor(SENSOR_2, nxtT3);
    CloseSensor(SENSOR_3, nxtT3);
    COM_CloseNXT(nxtT3);
    if fileInit.Data(1) ~= 49
        disp('Error reading initialization data');
        pause(5);
    end
    clear fileInit;
    quit;
end

%% Start the main loop
disp('Started!');
currentLight1 = GetLight(SENSOR_1, nxtT3);
currentLight3 = GetLight(SENSOR_3, nxtT3);
cd([pwd filesep 'Local_Control']);%CRUCIAL
for i=1:1:11
    if (fileInit.Data(1) == 53) %Needs to shutdown in this case according to the user
        break;
    end
    while abs(GetLight(SENSOR_1, nxtT3) - currentLight1) < 11
        pause(0.05);
    end
    if (fileInit.Data(1) == 53)
        break;
    end
    movePalletToLightSensor(MOTOR_A, -60, nxtT3, SENSOR_3, currentLight3, 4);
    if (fileInit.Data(1) == 53)
        break;
    end
    while fileJunc3.Data(1) > 48 %Wait until the mainline is clear
        if (fileInit.Data(1) == 53)
            clear fileInit;
            clear fileJunc3;
            delete(timerfind);
            CloseSensor(SENSOR_1, nxtT3);
            CloseSensor(SENSOR_2, nxtT3);
            CloseSensor(SENSOR_3, nxtT3);
            COM_CloseNXT(nxtT3);
            quit
        end
        pause(0.25);
    end
    runTransferArm(MOTOR_B, nxtT3, 105);
    if fileInit.Data(1) == 53
        break;
    end
    pause(1);
    if fileInit.Data(1) == 53
        break;
    end
    resetTransferArm(MOTOR_B, SENSOR_2, nxtT3, 14);%16
end

while fileInit.Data(1) ~= 53 %Wait for the finish button to be pressed
    pause(0.25);
end

%% Terminate this session
clear fileInit;
clear fileJunc3;
delete(timerfind);
CloseSensor(SENSOR_1, nxtT3);
CloseSensor(SENSOR_2, nxtT3);
CloseSensor(SENSOR_3, nxtT3);
COM_CloseNXT(nxtT3);
quit