# Reverse Snow Angels — side view, prone: arms sweep from the hips to overhead
# while hovering off the floor, chest slightly lifted.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2}
PRONE = (0, 1)

# Pose A: arms hovering along the sides, pointing back toward the hips,
# lifted slightly off the back so they read clearly.
s.add(SideFigure(
    pelvis=(300, 505),
    torso=8, head=18,
    upper_arm=166, forearm=171,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

# Pose B: arms swept overhead, pointing forward past the head.
s.add(SideFigure(
    pelvis=(760, 505),
    torso=8, head=18,
    upper_arm=16, forearm=18,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

s.chevrons(545, 350)
# sweeping arc: hands travel all the way from the hips to overhead
s.arrow((680, 465), (1010, 445), curve=-120)

s.save("pull_003")
