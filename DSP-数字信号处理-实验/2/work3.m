%% 第四步：实现频率采样型滤波器结构并分析输出信号
clear; clc;

% 参数设置
N = 16;          % 滤波器阶数
L = 2 * N;       % 采样点数
f = 50;          % 信号基频(Hz)
fs = N * f;      % 采样频率(Hz)
T = 1 / fs;      % 采样周期(s)
r = 0.999;       % 修正半径

% 采样时刻
n1 = 0:T:(L-1)*T; % 采样点位置

% 构建输入信号
s = 0.5*cos(0) + ...                 % DC分量 A0=0.5, φ0=0
    1*cos(2*pi*f*n1+pi/2) + ...      % 基波 A1=1, φ1=π/2
    0.5*cos(2*pi*2*f*n1+pi) + ...    % 二次谐波 A2=0.5, φ2=π
    2*cos(2*pi*3*f*n1-pi/2);         % 三次谐波 A3=2, φ3=-π/2

% 定义频率响应 H(k) - 使用第三步中的值
H = zeros(1, N);
H(1) = 1;  % H(0) = 1, MATLAB索引从1开始
H(2) = exp(-1j*pi*(N-1)/N);  % H(1)
H(3) = exp(-1j*2*pi*(N-1)/N);  % H(2)
% H(4)到H(14)保持为0 (对应H(3)到H(13))
H(15) = -exp(-1j*14*pi*(N-1)/N);  % H(14)
H(16) = -exp(-1j*15*pi*(N-1)/N);  % H(15)

% 通过频率采样型滤波器结构处理信号
x = CombFilter(s, N, r);  % 梳状滤波

% 并联谐振器处理
y1 = zeros(1, length(x));  % 初始化累加器
for i = 0: (N/2-1)
    y_resonator = Resonator2(x, N, r, i, H(i+1));  % 谐振器处理
    y1 = y1 + y_resonator;  % 累加所有谐振器输出
end

y = y1 / N;  % 归一化

% 提取第二个周期的输出 (n = N, N+1, ..., L-1)
y_second = y(N+1:L);  % 第二个周期的输出信号

% 绘制结果
figure('Position', [100, 100, 800, 600]);

% 子图1：第二个周期的时域波形
subplot(3, 1, 1);
stem(0:length(y_second)-1, y_second, 'b', 'filled', 'LineWidth', 1.5);
xlabel('采样点 (相对于第二个周期起点)');
ylabel('幅度');
title('通过滤波器后的信号第二个周期时域波形');
grid on;

% 对第二个周期输出进行FFT分析
Y_second = fft(y_second, N);

% 子图2：第二个周期的幅频特性
subplot(3, 1, 2);
stem(0:N-1, abs(Y_second), 'b', 'filled', 'LineWidth', 1.5);
xlabel('频率索引 k');
ylabel('幅度');
title('通过滤波器后的信号第二个周期幅频特性');
grid on;

% 子图3：第二个周期的相频特性
subplot(3, 1, 3);
stem(0:N-1, angle(Y_second), 'b', 'filled', 'LineWidth', 1.5);
xlabel('频率索引 k');
ylabel('相位 (弧度)');
title('通过滤波器后的信号第二个周期相频特性');
grid on;

%% 第五步： 绘制前4路谐振器输出
figure('Position', [100, 100, 1000, 800]);
i=N:1:L-1;

% 第1路谐振器 (Order=0, 对应DC分量)
y0 = Resonator2(x, N, r, 0, H(1));
subplot(2, 2, 1);
stem(i, y0(i+1), 'b', 'filled', 'LineWidth', 1.5);
title('第1路谐振器输出 (Order=0, DC分量)');
xlabel('采样点 n'); ylabel('y_0(n)');
grid on;

% 第2路谐振器 (Order=1, 对应50Hz分量)
y1 = Resonator2(x, N, r, 1, H(2));
subplot(2, 2, 2);
stem(i, y1(i+1), 'b', 'filled', 'LineWidth', 1.5);
title('第2路谐振器输出 (Order=1, 50Hz分量)');
xlabel('采样点 n'); ylabel('y_1(n)');
grid on;

% 第3路谐振器 (Order=2, 对应100Hz分量)
y2 = Resonator2(x, N, r, 2, H(3));
subplot(2, 2, 3);
stem(i, y2(i+1), 'b', 'filled', 'LineWidth', 1.5);
title('第3路谐振器输出 (Order=2, 100Hz分量)');
xlabel('采样点 n'); ylabel('y_2(n)');
grid on;

% 第4路谐振器 (Order=3, 对应150Hz分量)
y3 = Resonator2(x, N, r, 3, H(4));  % 修正：Order应为3，不是0
subplot(2, 2, 4);
stem(i, y3(i+1), 'b', 'filled', 'LineWidth', 1.5);
title('第4路谐振器输出 (Order=3, 150Hz分量)');
xlabel('采样点 n'); ylabel('y_3(n)');
grid on;

%%
% 计算滤波器的实际频率响应
w = linspace(0, pi, 1000);
H_actual = zeros(1, length(w));

for idx = 1:length(w)
    % 计算梳状滤波器响应
    H_comb = 1 - r^N * exp(-1j * w(idx) * N);
    
    % 计算谐振器并联响应
    H_resonators = 0;
    for k = 0:N/2-1
        H_res = H(k+1) ./ (1 - 2*r*cos(2*pi*k/N)*exp(-1j*w(idx)) + r^2*exp(-1j*2*w(idx)));
        H_resonators = H_resonators + H_res;
    end
    
    H_actual(idx) = H_comb * H_resonators / N;
end

% 找到3dB截止点
f_actual = w * fs / (2*pi);
mag_response = abs(H_actual);
max_mag = max(mag_response);
three_dB_point = max_mag / sqrt(2);

% 查找3dB交叉点
cross_points = find(diff(mag_response >= three_dB_point));