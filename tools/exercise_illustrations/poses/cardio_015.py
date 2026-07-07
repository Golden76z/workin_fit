# Jumping Lunges — side view: lunge with left leg forward, hop, land with
# legs switched (right leg forward) — the switch shown by an over-arc arrow.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2}

# Pose A: lunge, NEAR leg forward, far knee low behind.
s.add(SideFigure(
    pelvis=(280, 420),
    torso=86, head=84,
    upper_arm=-60, forearm=25,
    far_upper_arm=-118, far_forearm=-155,
    thigh=-28, shin=-88, foot=0,
    far_thigh=-115, far_shin=-10, far_foot=-78,
    highlights=HL,
))

# Pose B: landed with legs switched — FAR leg forward, near knee low behind.
s.add(SideFigure(
    pelvis=(760, 420),
    torso=86, head=84,
    upper_arm=-118, forearm=-155,
    far_upper_arm=-60, far_forearm=25,
    thigh=-115, shin=-10, foot=-78,
    far_thigh=-28, far_shin=-88, far_foot=0,
    highlights=HL,
))

s.chevrons(510, 300)
# scissor-switch: legs trade places over a hop (cycle drawn between the poses)
s.arrow((445, 475), (575, 475), curve=-42)
s.arrow((575, 425), (445, 425), curve=-42)

s.pulse_icon()
s.save("cardio_015")
