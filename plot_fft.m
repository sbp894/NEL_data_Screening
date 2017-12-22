% [amp_dB,freq, ax]=plot_fft(, Fs, plot_phase, NFFT, x_semilog, title_str)
% amp_dB= 1 sided amplitudes in dB
% freq= frequency corresponding to P1
% ax= axes of the subplots (magnitude and phase)

function [amp_dB,freq, ax]=plot_fft(vecin, Fs, plot_phase, NFFT, x_semilog, title_str)

if nargin==5
    title_str='1 sided fft plot';
elseif nargin==4
    x_semilog=1;
    title_str='1 sided fft plot';
elseif nargin==3
    NFFT=2^nextpow2(length(vecin));
    x_semilog=1;
    title_str='1 sided fft plot';
elseif nargin==2
    NFFT=2^nextpow2(length(vecin));
    x_semilog=1;
    title_str='1 sided fft plot';
    plot_phase=0;
end

L = length(vecin);
Y = fft(vecin, NFFT);

P2 = Y/L;
amp_dB = abs(P2(1:ceil(NFFT/2+1)));
amp_dB(2:end-1) = 2*amp_dB(2:end-1);
amp_dB=20*log10(amp_dB);
freq =linspace(0,Fs/2,length(amp_dB));

if x_semilog
    if plot_phase
        ax(1)=subplot(211);
    end
    semilogx(freq,amp_dB);
    xlabel('f (Hz)');
    ylabel('20*log10(|P1(f)|), dB');
    title(title_str);
    %     xlim([.1 Fs/2]);
    if plot_phase
        ax(2)=subplot(212);
        semilogx(freq,unwrap(angle(P2(1:ceil(NFFT/2+1)))));
        title('Phase Plot');
        linkaxes(ax, 'x');
    end
else
    if plot_phase
        ax(1)=subplot(211);
    end
    plot(freq,amp_dB);
    xlabel('f (Hz)');
    ylabel('Amplitude (dB)');
    
    if plot_phase
        ax(2)=subplot(212);
        plot(freq,unwrap(angle(P2(1:ceil(NFFT/2+1)))));
        ylabel('Phase (rad)');
        title('Phase Plot');
    end
end

