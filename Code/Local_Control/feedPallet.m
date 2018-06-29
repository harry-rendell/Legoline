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
    pause(0.1);% Updating the touch sensor too often leads to IO error
end
initMotor.Stop('brake',nxtFeed);
pushPallet.SendToNXT(nxtFeed);
result = pushPallet.WaitFor(1.5, nxtFeed);
if (result == 1)
    disp('Error feeding pallets');
    pushPallet.Stop('off', nxtFeed);
end