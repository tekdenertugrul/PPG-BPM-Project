clear
clc
close all


%% 1 Plotting the fixed Raw Signal
fid=fopen('Green3.txt','r');
S=textscan(fid,'%f');

Fs = 200;
Ts = 1/Fs;

green_signal1 = transpose(S{1});
green_signal=resample(green_signal1,20,23,3); %%Original signal sampling rate = Total_Indices/Total_Time approx 230, so We are going to fix the sampling rate to 200. 



t = 0:Ts:length(green_signal)*Ts-Ts; %%Arranging the time interval based on the indices & Sampling Rate
figure (1)
plot(t, green_signal) % Raw Signal
xlabel('Time in seconds')
ylabel('Intensity(V)')
title('Raw PPG Signal')
xlim([0 13])

%% 2 Fourier Transforming
n=length(t)
fhatGreenDC=fft(green_signal,n); %% Taking FFT for finding DC values
fhatGreenAC=fft(green_signal,n); %% Taking FFT for finding AC values

PSDGreen=fhatGreenDC.*conj(fhatGreenDC)/n; %%Power Spectrum Density

freq = 1/(Ts*n)*(0:n-1);
L=1:floor(n/2);
figure (2)
plot(freq(L),PSDGreen(L),'LineWidth',3); %% FFT of the Raw Signal

%% 3 FFT Type Filtering & Processing the signal
indices=freq<0.5; %%DC components can be found below 0.5 Hz
indices2=(0.5<freq & freq<10); %%AC components can be found between 0.5 Hz to 10 Hz
fhatGreenDC=indices.*fhatGreenDC;
fhatGreenAC=indices2.*fhatGreenAC;
ffiltDC=ifft(fhatGreenDC);
ffiltAC=real(ifft(fhatGreenAC));
figure(3);
plot(t,real(ffiltDC)); %%DC components
xlabel('Time in seconds')
ylabel('Intensity(V)')
title('DC Components of PPG Signal')
ylim([500 700])
xlim([0 13])

figure(4);
plot(t,real(ffiltAC)); %%AC components
xlabel('Time in seconds')
ylabel('Intensity(V)')
title('AC Components of PPG Signal')
xlim([0 13])
NormalizedGreen=real(ffiltAC)./real(ffiltDC); %% Processed Signal (Normalized Signal) 
figure(5)
plot(t,real(transpose(ffiltAC)))

%% 4 Power Spectrum Of Normalized Signal
fhatGreenNormalizedClean=fft(NormalizedGreen,n);
PSDNormalizedGreenClean=fhatGreenNormalizedClean.*conj(fhatGreenNormalizedClean)/n;
figure(6);
plot(freq(L),PSDNormalizedGreenClean(L),'LineWidth',3);
xlim([0 10])
xlabel('Frequency in termz of Hertz')
ylabel('Amplitude')
title('Power Spectrum ')
%% 5 BPM Calculation using FFT Method
Maxima=0; %% The BPM= Most dominant pulse in power spectrum *60
BPMloc=0;
for i=1:length(freq);
  if i>5;
      if i<25;
          if Maxima<fhatGreenNormalizedClean(i).*conj(fhatGreenNormalizedClean(i));
              Maxima=abs(fhatGreenNormalizedClean(i));
                    BPMloc=freq(i);
          end
      end
  end

end

BPM=BPMloc*60 %% We can observe the BPM value of the user.