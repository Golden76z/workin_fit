# Fast Feet — side view: quick low steps in place on the balls of the feet,
# alternating which foot is off the ground.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"calves": 3}

# Pose A: near foot barely lifted, far foot planted, arms in running guard.
s.add(SideFigure(
    pelvis=(290, 380),
    torso=84, head=82,
    upper_arm=-62, forearm=28,
    far_upper_arm=-118, far_forearm=-40,
    thigh=-45, shin=-115, foot=-25,
    far_thigh=-92, far_shin=-86, far_foot=0,
    highlights=HL,
))

# Pose B: switched — near foot planted, far foot lifted.
s.add(SideFigure(
    pelvis=(760, 380),
    torso=84, head=82,
    upper_arm=-118, forearm=-40,
    far_upper_arm=-62, far_forearm=28,
    thigh=-92, shin=-86, foot=0,
    far_thigh=-45, far_shin=-115, far_foot=-25,
    highlights=HL,
))

s.chevrons(525, 290)
# rapid alternating steps: small up arrows beside the lifted foot
s.arrow((420, 535), (420, 480), curve=0)
s.arrow((890, 535), (890, 480), curve=0)

s.pulse_icon()
s.save("cardio_011")
