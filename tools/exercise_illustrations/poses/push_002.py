# Incline Push-up — hands elevated on a chair/box, feet on floor.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2}

BOX_TOP = 453.5
s.box(420, BOX_TOP, 120, 548 - BOX_TOP)   # under pose A hands
s.box(815, BOX_TOP, 120, 548 - BOX_TOP)   # under pose B hands

# Pose A: arms extended, body inclined, hands on box.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=40, head=45,
    upper_arm=-48, forearm=-48,
    thigh=218, shin=218, foot=-105,
    highlights=HL,
))

# Pose B: elbows bent back, chest toward the box edge.
s.add(SideFigure(
    pelvis=(790, 430),
    torso=30, head=34,
    upper_arm=190, forearm=-52,
    thigh=210, shin=212, foot=-105,
    highlights=HL,
))

s.chevrons(585, 270)
s.arrow((990, 340), (990, 420))
s.arrow((1030, 420), (1030, 340))

s.save("push_002")
