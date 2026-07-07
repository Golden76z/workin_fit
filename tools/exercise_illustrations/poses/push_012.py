# Shoulder Tap Push-up — side view: push-up top, then plank on one arm while
# the free hand taps the opposite shoulder.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2, "abs": 2}

# Pose A: plank top, both hands on the floor.
s.add(SideFigure(
    pelvis=(290, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: top position, far arm supporting, near hand folded up to tap the
# opposite shoulder.
s.add(SideFigure(
    pelvis=(770, 430),
    torso=18, head=24,
    upper_arm=-55, forearm=100,
    far_upper_arm=-85, far_forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

s.chevrons(530, 280)
# hand travels from the floor up to the opposite shoulder
s.arrow((1030, 510), (990, 410), curve=-30)

s.save("push_012")
