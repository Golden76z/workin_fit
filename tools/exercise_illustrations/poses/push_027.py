# Body Saw — side view: forearm plank, body rocks forward then backward
# pivoting at the shoulders while forearms stay planted.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "triceps": 2, "shoulders": 2}

# Pose A: standard forearm plank, shoulders stacked over elbows,
# forearms flat on the floor.
s.add(SideFigure(
    pelvis=(300, 440),
    torso=5, head=12,
    upper_arm=-85, forearm=-2,
    thigh=193, shin=193, foot=-144,
    highlights=HL,
))

# Pose B: rocked back — shoulders behind the elbows, heels pushed back,
# ankles extended so the toes stay planted.
s.add(SideFigure(
    pelvis=(770, 440),
    torso=3, head=10,
    upper_arm=-52, forearm=-2,
    thigh=190, shin=190, foot=-34,
    highlights=HL,
))

s.chevrons(545, 300)
# rocking motion cue: back and forth along the body line
s.arrow((880, 370), (980, 370))
s.arrow((980, 400), (880, 400))

s.save("push_027")
