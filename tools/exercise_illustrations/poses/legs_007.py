# Walking Lunge — side view: lunge on one leg, then the next lunge one step
# further with the legs swapped; travel arrow shows forward progression.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: lunge, near leg forward, far knee low behind.
s.add(SideFigure(
    pelvis=(270, 430),
    torso=88, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-15, shin=-95, foot=0,
    far_thigh=-100, far_shin=172, far_foot=-100,
    highlights=HL,
))

# Pose B: next step — legs swapped (far leg now forward), one step ahead.
s.add(SideFigure(
    pelvis=(760, 430),
    torso=88, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-100, shin=172, foot=-100,
    far_thigh=-15, far_shin=-95, far_foot=0,
    highlights=HL,
))

s.chevrons(500, 280)
# continuous forward travel
s.arrow((430, 505), (595, 505), curve=-25)

s.save("legs_007")
