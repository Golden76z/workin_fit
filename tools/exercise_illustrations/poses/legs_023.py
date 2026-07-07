# Cossack Squat — front view: wide stance, then a deep lateral squat over one
# leg with the other leg extended straight out to the side.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: wide stance, arms relaxed at sides.
s.add(FrontFigure(
    pelvis=(300, 370),
    l_upper_arm=-108, l_forearm=-104,
    r_upper_arm=-72, r_forearm=-76,
    l_thigh=-112, l_shin=-102,
    r_thigh=-68, r_shin=-78,
    highlights=HL,
))

# Pose B: sitting deep over the viewer-left leg, viewer-right leg extended
# straight sideways, hands together in front for balance.
s.add(FrontFigure(
    pelvis=(730, 470),
    l_upper_arm=-125, l_forearm=-55,
    r_upper_arm=-55, r_forearm=-125,
    l_thigh=-185, l_shin=-88,
    r_thigh=-25, r_shin=-25,
    highlights=HL,
))

s.chevrons(520, 280)
# hips shift sideways and down over the bent leg
s.arrow((625, 280), (585, 385), curve=25)

s.save("legs_023")
