# Dead Hang — single centered hold pose hanging from a bar, arms straight.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"forearms": 3, "back": 2, "biceps": 2}

f = SideFigure(
    pelvis=(540, 310),
    torso=88, head=78,
    upper_arm=104, forearm=97,
    thigh=-95, shin=-125, foot=-60,
    snap=False, scale=1.1,
    highlights=HL,
)
s.add(f)
print("hand:", f.j["hand"])
s.bar(int(f.j["hand"][1]), 340, 740)

s.save("pull_025")
