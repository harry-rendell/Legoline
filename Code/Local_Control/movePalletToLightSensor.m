function result = movePalletToLightSensor(motor, power, nxt, port, currentValue, timeOut)
%movePalletToLightSensor(motor, power, nxt, port, currentValue)
%Move the pallet until the light sensor detects it
%Return true if the function is completed within timeOut false otherwise
tic;
currentTime = toc;
movePallet = NXTMotor(motor, 'Power', power);
movePallet.SpeedRegulation = 0;
movePallet.SendToNXT(nxt);
while abs(GetLight(port, nxt) - currentValue) < 11
    if (toc - currentTime > timeOut)
        disp('The light sensor hasnt detected the pallet before timeout');
        movePallet.Stop('off', nxt);
        result = false;
        return;
    end
    pause(0.1);% Updating the light sensor too often leads to IO error
end
result = true;
movePallet.Stop('off', nxt);
end