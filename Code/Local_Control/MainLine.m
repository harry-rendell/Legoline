disp('Running Mainline continuously');
path2code = pwd;
path2code = path2code(1: length(path2code) - 13);
cd(path2code);
fileJunc1 = memmapfile('Junction1.txt', 'Writable', true);
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');
fileInit.Data(3) = 49;
fileInit.Data(6) = 49;
fileInit.Data(9) = 49;
fileConfig = fopen('Configurations.txt', 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
ind = strmatch('Main1', out{1}, 'exact');
nxtM1Addr = char(out{2}(ind));
ind = strmatch('Main2', out{1}, 'exact');
nxtM2Addr = char(out{2}(ind));
ind = strmatch('Main3', out{1}, 'exact');
nxtM3Addr = char(out{2}(ind));
%It takes a while to connect to the NXTs. If I place this block of code
%after the file modification the mainline is going to start after the other
%three units start
nxtM1 = COM_OpenNXTEx('USB', nxtM1Addr);
nxtM2 = COM_OpenNXTEx('USB', nxtM2Addr);
nxtM3 = COM_OpenNXTEx('USB', nxtM3Addr);
fileInit.Data(3) = 50;
fileInit.Data(6) = 50;
fileInit.Data(9) = 50;

while fileInit.Data(1) == 48
    pause(0.25);
end

if (fileInit.Data(1) == 49) %Needs to shutdown in this case according to the user
    clear fileInit;
    COM_CloseNXT(nxtM1);
    COM_CloseNXT(nxtM2);
    COM_CloseNXT(nxtM3);
    quit force;
end

if (fileInit.Data(1) ~= 50) %Maybe the file 'Initialization data' has been modified?
    clear fileInit;
    COM_CloseNXT(nxtM1);
    COM_CloseNXT(nxtM2);
    COM_CloseNXT(nxtM3);
    disp('Error reading initialization data');
    pause(5);
    quit force;
end
disp('Started!');
keepMainlineRunning = NXTMotor(MOTOR_A);
keepMainLineRunning.SpeedRegulation = false;
keepMainlineRunning.Power = -40;
keepMainlineRunning.SendToNXT(nxtM1);
keepMainlineRunning.SendToNXT(nxtM2);
%keepMainlineRunning.SendToNXT(nxtM3);
while fileInit.Data(1) ~= 53
    
end
clear fileInit;
clear fileJunc1;
keepMainlineRunning.Stop('off', nxtM1);
keepMainlineRunning.Stop('off', nxtM2);
keepMainlineRunning.Stop('off', nxtM3);
COM_CloseNXT('all');
quit