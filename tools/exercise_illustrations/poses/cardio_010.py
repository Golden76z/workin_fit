# Jump Rope (No Rope) — front view: ready on balls of feet, then light hop,
# elbows tucked and forearms out as if spinning a rope.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"calves": 3}

# Pose A: standing, elbows at the ribs, forearms angled out-down (rope hands).
s.add(FrontFigure(
    pelvis=(300, 370),
    l_upper_arm=-100, l_forearm=-155,
    r_upper_arm=-80, r_forearm=-25,
    l_thigh=-93, l_shin=-91,
    r_thigh=-87, r_shin=-89,
    highlights=HL,
))

# Pose B: light hop — airborne, knees slightly bent, same rope hands.
s.add(FrontFigure(
    pelvis=(770, 370),
    l_upper_arm=-100, l_forearm=-155,
    r_upper_arm=-80, r_forearm=-25,
    l_thigh=-97, l_shin=-85,
    r_thigh=-83, r_shin=-95,
    clearance=42,
    highlights=HL,
))

s.chevrons(535, 300)
# small wrist-circle cues + hop arrow
s.arrow((640, 470), (655, 415), curve=-14)
s.arrow((905, 470), (890, 415), curve=14)

s.pulse_icon()
s.save("cardio_010")
