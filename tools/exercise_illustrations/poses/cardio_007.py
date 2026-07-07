# Tuck Jumps — side view: quarter-squat load, then airborne with knees to chest.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "calves": 2, "abs": 2}

# Pose A: loading quarter squat, arms swung back.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=70, head=80,
    upper_arm=-130, forearm=-115,
    thigh=-55, shin=-110, foot=0,
    highlights=HL,
))

# Pose B: airborne tuck — knees driven to the chest.
s.add(SideFigure(
    pelvis=(790, 330),
    torso=85, head=80,
    upper_arm=-50, forearm=-5,          # arms wrap forward toward the shins
    thigh=52, shin=-80, foot=-40,       # knees driven up toward the chest
    clearance=90,
    highlights=HL,
))

s.chevrons(520, 290)
# explode upward next to pose B
s.arrow((650, 480), (670, 220), curve=-40)

s.pulse_icon()
s.save("cardio_007")
