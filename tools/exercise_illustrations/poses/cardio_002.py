# High Knees — side view running in place, alternating knees driven up high.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3}

# Pose A: near knee driven up high, far leg standing.
s.add(SideFigure(
    pelvis=(300, 380),
    torso=92, head=90,
    upper_arm=-125, forearm=-45,        # near arm back, elbow bent
    far_upper_arm=-50, far_forearm=25,  # far arm swings forward
    thigh=25, shin=-65, foot=-20,       # near knee high in front
    far_thigh=-90, far_shin=-90, far_foot=0,
    highlights=HL,
))

# Pose B: legs alternate — near leg standing, far knee up.
s.add(SideFigure(
    pelvis=(770, 380),
    torso=92, head=90,
    upper_arm=-50, forearm=25,          # near arm forward
    far_upper_arm=-125, far_forearm=-45,
    thigh=-90, shin=-90, foot=0,
    far_thigh=25, far_shin=-65, far_foot=-20,
    highlights=HL,
))

s.chevrons(520, 290)
# knee drives up in front of pose A
s.arrow((460, 450), (445, 310), curve=-35)
# and again on pose B (far knee)
s.arrow((930, 450), (915, 310), curve=-35)

s.pulse_icon()
s.save("cardio_002")
