import os
import sys

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')

from uart_communication_functions import *

uart = uart_link("COM10", 5e6)

print("test reading data from hvhdl example interconnect")
print("this should be 44252 : ", uart.request_data_from_address(99)) 
print("now write 37 to the same address with write_data_to_address(99,37)")
uart.write_data_to_address(99,37)
print("the register should now read 37 : ", uart.request_data_from_address(99)) 
print("we will now write back 44252 with with write_data_to_address(99,44252)")
uart.write_data_to_address(99,44252)
print("this should be again 44252 : ", uart.request_data_from_address(99)) 

print("now we will get 200 000 data point stream from register 108, which corresponds with floating point filtered output")

input_data = uart.stream_data_from_address(255, 15000)
input1_data = uart.stream_data_from_address(256, 15000)
# float_test = uart.stream_data_from_address(108, 50000)
# fixed_test = uart.stream_data_from_address(105, 50000)
pyplot.subplot(1, 2, 1)
# pyplot.plot(input_data-32768)
# pyplot.plot(float_test-32768)
# pyplot.subplot(1, 3, 3)
pyplot.stairs(input_data-2**15)
pyplot.subplot(1, 2, 2)
pyplot.stairs(input1_data-2**15)

pyplot.show()

