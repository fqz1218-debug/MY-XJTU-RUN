
function Y = calcFreqSpectrum(X, omega)
% 计算信号的离散时间傅里叶变换(DTFT)
% 输入:
%   X - 输入信号(时域)
%   omega - 频率点向量(范围通常为[-π, π])
% 输出:
%   Y - 信号的频域表示(DTFT)

N = size(X, 1);          % 获取信号长度
Y = zeros(length(omega), 1);  % 初始化输出频域表示

% 双重循环计算DTFT
for idx = 1 : length(omega)   % 遍历每个频率点
   for n = 1 : N             % 遍历每个时域样本
       % 累加计算傅里叶变换(直接实现公式)
       Y(idx) = Y(idx) + exp(-1j*omega(idx)*n)*X(n);   
   end    
end