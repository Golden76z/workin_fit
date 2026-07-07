# Fist Plank Hold — side view: single high-plank hold on straight arms (fists).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

# High plank: arms extended under shoulders, body in one straight line.
s.add(SideFigure(
    pelvis=(480, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    scale=1.25,
    highlights={"forearms": 3, "abs": 2, "shoulders": 2},
))

s.save("pull_027")
