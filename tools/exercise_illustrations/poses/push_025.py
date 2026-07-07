# Prone I Raise — side view, prone: arms overhead on the floor, then lifted
# straight up forming an "I" line with the body.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"shoulders": 3, "back": 2}
PRONE = (0, 1)

# Pose A: prone flat, straight arms resting overhead on the floor.
s.add(SideFigure(
    pelvis=(290, 505),
    torso=3, head=8,
    upper_arm=-6, forearm=-3,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

# Pose B: straight arms lifted overhead (torso stays low — only the arms rise).
s.add(SideFigure(
    pelvis=(760, 505),
    torso=7, head=14,
    upper_arm=32, forearm=34,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

s.chevrons(545, 350)
# motion cue: straight arms rise from the floor
s.arrow((1000, 480), (1030, 405), curve=-20)

s.save("push_025")
