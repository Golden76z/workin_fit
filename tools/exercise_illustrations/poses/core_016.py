# Windshield Wipers — top view (lying on back): legs together sweep side to side.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

# Top-down view of the lying body: no ground line, no snapping.
s = Scene(ground=False)
HL = {"abs": 3, "obliques": 2}

# Pose A: arms out in a T for support, straight legs swept to the viewer-left.
s.add(FrontFigure(
    pelvis=(300, 330),
    torso=90,
    l_upper_arm=175, l_forearm=178,
    r_upper_arm=5, r_forearm=2,
    l_thigh=-128, l_shin=-128,
    r_thigh=-122, r_shin=-122,
    snap=False,
    highlights=HL,
))

# Pose B: legs swept to the viewer-right.
s.add(FrontFigure(
    pelvis=(770, 330),
    torso=90,
    l_upper_arm=175, l_forearm=178,
    r_upper_arm=5, r_forearm=2,
    l_thigh=-58, l_shin=-58,
    r_thigh=-52, r_shin=-52,
    snap=False,
    highlights=HL,
))

s.chevrons(538, 280)
# feet sweep across in an arc
s.arrow((700, 500), (860, 500), curve=45)

s.save("core_016")
