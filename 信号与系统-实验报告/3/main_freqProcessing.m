clear all;

for  idx = 26
    
    filename = sprintf('samples\\trip.wav', idx);
    filenameNoise = sprintf('samples\\%dnoise.wav', idx);

    [xr,fs] = audioread(filename);
    [x,fs] = audioread(filenameNoise);

    omega = -pi : 2*pi/10000 : pi;    
    xDTFT = calcFreqSpectrum(x, omega);
    xrDTFT = calcFreqSpectrum(xr, omega);
    
    figure(3); hold off;
    plot(omega, 20*log10(abs(xDTFT))); hold on;
    plot(omega, 20*log10(abs(xrDTFT)),'r-'); hold on;    
    xlabel('\omega')
    xlim([-pi pi])
    ylabel('20 lg |X(j\omega)|')
    drawnow
    

        
    freqInf1 = input('Nulling freq1 = ');
    freqInf2 = input('Nulling freq2 = ');
    freqInf3 = input('Nulling freq3 = ');

    firCoefh1 = [1 -2*cos(freqInf1) 1];
    firCoefh2= [1 -2*cos(freqInf2) 1];
    firCoefh3= [1 -2*cos(freqInf3) 1];
    firCoefh = conv(firCoefh1, firCoefh2);
    firCoefh = conv(firCoefh, firCoefh3);

    firCoefh = firCoefh/sum(firCoefh);

    xfilter = conv(x, firCoefh);

    xfilterDTFT = calcFreqSpectrum(xfilter, omega);

    plot(omega, 20*log10(abs(xfilterDTFT)),'g-'); hold on;
        

    sound(x, fs);

    pause(3)

    sound(xfilter, fs);

    pause(3)
   
    audiowrite('filternoise.wav', xfilter,  fs);
    
    return
end

clear all;  % 清除所有变量

% 只处理idx=26的情况(循环结构多余，因为立即return)
for idx = 26
    % 构造音频文件名
    filename = sprintf('samples\\trip.wav', idx);         % 参考音频文件
    filenameNoise = sprintf('samples\\%dnoise.wav', idx); % 含噪音频文件

    % 读取音频文件
    [xr,fs] = audioread(filename);      % 读取参考音频(clean)
    [x,fs] = audioread(filenameNoise);  % 读取含噪音频

    % 设置频率范围(-π到π)和分辨率(10000个点)
    omega = -pi : 2*pi/10000 : pi;    
    
    % 计算两个信号的DTFT
    xDTFT = calcFreqSpectrum(x, omega);    % 含噪信号频谱
    xrDTFT = calcFreqSpectrum(xr, omega);  % 参考信号频谱
    
    % 绘制频谱图(对数幅度)
    figure(3); hold off;
    plot(omega, 20*log10(abs(xDTFT))); hold on;      % 含噪信号(蓝色)
    plot(omega, 20*log10(abs(xrDTFT)),'r-'); hold on; % 参考信号(红色)   
    xlabel('\omega')                   % x轴标签
    xlim([-pi pi])                     % x轴范围限制
    ylabel('20 lg |X(j\omega)|')       % y轴标签(对数幅度)
    drawnow                            % 立即更新图形
    
    % 用户交互:输入需要滤除的频率(3个)
    freqInf1 = input('Nulling freq1 = ');  % 第一个需要滤除的频率
    freqInf2 = input('Nulling freq2 = ');  % 第二个需要滤除的频率
    freqInf3 = input('Nulling freq3 = ');  % 第三个需要滤除的频率

    % 设计三个二阶FIR滤波器(零点在指定频率处)
    firCoefh1 = [1 -2*cos(freqInf1) 1];  % 第一个滤波器系数
    firCoefh2 = [1 -2*cos(freqInf2) 1];  % 第二个滤波器系数
    firCoefh3 = [1 -2*cos(freqInf3) 1];  % 第三个滤波器系数
    
    % 级联三个滤波器(通过卷积实现)
    firCoefh = conv(firCoefh1, firCoefh2);  % 前两个滤波器合并
    firCoefh = conv(firCoefh, firCoefh3);    % 再合并第三个滤波器

    % 归一化滤波器系数(保持增益)
    firCoefh = firCoefh/sum(firCoefh);

    % 应用滤波器到含噪信号
    xfilter = conv(x, firCoefh);  % 卷积实现滤波

    % 计算滤波后信号的频谱
    xfilterDTFT = calcFreqSpectrum(xfilter, omega);

    % 在图中添加滤波后信号的频谱(绿色)
    plot(omega, 20*log10(abs(xfilterDTFT)),'g-'); hold on;
        
    % 播放原始含噪音频
    sound(x, fs);
    pause(3)  % 暂停3秒

    % 播放滤波后音频
    sound(xfilter, fs);
    pause(3)  % 暂停3秒
   
    % 保存滤波后的音频文件
    audiowrite('filternoise.wav', xfilter, fs);
    
    return  % 结束程序(使循环只执行一次)
end










