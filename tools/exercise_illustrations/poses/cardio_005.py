# Skater Jumps — front view lateral hops, landing on one leg with the other
# swept behind, then the mirror on the other side.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2}

# Pose A: landed on viewer-left leg, right leg swept behind, leaning left.
s.add(FrontFigure(
    pelvis=(300, 390),
    torso=100,                          # slight lean toward viewer-left
    l_upper_arm=-160, l_forearm=-140,   # left arm out for balance
    r_upper_arm=-45, r_forearm=-10,     # right arm swings across
    l_thigh=-100, l_shin=-78,           # weight leg, knee bent to absorb landing
    r_thigh=-135, r_shin=-152,          # trailing leg swept across behind
    highlights=HL,
))

# Pose B: mirror — landed on viewer-right leg.
s.add(FrontFigure(
    pelvis=(770, 390),
    torso=80,
    l_upper_arm=-135, l_forearm=-170,
    r_upper_arm=-20, r_forearm=-40,
    l_thigh=-45, l_shin=-28,
    r_thigh=-80, r_shin=-102,
    highlights=HL,
))

s.chevrons(520, 330)
# lateral hop arc from pose A to pose B
s.arrow((420, 250), (650, 250), curve=-55)

s.pulse_icon()
s.save("cardio_005")
