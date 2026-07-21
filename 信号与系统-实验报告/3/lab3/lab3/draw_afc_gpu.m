function X_x = draw_afc_gpu(x)
% DRAW_AFC_GPU : Draw amplitude-frequency characteristic using GPU acceleration

x_length = length(x);
w = gpuArray(-pi:0.0002*pi:pi); 
n = gpuArray((1:x_length)'); 
x_gpu = gpuArray(x); 

% 预分配
X_x_gpu = gpuArray.zeros(size(w));

% 使用GPU并行计算
for k = 1:length(w)
    exponent = exp(-1j * w(k) * n);
    X_x_gpu(k) = dot(x_gpu,exponent); %点积
end

% 将结果移回CPU内存
X_x = gather(X_x_gpu);


plot(gather(w), 20*log10(abs(X_x))); 
xlabel("\omega_{q}");
ylabel("20lg|X(e^{\omega_{q}})|");
title('Amplitude-Frequency Characteristic (GPU Accelerated)');
grid on;
