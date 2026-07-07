# Lunge Jumps — side view: deep lunge loaded, then explosive jump straight up
# with the legs scissoring mid-air.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2}

# Pose A: lunge — near leg forward at 90°, rear knee low, torso upright.
s.add(SideFigure(
    pelvis=(280, 420),
    torso=86, head=84,
    upper_arm=-60, forearm=25,
    far_upper_arm=-118, far_forearm=-155,
    thigh=-28, shin=-88, foot=0,
    far_thigh=-115, far_shin=-10, far_foot=-78,
    highlights=HL,
))

# Pose B: airborne — legs scissoring to switch, arms driving.
s.add(SideFigure(
    pelvis=(760, 300),
    torso=90, head=88,
    upper_arm=-125, forearm=-160,
    far_upper_arm=-55, far_forearm=30,
    thigh=-130, shin=-95, foot=-50,
    far_thigh=-45, far_shin=-115, far_foot=-25,
    clearance=70,
    highlights=HL,
))

s.chevrons(510, 290)
# jump straight up
s.arrow((915, 400), (915, 230), curve=-22)

s.pulse_icon()
s.save("cardio_013")
