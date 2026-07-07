"""SVG drawing toolkit for exercise tutorial illustrations.

Style contract (must match the app's muscle-atlas look):
  - canvas 1080x608, background #111111 (AppColors.mediaCanvas)
  - body silhouette in atlas gray #BDBDBD, far-side limbs darker for depth
  - worked muscle zones highlighted in brand purple #5E2BFF
    (level 3 = 1.0, level 2 = 0.68, level 1 = 0.38 — same as MuscleActivationLevel)
  - motion arrows in near-white, pose-transition chevrons in purple
  - no text of any kind inside the image

Angle convention: degrees, 0 = pointing right (+x), 90 = pointing UP.
Figures are designed facing right; pass facing=-1 to mirror.
"""

from __future__ import annotations

import math
import os
import subprocess

# ---------------------------------------------------------------- palette

BG = "#111111"
BODY = "#BDBDBD"
BODY_FAR = "#7F7F7F"
PURPLE = (0x5E, 0x2B, 0xFF)
ARROW = "#ECECEC"
PROP = "#3A3A3A"
PROP_EDGE = "#5A5A5A"
GROUND = "#333333"

LEVEL_ALPHA = {3: 1.0, 2: 0.68, 1: 0.38}

CANVAS_W, CANVAS_H = 1080, 608
GROUND_Y = 548.0


def _mix(rgb, base_hex, alpha):
    """Blend rgb over the hex base color with given alpha, return hex."""
    br = int(base_hex[1:3], 16)
    bg_ = int(base_hex[3:5], 16)
    bb = int(base_hex[5:7], 16)
    r = round(rgb[0] * alpha + br * (1 - alpha))
    g = round(rgb[1] * alpha + bg_ * (1 - alpha))
    b = round(rgb[2] * alpha + bb * (1 - alpha))
    return f"#{r:02X}{g:02X}{b:02X}"


def highlight_color(level, far=False):
    alpha = LEVEL_ALPHA.get(level, 1.0)
    base = BODY_FAR if far else BODY
    if far:
        alpha *= 0.55
    return _mix(PURPLE, base, alpha)


# ---------------------------------------------------------------- geometry

def _rad(deg):
    return math.radians(deg)


def step(p, angle_deg, dist):
    """Move from p in direction angle_deg (0=right, 90=up) by dist (SVG y-down)."""
    a = _rad(angle_deg)
    return (p[0] + math.cos(a) * dist, p[1] - math.sin(a) * dist)


