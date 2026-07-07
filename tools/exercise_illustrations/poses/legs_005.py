# Forward Lunge — side view: standing, then long step forward into a lunge,
# front knee at 90°, rear knee hovering above the floor.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: standing tall.
s.add(SideFigure(
    pelvis=(260, 370),
    torso=90, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
))

# Pose B: lunge — front (near) leg bent 90°, rear (far) knee just off the floor.
s.add(SideFigure(
    pelvis=(760, 430),
    torso=88, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-15, shin=-95, foot=0,
    far_thigh=-100, far_shin=172, far_foot=-100,
    highlights=HL,
))

s.chevrons(500, 280)
# step forward: arrow low along the ground toward the front foot
s.arrow((470, 505), (600, 505), curve=-25)

s.save("legs_005")
