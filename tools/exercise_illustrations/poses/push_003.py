# Decline Push-up — feet elevated on a chair/box, hands on floor.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2}
PRONE = (0, 1)

BOX_TOP = 396.5
s.box(75, BOX_TOP, 120, 548 - BOX_TOP)    # under pose A feet
s.box(585, BOX_TOP, 120, 548 - BOX_TOP)   # under pose B feet

# Pose A: arms extended, feet up on box, body sloping down to shoulders.
s.add(SideFigure(
    pelvis=(300, 400),
    torso=-14, head=-6,
    upper_arm=-80, forearm=-80,
    thigh=168, shin=172, foot=-95,
    front_hint=PRONE,
    highlights=HL,
))

# Pose B: elbows bent, chest near floor, feet stay on box.
s.add(SideFigure(
    pelvis=(790, 420),
    torso=-26, head=-16,
    upper_arm=165, forearm=-80,
    thigh=146, shin=150, foot=-95,
    front_hint=PRONE,
    highlights=HL,
))

s.chevrons(505, 250)
s.arrow((990, 380), (990, 470))
s.arrow((1030, 470), (1030, 380))

s.save("push_003")
