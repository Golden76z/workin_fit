# Reverse Lunge — side view: standing, then step BACKWARD into a lunge.
# Same bottom shape as a lunge but the motion arrow shows the rear foot
# travelling back.
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

# Pose B: lunge reached by stepping back — torso upright, rear knee low.
s.add(SideFigure(
    pelvis=(740, 430),
    torso=90, head=92,
    upper_arm=-78, forearm=-74,
    thigh=-15, shin=-95, foot=0,
    far_thigh=-100, far_shin=172, far_foot=-100,
    highlights=HL,
))

s.chevrons(490, 280)
# rear foot travels backward: arrow points back-down behind the figure
s.arrow((660, 445), (585, 512), curve=-18)

s.save("legs_006")