def _unit(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    d = math.hypot(dx, dy) or 1.0
    return dx / d, dy / d


def _perp_front(a, b, hint):
    """Unit perpendicular of segment a->b closest to the front-hint vector.

    `hint` points toward the figure's belly: (1, 0) for standing facing right,
    (0, -1) for lying on the back (front = up), (0, 1) for prone positions.
    """
    ux, uy = _unit(a, b)
    p1 = (-uy, ux)
    p2 = (uy, -ux)
    d1 = p1[0] * hint[0] + p1[1] * hint[1]
    d2 = p2[0] * hint[0] + p2[1] * hint[1]
    return p1 if d1 >= d2 else p2


def _fmt(v):
    return f"{v:.1f}".rstrip("0").rstrip(".")


# ---------------------------------------------------------------- skeleton

# segment lengths (px at scale 1)
L = {
    "torso": 104.0,
    "neck": 12.0,
    "head_r": 21.0,
    "upper_arm": 62.0,
    "forearm": 58.0,
    "hand": 14.0,
    "thigh": 84.0,
    "shin": 80.0,
    "foot": 32.0,
}

# stroke widths
W = {
    "torso": 40.0,
    "neck": 13.0,
    "upper_arm": 19.0,
    "forearm": 15.0,
    "thigh": 27.0,
    "shin": 20.0,
    "foot": 12.0,
}


class _Fig:
    """Base: collects capsules + circles for body and highlight overlays."""

    def __init__(self, scale, facing, highlights, front_hint=None):
        self.scale = scale
        self.facing = facing
        self.front = front_hint or (facing, 0)
        self.highlights = highlights or {}
        self.body_near = []   # svg element strings
        self.body_far = []
        self.hl_near = []
        self.hl_far = []

    # pad below each joint = half width of the thickest part ending there
    _PADS = {
        "toe": 8, "far_toe": 8, "ankle": 10, "far_ankle": 10,
        "knee": 13.5, "far_knee": 13.5, "hand": 7.5, "far_hand": 7.5,
        "wrist": 7.5, "far_wrist": 7.5, "elbow": 9.5, "far_elbow": 9.5,
        "pelvis": 21, "hip": 21, "l_hip": 15, "r_hip": 15,
        "shoulder": 10, "l_shoulder": 15, "r_shoulder": 15,
        "neck": 6, "head": 21,
        "l_knee": 13.5, "r_knee": 13.5, "l_ankle": 15, "r_ankle": 15,
        "l_elbow": 9.5, "r_elbow": 9.5, "l_wrist": 7.5, "r_wrist": 7.5,
    }

    def _snap(self, joints, ground_y, clearance):
        """Shift all joints so the lowest body point rests on ground_y."""
        lowest = max(
            pt[1] + self._PADS.get(name, 8) * self.scale
            for name, pt in joints.items() if pt is not None
        )
        dy = ground_y - clearance - lowest
        return {
            name: ((pt[0], pt[1] + dy) if pt is not None else None)
            for name, pt in joints.items()
        }

    # -- primitives --------------------------------------------------------
    def _cap(self, out, a, b, w, color):
        out.append(
            f'<line x1="{_fmt(a[0])}" y1="{_fmt(a[1])}" x2="{_fmt(b[0])}" '
            f'y2="{_fmt(b[1])}" stroke="{color}" stroke-width="{_fmt(w)}" '
            f'stroke-linecap="round"/>'
        )

    def _dot(self, out, c, r, color):
        out.append(
            f'<circle cx="{_fmt(c[0])}" cy="{_fmt(c[1])}" r="{_fmt(r)}" '
            f'fill="{color}"/>'
        )

    # -- highlight helpers --------------------------------------------------
    def _hl_capsule(self, out, level, far, j1, j2, side, off, width, m1, m2):
        """Capsule along j1->j2, trimmed by margins, offset to front/back/center."""
        s = self.scale
        ux, uy = _unit(j1, j2)
        a = (j1[0] + ux * m1 * s, j1[1] + uy * m1 * s)
        b = (j2[0] - ux * m2 * s, j2[1] - uy * m2 * s)
        if side != 0:
            px, py = _perp_front(j1, j2, self.front)
            a = (a[0] + px * off * s * side, a[1] + py * off * s * side)
            b = (b[0] + px * off * s * side, b[1] + py * off * s * side)
        self._cap(out, a, b, width * s, highlight_color(level, far))

    def _hl_dot(self, out, level, far, c, r):
        self._dot(out, c, r * self.scale, highlight_color(level, far))


class SideFigure(_Fig):
    """Profile-view figure. All angles absolute (0=right, 90=up).

    Far-side limbs default to slightly offset copies of the near limbs; pass
    explicit far_* angles when the two sides differ (lunges, climbers...).
    """

    def __init__(
        self,
        pelvis,
        torso=90.0,
        head=None,
        upper_arm=-90.0,
        forearm=None,
        thigh=-90.0,
        shin=None,
        foot=0.0,
        far_upper_arm=None,
        far_forearm=None,
        far_thigh=None,
        far_shin=None,
        far_foot=None,
        facing=1,
        scale=1.0,
        highlights=None,
        far_limbs=True,
        snap=True,
        ground_y=GROUND_Y,
        clearance=0.0,
        head_offset=None,
        front_hint=None,
    ):
        super().__init__(scale, facing, highlights, front_hint)
        s = scale
        forearm = upper_arm if forearm is None else forearm
        shin = thigh if shin is None else shin
        head = torso if head is None else head

        pelvis = tuple(map(float, pelvis))
        neck = step(pelvis, torso, L["torso"] * s)
        head_c = step(step(neck, head, L["neck"] * s), head, (L["head_r"] + 2) * s)
        if head_offset:
            head_c = (head_c[0] + head_offset[0] * s, head_c[1] + head_offset[1] * s)
        shoulder = step(neck, torso, -8 * s)  # slightly below neck point
        elbow = step(shoulder, upper_arm, L["upper_arm"] * s)
        wrist = step(elbow, forearm, L["forearm"] * s)
        hand = step(wrist, forearm, L["hand"] * s)
        hip = pelvis
        knee = step(hip, thigh, L["thigh"] * s)
        ankle = step(knee, shin, L["shin"] * s)
        toe = step(ankle, foot, L["foot"] * s) if foot is not None else None

        j = {
            "pelvis": pelvis, "neck": neck, "head": head_c, "shoulder": shoulder,
            "elbow": elbow, "wrist": wrist, "hand": hand, "hip": hip,
            "knee": knee, "ankle": ankle, "toe": toe,
        }

        # ---- far limbs (kept behind; invisible unless angles differ) ----
        self._has_far = far_limbs
        if far_limbs:
            fua = upper_arm if far_upper_arm is None else far_upper_arm
            ffa = (forearm if far_forearm is None else far_forearm)
            fth = thigh if far_thigh is None else far_thigh
            fsh = (shin if far_shin is None else far_shin)
            fft = foot if far_foot is None else far_foot
            f_el = step(shoulder, fua, L["upper_arm"] * s)
            f_wr = step(f_el, ffa, L["forearm"] * s)
            f_hd = step(f_wr, ffa, L["hand"] * s)
            f_kn = step(hip, fth, L["thigh"] * s)
            f_an = step(f_kn, fsh, L["shin"] * s)
            f_toe = step(f_an, fft, L["foot"] * s) if fft is not None else None
            j.update({"far_elbow": f_el, "far_wrist": f_wr, "far_hand": f_hd,
                      "far_knee": f_kn, "far_ankle": f_an, "far_toe": f_toe})

        if snap:
            j = self._snap(j, ground_y, clearance)
        self.j = j

        # ---- draw: far limbs first ----
        if far_limbs:
            o = self.body_far
            self._cap(o, j["hip"], j["far_knee"], W["thigh"] * s, BODY_FAR)
            self._cap(o, j["far_knee"], j["far_ankle"], W["shin"] * s, BODY_FAR)
            if j["far_toe"]:
                self._cap(o, j["far_ankle"], j["far_toe"], W["foot"] * s, BODY_FAR)
            self._cap(o, j["shoulder"], j["far_elbow"], W["upper_arm"] * s, BODY_FAR)
            self._cap(o, j["far_elbow"], j["far_wrist"], W["forearm"] * s, BODY_FAR)
            self._dot(o, j["far_hand"], 7 * s, BODY_FAR)
            self._far_joints = (j["shoulder"], j["far_elbow"], j["far_wrist"],
                                j["hip"], j["far_knee"], j["far_ankle"])
        else:
            self._far_joints = None

        # ---- torso + head ----
        t = self.body_near
        self._cap(t, j["pelvis"], j["neck"], W["torso"] * s, BODY)
        tu = _unit(j["pelvis"], j["neck"])
        chest = (j["pelvis"][0] + tu[0] * L["torso"] * 0.74 * s,
                 j["pelvis"][1] + tu[1] * L["torso"] * 0.74 * s)
        self._dot(t, chest, 22 * s, BODY)
        self._dot(t, j["pelvis"], 20.5 * s, BODY)
        neck_end = (j["neck"][0] + (j["head"][0] - j["neck"][0]) * 0.5,
                    j["neck"][1] + (j["head"][1] - j["neck"][1]) * 0.5)
        self._cap(t, j["neck"], neck_end, W["neck"] * s, BODY)
        self._dot(t, j["head"], L["head_r"] * s, BODY)

        # ---- near limbs ----
        n = self.body_near
        self._cap(n, j["hip"], j["knee"], W["thigh"] * s, BODY)
        self._cap(n, j["knee"], j["ankle"], W["shin"] * s, BODY)
        if j["toe"]:
            self._cap(n, j["ankle"], j["toe"], W["foot"] * s, BODY)
        self._cap(n, j["shoulder"], j["elbow"], W["upper_arm"] * s, BODY)
        self._cap(n, j["elbow"], j["wrist"], W["forearm"] * s, BODY)
        self._dot(n, j["hand"], 7.5 * s, BODY)

        self._emit_highlights()

    # ------------------------------------------------------------------
    def _emit_highlights(self):
        j = self.j
        torso_pair = (j["pelvis"], j["neck"])

        def torso_pt(t):
            return (
                j["pelvis"][0] + (j["neck"][0] - j["pelvis"][0]) * t,
                j["pelvis"][1] + (j["neck"][1] - j["pelvis"][1]) * t,
            )

        for group, level in self.highlights.items():
            near, far = self.hl_near, self.hl_far
            if group == "quads":
                self._hl_capsule(near, level, False, j["hip"], j["knee"], +1, 7.5, 13, 14, 15)
                if self._far_joints:
                    self._hl_capsule(far, level, True, self._far_joints[3], self._far_joints[4], +1, 7.5, 13, 14, 15)
            elif group == "hamstrings":
                self._hl_capsule(near, level, False, j["hip"], j["knee"], -1, 7.5, 12, 15, 16)
                if self._far_joints:
                    self._hl_capsule(far, level, True, self._far_joints[3], self._far_joints[4], -1, 7.5, 12, 15, 16)
            elif group == "calves":
                self._hl_capsule(near, level, False, j["knee"], j["ankle"], -1, 5.5, 9, 13, 18)
                if self._far_joints:
                    self._hl_capsule(far, level, True, self._far_joints[4], self._far_joints[5], -1, 5.5, 9, 13, 18)
            elif group == "glutes":
                px, py = _perp_front(*torso_pair, self.front)
                c = torso_pt(0.04)
                c = (c[0] - px * 12 * self.scale, c[1] - py * 12 * self.scale)
                self._hl_dot(near, level, False, c, 13)
            elif group == "abs":
                self._hl_capsule(near, level, False, torso_pt(0.18), torso_pt(0.60), +1, 10, 13, 0, 0)
            elif group == "obliques":
                self._hl_capsule(near, level, False, torso_pt(0.30), torso_pt(0.58), +1, 2, 11, 0, 0)
            elif group == "chest":
                self._hl_capsule(near, level, False, torso_pt(0.56), torso_pt(0.88), +1, 12, 17, 0, 0)
            elif group == "back":
                self._hl_capsule(near, level, False, torso_pt(0.48), torso_pt(0.86), -1, 10, 14, 0, 0)
            elif group == "lowerBack":
                self._hl_capsule(near, level, False, torso_pt(0.10), torso_pt(0.42), -1, 10, 12, 0, 0)
            elif group == "shoulders":
                self._hl_dot(near, level, False, j["shoulder"], 12)
            elif group == "biceps":
                self._hl_capsule(near, level, False, j["shoulder"], j["elbow"], +1, 4.5, 8.5, 12, 12)
            elif group == "triceps":
                self._hl_capsule(near, level, False, j["shoulder"], j["elbow"], -1, 4.5, 8.5, 12, 12)
            elif group == "forearms":
                self._hl_capsule(near, level, False, j["elbow"], j["wrist"], 0, 0, 8, 10, 8)
            # 'cardio' has no drawable zone


class FrontFigure(_Fig):
    """Front-view figure; l_* = viewer-left limbs, r_* = viewer-right limbs."""

    def __init__(
        self,
        pelvis,
        torso=90.0,
        l_upper_arm=-115.0, l_forearm=None,
        r_upper_arm=-65.0, r_forearm=None,
        l_thigh=-98.0, l_shin=None,
        r_thigh=-82.0, r_shin=None,
        scale=1.0,
        highlights=None,
        snap=True,
        ground_y=GROUND_Y,
        clearance=0.0,
    ):
        super().__init__(scale, 1, highlights)
        s = scale
        l_forearm = l_upper_arm if l_forearm is None else l_forearm
        r_forearm = r_upper_arm if r_forearm is None else r_forearm
        l_shin = l_thigh if l_shin is None else l_shin
        r_shin = r_thigh if r_shin is None else r_shin

        pelvis = tuple(map(float, pelvis))
        neck = step(pelvis, torso, L["torso"] * s)
        head_c = step(neck, torso, (L["neck"] + L["head_r"] + 4) * s)
        # shoulders splayed
        sh_off = 27 * s
        px, py = _perp_front(pelvis, neck, (1, 0))
        n2 = step(neck, torso, -6 * s)
        l_sh = (n2[0] - px * sh_off, n2[1] - py * sh_off)
        r_sh = (n2[0] + px * sh_off, n2[1] + py * sh_off)
        hip_off = 13 * s
        l_hip = (pelvis[0] - px * hip_off, pelvis[1] - py * hip_off)
        r_hip = (pelvis[0] + px * hip_off, pelvis[1] + py * hip_off)

        l_el = step(l_sh, l_upper_arm, L["upper_arm"] * s)
        l_wr = step(l_el, l_forearm, L["forearm"] * s)
        l_hd = step(l_wr, l_forearm, L["hand"] * s)
        r_el = step(r_sh, r_upper_arm, L["upper_arm"] * s)
        r_wr = step(r_el, r_forearm, L["forearm"] * s)
        r_hd = step(r_wr, r_forearm, L["hand"] * s)
        l_kn = step(l_hip, l_thigh, L["thigh"] * s)
        l_an = step(l_kn, l_shin, L["shin"] * s)
        r_kn = step(r_hip, r_thigh, L["thigh"] * s)
        r_an = step(r_kn, r_shin, L["shin"] * s)

        j = {
            "pelvis": pelvis, "neck": neck, "head": head_c,
            "l_shoulder": l_sh, "r_shoulder": r_sh,
            "l_elbow": l_el, "r_elbow": r_el,
            "l_wrist": l_wr, "r_wrist": r_wr,
            "l_hand": l_hd, "r_hand": r_hd,
            "l_hip": l_hip, "r_hip": r_hip,
            "l_knee": l_kn, "r_knee": r_kn,
            "l_ankle": l_an, "r_ankle": r_an,
        }
        if snap:
            j = self._snap(j, ground_y, clearance)
        self.j = j
        pelvis, neck, head_c = j["pelvis"], j["neck"], j["head"]
        l_sh, r_sh = j["l_shoulder"], j["r_shoulder"]
        l_el, r_el = j["l_elbow"], j["r_elbow"]
        l_wr, r_wr = j["l_wrist"], j["r_wrist"]
        l_hd, r_hd = j["l_hand"], j["r_hand"]
        l_hip, r_hip = j["l_hip"], j["r_hip"]
        l_kn, r_kn = j["l_knee"], j["r_knee"]
        l_an, r_an = j["l_ankle"], j["r_ankle"]
        n2 = step(neck, torso, -6 * s)

        t = self.body_near
        # torso: trapezoid via overlapping capsules
        self._cap(t, l_sh, r_sh, 30 * s, BODY)
        self._cap(t, l_hip, r_hip, 30 * s, BODY)
        self._cap(t, pelvis, n2, 52 * s, BODY)
        self._cap(t, neck, step(neck, torso, L["neck"] * s), W["neck"] * s, BODY)
        self._dot(t, head_c, L["head_r"] * s, BODY)
        for sh, el, wr, hd in ((l_sh, l_el, l_wr, l_hd), (r_sh, r_el, r_wr, r_hd)):
            self._cap(t, sh, el, W["upper_arm"] * s, BODY)
            self._cap(t, el, wr, W["forearm"] * s, BODY)
            self._dot(t, hd, 7.5 * s, BODY)
        for hip, kn, an in ((l_hip, l_kn, l_an), (r_hip, r_kn, r_an)):
            self._cap(t, hip, kn, W["thigh"] * s, BODY)
            self._cap(t, kn, an, W["shin"] * s, BODY)
            # small foot ellipse
            f = step(an, -90, 6 * s)
            self._dot(t, f, 9 * s, BODY)

        self._emit_highlights()

    def _emit_highlights(self):
        j = self.j
        s = self.scale
        out = self.hl_near

        def mid(a, b, t):
            return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)

        for group, level in self.highlights.items():
            if group == "chest":
                for sh in ("l_shoulder", "r_shoulder"):
                    c = mid(j[sh], j["pelvis"], 0.22)
                    self._hl_dot(out, level, False, c, 13)
            elif group == "abs":
                a = mid(j["pelvis"], j["neck"], 0.12)
                b = mid(j["pelvis"], j["neck"], 0.55)
                self._hl_capsule(out, level, False, a, b, 0, 0, 16, 0, 0)
            elif group == "obliques":
                for side in ("l", "r"):
                    a = mid(j[f"{side}_hip"], j[f"{side}_shoulder"], 0.25)
                    b = mid(j[f"{side}_hip"], j[f"{side}_shoulder"], 0.52)
                    self._hl_capsule(out, level, False, a, b, 0, 0, 9, 0, 0)
            elif group == "shoulders":
                for sh in ("l_shoulder", "r_shoulder"):
                    self._hl_dot(out, level, False, j[sh], 12)
            elif group in ("biceps", "triceps", "forearms"):
                for side in ("l", "r"):
                    if group == "forearms":
                        self._hl_capsule(out, level, False, j[f"{side}_elbow"], j[f"{side}_wrist"], 0, 0, 8, 10, 8)
                    else:
                        self._hl_capsule(out, level, False, j[f"{side}_shoulder"], j[f"{side}_elbow"], 0, 0, 9, 12, 12)
            elif group == "quads":
                for side in ("l", "r"):
                    self._hl_capsule(out, level, False, j[f"{side}_hip"], j[f"{side}_knee"], 0, 0, 13, 14, 15)
            elif group in ("hamstrings", "glutes"):
                for side in ("l", "r"):
                    self._hl_capsule(out, level, False, j[f"{side}_hip"], j[f"{side}_knee"], 0, 0, 11, 6, 40)
            elif group == "calves":
                for side in ("l", "r"):
                    self._hl_capsule(out, level, False, j[f"{side}_knee"], j[f"{side}_ankle"], 0, 0, 9, 13, 18)
            elif group in ("back", "lowerBack"):
                a = mid(j["pelvis"], j["neck"], 0.15 if group == "lowerBack" else 0.5)
                b = mid(j["pelvis"], j["neck"], 0.45 if group == "lowerBack" else 0.85)
                self._hl_capsule(out, level, False, a, b, 0, 0, 14, 0, 0)


