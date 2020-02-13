close all; clear var;
%========%
%此仿真条件对应教材上图3-4，把thetaT的误差调整一位小数点之后(0.5e-2)接近书上的效果
%========%

xt = 0; yt = 0;    %x发射站地址
x = -20e3 : 100 : 20e3; y = -20e3 : 100 : 20e3;    %x和y的范围
c = 1500; 
sigmaT = 1e-3; sigmaThetaT = 0.5e-2; sigmaS = 5;    %各种误差
sigmaRt = c * sigmaT * 2;    %此处不确定要不要?2

GDOP = zeros(401);
GDOPTotal = zeros(401);

% rT = zeros; thetaT = zeros; 
squareSigmaX = zeros; squareSigmaY = zeros;    %增加运算速度，消除警告?

timeOfMonteCarlo = 500;    %蒙塔卡洛次数
randomXt = unifrnd(xt - sigmaS, xt + sigmaS, 1, timeOfMonteCarlo);
randomYt = unifrnd(yt - sigmaS, yt + sigmaS, 1, timeOfMonteCarlo);    %生成500个带误差的站址
deltaRandomRt = unifrnd(-sigmaRt, sigmaRt, 1, timeOfMonteCarlo);    %500个Rt的误差增量
deltaRandomThetaT = unifrnd(-sigmaThetaT, sigmaThetaT, 1, timeOfMonteCarlo);    %500个thetaT的误差增量

for time = 1 : timeOfMonteCarlo    %若干次蒙特卡洛
    for inX = 1 : length(x)
        for inY = 1 : length(y)
            xt = randomXt(time); yt = randomYt(time);    %将站址替换为有误差的站址
            
            rT = sqrt((x(inX) - xt) ^ 2 + (y(inY) - yt) ^ 2);
            thetaT = atan2(y(inY) - yt, x(inX) - xt);
            % rT = rT + deltaRandomRt(time);
            % thetaT = thetaT + deltaRandomThetaT(time);    %不确定这两句要不要加上
            %(3-7)
            
            xSolution = xt + rT * cos(thetaT);
            ySolution = yt + rT * sin(thetaT);
            % (3-8)
            
            squareSigmaX(inX, inY) = cos(thetaT) ^ 2 * sigmaRt ^ 2 + rT ^ 2 * sin(thetaT) ^ 2 * sigmaThetaT ^ 2 + sigmaS ^ 2;
            squareSigmaY(inX, inY) = sin(thetaT) ^ 2 * sigmaRt ^ 2 + rT ^ 2 * cos(thetaT) ^ 2 * sigmaThetaT ^ 2 + sigmaS ^ 2;
            % (3-14)
            
            GDOP(inX, inY) = sqrt(squareSigmaX(inX, inY) + squareSigmaY(inX, inY));
            %(3-13)
            
            %这个时候应该把GDOP存起来
            GDOPTotal(inX, inY) = GDOPTotal(inX, inY) + GDOP(inX, inY);
            %存到GDOPTotal里
            
        end
    end    
end

GDOPTotal = GDOPTotal / timeOfMonteCarlo;    %GDOP求均值

figure
mesh(x, y, GDOPTotal);
colorbar;
title('三维GDOP图像');
xlabel('x(m)');
ylabel('y(m)');
zlabel('z(m)');

figure;
[C, h] = contour(x, y, GDOPTotal,  'ShowText', 'On');
v = [50 100 200 300 400];
clabel(C, h);
title('GDOP(m)');
xlabel('x(m)');
ylabel('y(m)');