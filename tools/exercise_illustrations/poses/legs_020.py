# Step-up — side view with a box: front foot planted on the step, then standing
# tall on top of the step with the trailing knee driving up.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

BOX_TOP = 438  # ground 548 -> box 110 px tall
BOX_H = 548 - BOX_TOP

# Pose A: rear foot on the floor, front foot planted on top of the box.
s.add(SideFigure(
    pelvis=(250, 380),
    torso=82, head=85,
    upper_arm=-60, forearm=-30,
    thigh=-90, shin=-90, foot=0,           # rear (near) leg on the floor
    far_thigh=8, far_shin=-62, far_foot=0,  # front foot planted on the box top
    highlights=HL,
))
s.box(320, BOX_TOP, 150, BOX_H)

# Pose B: standing tall on the box, trailing knee lifted high.
s.add(SideFigure(
    pelvis=(770, 264),
    torso=90, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,           # support leg on the box top
    far_thigh=-10, far_shin=-95, far_foot=-10,  # knee driven up
    snap=False,
    highlights=HL,
))
s.box(700, BOX_TOP, 150, BOX_H)

s.chevrons(540, 250)
# drive up onto the box
s.arrow((580, 430), (630, 330), curve=-20)

s.save("legs_020")
