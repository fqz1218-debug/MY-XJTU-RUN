% 基-2按时间抽取FFT算法（非递归实现）
clear; clc; close all;

%% 参数输入
F = input('请输入信号频率(单位为Hz) F = ');
N = input('请输入采样点数 N = ');
T = input('请输入采样周期 T = ');
phi = input('请输入初始相位(弧度) phi = ');
zeroflag= input('是否增加零点？增加请输入1，否则输入0: ');

%% 生成信号
n = 0:T:(N-1)*T; % 采样点
fs = 1/T; % 采样频率
x = sin(2*pi*F*n + phi); % 带初始相位的正弦信号

% 补零处理
if zeroflag == 1
    num = input('请输入增加零点的个数: ');
    x = [x, zeros(1, num)]; % 在信号后补零
    N_total = N + num;
else
    N_total = N;
end

%% 检查点数是否为2的幂次
if log2(N_total) ~= fix(log2(N_total))
    error('总点数须是2的幂次');
end

%% 保存原始信号用于绘图
x_original = x;

%% 变址运算（比特反转）
k = 0:N_total-1;
bit_length = log2(N_total);
trans_addr = zeros(1, N_total);

for m = 1:N_total
    % 将索引转换为二进制并反转
    binary_str = dec2bin(k(m), bit_length);
    reversed_binary = fliplr(binary_str);
    % 将反转后的二进制转换回十进制
    new_index = bin2dec(reversed_binary);
    trans_addr(m) = new_index + 1; % MATLAB索引从1开始
end

% 按比特反转顺序重新排列数据
X = zeros(1, N_total);
for m = 1:N_total
    X(m) = x_original(trans_addr(m));
end

%% 蝶形运算
M = log2(N_total); % 级数
LE1 = 1; % 初始蝶形间距

for L = 1:M % 对每一级循环
    LE2 = LE1; % 该级中蝶形运算的两个输入数据之间的距离
    LE1 = LE1 * 2; % 下一级中蝶形运算的两个输入数据之间的距离
    W = 1; 
    WN = exp(-1j * 2 * pi / LE1); 
    
    for J = 0:LE2-1 % 对每个WN循环
        for I = J:LE1:N_total-1 % 对每个蝶形循环
            if I + LE2 >= N_total
                continue;
            end
            IP = I + LE2;
            temp = X(IP+1) * W;
            X(IP+1) = X(I+1) - temp;
            X(I+1) = X(I+1) + temp;
        end
        W = W * WN; % 更新WN
    end
end

%% 绘制图形进行比较

% 绘制连续信号原图
subplot(2,2,1);
t_continuous = 0:0.000001:(N_total-1)*T;
x_continuous = sin(2*pi*F*t_continuous + phi);
plot(t_continuous, x_continuous, 'b-', 'LineWidth', 1);
title('原始连续信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;
xlim([0, (N_total-1)*T]);

% 绘制采样信号
subplot(2,2,2);
n_discrete = 0:N_total-1;
t_discrete = n_discrete * T;
if zeroflag == 1
    % 用蓝色标记原始采样点，红色表示补零点
    stem(0:N-1, x_original(1:N), 'b', 'filled', 'LineWidth', 1.5);
    hold on;
    stem(N:N_total-1, x_original(N+1:end), 'r', 'filled', 'LineWidth', 1.5);
    legend('原始采样点', '补零点', 'Location', 'best');
else
    stem(t_discrete, x_original, 'b', 'filled', 'LineWidth', 1.5);
end

title('采样后的离散信号');
xlabel('时间 (s)');
ylabel('幅度');
grid on;

% 绘制两种FFT结果频谱图
subplot(2,2,3);
X_matlab = fft(x_original);
f_axis = (0:N_total-1) * (fs/N_total);
stem((0:N_total-1), abs(X_matlab(1:N_total)), 'g', 'filled', 'LineWidth', 1.5);
title('MATLAB内置FFT结果');
xlabel('频率N');
ylabel('|X(f)|');
grid on;

subplot(2,2,4);
stem((0:N_total-1), abs(X(1:N_total)), 'r', 'filled', 'LineWidth', 1.5);
title('自定义基-2 FFT结果');
xlabel('频率N');
ylabel('|X(f)|');
grid on;