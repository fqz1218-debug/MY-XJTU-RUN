%% 绘制FIR滤波器的完整幅频响应
clear; clc; close all;

% 参数设置
N = 16;          % 滤波器阶数
f = 50;          % 信号基频(Hz)
fs = N * f;      % 采样频率(Hz)
r = 0.999;       % 修正半径

% 定义频率响应 H(k) - 使用第三步中的值
H = zeros(1, N);
H(1) = 1;  % H(0) = 1, MATLAB索引从1开始
H(2) = exp(-1j*pi*(N-1)/N);  % H(1)
H(3) = exp(-1j*2*pi*(N-1)/N);  % H(2)
% H(4)到H(14)保持为0 (对应H(3)到H(13))
H(15) = -exp(-1j*14*pi*(N-1)/N);  % H(14)
H(16) = -exp(-1j*15*pi*(N-1)/N);  % H(15)

% 方法1：通过IFFT计算时域冲激响应，然后计算DTFT
h = ifft(H, N);

% 计算DTFT（高分辨率）
w = linspace(0, pi, 2000);  % 0到π的频率范围
f_actual = w * fs / (2*pi);  % 转换为实际频率(Hz)

H_dtft = zeros(1, length(w));
for idx = 1:length(w)
    H_dtft(idx) = sum(h .* exp(-1j * w(idx) * (0:N-1)));
end

% 方法2：直接通过频率采样型结构计算频率响应
H_direct = zeros(1, length(w));
for idx = 1:length(w)
    % 梳状滤波器部分
    H_comb = 1 - r^N * exp(-1j * w(idx) * N);
    
    % 谐振器并联部分
    H_resonators = 0;
    for k = 0:N/2-1
        % 二阶谐振器的频率响应
        denominator = 1 - 2*r*cos(2*pi*k/N)*exp(-1j*w(idx)) + r^2*exp(-1j*2*w(idx));
        H_res = H(k+1) / denominator;
        H_resonators = H_resonators + H_res;
    end
    
    H_direct(idx) = H_comb * H_resonators / N;
end

% 绘制结果
figure('Position', [100, 100, 1200, 800]);

% 子图1：线性幅度响应
subplot(3, 2, 1);
plot(f_actual, abs(H_dtft), 'b-', 'LineWidth', 2);
hold on;
plot(f_actual, abs(H_direct), 'r--', 'LineWidth', 1.5, 'DisplayName', '直接计算');
xlabel('频率 (Hz)');
ylabel('|H(f)|');
title('FIR滤波器幅频响应 (线性刻度)');
grid on;
legend('IFFT+DTFT方法', '直接计算方法', 'Location', 'best');

