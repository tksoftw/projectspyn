% Team 4
% Thomas Kennedy, Seva Gaskov, Riley Seefeldt, Man-Ning Chen

% brick = ConnectBrick('ASU_PD_VAN_8');

% COLORS:
% Yellow: Starting position
% Red: Stop for a second
% Blue: Pick up passenger
% Green: Drop off location


stop(brick);
brick.GyroCalibrate(4);
pause(1);   
brick.SetColorMode(3, 2);
%turnLeft(brick);
%turnRight(brick);
%turnLeft(brick);


global key;
global clawOpen;
global passengerPickedUp;
global passengerDroppedOff;
global running;
global greenTimerStart;
global greenTimerEnd;

greenTimerStart = 0;
greenTimerEnd = 0;
passengerDroppedOff = false;
passengerPickedUp = false;
clawOpen = false;


%turnRight(brick);
%turnUntilAngle(brick, 175);
%pickUpPassenger(brick);
%turnLeft(brick);


%moveBackward(brick);
%pause(1);

%toggleClaw(brick);
%passengerPickedUp = ~passengerPickedUp;

%turnUntilAngle(brick, 175);

nonBlockingMoveForward(brick, 2);

running = 0;
while running
    moveForward(brick);
    if ~clawOpen
        keepClawClosed(brick);
    end
    if (~frontClear(brick))
        backupAndTurn(brick);
    elseif (~onWall(brick))
        moveAroundWall(brick);
    else
        reactToColor(brick); 
    end
end


function dropOffPassenger(brick)
    disp("Dropping off");
    global clawOpen;
    global key;
    global passengerPickedUp;
    global passengerDroppedOff;

    passengerPickedUp = false;

    stop(brick);
    
    brick.GyroCalibrate(4);

    turnUntilAngle(brick, 175);    
    
    InitKeyboard();
    disp("Pausing to initialize keyboard");
    pause(2);

    while ~clawOpen
        moveBackward(brick);
        pause(0.1);
        switch key
            case 'space'
                stop(brick);
                toggleClaw(brick);
            otherwise
               
        end
    end
    passengerDroppedOff = true;
    stop(brick);

    CloseKeyboard();
    disp("Pausing to close keyboard");
end


function pickUpPassenger(brick)
    disp("Picking Up")
    global clawOpen;
    global key;
    global passengerPickedUp;
    
    passengerPickedUp = true;
    stop(brick);
    
    brick.GyroCalibrate(4);
    pause(1);

    turnUntilAngle(brick, 175);
    if ~clawOpen
        toggleClaw(brick);
    end

    InitKeyboard();
    disp("Pausing to initialize keyboard");
    pause(2);


    while clawOpen
        moveBackward(brick);
        pause(0.1);
        switch key
            case 'space'
                stop(brick);
                toggleClaw(brick);
            otherwise
               
        end
    end
    
    
    CloseKeyboard();
    disp("Pausing to close keyboard");
    pause(2);
    turnUntilAngle(brick, 175);
end

function moveAroundWall(brick)
    disp("No wall, turning...");
    stop(brick);
    nonBlockingMoveForward(brick, 2.5);
    turnRight(brick);
    nonBlockingMoveForward(brick, 5);
end

function backupAndTurn(brick)
    disp("Hit wall, backing up...")
    stop(brick);
    nonBlockingMoveBackward(brick, 2);
    turnLeft(brick);
end

function toggleClaw(brick)
    global clawOpen;
    %disp(clawOpen)
    clawOpen = ~clawOpen;
    %disp(clawOpen)
    speed = 10;
    brick.MoveMotor('A', speed*(-1)^clawOpen);
    pause(0.75);
    stop(brick);
    brick.MoveMotor('A', speed*(-1)^clawOpen);
end

function keepClawClosed(brick)
    brick.MoveMotor('A', 20);
end
    

function moveBackward(brick)
    speed = 20;
    brick.MoveMotor('C', speed*1.11);
    brick.MoveMotor('B', speed);
end

function moveForward(brick)
    speed = -20;
    brick.MoveMotor('C', speed*1.11);
    brick.MoveMotor('B', speed);
end

function nonBlockingMoveForward(brick, duration)
    global clawOpen;
    tic;  % Start timer
    moveForward(brick);
    while toc < duration
        reactToColor(brick);
        if ~clawOpen
            keepClawClosed(brick);
        end
        %reactToColor(brick, color);
        %pause(0.05);  % Short pause to avoid overloading the CPU
    end
    stop(brick);  % Stop after duration
end

function nonBlockingMoveBackward(brick, duration)
    tic;  % Start timer
    moveBackward(brick);
    while toc < duration
        reactToColor(brick);
        %pause(0.05);  % Short pause to avoid overloading the CPU
    end
    stop(brick);  % Stop after duration
end

function turnRight(brick)
    turnUntilAngle(brick, -86);
end

function turnLeft(brick)
    turnUntilAngle(brick, 86);
end

function turnUntilAngle(brick, targetAngle)
    speed = 20;
    error = 3;
    brick.GyroCalibrate(4);
    currentAngle = brick.GyroAngle(4);
    while (abs(targetAngle - currentAngle) > error)
        reactToColor(brick);
        brick.MoveMotor('B', -speed);
        brick.MoveMotor('C', speed);
        if (targetAngle > currentAngle && speed < 0 || targetAngle < currentAngle && speed > 0)
            speed = -speed;
        end
        currentAngle = brick.GyroAngle(4);
        %pause(0.05);
    end
    stop(brick);
end

function reactToColor(brick)
    global passengerPickedUp;
    global passengerDroppedOff;
    global running;
    global greenTimerStart;
    global greenTimerEnd;

    color = brick.ColorCode(3);
    %disp(color)
    if greenTimerStart ~= 0 && color ~= 3
        greenTimerStart = 0;
        greenTimerEnd = 0;
    end
    switch color
        case 5 % Red 
            % Perform action for red color
            stop(brick);
            pause(1);
            moveForward(brick);
        case 2 % Blue
            if ~passengerPickedUp
                pickUpPassenger(brick);
            end
        case 3 % Green
            if greenTimerStart == 0
                greenTimerStart = tic;
            end
            greenTimerEnd = toc(greenTimerStart);
            if passengerPickedUp && (greenTimerEnd > 1)
                dropOffPassenger(brick);
            end
        case 4 % Yellow
            if passengerDroppedOff
                stop(brick);
                nonBlockingMoveForward(brick, 2);
                running = false;
            end
        otherwise
          
    end
end

function beepMultiple(brick, amount, duration)
    for i=1:amount
        brick.beep(duration);
        pause(duration);
    end
end


function frontIsClear = frontClear(brick)
    frontIsClear = ~brick.TouchPressed(2);
end

function isOnWall = onWall(brick)
    isOnWall = brick.UltrasonicDist(1) < 50;
end

function stop(brick)
    brick.StopAllMotors();
end
