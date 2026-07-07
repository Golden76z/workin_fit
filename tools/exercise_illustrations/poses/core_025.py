# Standing Side Crunch — front view: standing tall, then crunching to the side.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"obliques": 3, "abs": 2}

# Pose A: standing tall, hands behind the head, elbows out.
s.add(FrontFigure(
    pelvis=(300, 370),
    torso=90,
    l_upper_arm=160, l_forearm=55,
    r_upper_arm=20, r_forearm=125,
    l_thigh=-95, r_thigh=-85,
    highlights=HL,
))

# Pose B: torso tilted to the (viewer-)right, elbow driving toward the hip.
s.add(FrontFigure(
    pelvis=(760, 370),
    torso=68,
    l_upper_arm=140, l_forearm=35,
    r_upper_arm=-62, r_forearm=105,
    l_thigh=-95, r_thigh=-85,
    highlights=HL,
))

s.chevrons(530, 260)
# torso bends sideways
s.arrow((900, 170), (960, 260), curve=-30)

s.save("core_025")
