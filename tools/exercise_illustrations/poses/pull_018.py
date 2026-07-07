# Reverse Fly (prone) — lying face down, sweep the arms up and back, squeezing the upper back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2}
PRONE = (0, 1)

# Pose A: lying prone and flat, the arm resting unloaded beside the chest.
s.add(SideFigure(
    pelvis=(250, 520),
    torso=12, head=18,
    upper_arm=-35, forearm=-5,
    thigh=183, shin=181, foot=175,
    front_hint=PRONE, scale=1.1,
    highlights=HL,
))

# Pose B: chest slightly lifted, arms swept up and back toward the ceiling.
s.add(SideFigure(
    pelvis=(740, 520),
    torso=20, head=26,
    upper_arm=125, forearm=132,
    thigh=184, shin=182, foot=175,
    front_hint=PRONE, scale=1.1,
    highlights=HL,
))

s.chevrons(520, 420)
# Arms sweep up/back.
s.arrow((1010, 480), (985, 370), curve=-30)

s.save("pull_018")
