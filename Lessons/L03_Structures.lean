/-
L03 · structure：把数据打包，以及点号是怎么工作的

为什么学这个：
到现在函数只能收发单个值。`structure` 把几个带名字的字段打包成一个新类型。
它在 Lean 里的地位比 Rust 的 struct 更重：
后面的类型类（type class）和 Mathlib 里的「群」「向量空间」，全都是 structure。

检查：`lake env lean Lessons/L03_Structures.lean`
-/

-- ## 1. 定义

structure Vec2 where
  x : Float
  y : Float
deriving Repr     -- 让 `#eval` 能把它打印出来，类似 Rust 的 `#[derive(Debug)]`

#check Vec2       -- Vec2 : Type     ← 一个新的类型，和 `Nat` 平起平坐

-- ## 2. 构造：三种写法，结果相同

def v1 : Vec2 := { x := 3, y := 4 }   -- 按字段名
def v2 : Vec2 := Vec2.mk 3 4          -- 构造函数
def v3 : Vec2 := ⟨3, 4⟩               -- 匿名构造：输入 \< 和 \>，类型已知时可用

#eval v1          -- { x := 3.000000, y := 4.000000 }

-- 构造函数和字段访问器都只是普通函数，`structure` 替你自动生成了它们：
#check (Vec2.mk)  -- Vec2.mk : Float → Float → Vec2
#check (Vec2.x)   -- Vec2.x : Vec2 → Float

-- ## 3. 点号：`v.f` 就是 `Vec2.f v`
-- 没有 `impl`，没有 `self`，没有 `class`。
-- 只要一个函数的名字以 `Vec2.` 开头，就能用点号在 `Vec2` 的值上调用。

#eval v1.x        -- 3.000000
#eval Vec2.x v1   -- 3.000000    和上一行是同一个东西

def Vec2.add (a b : Vec2) : Vec2 :=
  { x := a.x + b.x, y := a.y + b.y }

#eval v1.add v2        -- { x := 6.000000, y := 8.000000 }
#eval Vec2.add v1 v2   -- 同上

-- 点号左边的值，填进「第一个类型是 Vec2 的参数」，不一定是第一个参数：
def Vec2.scale (k : Float) (v : Vec2) : Vec2 :=
  ⟨k * v.x, k * v.y⟩

#eval v1.scale 2       -- { x := 6.000000, y := 8.000000 }    即 Vec2.scale 2 v1

-- ## 4. 「修改」：值不可变，`with` 造一个新的

def v4 : Vec2 := { v1 with y := 0 }

#eval v4          -- { x := 3.000000, y := 0.000000 }
#eval v1          -- { x := 3.000000, y := 4.000000 }    原来的没变

/-
## 练习

让底部的 `#guard` 全部通过。

(a) `Vec2.dot`：两个向量的点积。

(b) `Particle`：一个 structure，两个字段，顺序是
    `mass`（质量，`Float`）和 `vel`（速度，`Vec2`）。

(c) `Particle.kineticEnergy`：动能 ½m|v|²。要求用上 (a)。

(d) `Particle.boost`：接收一个粒子和一个速度增量 `dv : Vec2`，
    返回速度加上 `dv` 之后的新粒子，质量不变。
    要求用 `with`，并且用上 `Vec2.add`。

思考题（把回答写成注释）：
`#check (Particle.kineticEnergy)` 的类型是什么？
Particle → Float
那么 Lean 里的「方法」和 L01 的普通函数有区别吗？
No difference, just input structure and output structure
-/

-- 在这里写你的定义 ↓
def Vec2.dot (a b : Vec2) : Float := a.x * b.x + a.y * b.y
structure Particle where
  mass : Float
  vel : Vec2
deriving Repr

def Particle.kineticEnergy (p : Particle) : Float := 0.5 * p.mass * ( p.vel.dot p.vel )
def Particle.boost (p : Particle) (dv : Vec2) : Particle := {p with vel := p.vel.add dv}

-- 测试（不要改）
#guard Vec2.dot ⟨1, 2⟩ ⟨3, 4⟩ == 11
#guard (Particle.mk 2 ⟨3, 4⟩).kineticEnergy == 25
#guard ((Particle.mk 2 ⟨3, 4⟩).boost ⟨1, 1⟩).vel.x == 4
#guard ((Particle.mk 2 ⟨3, 4⟩).boost ⟨1, 1⟩).mass == 2
#check (Particle.kineticEnergy)
