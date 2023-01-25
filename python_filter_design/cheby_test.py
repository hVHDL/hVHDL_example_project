from scipy import signal
import matplotlib.pyplot as plt
import numpy as np

b, a = signal.cheby1(4, 5, 0.1, 'low')
w, h = signal.freqs(b, a)
plt.semilogx(w, 20 * np.log10(abs(h)))
plt.title('Chebyshev Type I frequency response (rp=5)')
plt.xlabel('Frequency [radians / second]')
plt.ylabel('Amplitude [dB]')
plt.margins(0, 0.1)
plt.grid(which='both', axis='both')
# plt.axvline(100, color='green') # cutoff frequency
# plt.axhline(-5, color='green') # rp
plt.show()
