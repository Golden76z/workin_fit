# Prone W Raise — side view, prone: elbows bent with hands resting on the floor
# by the shoulders, then elbows squeezed up and back into the W.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2}
PRONE = (0, 1)

# Pose A: lying flat, elbows bent, hands on the floor next to the shoulders.
s.add(SideFigure(
    pelvis=(290, 510),
    torso=4, head=8,
    upper_arm=200, forearm=-8,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

# Pose B: chest slightly lifted, bent elbows raised up and back.
s.add(SideFigure(
    pelvis=(770, 505),
    torso=10, head=20,
    upper_arm=150, forearm=42,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

s.chevrons(545, 350)
# elbows lift up and back
s.arrow((990, 490), (940, 395), curve=-40)

s.save("pull_008")
