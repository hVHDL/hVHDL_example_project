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

print("now we will get 200 000 data point stream from register 108, which corresponds with floating point filtered output")

uart.plot_data_from_address(15357, 200000)
# uart.plot_data_from_address(102, 200000)
# uart.plot_data_from_address(103, 200000)
# uart.plot_data_from_address(108, 200000)

