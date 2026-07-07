# Burpees — plank/push-up position on the left, explosive jump on the right.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "quads": 2, "shoulders": 2}

# Pose A: plank / push-up position.
s.add(SideFigure(
    pelvis=(280, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: airborne jump, arms overhead, body extended.
s.add(SideFigure(
    pelvis=(790, 330),
    torso=92, head=95,
    upper_arm=105, forearm=95,          # arms reach overhead
    thigh=-85, shin=-95, foot=-45,      # toes pointed
    snap=True, clearance=70,
    highlights=HL,
))

s.chevrons(520, 290)
# explode upward next to pose B
s.arrow((650, 460), (680, 200), curve=-40)

s.pulse_icon()
s.save("cardio_004")
