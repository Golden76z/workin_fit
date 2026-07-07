# Prone T Raise — side view, prone: arms resting out on the floor beside the
# shoulders, then swept up and back (reverse-fly style) with straight elbows.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2}
PRONE = (0, 1)

# Pose A: lying flat, arms resting on the floor just ahead of the shoulders.
s.add(SideFigure(
    pelvis=(290, 510),
    torso=4, head=8,
    upper_arm=-20, forearm=-5,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

# Pose B: chest slightly lifted, straight arms swept up level with the back.
s.add(SideFigure(
    pelvis=(770, 505),
    torso=10, head=20,
    upper_arm=140, forearm=142,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

s.chevrons(545, 350)
# hands arc from the floor up behind the shoulders
s.arrow((990, 490), (940, 390), curve=-40)

s.save("pull_007")
