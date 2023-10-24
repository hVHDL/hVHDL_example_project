import os
import sys
import serial.tools.list_ports

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')


ports = serial.tools.list_ports.comports()
for port, desc, hwid in sorted(ports):
        print("{}: {} [{}]".format(port, desc, hwid))
comport = str(sys.argv[1])

from uart_communication_functions import *
uart = uart_link(comport, 5e6)

print("test reading data from hvhdl example interconnect")
print("this should be 44252 : ", uart.request_data_from_address(99)) 
print("now write 37 to the same address with write_data_to_address(99,37)")
uart.write_data_to_address(99,37)
print("the register should now read 37 : ", uart.request_data_from_address(99)) 
print("we will now write back 44252 with with write_data_to_address(99,44252)")
uart.write_data_to_address(99,44252)
print("this should be again 44252 : ", uart.request_data_from_address(99)) 

print("now we will get 200 000 data point stream which correspond to clean sine and noisy sine which is fixed and floating point filered")
number_of_points = 50000

sinewave = uart.stream_data_from_address(100, number_of_points);
noisy_sine = uart.stream_data_from_address(103, number_of_points);
fixed_point_filtered_data = uart.stream_data_from_address(104, number_of_points);
floating_point_filtered_data = uart.stream_data_from_address(108, number_of_points);

pyplot.subplot(2, 2, 1)
pyplot.plot(sinewave) 
pyplot.title('clean sine')
pyplot.subplot(2, 2, 2)
pyplot.plot(noisy_sine) 
pyplot.title('noisy sine')
pyplot.subplot(2, 2, 2)
pyplot.plot(microprocessor_filtered_data) 
pyplot.title('microprocessor filtered sine')
pyplot.subplot(2, 2, 3)
pyplot.plot(fixed_point_filtered_data) 
pyplot.title('fixed point filtered sine')
pyplot.subplot(2, 2, 4)
pyplot.plot(floating_point_filtered_data) 
pyplot.title('floating point filtered sine')
pyplot.show()

