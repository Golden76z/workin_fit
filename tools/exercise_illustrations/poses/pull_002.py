# Superman — side view, prone: lying flat, then arms and legs lifted together.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"lowerBack": 3, "glutes": 2}
PRONE = (0, 1)

# Pose A: prone flat, arms extended forward on the floor, legs flat.
s.add(SideFigure(
    pelvis=(280, 510),
    torso=2, head=6,
    upper_arm=-7, forearm=-3,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

# Pose B: chest, arms and legs lifted off the floor.
s.add(SideFigure(
    pelvis=(770, 505),
    torso=14, head=26,
    upper_arm=24, forearm=28,
    thigh=170, shin=166, foot=155,
    front_hint=PRONE,
    highlights=HL,
))

s.chevrons(545, 350)
# motion cues: arms and legs rise
s.arrow((1000, 470), (1025, 400), curve=-18)
s.arrow((585, 500), (562, 432), curve=18)

s.save("pull_002")
