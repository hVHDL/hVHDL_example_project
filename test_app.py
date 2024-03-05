import os
import sys
import serial.tools.list_ports

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')


ports = serial.tools.list_ports.comports()
for port, desc, hwid in sorted(ports):
        print("{}: {} [{}]".format(port, desc, hwid))
comport = str(sys.argv[1])
plot_title = str(sys.argv[2])

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
uart.write_data_to_address(111,8)
print("requested filter index : ", uart.request_data_from_address(111)) 

print("now we will get 200 000 data point stream which correspond to clean sine and noisy sine which is fixed and floating point filered")
number_of_points = 50000

noisy_sine = uart.stream_data_from_address(103, number_of_points);
fixed_point_filtered_data = uart.stream_data_from_address(104, number_of_points);
floating_point_filtered_data = uart.stream_data_from_address(108, number_of_points);
microprocessor_filtered_data = uart.stream_data_from_address(110, number_of_points);


(fig, ax) = pyplot.subplots(2, 2)

# ax[0][0].subplot(2, 2, 1)
ax[0][0].plot(noisy_sine) 
ax[0][0].set_title('noisy sine')

ax[0][1].plot(microprocessor_filtered_data) 
ax[0][1].set_title('microprocessor filtered sine')

ax[1][0].plot(fixed_point_filtered_data) 
ax[1][0].set_title('fixed point filtered sine')

ax[1][1].plot(floating_point_filtered_data) 
ax[1][1].set_title('floating point filtered sine')
fig.suptitle(plot_title, fontsize=15)
pyplot.show()

