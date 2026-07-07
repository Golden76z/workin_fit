# Single Leg Deadlift — side view: standing tall, then hip hinge with rear leg lifted.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"hamstrings": 3, "glutes": 2, "lowerBack": 2}

# Pose A: standing tall, arms at sides.
s.add(SideFigure(
    pelvis=(300, 370),
    torso=90, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
))

# Pose B: hinged at the hip, torso near horizontal, rear leg extended behind,
# arms reaching toward the floor. Belly faces down in the hinge, so front_hint
# points downward — this keeps the hamstring stripe on the UPPER (posterior)
# edge of the raised rear thigh.
s.add(SideFigure(
    pelvis=(760, 400),
    torso=15, head=15,
    upper_arm=-80, forearm=-85,
    thigh=-85, shin=-88, foot=0,
    far_thigh=160, far_shin=162, far_foot=150,
    front_hint=(0.35, 1),
    highlights=HL,
))

s.chevrons(520, 280)
# rear leg rises as the torso hinges forward
s.arrow((680, 480), (610, 360), curve=25)

s.save("legs_018")
