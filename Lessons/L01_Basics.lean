/-
L01 · 函数：定义、类型、柯里化

为什么先学这个：
Lean 里几乎一切都是「带类型的表达式」，函数是其中最核心的一种。
后面的结构体、类型类，乃至「证明」，本质上都是在写函数、读函数的类型。
所以第一课只做一件事：学会定义函数，并读懂它的类型。

怎么看输出：
- VS Code：光标停在 `#check` / `#eval` 那一行，右侧 infoview 显示结果
- 命令行：`lake env lean Lessons/L01_Basics.lean`
-/

-- ## 0. 两个探针：`#check` 问类型，`#eval` 求值
-- 它们是「命令」，在编译阶段由编译器执行，不会进入最终的二进制。

#check 1 + 2             -- 1 + 2 : Nat
#eval 1 + 2              -- 3
#check "phys" ++ "ics"   -- "phys" ++ "ics" : String
#eval "phys" ++ "ics"    -- "physics"
#check 2.5               -- 2.5 : Float

-- ## 1. `def`：定义函数
-- 形状：def 名字 (参数 : 类型) : 返回类型 := 函数体
-- 没有 `return`，函数体就是一个表达式，它的值就是返回值。

def double (n : Nat) : Nat := n * 2

#eval double 21          -- 42
#check double            -- double (n : Nat) : Nat    ← 按你写的签名显示
#check (double)          -- double : Nat → Nat        ← 加括号：当成普通表达式，显示纯类型

-- ## 2. 调用函数：空格，不是括号
-- `f x y` 而不是 `f(x, y)`。括号只用来分组。

def add (x y : Nat) : Nat := x + y

#eval add 1 2            -- 3
#eval double (add 1 2)   -- 6

-- 去掉下面这行开头的 `--`，读一读报错，再把它注释回去：
-- #eval double add 1 2

-- ## 3. 柯里化：多参数函数 = 「返回函数的函数」
-- `Nat → Nat → Nat` 读作 `Nat → (Nat → Nat)`：吃一个 Nat，吐出一个 `Nat → Nat`。
-- 所以参数可以只给一部分（partial application），得到一个新函数。

#check (add)             -- add : Nat → Nat → Nat
#check add 2             -- add 2 : Nat → Nat

def addTwo := add 2      -- 没写类型，Lean 自己推断出 Nat → Nat

#eval addTwo 40          -- 42

-- ## 4. 匿名函数：`fun x => ...`
-- `def` 只是给一个函数值起名字。下面两个定义完全等价：

def square (x : Nat) : Nat := x * x
def square' : Nat → Nat := fun x => x * x

#eval square 9                -- 81
#eval square' 9               -- 81
#eval (fun x => x * x) 7      -- 49
#eval (· * 2) 21              -- 42    `(· * 2)` 是 `fun x => x * 2` 的简写
#eval (· + ·) 1 2              -- 3     `(· + ·)` 是 `fun x y => x + y` 的简写
-- 顺带一个坑（原因以后讲）：`Nat` 是自然数，减法减不动就停在 0
#eval 2 - 5                   -- 0
#eval (2 - 5 : Int)           -- -3

/-
## 练习

在下面写三个定义，让文件底部的三条 `#guard` 全部通过。
`#guard e`：编译时对 `e` 求值，结果不是 `true` 就报错，相当于最朴素的单元测试。
现在它们是红的（Unknown identifier），这是预期的。

(a) `kineticEnergy`：接收质量 m 和速率 v（都是 `Float`），返回动能 ½mv²。

(b) `applyTwice`：接收一个 `Nat → Nat` 的函数 f 和一个 `Nat` x，
    把 f 对 x 连续作用两次。

(c) `addFour`：类型是 `Nat → Nat`，给输入加 4。
    限制：不许写 `fun`，不许给它声明参数，
    只能用 `applyTwice` 和上面已有的定义拼出来。

思考题（把回答写成注释）：
写完 (b) 后运行 `#check (applyTwice)`。类型里的那对括号能去掉吗？
去掉以后描述的是一个什么样的函数？
-/

-- 在这里写你的定义 ↓
def kineticEnergy (m v : Float) : Float := 0.5 * m * v * v
def applyTwice (f : Nat → Nat) (x: Nat) : Nat := f (f x)
def addFour : Nat → Nat := applyTwice addTwo

-- 测试（不要改）
#guard kineticEnergy 2.0 3.0 == 9.0
#guard applyTwice double 3 == 12
#guard addFour 38 == 42

#check (applyTwice)
-- Can not remove the brackets (Nat → Nat) because it donominate the input type of the function is a Nat→Nat function, not a Nat numbner.
#check (applyTwice addTwo)
-- applyTwice receive a (Nat→ Nat) function addTwo, and return a (Nat→ Nat) function)
