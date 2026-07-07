# Broad Jump — side view: crouched with arms swung back, then landing forward
# in a soft athletic stance; big forward arc shows the jump.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2}

# Pose A: loaded crouch, hips back, arms swung behind for the launch.
s.add(SideFigure(
    pelvis=(230, 445),
    torso=48, head=62,
    upper_arm=-150, forearm=-165,
    thigh=-25, shin=-112, foot=0,
    highlights=HL,
))

# Pose B: soft landing — half squat, arms forward for balance.
s.add(SideFigure(
    pelvis=(790, 430),
    torso=62, head=74,
    upper_arm=-15, forearm=-5,
    thigh=-35, shin=-108, foot=0,
    highlights=HL,
))

s.chevrons(500, 460)
# long forward arc over both figures
s.arrow((320, 290), (750, 285), curve=-120)

s.pulse_icon()
s.save("cardio_016")
