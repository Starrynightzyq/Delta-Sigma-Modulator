% PSD
% reference: https://zhuanlan.zhihu.com/p/50272016
clc
clear

% 加窗
ADD_WIN_FLAG = 1;
% 对数坐标
LOG_PLOT_FLAG = 1;
% 去除直流量
DC_REMOVE_FLAG = 1;

% -------------------------------------------------
name = "MASH 9bit input 255";              % 图片 legend 名字
figname = "results/mash_9bit_255_psd.svg"; % 图片保存的路径
x = load("data.txt");                      % 数据
% -------------------------------------------------

x = double(x);

% FFT 求功率谱密度
L = length(x);
% N = L;

% % 比当前长度大的下一个最小的 2 的次幂值
% N = 2^nextpow2(L);
% x_new = zeros(1, N-L);
% x = [x, x_new];


% 取2的幂次方
N = 2^(nextpow2(L)-1);
x = x(1:N);

% 去除直流量
if DC_REMOVE_FLAG
    average = mean(x);
    x = x - average;
end


% 加窗
if ADD_WIN_FLAG
    wn=hann(N);  %汉宁窗
    x=x.*wn;   % 原始信号时域加窗
end

xdft = fft(x, N);
psdx = xdft.*conj(xdft)/N; % 双边功率谱密度，conj 共轭复数

% 加窗系数修正
if ADD_WIN_FLAG
    zz = wn.*wn;
    zz1 = sum(zz);
    psdx = psdx*N/zz1;
end

spsdx = psdx(1:floor(N/2)+1)*2; % 单边功率谱密度
spsdx(1) = psdx(1);

spsdx_log = 10*log10(spsdx); % 取log
spsdx_log(spsdx_log == -inf) = -300; % 处理 log10(0) 的情况

% 单边带
freq = 0:(2*pi)/N:pi;
% 双边带
% freq = 0:(2*pi)/N:(2*pi-(2*pi)/N);

% NTF 3阶
NTF = 3*20*log10(2*sin(freq/2));

if LOG_PLOT_FLAG
    semilogx(freq/pi, spsdx_log, freq/pi, NTF, '--')
else
    plot(freq/pi, spsdx_log, freq/pi, NTF, '--')
end
grid on
legend(name, 'NTF','Location', 'northwest')
title('Periodogram Using FFT')
xlabel('Normalized Frequency (\times\pi rad/sample)') 
ylabel('Power/Frequency (dB/rad/sample)')
saveas(gcf,figname)