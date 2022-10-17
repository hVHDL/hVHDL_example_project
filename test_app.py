import os
import sys

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')

from uart_communication_functions import *

print("test reading data from hvhdl example interconnect")
print("this should be 44252 : ", request_data_from_address(99)) 
print("now write 37 to the same address with write_data_to_address(99,37)")
write_data_to_address(99,37)
print("the register should now read 37 : ", request_data_from_address(99)) 
print("we will now write back 44252 with with write_data_to_address(99,44252)")
write_data_to_address(99,44252)
print("this should be again 44252 : ", request_data_from_address(99)) 

print("now we will get 200 000 data point stream from register 108, which corresponds with floating point filtered output")

plot_data_from_address(104, 200000)
