# Sprawl — standing, then hips drop back and legs shoot out to a plank (no push-up).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "shoulders": 2, "abs": 2}

# Pose A: standing tall, ready.
s.add(SideFigure(
    pelvis=(280, 370),
    torso=90, upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
))

# Pose B: plank on hands, legs shot back.
s.add(SideFigure(
    pelvis=(800, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

s.chevrons(510, 300)
# motion: drop down, then feet shoot back (toward the left, behind the legs)
s.arrow((610, 250), (580, 400), curve=35)
s.arrow((760, 380), (630, 460), curve=-30)

s.pulse_icon()
s.save("cardio_017")
