disp('Running Feed2');
path2code = pwd;
path2code = path2code(1: length(path2code) - 13);
cd(path2code);

%% Collect information from configuration files
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(8) = 49;
fileConfig = fopen('Configurations.txt', 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Feed2', out{1}, 'exact');
nxtF2Addr = char(out{2}(ind));
fileParam = fopen('Parameters.txt', 'rt');
out = textscan(fileParam, '%s %s %s %s %s')
fclose(fileParam);
ind = strmatch('ControlLine2', out{1}, 'exact');
mode = out{2}(ind) %which type of distribution
param1 = str2num(char(out{3}(ind)));
param2 = out{4}(ind);
param3 = out{5}(ind);

%% Open NXT and wait for the ready sign
nxtF2 = COM_OpenNXTEx('USB', nxtF2Addr);
OpenSwitch(SENSOR_1, nxtF2);
OpenLight(SENSOR_3, 'ACTIVE', nxtF2);
fileInit.Data(8) = 50;

while fileInit.Data(1) == 48 %Wait for the ready sign
    pause(0.25);
end

if fileInit.Data(1) ~= 50
    %Needs to stop in this case either because the user chooses to shut
    %down or the configuration file is corrupted
    CloseSensor(SENSOR_1, nxtF2);
    CloseSensor(SENSOR_3, nxtF2);
    COM_CloseNXT(nxtF2);
    if fileInit.Data(1) ~= 49
        disp('Error reading initialization data');
        pause(5);
    end
    clear fileInit;
    quit;
end

%% Start the main loop
disp('Started!');
currentLight3 = GetLight(SENSOR_3, nxtF2);
cd([pwd filesep 'Local_Control']);%Crucial
for i=1:1:11
    if fileInit.Data(1) == 53
        break;
    end
    feedPallet(nxtF2, SENSOR_1, MOTOR_A);
    if fileInit.Data(1) == 53
        break;
    end
    movePalletToLightSensor(MOTOR_B, 70, nxtF2, SENSOR_3, currentLight3, 4);
    if fileInit.Data(1) == 53
        break;
    end
    pause(param1);
end

while fileInit.Data(1) ~= 53 %Wait for the finish button to be pressed
    pause(0.25);
end

%% Terminate this session
clear fileInit;
CloseSensor(SENSOR_3, nxtF2);
CloseSensor(SENSOR_1, nxtF2);
COM_CloseNXT(nxtF2);
quit;