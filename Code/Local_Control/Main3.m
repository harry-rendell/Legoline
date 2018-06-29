disp('Running Main3 continuously');
path2code = pwd;
path2code = path2code(1: length(path2code) - 13);
cd(path2code);

%% Collect information from configuration files
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(9) = 49;
fileConfig = fopen('Configurations.txt', 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Main3', out{1}, 'exact');

%% Open NXT and wait for the ready sign
nxtM3Addr = char(out{2}(ind));
nxtM3 = COM_OpenNXTEx('USB', nxtM3Addr);
OpenLight(SENSOR_1, 'ACTIVE', nxtM3);
OpenLight(SENSOR_2, 'ACTIVE', nxtM3);
fileInit.Data(9) = 50;
while fileInit.Data(1) == 48
    pause(0.25);
end

if fileInit.Data(1) ~= 50
    %Needs to stop in this case either because the user chooses to shut
    %down or the configuration file is corrupted
    CloseSensor(SENSOR_1, nxtM3);
    CloseSensor(SENSOR_2, nxtM3);
    COM_CloseNXT(nxtM3);
    if fileInit.Data(1) ~= 49
        disp('Error reading initialization data');
        pause(5);
    end
    clear fileInit;
    quit;
end

%% Start the main loop
disp('Started!');
keepMainlineRunning = NXTMotor(MOTOR_A);
keepMainLineRunning.SpeedRegulation = false;
keepMainlineRunning.Power = -40;
keepMainlineRunning.SendToNXT(nxtM3);
while fileInit.Data(1) ~= 53
    pause(0.25);
end

%% Terminate this session
clear fileInit;
keepMainlineRunning.Stop('off', nxtM3);
CloseSensor(SENSOR_1, nxtM3);
CloseSensor(SENSOR_2, nxtM3);
COM_CloseNXT(nxtM3);
quit;