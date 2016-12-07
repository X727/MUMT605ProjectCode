%Constant definitions
N = 1024;
hop = 256;
w1 = hanning(N);
w2 = w1;
order1 = 30;
order2 = 30;

%Read in audio signals to cross synthesize
[sound1, fs] = audioread('../Audio/SourceSounds/xjs-14-xsynth-speech-car-plane.wav');
sound2 = audioread('../Audio/SourceSounds/xjs-14-xsynth-speech-mod.wav');

%Reduce to 1 channel (if necessary) and pad with zeros
L = min(length(sound1), length(sound2));
sound1 = [zeros(N,1); sound1(:, 1); zeros(N-mod(L,hop),1)]/max(abs(sound1(:,1)));
sound2 = [zeros(N,1); sound2(:, 1); zeros(N-mod(L,hop),1)]/max(abs(sound2(:,1)));

%Initialize buffer for output sound 
soundOut = zeros(L, 1);
%Initialize start point and end point for overlap add
startPt = 0;
endPt = L-N;

%While there are still samples to process
while startPt < endPt
    %Take a windowed frame of each sound
    frame1 = sound1(startPt+1:startPt+N).*w1;
    frame2 = sound2(startPt+1:startPt+N).*w1;
    
    %Find FFT for both frames
    FFTframe1 = fft(frame1)/(N/2);
    FFTframe2 = fft(frame2)/(N/2);
    
    %Take the log of the magnitude
    LogFFTframe1 = log(0.00001+abs(FFTframe1));
    LogFFTframe2 = log(0.00001+abs(FFTframe2));
    
    %Take IFFT to get cepstrum
    cepstrum1 = ifft(LogFFTframe1);
    cepstrum2 = ifft(LogFFTframe2);
    
    %Window the cepstrum
    winCepstrum1 = [cepstrum1(1)/2;cepstrum1(2:order1);zeros(N-order1, 1)];
    winCepstrum2 = [cepstrum2(1)/2;cepstrum2(2:order2);zeros(N-order2, 1)];
    
    %Take FFT to get spectral envelope
    CH1 = 2*real(fft(winCepstrum1));
    CH2 = 2*real(fft(winCepstrum2));
    
    %Make Filter that whitens sound1 and imposes spectral envelope of sound2 
    H = exp(CH2-CH1);
    
    %Pass the frame of sound1 and take the ifft
    frameOut = (real(ifft(FFTframe1.*H))).*w2;
    
    %Overlap and Add output sound
    soundOut(startPt+1:startPt+N) = soundOut(startPt+1:startPt+N)+frameOut;
    
    %Add hop size to start point to get next frame
    startPt = startPt+hop;
end

%Normalize output sound
soundOut = soundOut/max(soundOut);

%Write output sound to file
audiowrite('../Audio/OutputSounds/PlaneModulated.wav', soundOut, fs);