% 标记主要频率点
freq_points = [0, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750];
for k = 1:length(freq_points)
    [~, idx] = min(abs(f_actual - freq_points(k)));
    if k == 1 || k == 2 || k == 3 || k == 15 || k == 16  % H(k)不为零的点
        plot(f_actual(idx), abs(H_dtft(idx)), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
        text(f_actual(idx), abs(H_dtft(idx))*1.1, sprintf('H(%d)', k-1), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    else
        plot(f_actual(idx), abs(H_dtft(idx)), 'kx', 'MarkerSize', 6, 'LineWidth', 1);
    end
end

% 子图2：dB刻度幅频响应
subplot(3, 2, 2);
plot(f_actual, 20*log10(abs(H_dtft) + eps), 'b-', 'LineWidth', 2);
xlabel('频率 (Hz)');
ylabel('|H(f)| (dB)');
title('FIR滤波器幅频响应 (dB刻度)');
grid on;
ylim([0,-50]);

% 标记3dB点
max_mag = max(abs(H_dtft));
three_dB_level = 20*log10(max_mag/sqrt(2));
hold on;
plot([0, fs/2], [three_dB_level, three_dB_level], 'r--', 'LineWidth', 1.5, ...
     'DisplayName', '-3dB线');

% 找到3dB交叉点
mag_db = 20*log10(abs(H_dtft) + eps);
cross_idx = find(diff(sign(mag_db - three_dB_level)) ~= 0);
for i = 1:length(cross_idx)
    if cross_idx(i) < length(f_actual)
        plot(f_actual(cross_idx(i)), three_dB_level, 'ro', 'MarkerSize', 6, 'LineWidth', 2);
        text(f_actual(cross_idx(i)), three_dB_level-5, ...
             sprintf('%.1fHz', f_actual(cross_idx(i))), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    end
end
legend('幅频响应', '-3dB线', '3dB截止点', 'Location', 'best');

% 子图3：相频响应
subplot(3, 2, 3);
plot(f_actual, angle(H_dtft), 'g-', 'LineWidth', 2);
xlabel('频率 (Hz)');
ylabel('相位 (弧度)');
title('FIR滤波器相频响应');
grid on;

% 子图4：群延迟
subplot(3, 2, 4);
phase_response = angle(H_dtft);
group_delay = -diff(unwrap(phase_response)) ./ diff(w);
plot(f_actual(1:end-1), group_delay, 'm-', 'LineWidth', 2);
xlabel('频率 (Hz)');
ylabel('群延迟 (样本)');
title('FIR滤波器群延迟');
grid on;

% 子图5：冲激响应
subplot(3, 2, 5);
stem(0:N-1, real(h), 'b', 'filled', 'LineWidth', 1.5);
hold on;
stem(0:N-1, imag(h), 'r', 'filled', 'LineWidth', 1.5);
xlabel('样本 n');
ylabel('幅度');
title('FIR滤波器冲激响应 h(n)');
legend('实部', '虚部', 'Location', 'best');
grid on;

% 子图6：极点零点图
subplot(3, 2, 6);
% 计算系统函数的零极点
[h_comb, ~] = tfdata(tf([1 zeros(1, N-1) -r^N], [1 zeros(1, N)]), 'v');

% 绘制单位圆
theta = linspace(0, 2*pi, 100);
plot(cos(theta), sin(theta), 'k--', 'LineWidth', 1);
hold on;

% 绘制极点（谐振器部分）
for k = 0:N/2-1
    if abs(H(k+1)) > 0  % 只绘制非零H(k)对应的极点
        pole_angle = 2*pi*k/N;
        pole_mag = r;
        polar_pole_x = pole_mag * cos(pole_angle);
        polar_pole_y = pole_mag * sin(pole_angle);
        plot(polar_pole_x, polar_pole_y, 'rx', 'MarkerSize', 10, 'LineWidth', 2);
    end
end

% 绘制零点（梳状滤波器部分）
zero_angles = 2*pi*(0:N-1)/N;
zero_mag = r;
zero_x = zero_mag * cos(zero_angles);
zero_y = zero_mag * sin(zero_angles);
plot(zero_x, zero_y, 'bo', 'MarkerSize', 6, 'LineWidth', 1);

axis equal;
xlabel('实部');
ylabel('虚部');
title('极点零点图 (单位圆)');
legend('单位圆', '极点', '零点', 'Location', 'best');
grid on;

% 显示滤波器特性参数
fprintf('FIR滤波器特性参数:\n');
fprintf('===================\n');
fprintf('滤波器阶数: N = %d\n', N);
fprintf('采样频率: fs = %.1f Hz\n', fs);
fprintf('频率分辨率: Δf = %.1f Hz\n', fs/N);
fprintf('修正半径: r = %.3f\n', r);
fprintf('\n');

% 计算主要通带的3dB带宽
fprintf('主要通带特性:\n');
fprintf('频率点\t中心频率(Hz)\t3dB带宽(Hz)\t峰值幅度\n');
fprintf('------------------------------------------------\n');

main_peaks = [1, 2, 3, 15, 16];  % H(k)不为零的点
for k = main_peaks
    center_freq = (k-1) * fs / N;
    if center_freq > fs/2
        center_freq = center_freq - fs;  % 考虑混叠
    end
    
    % 在中心频率附近搜索3dB点
    freq_idx = round(center_freq / (fs/2) * length(f_actual));
    search_range = max(1, freq_idx-100):min(length(f_actual), freq_idx+100);
    
    if ~isempty(search_range)
        local_mag = abs(H_dtft(search_range));
        peak_val = max(local_mag);
        three_dB_val = peak_val / sqrt(2);
        
        % 找到3dB交叉点
        above_3dB = local_mag >= three_dB_val;
        if sum(above_3dB) > 0
            first_idx = find(above_3dB, 1, 'first');
            last_idx = find(above_3dB, 1, 'last');
            bw_3dB = f_actual(search_range(last_idx)) - f_actual(search_range(first_idx));
            
            fprintf('H(%d)\t%.1f\t\t%.1f\t\t%.4f\n', ...
                    k-1, center_freq, bw_3dB, peak_val);
        end
    end
end