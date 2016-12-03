%Constant definitions
N = 2048;
N1 = 150;
w1 = hanning(N);
w2 = w1;
wLP = [1, 2*ones(1, N1 - 2), 1, zeros(1, N - N1)]';
hop = 256;

%Read in audio signal
[sound1, fs] = audioread('./solfege-ti.wav');
sound2 = audioread('./solfege-la.wav');
freq=(0:N-1)/N*fs/1000;      % frequencies in kHz

%Reduce to 1 channel and same number of samples
L = min(length(sound1), length(sound2));
sound1 = sound1(1:L, 1);
sound2 = sound2(1:L, 1);

soundOut = zeros(L, 1);
startPt = 0;
endPt = L-N;

while startPt < endPt
    %Take a windowed frame of each sound
    frame1 = sound1(startPt+1:startPt+N).*w1;
    frame2 = sound2(startPt+1:startPt+N).*w1;
    
    %Take the fft
    FFTframe1 = fft(frame1, N);
    FFTframe2 = fft(frame2, N);
    
    %Take the IFFT of the log FFT to get Cepstrum
    cepstrum1 = ifft(log(FFTframe1),N);
    cepstrum2 = ifft(log(FFTframe2),N);
    
    %Determine the filters by taking FFT of windowed cepstrum and than exp
    FFTcep1 = fft(cepstrum1.*wLP, N);
    FFTcep2 = fft(cepstrum2.*wLP, N);
    H1 = exp(FFTcep1);
    H2 = exp(FFTcep2);
    
    %Whiten frame1 with H1
    X = FFTframe1.*H1;
    %Pass through H2 to get output sound spectrum
    Y = X.*H2;
    
    %Store output
    soundOut(startPt+1:startPt+N)= (real(ifft(Y.*w1, N)));
    %Move up a hop size
    startPt = startPt +hop;
    
end
    
    
    
