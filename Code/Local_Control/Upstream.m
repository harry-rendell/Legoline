disp('Running upstream');
path2code = pwd;
path2code = path2code(1: length(path2code) - 13);
cd(path2code);

%% Collect information from configuration files
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(2) = 49;
fileJunc1 = memmapfile('Junction1.txt', 'Writable', true);
fileConfig = fopen('Configurations.txt', 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Upstream', out{1}, 'exact');
nxtUAddr = char(out{2}(ind));
fileParam = fopen('Parameters.txt', 'rt');
out = textscan(fileParam, '%s %s %s %s %s')
fclose(fileParam);
ind = strmatch('ControlUpstr', out{1}, 'exact');
mode = out{2}(ind) %which type of distribution
param1 = str2num(char(out{3}(ind)));
param2 = out{4}(ind);
param3 = out{5}(ind);

%% Open NXT and wait for the ready sign
nxtU = COM_OpenNXTEx('USB', nxtUAddr);
OpenSwitch(SENSOR_1, nxtU);
OpenLight(SENSOR_2, 'ACTIVE', nxtU);
fileInit.Data(2) = 50;
while fileInit.Data(1) == 48
    pause(0.25);
end

if fileInit.Data(1) ~= 50
    %Needs to stop in this case either because the user chooses to shut
    %down or the configuration file is corrupted
    clear fileJunc1;
    CloseSensor(SENSOR_2, nxtU);
    CloseSensor(SENSOR_1, nxtU);
    COM_CloseNXT(nxtU);
    if fileInit.Data(1) ~= 49
        disp('Error reading initialization data');
        pause(5);
    end
    clear fileInit;
    quit;
end

%% Start the main loop
disp('Started!');
currentLight2 = GetLight(SENSOR_2, nxtU);
cd([pwd filesep 'Local_Control']);%CRUCIAL
clearPalletU = [timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);
                timer('TimerFcn', 'fileJunc1.Data(1) = fileJunc1.Data(1) - 1', 'StartDelay', 1.8);];
currentTimer = 0;
for i=1:1:11
    fileJunc1.Data(1) = fileJunc1.Data(1) + 1;
    if fileInit.Data(1) == 53
        break;
    end
    feedPallet(nxtU, SENSOR_1, MOTOR_A);
    if fileInit.Data(1) == 53
        break;
    end
    movePalletToLightSensor(MOTOR_B, 60, nxtU, SENSOR_2, currentLight2, 4);
    if fileInit.Data(1) == 53
        break;
    end
    currentTimer = currentTimer + 1;
    %{
    if currentTimer == 9
        currentTimer = 1;
    end
    %}
    start(clearPalletU(currentTimer));
    pause(param1);
end

while fileInit.Data(1) ~= 53 %Wait for the finish button to be pressed
    pause(0.25);
end

%% Terminate this session
CloseSensor(SENSOR_2, nxtU);
CloseSensor(SENSOR_1, nxtU);
COM_CloseNXT(nxtU);
delete(timerfind);
clear fileJunc1;
clear fileInit;
quit;