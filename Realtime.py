## 1 Defining The variables
import serial
import timeit
import numpy as np
import matplotlib.pyplot as plt

PPGgreentest=[] # Digital data that sampled in 230 Hz
time=[] # The time
BPM=[] # Heart Rate Values
time2=[] # 10 secs self-renewing time. For example, 2-12, 4-14, etc.
PPGgreentest2=np.zeros(2300) #10 secs data



## 2 Communicating Arduino with Computer
def read():

    rf_id_input = ser.readline().decode('utf-8').rstrip()
    return rf_id_input

def write(command):

    ser.write(command.encode('utf-8'))

ser = serial.Serial("COM7")
ser.baudrate=115200 # We take 230 data per second. So this baudrate is quite enough.
ser.flush()
print("Arduino is connected") # Looking at whether Arduino is connected


counter=0 # Random Counter
start = timeit.default_timer()
zed=0    # Random Counter 2



## 3 Arranging the Multiple Graphs
fig, ax = plt.subplots(2, 2)
plt.subplots_adjust(left=0.1,
                    bottom=0.1,
                    right=0.9,
                    top=0.9,
                    wspace=0.4,
                    hspace=0.4)
fig.set_size_inches(17, 7)
fig.set_dpi(100)
fig.canvas.draw()
plt.show(block=False)
li, =  ax[0,0].plot(time, PPGgreentest)
li2, = ax[0,1].plot(time, PPGgreentest)
li3, = ax[1,0].plot(time, PPGgreentest)
li4, = ax[1,1].plot(time, PPGgreentest)

## 4 Main Function Starts Here
Fs = 230    # Sampling Rate
dt = 1 / Fs
counter_3=0
while(1):
    ardData = float(read())


    counter=counter+1
    if counter > 460:   ## Starting with 2 secs delay
        PPGgreentest.append(ardData)

## 5 After 10 secs Data is accumulated by Pc, The Signal Processing starts
    if counter == 2760+zed*460:
        counter_4 = zed*460
        counter_3= 2300+zed*460
        PPGgreentest2 = np.array(PPGgreentest[counter_4:counter_3]) #10 Secs Data for process
        time=np.arange(0,dt*len(PPGgreentest),dt)
        time2=np.arange(zed*2,dt*len(PPGgreentest2)+zed*2,dt)
        TimeBPM=np.arange(8,10+zed*2,2)
        n = len(time)
        n2=len(time2)

## FFT Method Filtering
        fhatgreenDC = np.fft.fft(PPGgreentest2, n2)
        freq = (1 / (dt * n2)) * np.arange(n2)
        L = np.arange(1, np.floor(n2 / 2), dtype='int')
        fhatgreenAC = np.fft.fft(PPGgreentest2,n2)
        indicesDC = freq < 0.5
        indicesAC = np.logical_and(freq>0.5,freq<10)
        fhatgreenDC = indicesDC * fhatgreenDC
        fhatgreenAC = indicesAC * fhatgreenAC
        ffiltDCgreen = np.fft.ifft(fhatgreenDC)
        ffiltACgreen = np.fft.ifft(fhatgreenAC)
        NormalizedGreen=(np.real(ffiltACgreen)/np.real(ffiltDCgreen))
        fhatNormalizedGreen=np.fft.fft(NormalizedGreen,n2)
        PSDgreen=fhatNormalizedGreen*np.conj(fhatNormalizedGreen)/n
        s = 0   #Random Counter
        k = 0   #Random Counter
        BPMloc = 0
        zed = zed + 1   #Random Counter
        
## 6 Heart Rate Calculations
        for l in freq:
            if np.logical_and(freq[s] > 0.8, freq[s] < 2.5):
                if k < abs(fhatNormalizedGreen[s]):
                    k = abs(fhatNormalizedGreen[s])
                    BPMloc = freq[s]
            s = s + 1
        BPM.append(BPMloc * 60)
        print(BPMloc*60)
        
## 7 Printing the Real Time Graphs
        li.set_ydata(PPGgreentest2)
        li.set_xdata(time2)
        li2.set_xdata(time2)
        li2.set_ydata(NormalizedGreen)
        li3.set_xdata(freq)
        li3.set_ydata(PSDgreen)
        li4.set_xdata(TimeBPM)
        li4.set_ydata(BPM)
        stop = timeit.default_timer()
        print('Time: ', stop - start)
        ax[0,0].relim()
        ax[0,1].relim()
        ax[1, 1].relim()
        ax[1, 0].relim()
        ax[1,0].set_xlim(0,5)
        ax[1, 0].autoscale_view(True, True, True)
        ax[1, 1].autoscale_view(True, True, True)
        ax[0,0].autoscale_view(True, True, True)
        ax[0, 0].set_title('PPG Green')
        ax[0,0].set_ylabel('Light Intensity (V)')
        ax[0, 0].set_xlabel('Time in Seconds')
        ax[0, 1].set_title('Normalized Green')
        ax[0, 1].set_ylabel('Light Intensity (V)')
        ax[0, 1].set_xlabel('Time in Seconds')
        ax[1, 0].set_ylabel('Magnitude Response')
        ax[1, 0].set_title('Power Spectrum Of Normalized Signal')
        ax[1, 0].set_xlabel('Frequency in terms of Hz')
        ax[1, 1].set_title('Heart Rate')
        ax[1, 1].set_ylabel('BPM')
        ax[1, 1].set_xlabel('Time in Seconds')
        ax[0, 1].autoscale_view(True, True, True)
        fig.canvas.draw()
        plt.pause(0.001)