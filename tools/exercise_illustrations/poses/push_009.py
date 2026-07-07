# Archer Push-up — side view: wide plank top, then bottom shifted onto the
# bent (near) arm while the other arm stays straight, extended forward.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2}

# Pose A: plank top, arms extended under shoulders.
s.add(SideFigure(
    pelvis=(280, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom — near arm bent deep (loaded side), far arm straight,
# extended away with hand still on the floor.
s.add(SideFigure(
    pelvis=(750, 470),
    torso=5, head=14,
    upper_arm=188, forearm=-87,
    far_upper_arm=-37, far_forearm=-37,
    thigh=193, shin=196, foot=-100,
    highlights=HL,
))

s.chevrons(520, 280)
# lower onto the bent arm, then press back up
s.arrow((1010, 400), (1010, 490))
s.arrow((1050, 490), (1050, 400))

s.save("push_009")
