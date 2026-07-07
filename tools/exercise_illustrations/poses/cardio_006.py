# Star Jumps — front view: crouch, then explode into an airborne star shape.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"shoulders": 3, "calves": 2}

# Pose A: crouched, knees bent out, arms down in front.
s.add(FrontFigure(
    pelvis=(300, 440),
    l_upper_arm=-110, l_forearm=-85,
    r_upper_arm=-70, r_forearm=-95,
    l_thigh=-115, l_shin=-80,
    r_thigh=-65, r_shin=-100,
    highlights=HL,
))

# Pose B: airborne star — arms and legs spread wide, off the ground.
s.add(FrontFigure(
    pelvis=(770, 350),
    l_upper_arm=145, l_forearm=150,
    r_upper_arm=35, r_forearm=30,
    l_thigh=-130, l_shin=-135,
    r_thigh=-50, r_shin=-45,
    clearance=60,
    highlights=HL,
))

s.chevrons(520, 290)
# explode upward on both sides of pose B
s.arrow((620, 420), (600, 220), curve=-35)
s.arrow((920, 420), (940, 220), curve=35)

s.pulse_icon()
s.save("cardio_006")
