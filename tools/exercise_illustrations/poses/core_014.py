# Bear Crawl — side view: quadruped with knees hovering, opposite limbs stepping.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "shoulders": 2, "quads": 2}

# Hips above shoulders, knees hovering, hands and toes on the floor.
# Pose A: near arm slightly forward, near leg stepped forward.
s.add(SideFigure(
    pelvis=(330, 400),
    torso=-14, head=8,
    upper_arm=-84, forearm=-84,
    far_upper_arm=-96, far_forearm=-92,
    thigh=-112, shin=-55, foot=-20,
    far_thigh=-130, far_shin=-70, far_foot=-30,
    front_hint=(0.4, 1),
    highlights=HL,
))

# Pose B: limbs swapped — far arm forward, far leg stepped forward.
s.add(SideFigure(
    pelvis=(800, 400),
    torso=-14, head=8,
    upper_arm=-96, forearm=-92,
    far_upper_arm=-84, far_forearm=-84,
    thigh=-130, shin=-70, foot=-30,
    far_thigh=-112, far_shin=-55, far_foot=-20,
    front_hint=(0.4, 1),
    highlights=HL,
))

s.chevrons(555, 280)
# travelling forward
s.arrow((900, 220), (1000, 220), curve=0)

s.save("core_014")
