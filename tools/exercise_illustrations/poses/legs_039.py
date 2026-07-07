# Lateral Lunge Pulse — front view: standing, then wide side lunge with pulse arrows.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: standing tall, feet together-ish, arms relaxed.
s.add(FrontFigure(
    pelvis=(280, 370),
    l_upper_arm=-115, l_forearm=-108,
    r_upper_arm=-65, r_forearm=-72,
    l_thigh=-95, r_thigh=-85,
    highlights=HL,
))

# Pose B: wide lateral lunge — right leg bent, left leg straight out to the side,
# arms reaching forward/center for balance.
s.add(FrontFigure(
    pelvis=(790, 450),
    l_upper_arm=-150, l_forearm=-135,
    r_upper_arm=-30, r_forearm=-45,
    l_thigh=232, l_shin=232,
    r_thigh=-40, r_shin=-100,
    highlights=HL,
))

s.chevrons(510, 280)
# small up-down pulse in the bottom position
s.arrow((985, 385), (985, 435), curve=0)
s.arrow((1010, 435), (1010, 385), curve=0)

s.save("legs_039")
