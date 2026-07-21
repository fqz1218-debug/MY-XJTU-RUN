clear; clc; close all;

%% a) F=50Hz, N=32, T=0.000625s
figure;
F = 50; N = 32; T = 0.000625;
t = (0:N-1)*T;
x = sin(2*pi*F*t);

subplot(1,3,1);
t1 = 0:0.000001:(N-1)*T;
x1 = sin(2*pi*F*t1 );
plot(t1, x1, 'b-', 'LineWidth', 1);
title('原始连续信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
xlim([0, N*T]);

subplot(1,3,2);
stem(0:N-1, x(1:N), 'b', 'filled', 'LineWidth', 1.5);
% 蓝色
% 每个数据点用点（圆点）标记
% 数据点之间用实线连接
title('采样信号 F=50Hz, T=0.000625s');
xlabel('n点采样');
ylabel('幅度');
grid on;

subplot(1,3,3);
X = fft(x);
stem((0:N-1), abs(X(1:N)), 'r');% 红色
title('a) 频域结果');
xlabel('N'); ylabel('幅度');
grid on;

%% b) F=50Hz, N=32, T=0.005s
figure;
F = 50; N = 32; T = 0.005;
subplot(1,2,1);
t = (0:N-1)*T;
x = sin(2*pi*F*t);

subplot(1,3,1);
t1 = 0:0.000001:(N-1)*T;
x1 = sin(2*pi*F*t1 );
plot(t1, x1, 'b-', 'LineWidth', 1);
title('原始连续信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
xlim([0, N*T]);

subplot(1,3,2)
stem(0:N-1, x(1:N), 'b', 'filled', 'LineWidth', 1.5);
title('采样信号 F=50Hz, T=0.005s');
xlabel('n点采样'); ylabel('幅度');
grid on;

subplot(1,3,3);
X = fft(x);
stem((0:N-1), abs(X(1:N)), 'r');
title('b) 频域结果');
xlabel('N'); ylabel('幅度');
grid on;

%% c) F=50Hz, N=32, T=0.0046875s
figure;
F = 50; N = 32; T = 0.0046875;
t = (0:N-1)*T;
x = sin(2*pi*F*t);

subplot(1,3,1);
t1 = 0:0.000001:(N-1)*T;
x1 = sin(2*pi*F*t1 );
plot(t1, x1, 'b-', 'LineWidth', 1);
title('原始连续信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
xlim([0, N*T]);

subplot(1,3,2);
stem(0:N-1, x(1:N), 'b', 'filled', 'LineWidth', 1.5);
title('采样信号 F=50Hz, T=0.0046875s');
xlabel('n点采样'); ylabel('幅度');
grid on;

subplot(1,3,3);
X = fft(x);
stem((0:N-1), abs(X(1:N)), 'r');
title('c) 频域结果');
xlabel('N'); ylabel('幅度');
grid on;

%% d) F=50Hz, N=32, T=0.004s
figure;
F = 50; N = 32; T = 0.004;
t = (0:N-1)*T;
x = sin(2*pi*F*t);

subplot(1,3,1);
t1 = 0:0.000001:(N-1)*T;
x1 = sin(2*pi*F*t1 );
plot(t1, x1, 'b-', 'LineWidth', 1);
title('原始连续信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
xlim([0, N*T]);

subplot(1,3,2);
stem(0:N-1, x(1:N), 'b', 'filled', 'LineWidth', 1.5);
title('采样信号 F=50Hz, T=0.004s');
xlabel('n点采样'); ylabel('幅度');
grid on;

subplot(1,3,3);
X = fft(x);
stem((0:N-1), abs(X(1:N)), 'r');
title('d) 频域结果');
xlabel('N'); ylabel('幅度');
grid on;

%% e) F=50Hz, N=64, T=0.000625s
figure;
F = 50; N = 64; T = 0.000625;
t = (0:N-1)*T;
x = sin(2*pi*F*t);

subplot(1,3,1);
t1 = 0:0.000001:(N-1)*T;
x1 = sin(2*pi*F*t1 );
plot(t1, x1, 'b-', 'LineWidth', 1);
title('原始连续信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
xlim([0, N*T]);

subplot(1,3,2);
stem(0:N-1, x(1:N), 'b', 'filled', 'LineWidth', 1.5);
title('采样信号 F=50Hz, N=64, T=0.000625s');
xlabel('n点采样'); ylabel('幅度');
grid on;

subplot(1,3,3);
X = fft(x);
stem((0:N-1), abs(X(1:N)), 'r');
title('e) 频域结果');
xlabel('N'); ylabel('幅度');
grid on;

%% f) F=250Hz, N=32, T=0.005s
figure;
F = 250; N = 32; T = 0.005;
t = (0:N-1)*T;
x = sin(2*pi*F*t);

