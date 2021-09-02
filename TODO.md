# TODO


### Necessary TODOs

##### Future
- [ ] Replace LED blinking with PWM signal to motor

##### In Progress
- [x] Get NTPD to work, this requires installing it through buildroot
- [x] Create logfile in /dev/shm for debugging
- [x] Get watchdog to work on boot
- [x] Create intelligent state machine for convenience



### Nonessential TODOS

##### Future
- [ ] Have the /dev/shm/log.txt file capture why python crashed AND have the watchdog tail
the last ~15 lines the file (reason why it crashed) into disk
- [ ] Have door unlock when I'm ready to leave for my lunchbreak, if I go home for it

##### In Progress
- [x] Have emailer or some other alert for when door becomes locked/unlocked
- [x] Create state machine
