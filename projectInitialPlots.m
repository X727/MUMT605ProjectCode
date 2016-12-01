%Constant definitions
N = 2048;
N1 = 150;
win = hanning(N);
wLP = [1, 2*ones(1, N1 - 2), 1, zeros(1, N - N1)]';
wHP = [zeros(1, N1), 1, 2*ones(1, (N-N1-2)), 1]';

%Read in audio signal
[xin, fs] = audioread('./solfege-la.wav');
freq=(0:N-1)/N*fs/1000;      % frequencies in kHz
%Take frame of audio signal
xin = xin(:,1);
x = xin((1:N) + 20000);

%Calculate fft of windowed frame of audio signal
X = fft(x.*win, N);

%Add plot of windowed signal
figure(1)
subplot(2, 4, [1 2])
plot(x.*win)
set(gca,'XLim',[0 N])
xlabel('n')
title('Windowed Cepstrum c_{LP}[n]')

%Determine the logarithm of the spectrum
Xcep = log(abs(X));

%Add plot of spectrum X(f)
subplot(2,4,[3 4])
plot(freq(1:N/2), 20*Xcep(1:N/2))
set(gca,'XLim',[freq(1) freq(N/2)],'YLim',[20*min(Xcep) 20*max(Xcep)])
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
title('Spectrum X(f)')

%Calculate real cepstrum and Windowed real cepstrum
c = ifft(Xcep);
clp = c.*wLP;

%Add plot of real cepstrum
subplot(2, 4, 5)
plot(c(1:400))
set(gca,'XLim',[0 400],'YLim',[min(c) max(c)])
xlabel('n')
title('Real Cepstrum c[n]')

%Add plot of windowed cepstrum
subplot(2, 4, 6)
plot(clp(1:400))
set(gca,'XLim',[0 400],'YLim',[min(clp) max(clp)])
xlabel('n')
title('Windowed Cepstrum c_{LP}[n]')

%Calculate spectral envelope
CLP = real(fft(clp, N));

%Add plot of spectrum and envelope
subplot(2,4,[7 8])
plot(freq(1:N/2), 20*Xcep(1:N/2), freq(1:N/2), 20*CLP(1:N/2))
set(gca,'XLim',[freq(1) freq(N/2)],'YLim',[20*min(Xcep) 20*max(Xcep)])
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
title('Spectrum X(f) and spectral envelope C_{LP}(f) in dB')
legend('X(f)', 'C_{LP}(f)')

chp = c.*wHP;
CHP = real(fft(chp, N));
figure(2)
plot(freq(1:N/2), 20*Xcep(1:N/2), freq(1:N/2), 20*CLP(1:N/2), freq(1:N/2),20*CHP(1:N/2))
set(gca,'XLim',[freq(1) freq(N/2)],'YLim',[20*min(CHP) 20*max(CHP)])
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB)')
title('Spectrum X(f) and spectral envelope C_{LP}(f) in dB')
legend('X(f)', 'C_{LP}(f)', 'C_{HP}(f)' )

%plot(freq(1:N/2), Xcep(1:N/2), freq(1:N/2),(CLP(1:N/2)+CHP(1:N/2)))