# ---------------------------------------------------------------- scene

class Scene:
    def __init__(self, ground=True, ground_y=GROUND_Y):
        self.ground_y = ground_y
        self._pre = []    # props behind figures
        self._figs = []
        self._post = []   # arrows etc. on top
        if ground:
            self._pre.append(
                f'<line x1="60" y1="{_fmt(ground_y)}" x2="{CANVAS_W - 60}" '
                f'y2="{_fmt(ground_y)}" stroke="{GROUND}" stroke-width="5" '
                f'stroke-linecap="round"/>'
            )

    # -- figures ------------------------------------------------------------
    def add(self, fig):
        self._figs.append(fig)
        return fig

    # -- props (drawn behind figures) ---------------------------------------
    def box(self, x, y, w, h, rx=6):
        """Bench/step prop; (x, y) top-left."""
        self._pre.append(
            f'<rect x="{_fmt(x)}" y="{_fmt(y)}" width="{_fmt(w)}" height="{_fmt(h)}" '
            f'rx="{rx}" fill="{PROP}" stroke="{PROP_EDGE}" stroke-width="2"/>'
        )

    def wall(self, x, y0=60, y1=None):
        y1 = self.ground_y if y1 is None else y1
        self._pre.append(
            f'<line x1="{_fmt(x)}" y1="{_fmt(y0)}" x2="{_fmt(x)}" y2="{_fmt(y1)}" '
            f'stroke="{PROP_EDGE}" stroke-width="10" stroke-linecap="round"/>'
        )

    def bar(self, y, x0, x1, posts=True):
        """Pull-up bar with optional posts down to the ground."""
        if posts:
            for px_ in (x0, x1):
                self._pre.append(
                    f'<line x1="{_fmt(px_)}" y1="{_fmt(y)}" x2="{_fmt(px_)}" '
                    f'y2="{_fmt(self.ground_y)}" stroke="{PROP}" stroke-width="8"/>'
                )
        self._pre.append(
            f'<line x1="{_fmt(x0)}" y1="{_fmt(y)}" x2="{_fmt(x1)}" y2="{_fmt(y)}" '
            f'stroke="{PROP_EDGE}" stroke-width="9" stroke-linecap="round"/>'
        )

    def line(self, a, b, color=PROP_EDGE, width=6):
        self._pre.append(
            f'<line x1="{_fmt(a[0])}" y1="{_fmt(a[1])}" x2="{_fmt(b[0])}" '
            f'y2="{_fmt(b[1])}" stroke="{color}" stroke-width="{width}" '
            f'stroke-linecap="round"/>'
        )

    # -- annotations (on top) -------------------------------------------------
    def arrow(self, a, b, curve=0.0, color=ARROW, width=6.0):
        """Motion arrow from a to b; curve = perpendicular bow in px (+ = left of a->b)."""
        ax, ay = a
        bx, by = b
        mx, my = (ax + bx) / 2, (ay + by) / 2
        dx, dy = bx - ax, by - ay
        d = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / d, dx / d
        cx, cy = mx + nx * curve, my + ny * curve
        # arrowhead direction = tangent at end of quadratic
        tx, ty = bx - cx, by - cy
        td = math.hypot(tx, ty) or 1.0
        tx, ty = tx / td, ty / td
        hl = 3.2 * width  # head length
        hw = 2.1 * width
        base = (bx - tx * hl, by - ty * hl)
        left = (base[0] - ty * hw / 1.0, base[1] + tx * hw)
        right = (base[0] + ty * hw, base[1] - tx * hw)
        shaft_end = (bx - tx * hl * 0.85, by - ty * hl * 0.85)
        self._post.append(
            f'<path d="M {_fmt(ax)} {_fmt(ay)} Q {_fmt(cx)} {_fmt(cy)} '
            f'{_fmt(shaft_end[0])} {_fmt(shaft_end[1])}" stroke="{color}" '
            f'stroke-width="{_fmt(width)}" fill="none" stroke-linecap="round"/>'
        )
        self._post.append(
            f'<path d="M {_fmt(bx)} {_fmt(by)} L {_fmt(left[0])} {_fmt(left[1])} '
            f'L {_fmt(right[0])} {_fmt(right[1])} Z" fill="{color}"/>'
        )

    def chevrons(self, x, y, size=26, color=None):
        """Pose-transition marker '>>' in brand purple, centered at (x, y)."""
        color = color or _mix(PURPLE, BG, 0.9)
        for i in (0, 1):
            ox = x - size * 0.7 + i * size * 0.95
            self._post.append(
                f'<path d="M {_fmt(ox)} {_fmt(y - size)} L {_fmt(ox + size * 0.8)} '
                f'{_fmt(y)} L {_fmt(ox)} {_fmt(y + size)}" stroke="{color}" '
                f'stroke-width="9" fill="none" stroke-linecap="round" '
                f'stroke-linejoin="round"/>'
            )

    def pulse_icon(self, x=72, y=76, color=None):
        """Small heartbeat mark for cardio exercises (top-left corner)."""
        color = color or _mix(PURPLE, BG, 0.9)
        p = (
            f"M {x - 34} {y} L {x - 14} {y} L {x - 6} {y - 22} "
            f"L {x + 6} {y + 22} L {x + 14} {y} L {x + 34} {y}"
        )
        self._post.append(
            f'<path d="{p}" stroke="{color}" stroke-width="7" fill="none" '
            f'stroke-linecap="round" stroke-linejoin="round"/>'
        )

    # -- output ----------------------------------------------------------------
    def svg(self):
        parts = [
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{CANVAS_W}" '
            f'height="{CANVAS_H}" viewBox="0 0 {CANVAS_W} {CANVAS_H}">',
            f'<rect width="{CANVAS_W}" height="{CANVAS_H}" fill="{BG}"/>',
        ]
        parts.extend(self._pre)
        for f in self._figs:
            parts.extend(f.body_far)
            parts.extend(f.hl_far)
        for f in self._figs:
            parts.extend(f.body_near)
            parts.extend(f.hl_near)
        parts.extend(self._post)
        parts.append("</svg>")
        return "\n".join(parts)

    def save(self, exercise_id, out_dir=None):
        """Write out/<id>.svg and render out/<id>.png (1080x608)."""
        here = os.path.dirname(os.path.abspath(__file__))
        out_dir = out_dir or os.path.join(here, "out")
        os.makedirs(out_dir, exist_ok=True)
        svg_path = os.path.join(out_dir, f"{exercise_id}.svg")
        png_path = os.path.join(out_dir, f"{exercise_id}.png")
        with open(svg_path, "w") as fh:
            fh.write(self.svg())
        subprocess.run(
            ["rsvg-convert", "-w", str(CANVAS_W), "-h", str(CANVAS_H),
             svg_path, "-o", png_path],
            check=True,
        )
        return png_path
