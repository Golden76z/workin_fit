# Prone Cobra — hold: lying face down, chest arched up, arms lifted back along the body.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"lowerBack": 3, "back": 2, "glutes": 2}
PRONE = (0, 1)

s.add(SideFigure(
    pelvis=(500, 510),
    torso=20, head=30,
    upper_arm=212, forearm=200,
    thigh=184, shin=182, foot=175,
    front_hint=PRONE, scale=1.25,
    highlights=HL,
))

# Effort direction: chest lifts up.
s.arrow((790, 470), (810, 380), curve=-18)

s.save("pull_021")
