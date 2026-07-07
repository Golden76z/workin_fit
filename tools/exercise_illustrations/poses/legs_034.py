# Curtsy Lunge — side view: standing, then one leg stepped diagonally behind
# into a deep curtsy lunge (both knees ~90°, rear knee near the floor,
# torso upright over the front leg).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"glutes": 3, "quads": 2}

# Pose A: standing tall, side view.
s.add(SideFigure(
    pelvis=(300, 370), torso=90,
    upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
))

# Pose B: curtsy bottom — near (front) leg bent ~90 with shin vertical,
# far (rear) leg stepped behind with the knee just above the floor,
# toes tucked. Torso stays upright.
s.add(SideFigure(
    pelvis=(790, 430), torso=87, head=85,
    upper_arm=-62, forearm=-18,
    thigh=-15, shin=-95, foot=0,
    far_thigh=-118, far_shin=182, far_foot=-118,
    highlights=HL,
))

s.chevrons(520, 270)
# pelvis sinks straight down as the rear leg steps behind
s.arrow((960, 320), (955, 440), curve=-30)

s.save("legs_034")
