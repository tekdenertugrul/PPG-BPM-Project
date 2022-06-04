clear
clc
close all


%% 1
fid=fopen('Green3.txt','r');
S=textscan(fid,'%f');

Fs = 200;
Ts = 1/Fs;

green_signal1 = transpose(S{1});
green_signal=resample(green_signal1,20,23,3);



t = 0:Ts:length(green_signal)*Ts-Ts;
figure (1)
plot(t, green_signal)
xlabel('Time in seconds')
ylabel('Intensity(V)')
title('Raw PPG Signal')
xlim([0 13])




%% 3 Fourier Transforming
n=length(t)
fhatGreenDC=fft(green_signal,n);
fhatGreenAC=fft(green_signal,n);

PSDGreen=fhatGreenDC.*conj(fhatGreenDC)/n;

freq = 1/(Ts*n)*(0:n-1);
L=1:floor(n/2);
figure (3)
plot(freq(L),PSDGreen(L),'LineWidth',3);

%% Zero Embedding
indices=freq<0.5;
indices2=((freq<0.5 | 4<freq) & (freq<0.25|freq>0.35));
freqClean=freq.*indices;
freqClean2=freq.*indices2;
fhatGreenDC=indices.*fhatGreenDC;
fhatGreenAC=indices2.*fhatGreenAC;
ffiltDC=ifft(fhatGreenDC);
ffiltAC=real(ifft(fhatGreenAC));
figure(4);
plot(t,real(ffiltDC));
xlabel('Time in seconds')
ylabel('Intensity(V)')
title('DC Components of PPG Signal')
ylim([500 700])
xlim([0 13])

figure(5);
plot(t,real(ffiltAC));
xlabel('Time in seconds')
ylabel('Intensity(V)')
title('AC Components of PPG Signal')
xlim([0 13])
lms = dsp.LMSFilter('Length',128,'StepSize',0.00000001);
[y,err,wts] = lms(real(transpose(ffiltAC)),transpose(green_signal)) 
NormalizedGreen=real(ffiltAC)./real(ffiltDC);
figure(6)
plot(t,real(transpose(ffiltAC)))

fhatGreenNormalized=fft(NormalizedGreen,n);
PSDNormalizedGreen=fhatGreenNormalized.*conj(fhatGreenNormalized)/n;
indicesNormal=freq<10 | freq >length(freq)-10;
freqCleanNormal1=freq.*indicesNormal;
fhatGreenNormalizedClean1=indicesNormal.*fhatGreenNormalized;
ffiltGreenNormalized=ifft(fhatGreenNormalizedClean1);
figure(7)
plot(t,real(ffiltGreenNormalized));
xlabel('Time in seconds')
ylabel('Intensity(V)')
title('Normalized (Processed) Signal')
xlim([0 13])

fhatGreenNormalizedClean=fft(real(ffiltGreenNormalized),n);
PSDNormalizedGreenClean=fhatGreenNormalizedClean.*conj(fhatGreenNormalizedClean)/n;
figure(8);
plot(freq(L),PSDNormalizedGreenClean(L),'LineWidth',3);
xlim([0 10])
xlabel('Frequency in termz of Hertz')
ylabel('Amplitude')
title('Power Spectrum ')
IIRFilter = dsp.IIRFilter('Numerator',sqrt(0.75),...
    'Denominator',[1 -0.5]);
for k = 1:size(NormalizedGreen,2)   
  NormalizedGreen(:,k) = IIRFilter(sign(randn(size(NormalizedGreen,1),1))); 
end
mu = 0.1;     
LMSFilter = dsp.LMSFilter('Length',32,...
    'StepSize',mu);
[mumax,mumaxmse] = maxstep(LMSFilter,NormalizedGreen)
%% BPM Calculation FFT
Maxima=0;
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

 BPM=BPMloc*60


%%BPM by time
time2=0:Ts:10-Ts;

sarah=length(real(ffiltGreenNormalized))/200;
SignalFFTtest=zeros(1,length(time2));
BPMtime=[]
z=1;
v=1;
d=1;
serah=0;
for i=10:2:sarah
   
    for i=serah*2:Ts:10+serah*2-Ts
        
        
      
        SignalFFTtest(v)=real(ffiltGreenNormalized(z));
    
        if i==10+serah*2-20*Ts
     
        n=length(t);
        SignalFFTHat=fft(SignalFFTtest,n);
        PSDGreentest=SignalFFTHat.*conj(SignalFFTHat)/n;

        
        Maxima=0;
        BPMloc=0;
    for i=1:length(freq);
        if freq(i)>0.5;
            if freq(i)<2.5;
                if Maxima<abs(SignalFFTHat(i));
                    Maxima=abs(SignalFFTHat(i));
                    BPMloc=freq(i);
                end
             end
        end

        end

            BPM=BPMloc*60
            BPMtime=[BPMtime BPM];
            d=d+1;
            z=z-1600;
            serah=serah+1; 
   
   
            
        end
           
    
    
    z=z+1;
    v=v+1;
    
    end
    v=1;    
end
figure(9)
plot(BPMtime)
figure(10)
plot(time2,SignalFFTtest)
figure(11)
plot(freq(L),PSDGreentest(L))
xlim([0 10])
  