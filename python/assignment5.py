"""
    Script to test serial devices
"""

from pylibftdi import Device, Driver, INTERFACE_B
import struct
import time
import sys
import re

CMD_FPGA_RESET = '\x00\xff'
CMD_BOARD_RESET = '\x00\xfe'
CMD_GLITCH = '\x00\x00'

def expect_read(expected):
    result = ""
    # Don't attempt to read more than 10 times
    for i in range(0,10):
        result += dev.read(len(expected))
        if expected in result:
            return None;

    print "\tExpected = " + repr(expected) + " got " + repr(result)
    return result

def synchronize():
    # Detect baud rate
    board_write('?')

    # Wait for 'Synchronized\r\n'
    expect_read('Synchronized\r\n')

    # Reply 'Synchronized\r\n'
    board_write('Synchronized\r\n')

    # Verify 'Synchronized\rOK\r\n'
    expect_read('Synchronized\rOK\r\n')

    # Set a clock rate (value doesn't matter)
    board_write("12000\r\n")

    # Verify OK
    expect_read('12000\rOK\r\n')

def read_address(address, length):
    cmd = 'R {:d} {:d}\r\n'.format(address, length)
    board_write(cmd)

    result = ""
    # Don't attempt to read more than 10 times
    for i in range(0,10):
        result += dev.read(61)
        if '\r\n' in result:
            break

    # Check if command succeeded.
    if '\r0' in result:
        board_write('OK\r\n')
        expect_read('OK\r\n')
        return result

    return None

def test_crp():
    result = read_address(0,4)
    if result:
        print "DEVICE UNLOCKED"
        print repr(result)
        return result

    print "device is locked."
    return None

def reset_fpga():
    dev.write(CMD_FPGA_RESET)

def reset_board():
    dev.write(CMD_BOARD_RESET)

def glitch():
    dev.write(CMD_GLITCH)

def board_write(msg):
    length = struct.pack('B',len(msg))
    dev.write(length + msg)

def enable_passthrough():
    dev.write('\x00\xfd')

#8'h40:
#    state <= STATE_PWM;
def get_cmd_pwm(pwm_value):
    return '\x00\x40' + struct.pack('B',int(pwm_value,2))

#8'h10:
#    state <= STATE_PATTERN0;
def get_cmd_pulse_width(width):
    if(width < 256):
        return '\x00\x10' + struct.pack('B', width)
    else:
        print "ERROR, invalid pulse_wdith"
        exit(1)

#8'h11:
#    state <= STATE_PATTERN1;
def get_cmd_pulse_cnt(cnt):
    if(cnt < 256):
        return '\x00\x11' + struct.pack('B',cnt)
    else:
        print "ERROR, invalid pulse_cnt"
        exit(1)

def get_cmd_delay(delay):
    delay0 = delay & 0xff
    delay1 = (delay >> 8) & 0xff
    delay2 = (delay >> 16) & 0xff
    delay3 = (delay >> 24) & 0xff
    delay4 = (delay >> 32) & 0xff
    delay5 = (delay >> 40) & 0xff
    delay6 = (delay >> 48) & 0xff
    delay7 = (delay >> 56) & 0xff

    result = '\x00\x20'
    result += struct.pack('B',delay0)
    result += '\x00\x21'
    result += struct.pack('B',delay1)
    result += '\x00\x22'
    result += struct.pack('B',delay2)
    result += '\x00\x23'
    result += struct.pack('B',delay3)
    result += '\x00\x24'
    result += struct.pack('B',delay4)
    result += '\x00\x25'
    result += struct.pack('B',delay5)
    result += '\x00\x26'
    result += struct.pack('B',delay6)
    result += '\x00\x27'
    result += struct.pack('B',delay7)
    return result

def line_parse(s):
    # return everything between 0 and the \r\n, following the UU data
    match = re.findall(r'\$.*\r\n',s)[0]
    return match[1:-2]

def uu_decode_line(uudata):
    result = uu_decode(uudata[:4])
    result.append(uu_decode(uudata[4:])[0])
    return result

def uu_decode(uudata):
    data = [ord(c) for c in uudata]
    s0 = 0;
    s1 = 0;
    s2 = 0;

    s0 = ((data[0]-32)<<2) & 0xff
    s0 = s0 | (((data[1]-32)>>4) & 0x03)

    s1 = ((data[1]-32)<<4) & 0xf0
    s1 = s1 | (((data[2]-32)>>2) & 0x0f)

    s2 =((data[2]-32)<<6) & 0xC0
    s2 = s2 | (((data[3]-32))    & 0x3F)
    return [s0,s1,s2]

def unlock(delay_from, delay_to, width_from, width_to):
    for d in range(delay_from, delay_to):
        for width in range (width_from, width_to):
            delay = d
            sys.stdout.write("[%02d,%010d]: " % (width,delay))
            cmd = get_cmd_pulse_width(width)
            cmd += get_cmd_pulse_cnt(0)
            cmd += get_cmd_delay(delay)
            cmd += CMD_BOARD_RESET
            dev.write(cmd)
            synchronize()
            crp = test_crp()
            if crp:
                return crp

    return None

#print Driver().list_devices()
#Use binary mode! mode = 'b'
with Device(mode='b',interface_select=INTERFACE_B) as dev:
    dev.baudrate = 115200
    reset_fpga()
    # 5475
    unlock(5464, 6200, 10, 25)

    f = open('workfile', 'w')

    for i in range(0,0x8000):
        address = i * 4
        result = read_address(address,4)
        if result:
            data = uu_decode_line(line_parse(result))
            output = '[0x%06x]: ' % address
            output += ''.join(['%02X ' % x for x in data])
            print output
            f.write(bytearray(data))
        else:
            print "[!!!] Error"

    exit(0)
