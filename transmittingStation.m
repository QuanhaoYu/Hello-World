close all; clear var;
%========%
%�˷���������Ӧ�̲���ͼ3-4����thetaT��������һλС����֮��(0.5e-2)�ӽ����ϵ�Ч��
%========%

xt = 0; yt = 0;    %x����վ��ַ
x = -20e3 : 100 : 20e3; y = -20e3 : 100 : 20e3;    %x��y�ķ�Χ
c = 1500; 
sigmaT = 1e-3; sigmaThetaT = 0.5e-2; sigmaS = 5;    %�������
sigmaRt = c * sigmaT * 2;    %�˴���ȷ��Ҫ��Ҫ?2

GDOP = zeros(401);
GDOPTotal = zeros(401);

% rT = zeros; thetaT = zeros; 
squareSigmaX = zeros; squareSigmaY = zeros;    %���������ٶȣ���������?

timeOfMonteCarlo = 500;    %�����������
randomXt = unifrnd(xt - sigmaS, xt + sigmaS, 1, timeOfMonteCarlo);
randomYt = unifrnd(yt - sigmaS, yt + sigmaS, 1, timeOfMonteCarlo);    %����500��������վַ
deltaRandomRt = unifrnd(-sigmaRt, sigmaRt, 1, timeOfMonteCarlo);    %500��Rt���������
deltaRandomThetaT = unifrnd(-sigmaThetaT, sigmaThetaT, 1, timeOfMonteCarlo);    %500��thetaT���������

for time = 1 : timeOfMonteCarlo    %���ɴ����ؿ���
    for inX = 1 : length(x)
        for inY = 1 : length(y)
            xt = randomXt(time); yt = randomYt(time);    %��վַ�滻Ϊ������վַ
            
            rT = sqrt((x(inX) - xt) ^ 2 + (y(inY) - yt) ^ 2);
            thetaT = atan2(y(inY) - yt, x(inX) - xt);
            % rT = rT + deltaRandomRt(time);
            % thetaT = thetaT + deltaRandomThetaT(time);    %��ȷ��������Ҫ��Ҫ����
            %(3-7)
            
            xSolution = xt + rT * cos(thetaT);
            ySolution = yt + rT * sin(thetaT);
            % (3-8)
            
            squareSigmaX(inX, inY) = cos(thetaT) ^ 2 * sigmaRt ^ 2 + rT ^ 2 * sin(thetaT) ^ 2 * sigmaThetaT ^ 2 + sigmaS ^ 2;
            squareSigmaY(inX, inY) = sin(thetaT) ^ 2 * sigmaRt ^ 2 + rT ^ 2 * cos(thetaT) ^ 2 * sigmaThetaT ^ 2 + sigmaS ^ 2;
            % (3-14)
            
            GDOP(inX, inY) = sqrt(squareSigmaX(inX, inY) + squareSigmaY(inX, inY));
            %(3-13)
            
            %���ʱ��Ӧ�ð�GDOP������
            GDOPTotal(inX, inY) = GDOPTotal(inX, inY) + GDOP(inX, inY);
            %�浽GDOPTotal��
            
        end
    end    
end

GDOPTotal = GDOPTotal / timeOfMonteCarlo;    %GDOP���ֵ

figure
mesh(x, y, GDOPTotal);
colorbar;
title('��άGDOPͼ��');
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