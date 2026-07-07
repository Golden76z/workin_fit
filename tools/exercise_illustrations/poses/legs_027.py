# Sissy Squat Hold — isometric hold, one centered pose: lean back, knees forward,
# hips extended (knee-hip-shoulder in one line), heels raised on toes.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3}

s.add(SideFigure(
    pelvis=(520, 380),
    torso=112, head=105,
    upper_arm=-5, forearm=0,
    thigh=-68, shin=-122, foot=-35,
    scale=1.25,
    highlights=HL,
))

# effort cues: knees drive forward, shoulders lean back
s.arrow((620, 435), (690, 435))
s.arrow((400, 135), (342, 172), curve=-10)

s.save("legs_027")
