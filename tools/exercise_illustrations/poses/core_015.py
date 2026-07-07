# Crab Walk — side view: belly-up table position on hands and feet, walking.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "triceps": 2, "glutes": 2}
SUPINE = (0, -1)

# Pose A: hips lifted into a table, hands under shoulders, feet flat in front.
s.add(SideFigure(
    pelvis=(330, 440),
    torso=155, head=125,
    upper_arm=-92, forearm=-92,
    far_upper_arm=-86, far_forearm=-88,
    thigh=-8, shin=-85, foot=0,
    far_thigh=-12, far_shin=-68, far_foot=0,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose B: stepping — the other leg leads now.
s.add(SideFigure(
    pelvis=(810, 440),
    torso=155, head=125,
    upper_arm=-86, forearm=-88,
    far_upper_arm=-92, far_forearm=-92,
    thigh=-12, shin=-68, foot=0,
    far_thigh=-8, far_shin=-85, far_foot=0,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(560, 290)
# travelling forward (toward the feet)
s.arrow((905, 230), (1005, 230), curve=0)

s.save("core_015")
