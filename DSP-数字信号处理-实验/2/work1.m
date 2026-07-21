%% 第一步：构建输入信号并绘制时域波形
clear; clc;

% 参数设置
N = 16;          % 滤波器阶数
L = 2 * N;       % 采样点数
f = 50;          % 信号基频(Hz)
fs = N * f;      % 采样频率(Hz)
T = 1 / fs;      % 采样周期(s)

% 采样时刻
n = 0:T:(L-1)*T; % 采样点位置
k = 0:L-1;       % 采样点索引

% 构建输入信号 s(t) = A0*cos(2π*0*t + φ0) + A1*cos(2π*f*t + φ1) + A2*cos(2π*2f*t + φ2) + A3*cos(2π*3f*t + φ3)
s = 0.5*cos(0) + ...                 % DC分量 A0=0.5, φ0=0
    1*cos(2*pi*f*n+pi/2) + ...       % 基波 A1=1, φ1=π/2
    0.5*cos(2*pi*2*f*n+pi) + ...     % 二次谐波 A2=0.5, φ2=π
    2*cos(2*pi*3*f*n-pi/2);          % 三次谐波 A3=2, φ3=-π/2

% 绘制时域采样信号
figure('Position', [100, 100, 800, 600]);
subplot(3, 1, 1);
stem(k, s, 'b', 'filled', 'LineWidth', 1.5);
xlabel('采样点 k');
ylabel('幅度');
title('采样信号时域波形 (L=32个采样点)');
grid on;
hold on;

%% 第二步：对第二个周期进行DFT分析
% 提取第二个周期的采样点 (从第N+1个点到第2N个点)
n1 = N*T:T:(L-1)*T;    % 第二个周期的采样时刻

% 重新计算第二个周期的信号
s_second = 0.5*cos(0) + ...                    % DC分量
           1*cos(2*pi*f*n1+pi/2) + ...      % 基波
           0.5*cos(2*pi*2*f*n1+pi) + ...    % 二次谐波
           2*cos(2*pi*3*f*n1-pi/2);         % 三次谐波

% 对第二个周期进行N点DFT
S_second = fft(s_second, N);

% 绘制幅频特性
subplot(3, 1, 2);
stem( (0:N-1), abs(S_second), 'b', 'filled', 'LineWidth', 1.5);
xlabel('N');
ylabel('幅度');
title('第二个周期DFT的幅频特性 (16点DFT)');
grid on;

% 绘制相频特性
subplot(3, 1, 3);
stem( (0:N-1) , angle(S_second), 'b', 'filled', 'LineWidth', 1.5);
xlabel('N');
ylabel('相位 (弧度)');
title('第二个周期DFT的相频特性');
grid on;

% 验证采样定理
% fprintf('\n采样定理验证:\n');
% fprintf('最高频率分量: %d Hz\n', 3*f);
% fprintf('采样频率: %d Hz\n', fs);
% fprintf('奈奎斯特频率: %d Hz\n', fs/2);
% if fs > 2 * 3 * f
%     fprintf('✓ 满足采样定理 (fs > 2*f_max)\n');
% else
%     fprintf('✗ 不满足采样定理!\n');
% end