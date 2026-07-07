# Plank to Downward Dog — high plank on the left, inverted-V downward dog right.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "shoulders": 2}

# Pose A: high plank, arms extended under shoulders.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: downward dog — hips high, hands and feet on the floor.
s.add(SideFigure(
    pelvis=(790, 300),
    torso=-38, head=-52,
    upper_arm=-46, forearm=-46,
    thigh=-118, shin=-104, foot=-5,
    front_hint=(-0.55, 0.84),   # belly faces down-left in the inverted V
    highlights=HL,
))

s.chevrons(520, 260)
# hips drive up and back
s.arrow((650, 400), (720, 250), curve=-35)

s.save("core_018")
