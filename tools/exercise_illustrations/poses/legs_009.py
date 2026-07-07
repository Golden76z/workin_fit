# Side Lunge — front view: standing, then deep lateral lunge to the right.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: standing tall, feet hip width.
s.add(FrontFigure(
    pelvis=(280, 370),
    l_upper_arm=-112, l_forearm=-105,
    r_upper_arm=-68, r_forearm=-75,
    l_thigh=-96, r_thigh=-84,
    highlights=HL,
))

# Pose B: deep side lunge — right leg bent, left leg extended sideways.
s.add(FrontFigure(
    pelvis=(720, 450),
    l_upper_arm=182, l_forearm=182,     # arms out for balance
    r_upper_arm=-2, r_forearm=-2,
    l_thigh=-142, l_shin=-142,          # straight leg out to the side
    r_thigh=-15, r_shin=-100,           # bent leg, shin vertical
    highlights=HL,
))

s.chevrons(505, 260)
# pelvis drops down-and-sideways into the lunge
s.arrow((475, 340), (515, 445), curve=18)

s.save("legs_009")
