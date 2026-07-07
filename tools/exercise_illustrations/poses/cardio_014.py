# Dancing in Place — front view: freestyle groove, two mirrored dance poses
# (one arm up, hips shifted), no muscle highlight (cardio only).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()

# Pose A: left arm punched up, right arm out low, right knee popped.
s.add(FrontFigure(
    pelvis=(300, 370),
    torso=99,
    l_upper_arm=135, l_forearm=115,
    r_upper_arm=-25, r_forearm=-5,
    l_thigh=-98, l_shin=-88,
    r_thigh=-62, r_shin=-100,
))

# Pose B: mirrored — right arm up, left arm out, left knee popped.
s.add(FrontFigure(
    pelvis=(770, 370),
    torso=81,
    l_upper_arm=205, l_forearm=185,
    r_upper_arm=45, r_forearm=65,
    l_thigh=-118, l_shin=-80,
    r_thigh=-82, r_shin=-92,
))

s.chevrons(535, 300)
# sway cues: arcs suggesting side-to-side groove
s.arrow((240, 170), (300, 120), curve=-18)
s.arrow((930, 220), (890, 150), curve=20)

s.pulse_icon()
s.save("cardio_014")
