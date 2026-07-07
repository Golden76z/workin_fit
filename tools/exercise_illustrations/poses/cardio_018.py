# Power Skips — exaggerated skip: push-off, then airborne with explosive knee drive
# and big opposite arm swing.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2}

# Pose A: skip stride — standing leg planted, other leg trailing on the toe,
# arms in running swing.
s.add(SideFigure(
    pelvis=(270, 370),
    torso=88, head=92,
    upper_arm=-55, forearm=10,
    far_upper_arm=-115, far_forearm=-160,
    thigh=-90, shin=-90, foot=0,
    far_thigh=-118, far_shin=-112, far_foot=-40,
    highlights=HL,
))

# Pose B: airborne — knee driven high, arm punched up, push leg extended below.
s.add(SideFigure(
    pelvis=(770, 300),
    torso=85, head=95,
    upper_arm=-15, forearm=55,
    far_upper_arm=-125, far_forearm=-70,
    thigh=25, shin=-70, foot=-15,
    far_thigh=-100, far_shin=-85, far_foot=-40,
    clearance=70,
    highlights=HL,
))

s.chevrons(510, 290)
# explosive vertical drive
s.arrow((950, 430), (960, 210), curve=-25)

s.pulse_icon()
s.save("cardio_018")
