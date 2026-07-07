# Prone Y Raise — side view, prone: arms resting extended overhead on the floor,
# then lifted off the floor into the Y.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2}
PRONE = (0, 1)

# Pose A: lying flat, arms extended forward on the floor.
s.add(SideFigure(
    pelvis=(280, 510),
    torso=2, head=6,
    upper_arm=-7, forearm=-3,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

# Pose B: chest slightly lifted, straight arms raised into the Y.
s.add(SideFigure(
    pelvis=(760, 505),
    torso=8, head=18,
    upper_arm=26, forearm=28,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

s.chevrons(545, 350)
# hands lift off the floor
s.arrow((1010, 480), (1030, 410), curve=-14)

s.save("pull_006")
