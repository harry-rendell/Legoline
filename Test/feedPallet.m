function result = feedPallet(nxtFeed, touchSensor, liftMotor)
initMotor = NXTMotor(liftMotor);
initMotor.Power = -40;
initMotor.SpeedRegulation = 0;
pushPallet = NXTMotor(liftMotor,'Power',60);
pushPallet.SpeedRegulation=0;
pushPallet.TachoLimit=115+30;%Between 110+30 and 120+30 would do
pushPallet.ActionAtTachoLimit='Coast';
initMotor.SendToNXT(nxtFeed);
tic;
currentTime = toc;
while GetSwitch(touchSensor, nxtFeed) == 0
    if (toc - currentTime > 1.5)
        disp('Error reseting feeding unit');
        initMotor.Stop('off', nxtFeed);
        result = false;
        return;
    end
end
initMotor.Stop('brake', nxtFeed);
%The following code turns out to be unnecessary. It release the touch
%sensor by rotating the motor back by 30 degrees
%{
init.Power=50;
init.TachoLimit=30;
disp('comment');
init.ActionAtTachoLimit='brake';
init.SendToNXT(nxtFeed);
result=init.WaitFor(1,nxtFeed)
%}
pushPallet.SendToNXT(nxtFeed);
result = pushPallet.WaitFor(1.5, nxtFeed); %return 0 if the motor commands is finished otherwise return 1;
if (result == 1)
    disp('Error feeding pallets');
    pushPallet.Stop('off', nxtFeed);
end
%At first I just move the conveyor belt for a fixed degree
%Now I use the light sensor to detect if the pallet has reached the end
%of the conveyor belt
%{
movePallet = NXTMotor(MOTOR_B,'Power',60);
movePallet.SpeedRegulation=0;
movePallet.TachoLimit=780;%Push the pallet to almost the end
movePallet.SendToNXT(nxtFeed);
movePallet.WaitFor(0,nxtFeed);
disp('done');
%}