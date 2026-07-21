%% 第六步：使用周期为N的冲激串作为输入信号
clear; clc;

% 参数设置
N = 16;          % 滤波器阶数
L = 2 * N;       % 采样点数
f = 50;          % 信号基频(Hz)
fs = N * f;      % 采样频率(Hz)
T = 1 / fs;      % 采样周期(s)
r = 0.999;       % 修正半径

% 定义频率响应 H(k) - 使用第三步中的值
H = zeros(1, N);
H(1) = 1;  % H(0) = 1, MATLAB索引从1开始
H(2) = exp(-1j*pi*(N-1)/N);  % H(1)
H(3) = exp(-1j*2*pi*(N-1)/N);  % H(2)
% H(4)到H(14)保持为0 (对应H(3)到H(13))
H(15) = -exp(-1j*14*pi*(N-1)/N);  % H(14)
H(16) = -exp(-1j*15*pi*(N-1)/N);  % H(15)

% 构建周期为N的冲激串信号
s1 = [1 zeros(1, N-1) 1 zeros(1, N-1)];  % 两个周期的冲激串

% 绘制输入冲激串的时域波形
figure('Position', [100, 100, 800, 600]);
subplot(3, 1, 1);
stem(0:L-1, s1, 'b', 'filled', 'LineWidth', 1.5);
xlabel('采样点 n');
ylabel('幅度');
title('输入信号：周期为N的冲激串时域波形');
grid on;

% 通过频率采样型滤波器结构处理信号
x1 = CombFilter(s1, N, r);  % 梳状滤波

% 并联谐振器处理
y1 = zeros(1, length(x1));  % 初始化累加器
for i = 0: (N/2-1)
    y_resonator = Resonator2(x1, N, r, i, H(i+1));  % 谐振器处理
    y1 = y1 + y_resonator;  % 累加所有谐振器输出
end

y = y1 / N;  % 归一化

% 提取第二个周期的输出 (n = N, N+1, ..., L-1)
y_second = y(N+1:L);  % 第二个周期的输出信号

% 子图2：第二个周期的时域波形
subplot(3, 1, 2);
stem(0:length(y_second)-1, y_second, 'b', 'filled', 'LineWidth', 1.5);
xlabel('采样点 (相对于第二个周期起点)');
ylabel('幅度');
title('通过滤波器后的信号第二个周期时域波形');
grid on;

% 对第二个周期输出进行FFT分析
Y_second = fft(y_second, N);
mag = abs(Y_second);

% 子图3：第二个周期的幅频特性
subplot(3, 1, 3);
stem(0:N-1, abs(Y_second), 'b', 'filled', 'LineWidth', 1.5);
xlabel('N');
ylabel('幅度');
title('通过滤波器后的信号第二个周期幅频特性');
grid on;

