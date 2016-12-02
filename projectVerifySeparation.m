%Constant definitions
N = 2048;
N1 = 150;
win = hanning(N);
wLP = [1, 2*ones(1, N1 - 2), 1, zeros(1, N - N1)]';
wHP = [zeros(1, N1), 1, 2*ones(1, (N-N1-2)), 1]';

%Read in audio signal
[xin, fs] = audioread('./solfege-la.wav');
freq=(0:N-1)/N*fs/1000;      % frequencies in kHz

[b, a] = butter(4, 0.25, 'low');
[h, w] = freqz(b,a, N/2);
yin = filter(b, a, xin);
%Take frame of audio signal
xin = xin(:,1);
x = xin((1:N) + 20000);
%Take frame of filtered audio signal
yin = yin(:,1);
y = yin((1:N) + 20000);

%Calculate fft of windowed frame of audio signal
X = fft(x.*win, N);
%Calculate fft of windowed frame of filtered audio signal
Y = fft(y.*win, N);

%Determine the logarithm of the spectrum
Ycep = log(abs(Y));

%Calculate real cepstrum and Windowed real cepstrum
c = ifft(Ycep);
ch = c.*wLP;
cx = c.*wHP;

Ch = real(fft(ch, N));
Cx = real(fft(cx, N));

figure(1)
subplot(2,1,1)
plot(freq(1:N/2),20*Ycep(1:N/2), freq(1:N/2), 20*log(abs(h(1:N/2))), freq(1:N/2),20*log(abs(X(1:N/2))))
set(gca,'XLim',[freq(1) freq(N/2)], 'Ylim', [-400 200])
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
title('Spectra before cepstral analysis')
legend('Y(f)', 'H(f)', 'X(f)' )
subplot(2,1,2)
plot(freq(1:N/2), 20*Ycep(1:N/2), freq(1:N/2), 20*Ch(1:N/2), freq(1:N/2),20*Cx(1:N/2))
set(gca,'XLim',[freq(1) freq(N/2)], 'Ylim', [-400 200])
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
title('Spectra generated by cepstral analysis')
legend('Y(f)', 'C_{h}(f)', 'C_{x}(f)' )