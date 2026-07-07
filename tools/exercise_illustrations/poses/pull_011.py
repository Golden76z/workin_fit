# Isometric Pull Hold — static top-of-pull-up hold, chin over the bar.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

BAR_Y = 150
s.bar(BAR_Y, 320, 800)

f = SideFigure(
    pelvis=(540, 272),
    torso=110, head=100,
    upper_arm=-55, forearm=76,
    thigh=-80, shin=-115, foot=-60,
    snap=False, scale=1.15,
    highlights={"back": 3, "biceps": 2, "forearms": 2},
)
s.add(f)
print("hand:", f.j["hand"], "head:", f.j["head"])

s.save("pull_011")
