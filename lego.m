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
brick.SetColorMode(3, 2);
%turnLeft(brick);
%turnRight(brick, -1);

lastColor = [-1,2];

while 0
    moveForward(brick);
    if (~onWall(brick))
        moveAroundWall(brick, lastColor);
    elseif (~frontClear(brick))
        backupAndTurn(brick, lastColor);
    else
        colorCheckAndReact(brick, lastColor);
    end
end


function pickUpPassenger(brick)
    moveBackward(brick);
end

function moveAroundWall(brick, lastColor)
    stop(brick);
    nonBlockingMoveForward(brick, 1.5, lastColor);
    turnRight(brick, lastColor);
    nonBlockingMoveForward(brick, 3, lastColor);
end

function backupAndTurn(brick, lastColor)
    stop(brick);
    nonBlockingMoveBackward(brick, 2, lastColor);
    turnLeft(brick, lastColor);
end

function moveBackward(brick)
    speed = 20;
    brick.MoveMotor('C', speed*1.08);
    brick.MoveMotor('B', speed);
end

function moveForward(brick)
    speed = -20;
    brick.MoveMotor('C', speed*1.08);
    brick.MoveMotor('B', speed);
end

function nonBlockingMoveForward(brick, duration, lastColor)
    tic;  % Start timer
    moveForward(brick);
    while toc < duration
        colorCheckAndReact(brick, lastColor);  % Check color while moving
        %pause(0.05);  % Short pause to avoid overloading the CPU
    end
    stop(brick);  % Stop after duration
end

function nonBlockingMoveBackward(brick, duration, lastColor)
    tic;  % Start timer
    moveBackward(brick);
    while toc < duration
        colorCheckAndReact(brick, lastColor);  % Check color while moving
        %pause(0.05);  % Short pause to avoid overloading the CPU
    end
    stop(brick);  % Stop after duration
end

function turnRight(brick, lastColor)
    turnUntilAngle(brick, 87, lastColor);
end

function turnLeft(brick, lastColor)
    turnUntilAngle(brick, -87, lastColor);
end

function turnUntilAngle(brick, targetAngle, lastColor)
    speed = 20;
    error = 3;
    brick.GyroCalibrate(4);
    currentAngle = brick.GyroAngle(4);
    while (abs(targetAngle - currentAngle) > error)
        brick.MoveMotor('B', speed);
        brick.MoveMotor('C', -speed);
        if (targetAngle > currentAngle && speed < 0 || targetAngle < currentAngle && speed > 0)
            speed = -speed;
        end
        currentAngle = brick.GyroAngle(4);
        %pause(0.05);
        colorCheckAndReact(brick, lastColor);
    end
    stop(brick);
end

function colorCheckAndReact(brick, lastColor)
    brick.SetColorMode(3, 2);
    % global lastColor;  % Access the global variable inside the function

    currentColor = brick.ColorCode(3);  % Function to return the current color code detected

    % Check if a new color has been detected
    if true % currentColor ~= lastColor(1)
        disp(currentColor);

        lastColor(1) = currentColor;

        % Perform the action based on the color
        try
            switch currentColor
                case 5 % Red
                    % Perform action for red color
                    stop(brick);
                    pause(1);
                    moveForward(brick);
                case 2 % Blue
                    brick.playTone(100, 500, 1000);
                    pause(1);
                    brick.playTone(100, 500, 1000);
                    pause(1);
                    brick.playTone(100, 500, 1000);
                    pause(1);
                case 3 % Green
                    brick.playTone(100, 800, 1000);
                    pause(1);
                    brick.playTone(100, 800, 1000);
                    pause(1);
                otherwise
                    disp('nothing')
            end
        catch
            disp('errored')
        end
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
