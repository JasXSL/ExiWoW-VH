import logging, sys, signal, time, json, os, pytweening, threading
from collections import deque
from lib.vhWindows import vhWindows
from lib.vhSockets import vhSockets
from lib.vhUI import vhUI
from lib.libPrograms import out as progLib

logging.basicConfig(stream=sys.stdout, level=logging.INFO)
#logger = logging.getLogger(__name__)
#logger.setLevel(logging.DEBUG)

# Threading
def createThread(func, autostart = True):
    thrd = threading.Thread(target=func)
    thrd.daemon = True
    if autostart:
        thrd.start()
    return thrd

class App:
    colorBuffer = bytes([0])
    # This moves
    conf = vhWindows()
    sock = vhSockets()
    ui = vhUI()

    # Last loop tick
    tickTime = time.time()
    FRAMERATE = 20

    # Time to run a save
    saveScheduled = 0

    # Program management
    active_program = 0

    def __init__(self):
        signal.signal(signal.SIGINT, self.sigint_handler)
        self.conf.onWowStatus = self.onWowRunning
        self.conf.init()

        self.ui.setIntensity(self.conf.maxIntensity)
        self.ui.setMinIntensity(self.conf.minIntensity)
        self.ui.setDeviceId(self.conf.deviceID)
        self.ui.setDeviceServer(self.conf.server)
        self.ui.setCursorCoordinates(self.conf.cursor["x"], self.conf.cursor["y"])
        self.ui.onEvt = self.uiEvent

        self.sock.onConnection = self.onConnection
        self.sock.init(self.conf)

        thrd = threading.Thread(target=self.loop)
        thrd.daemon = True
        thrd.start()

        #start UI
        self.ui.begin()

    def uiEvent(self, t, data):
        c = self.conf
        if t == "settings":
            c.deviceID = data[0]
            c.server = data[1]
            c.saveConfig()
            self.sock.resetDevice()
        elif t == "click":
            c.cursor["x"] = data[0]
            c.cursor["y"] = data[1]
            c.saveConfig()
            self.ui.setCursorCoordinates(self.conf.cursor["x"], self.conf.cursor["y"])
        elif t == "intensity":
            c.maxIntensity = data[0]
            c.minIntensity = min(c.maxIntensity, c.minIntensity)
            self.ui.setMinIntensity(c.minIntensity)
            self.scheduleSave()
        elif t == "minintensity":
            c.minIntensity = data[0]
            c.maxIntensity = max(c.maxIntensity, c.minIntensity)
            self.ui.setIntensity(c.maxIntensity)
            self.scheduleSave()

    def onWowRunning(self, running):
        self.ui.setWowRunning(running)
        if not running:
            self.sock.resetVib()

    def onConnection(self, connected):
        self.sock.sendP(bytes([0,0,0,0,0,0,0,0]))
        self.ui.setConnectionStatus(connected)

    def scheduleSave(self):
        self.saveScheduled = time.time()+0.2

    def onProgramChange(self):
        print("Program is now", self.active_program)
        if self.active_program == 0:
            self.sock.sendProgram([0,{"d":200}])
        elif len(progLib) > self.active_program:
            self.sock.sendProgram(progLib[self.active_program])
        else:
            print("Program not found", self.active_program)

    # Sigint handling
    def sigint_handler(self, signal, frame):
        print ('Interrupted')
        self.sock.sendP(bytes([0,0,0,0,0,0,0,0]))
        os._exit(1)

    def loop(self):
        while True:
            t = time.time()
            self.tickTime = t
            conf = self.conf
            conf.processScan()   # See if WoW is running or not

            if self.saveScheduled:
                self.saveScheduled = 0
                self.conf.saveConfig()

            # This is where the magic happens
            if self.sock.connected and self.conf.wowPid:
                conf.updatePixelColor()
                if conf.g == 51 and conf.r < len(progLib):
                    pre = self.active_program
                    self.active_program = conf.r
                    if self.active_program != pre:
                        self.onProgramChange()
            
            # Scan for WoW every sec while not found
            if not self.conf.wowPid:
                time.sleep(1)
            # Sleep based on frame rate
            else:
                after = time.time()
                logicTime = 1/self.FRAMERATE-(after-t)
                if logicTime > 0:
                    time.sleep(logicTime)

#Begin
APP = App()
