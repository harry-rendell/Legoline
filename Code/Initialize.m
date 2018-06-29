COM_CloseNXT('all');
currentDir = pwd;
cd(currentDir(1:length(currentDir)-5));
ConfigurePaths;
fileInit = fopen(path2init, 'wt');
fwrite(fileInit, 48 * ones(15, 1));
fclose(fileInit);
fileConfig = fopen(path2config, 'rt');
out = textscan(fileConfig, '%s %s');
fclose(fileConfig);
fileJunction1 = fopen(path2Junc1, 'wt');
fwrite(fileJunction1, 48);
fclose(fileJunction1);
fileJunction2 = fopen(path2Junc2, 'wt');
fwrite(fileJunction2, 48);
fclose(fileJunction2);
fileJunction3 = fopen(path2Junc3, 'wt');
fwrite(fileJunction3, 48);
fclose(fileJunction3);
ind = strmatch('No_of_Feedlines', out{1}, 'exact');
Number_of_Feedlines = out{2}(ind);
disp(['The number of feed lines is ',Number_of_Feedlines{1}])
Number_of_Feedlines = str2num(Number_of_Feedlines{1}); 
ind = strmatch('No_of_Splitters', out{1}, 'exact');
Number_of_Splitters = out{2}(ind);
disp(['The number of splitters is ', Number_of_Splitters{1}])
clear ind;
clear out;
clear Number_of_Feedlines;
clear Number_of_Splitters;
cd(currentDir);
fileInit = memmapfile('InitializationStatus.txt', 'Writable', true, 'Format', 'int8');

cd([pwd filesep 'Local_Control']);

!matlab  -nodesktop -minimize -nosplash -r Upstream&
!matlab  -nodesktop -minimize -nosplash -r Feed1&
!matlab  -nodesktop -minimize -nosplash -r Transfer1&
!matlab  -nodesktop -minimize -nosplash -r Feed2&
!matlab  -nodesktop -minimize -nosplash -r Transfer2&
!matlab  -nodesktop -minimize -nosplash -r Feed3&
!matlab  -nodesktop -minimize -nosplash -r Transfer3&
!matlab  -nodesktop -minimize -nosplash -r Main1&
!matlab  -nodesktop -minimize -nosplash -r Main2&
!matlab  -nodesktop -minimize -nosplash -r Main3&
!matlab  -nodesktop -minimize -nosplash -r Splitter1&

for i=1:100
    result = input('Please enter one of the following numbers:\n0 if you want to view the status of initialization\n1 if you want to abort the initialization\n2 If you are happy with the initialization and wish to continue');
if result == 0
    clc;
    switch fileInit.Data(2)
            case 48
            disp('Upstream:......');
        case 49
            disp('Upstream: Connecting(Maybe failed)');
        case 50
            disp('Upstream: Success');
        otherwise
            disp('Upstream: Error');
    end
    switch fileInit.Data(3)
        case 48
            disp('Main1:......');
        case 49
            disp('Main1: Connecting(Maybe failed)');
        case 50
            disp('Main1: Success');
        otherwise
            disp('Main1: Error');
    end
    switch fileInit.Data(4)
        case 48
            disp('Transfer1:......');
        case 49
            disp('Transfer1: Connecting(Maybe failed)');
        case 50
            disp('Transfer1: Success');
        otherwise
            disp('Transfer1: Error');
    end
    switch fileInit.Data(5)
        case 48
            disp('Feed1:......');
        case 49
            disp('Feed1: Connecting(Maybe failed)');
        case 50
            disp('Feed1: Success');
        otherwise
            disp('Feed1: Error');
    end
    switch fileInit.Data(6)
        case 48
            disp('Main2:......');
        case 49
            disp('Main2: Connecting(Maybe failed)');
        case 50
            disp('Main2: Success');
        otherwise
            disp('Main2: Error');
    end
    switch fileInit.Data(7)
        case 48
            disp('Transfer2:......');
        case 49
            disp('Transfer2: Connecting(Maybe failed)');
        case 50
            disp('Transfer2: Success');
        otherwise
            disp('Transfer2: Error');
    end
    switch fileInit.Data(8)
        case 48
            disp('Feed2:......');
        case 49
            disp('Feed2: Connecting(Maybe failed)');
        case 50
            disp('Feed2: Success');
        otherwise
            disp('Feed2: Error');
    end
    switch fileInit.Data(9)
        case 48
            disp('Main3:......');
        case 49
            disp('Main3: Connecting(Maybe failed)');
        case 50
            disp('Main3: Success');
        otherwise
            disp('Main3: Error');
    end
    switch fileInit.Data(10)
        case 48
            disp('Transfer3:......');
        case 49
            disp('Transfer3: Connecting(Maybe failed)');
        case 50
            disp('Transfer3: Success');
        otherwise
            disp('Transfer3: Error');
    end
    switch fileInit.Data(11)
        case 48
            disp('Feed3:......');
        case 49
            disp('Feed3: Connecting(Maybe failed)');
        case 50
            disp('Feed3: Success');
        otherwise
            disp('Feed3: Error');
    end
    switch fileInit.Data(12)
        case 48
            disp('Splitter1:......');
        case 49
            disp('Splitter1: Connecting(Maybe failed)');
        case 50
            disp('Splitter1: Success');
        otherwise
            disp('Splitter1: Error');
    end
elseif result == 1
    fileInit.Data(1) = 49; %Let all the other MATLAB instances know that we are shutting down
    clear fileInit;
    clear i;
    clear result;
    clear fileInitStatus;
    clear fileConfig;
    quit;
elseif result == 2
    clear fileInit;%If user is OK with the initialization, then just quit the program.
    clear i;
    clear result;
    clear fileInitStatus;
    clear fileConfig;
    quit;
else
    clc;
    disp('Please enter a valid number');
end
end