subplot(1,3,1);
t1 = 0:0.000001:(N-1)*T;
x1 = sin(2*pi*F*t1 );
plot(t1, x1, 'b-', 'LineWidth', 1);
title('原始连续信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
xlim([0, N*T]);

subplot(1,3,2);
stem(0:N-1, x(1:N), 'b', 'filled', 'LineWidth', 1.5);
title('采样信号 F=250Hz, T=0.005s');
xlabel('n点采样'); ylabel('幅度');
grid on;

subplot(1,3,3);
X = fft(x);
stem((0:N-1), abs(X(1:N)), 'r');
title('f) 频域结果');
xlabel('N'); ylabel('幅度');
grid on;

%% g) 补零FFT对比分析
figure('Position', [100, 100, 1200, 600]);

F = 50; N = 32; T = 0.0046875;
fs = 1/T;
t = (0:N-1)*T;
x = sin(2*pi*F*t);
% c) 情况原始信号
subplot(2,3,1);
t1 = 0:0.000001:(N-1)*T;
x1 = sin(2*pi*F*t1 );
plot(t1, x1, 'b-', 'LineWidth', 1);
title('原始连续信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
xlim([0, N*T]);

subplot(2,3,4);
X = fft(x);
f = (0:N-1)*(fs/N);
stem((0:N-1), abs(X(1:N)), 'r');
title('g1) 原始FFT结果');
xlabel('N'); ylabel('幅度');
grid on;

% 补零到64点
subplot(2,3,2);
x_zeropad = [x, zeros(1,32)]; % 补32个零，将x和32个零水平拼接
t_zeropad = (0:63)*T;
stem(0:63, x_zeropad(1:64), 'b', 'filled', 'LineWidth', 1.5);
title('g2) 补零采样后信号 (N=64)');
xlabel('n点采样'); ylabel('幅度');
grid on;

subplot(2,3,5);
X_zeropad = fft(x_zeropad);
f_zeropad = (0:63)*(fs/64);
stem((0:63), abs(X_zeropad(1:64)), 'r');
title('g2) 补零FFT结果');
xlabel('N'); ylabel('幅度');
grid on;

% 直接采样64点
subplot(2,3,3);
N64 = 64; T64 = 0.0046875;
t64 = (0:N64-1)*T64;
x64 = sin(2*pi*F*t64);
stem(0:63, x64(1:64), 'b', 'filled', 'LineWidth', 1.5);
title('g3) 直接采样64点');
xlabel('n点采样'); ylabel('幅度');
grid on;

subplot(2,3,6);
X64 = fft(x64);
f64 = (0:N64-1)*(1/(N64*T64));
stem((0:N64-1), abs(X64(1:N64)), 'r');
title('g3) 直接采样64点FFT');
xlabel('N'); ylabel('幅度');
grid on;


%% 结果分析：
%频谱混淆（混叠）：当采样频率fs小于信号最高频率的2倍时，会发生混叠。
%频谱泄漏：当信号的非整周期被采样时，FFT变换后会出现频谱泄漏。
%栅栏效应：由于FFT是离散采样，只能得到离散频率点上的频谱，可能看不到实际频谱的细节。

% fprintf('频谱问题分析:\n\n');
% fprintf('a) F=50Hz, N=32, T=0.000625s:\n');
% fprintf('   - 采样频率: %.1fHz > 2*50Hz = 100Hz (满足采样定理)\n', 1/0.000625);
% fprintf('   - 频谱特点: 无频谱混淆，但存在栅栏效应\n');
% 
% fprintf('b) F=50Hz, N=32, T=0.005s:\n');
% fprintf('   - 采样频率: %.1fHz = 2*50Hz = 100Hz (临界采样)\n', 1/0.005);
% fprintf('   - 频谱特点: 临界采样，可能存在频谱混淆\n\n');
% 
% fprintf('c) F=50Hz, N=32, T=0.0046875s:\n');
% fprintf('   - 采样频率: %.3fHz > 100Hz\n', 1/0.0046875);
% fprintf('   - 频谱特点: 存在频谱泄漏，非整周期采样\n\n');
% 
% fprintf('d) F=50Hz, N=32, T=0.004s:\n');
% fprintf('   - 采样频率: %.1fHz > 100Hz\n', 1/0.004);
% fprintf('   - 频谱特点: 无混叠，存在频谱泄漏，非整周期采样\n\n');
% 
% fprintf('e) F=50Hz, N=64, T=0.000625s:\n');
% fprintf('   - 频率分辨率提高: %.3fHz (相比情况a)\n', 1/(64*0.000625));
% fprintf('   - 频谱特点: 无混叠，栅栏效应减轻\n\n');
% 
% fprintf('f) F=250Hz, N=32, T=0.005s:\n');
% fprintf('   - 采样频率: %.1fHz < 2*250Hz = 500Hz\n', 1/0.005);
% fprintf('   - 频谱特点: 严重频谱混淆！\n\n');
% 
% fprintf('g) 补零FFT对比:\n');
% fprintf('   - 补零FFT: 频率点更密，但频谱泄漏模式不变\n');
% fprintf('   - 直接采样: 提供真实的频率信息\n');
% fprintf('   - 结论: 补零不能改善频谱泄漏，只能使频谱显示更平滑\n');