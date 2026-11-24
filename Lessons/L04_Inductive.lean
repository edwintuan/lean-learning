/-
L04 · inductive：「几种情况之一」，以及 match

为什么学这个：
`structure` 表达的是「同时有 A 和 B」。`inductive` 表达的是「要么是 A，要么是 B」。
这两样合起来，就能描述 Lean 里的全部数据：`Bool`、`Option`、`Nat`、`List`
都是用 `inductive` 定义出来的，不是内置的。后面的命题和证明也是。

检查：`lake env lean Lessons/L04_Inductive.lean`
-/

-- ## 1. 最简单的情况：枚举

inductive Phase where
  | solid
  | liquid
  | gas
deriving Repr

#check Phase.solid       -- Phase.solid : Phase
#eval Phase.gas          -- Phase.gas

-- ## 2. 用 `match` 消费它：每种情况给一个结果

def Phase.canFlow (p : Phase) : Bool :=
  match p with
  | Phase.solid  => false
  | Phase.liquid => true
  | Phase.gas    => true

#eval Phase.liquid.canFlow    -- true

-- ## 3. 每种情况可以带不同的数据

inductive Shape where
  | circle (r : Float)
  | rect (w h : Float)
deriving Repr

-- 构造子（constructor）还是普通函数：
#check (Shape.circle)    -- Shape.circle : Float → Shape
#check (Shape.rect)      -- Shape.rect : Float → Float → Shape
#eval Shape.rect 2 3     -- Shape.rect 2.000000 3.000000

-- `match` 在分情况的同时，把里面的数据取出来绑定到名字上。
-- 类型已知时，`Shape.circle` 可以简写成 `.circle`。
def Shape.area (s : Shape) : Float :=
  match s with
  | .circle r => 3.14159 * r * r
  | .rect w h => w * h

#eval (Shape.rect 2 3).area     -- 6.000000
#eval (Shape.circle 1).area     -- 3.141590

-- ## 4. 标准库里的例子：`Option`
-- 「可能没有值」。Lean 没有 null，这是唯一的表达方式。

#check (some 5)               -- some 5 : Option Nat
#check (none : Option Nat)    -- none : Option Nat

/-
## 练习

让底部的 `#guard` 全部通过。

(a) `Temp`：一个 inductive，三种情况 `celsius`、`kelvin`、`fahrenheit`，
    每种都带一个 `Float`。

(b) `Temp.toKelvin`：把任意一种温度换算成开尔文数值（`Float`）。
    K = °C + 273.15，°C = (°F − 32) × 5 / 9。

(c) `withDefault`：接收一个默认值 `d` 和一个 `Option α`，
    有值就返回里面的值，没有就返回 `d`。对任意类型 α 都要能用。

思考题（把回答写成注释）：
把 `Phase.canFlow` 的最后一个分支删掉，读一下报错，再恢复。
Python 的 `match` 和 TypeScript 的 `switch` 少写一个分支会怎样？
Lean 为什么必须拒绝？（提示：一个 `Phase → Bool` 的函数承诺了什么）
If Phase.gas is putted this function, but no gate for it, thus no Bool output, the strict class claim can not be true
-/

-- 在这里写你的定义 ↓
inductive Temp : Type where
  | celsius (t : Float)
  | kelvin (t : Float)
  | fahrenheit (t : Float)
deriving Repr

def Temp.toKelvin (T : Temp) : Float :=
  match T with
  | .celsius t => 273.15 + t
  | .kelvin t => t
  | .fahrenheit t => (t - 32) * 5 / 9 + 273.15

def withDefault {α : Type} (d : α) (o : Option α) : α :=
  match o with
  | .none => d
  | .some v => v

-- 测试（不要改）
#guard (Temp.celsius 0).toKelvin == 273.15
#guard (Temp.celsius 100).toKelvin == 373.15
#guard (Temp.kelvin 4.2).toKelvin == 4.2
#guard (Temp.fahrenheit 32).toKelvin == 273.15
#guard withDefault 0 (some 5) == 5
#guard withDefault 0 none == 0
#guard withDefault "?" (some "ok") == "ok"
