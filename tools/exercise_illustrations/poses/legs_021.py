# Sumo Squat — front view: wide stance standing, then deep wide squat with
# knees tracking out over the toes.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: wide stance, feet well outside the shoulders, arms relaxed at sides.
s.add(FrontFigure(
    pelvis=(300, 370),
    l_upper_arm=-108, l_forearm=-104,
    r_upper_arm=-72, r_forearm=-76,
    l_thigh=-108, l_shin=-100,
    r_thigh=-72, r_shin=-80,
    highlights=HL,
))

# Pose B: deep sumo squat, thighs spread wide, hands together in front of the chest.
s.add(FrontFigure(
    pelvis=(770, 460),
    l_upper_arm=-125, l_forearm=-55,
    r_upper_arm=-55, r_forearm=-125,
    l_thigh=-155, l_shin=-98,
    r_thigh=-25, r_shin=-82,
    highlights=HL,
))

s.chevrons(520, 280)
# hips sink straight down between the heels
s.arrow((955, 300), (940, 400), curve=-25)

s.save("legs_021")
