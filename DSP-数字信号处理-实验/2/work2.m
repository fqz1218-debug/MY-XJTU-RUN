%% 第三步：计算滤波器抽头系数并分析频响特性
clear; clc;

% 参数设置
N = 16;          % 滤波器阶数

% 定义频率响应 H(k)
k = 0:N-1;
H = zeros(1, N);

% 根据给定的条件设置 H(k)
H(1) = 1;  % H(0) = 1, MATLAB索引从1开始
H(2) = exp(-1j*pi*(N-1)/N);  % H(1)
H(3) = exp(-1j*2*pi*(N-1)/N);  % H(2)
% H(4)到H(14)保持为0 (对应H(3)到H(13))
H(15) = -exp(-1j*14*pi*(N-1)/N);  % H(14)
H(16) = -exp(-1j*15*pi*(N-1)/N);  % H(15)

% 通过IFFT计算时域抽头系数 h(n)
h = ifft(H, N);

% 绘制结果
figure('Position', [100, 100, 800, 600]);

% 子图1：滤波器抽头系数（实部和虚部）
subplot(2, 2, 1);
stem(0:N-1, real(h), 'b', 'filled', 'LineWidth', 1.5);
xlabel('n');
ylabel('实部');
title('滤波器抽头系数 h(n) 实部');
grid on;

subplot(2, 2, 3);
stem(0:N-1, imag(h), 'b', 'filled', 'LineWidth', 1.5);
xlabel('n');
ylabel('虚部');
title('滤波器抽头系数 h(n) 虚部');
grid on;

% 计算DTFT（离散时间傅里叶变换）
w = linspace(-pi, pi, 1000);  % 频率范围从-π到π
Hw = zeros(1, length(w));

% 计算DTFT: H(e^jw) = sum_{n=0}^{N-1} h(n) * e^{-jwn}
for idx = 1:length(w)
    Hw(idx) = sum(h .* exp(-1j * w(idx) * (0:N-1)));
end

% 幅频特性
subplot(2, 2, 2);
plot(w, abs(Hw), 'b', 'LineWidth', 2);
xlabel('归一化频率 (\omega)');
ylabel('|H(e^{j\omega})|');
title('滤波器幅频特性');
grid on;

% 相频特性
subplot(2, 2, 4);
plot(w, angle(Hw), 'r', 'LineWidth', 2);
xlabel('频率 (\omega)');
ylabel('∠H(e^{j\omega}) (弧度)');
title('滤波器相频特性');
grid on;


% 显示滤波器系数信息
% fprintf('滤波器抽头系数 h(n):\n');
% fprintf('n\t实部\t\t\t虚部\n');
% for n = 1:N
%     fprintf('%d\t%f\t%f\n', n-1, real(h(n)), imag(h(n)));
% end
% 
% fprintf('\n频率响应 H(k):\n');
% fprintf('k\t实部\t\t\t虚部\t\t\t幅度\t\t相位\n');
% for k = 1:N
%     fprintf('%d\t%f\t%f\t%f\t%f\n', k-1, real(H(k)), imag(H(k)), abs(H(k)), angle(H(k)));
% end