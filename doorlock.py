import RPi.GPIO as GPIO # Import Raspberry Pi GPIO library
import time
from datetime import datetime
from enum import Enum
import subprocess

gpio_pin = 7
GPIO.setwarnings(False) # Ignore warning for now
GPIO.setmode(GPIO.BOARD) # Use physical pin numbering
GPIO.setup(gpio_pin, GPIO.OUT, initial=GPIO.LOW) # Set pin 8 to be an output pin and set initial value to low (off)

def ping(host):
    # Building the command
    command = ['ping', '-c', '1', '-W', '3', host]
    return subprocess.call(command, 
        stdout=subprocess.DEVNULL,
        stderr=subprocess.STDOUT) == 0

def lock_door():
    GPIO.output(gpio_pin, GPIO.HIGH) # Turn on lock if we are gone

def unlock_door():
    GPIO.output(gpio_pin, GPIO.LOW) # Turn off lock if we are home


class State(Enum):
    BRAD_GONE = 1
    BRAD_ARRIVED = 2
    BRAD_CHILLIN = 3
    BRAD_LEAVING = 4


state = State.BRAD_CHILLIN
prev_state = State.BRAD_CHILLIN
phone_present = True
arrive_time = 0
gone_count = 0

lock_door()

while True:
    phone_present = ping('192.168.1.42')
    
    # Run through what we should do depending on the state of me
    if state == State.BRAD_GONE:
        if phone_present:
            unlock_door()
            state = State.BRAD_ARRIVED
            arrive_time = time.time()
    elif state == State.BRAD_ARRIVED:
        if phone_present:
            # I want the door to unlock upon arrival, then relock ~120s after I've arrived
            if time.time() - arrive_time > 120:
                lock_door()
                state = State.BRAD_CHILLIN

    # If its past 7:30 am and im still here, we want to unlock the door for me
    if phone_present and datetime.now().hour == 7 and datetime.now().minute > 30:
        unlock_door()
        state = State.BRAD_LEAVING

    # Always lock the door if it sees that my phone isn't here
    if not phone_present and state!=State.BRAD_GONE:
        gone_count = gone_count + 1
        # Ping needs to not see my phone two times in a row for it to think im gone
        if gone_count > 1:
            lock_door()
            state = State.BRAD_GONE
    else:
        gone_count = 0

    # Helpful debugging
    if state != prev_state:
        print("State went from {} ---> {}".format(prev_state,state))
    prev_state = state

    time.sleep(0.25)
