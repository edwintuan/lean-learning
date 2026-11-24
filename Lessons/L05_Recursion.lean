/-
L05 · 递归：自己引用自己的类型，和必须停下来的函数

为什么学这个：
Lean 没有 `for` 和 `while`，重复的事情全靠递归。
更重要的是：下一课开始写证明，而「数学归纳法」在 Lean 里就是一个递归函数。
这一课写的三个练习函数，后面会被拿来当证明的对象。

检查：`lake env lean Lessons/L05_Recursion.lean`
-/

-- ## 1. `Nat` 是一个引用了自己的 inductive
-- 核心库里的定义（省略了注释）：
--
--   inductive Nat where
--     | zero : Nat
--     | succ (n : Nat) : Nat
--
-- 一个自然数要么是 0，要么是「某个自然数的后继」。数字字面量只是简写。

#check (Nat.zero)                     -- Nat.zero : Nat
#check (Nat.succ)                     -- Nat.succ : Nat → Nat
#eval Nat.succ (Nat.succ Nat.zero)    -- 2

-- ## 2. 类型怎么定义，函数就怎么递归
-- 两个构造子，两个分支。模式里的 `0` 就是 `Nat.zero`，`k + 1` 就是 `Nat.succ k`。

def factorial (n : Nat) : Nat :=
  match n with
  | 0     => 1
  | k + 1 => (k + 1) * factorial k

#eval factorial 5        -- 120
#eval factorial 30       -- 265252859812191058636308480000000    `Nat` 不会溢出

-- ## 3. `List` 也一样
-- 核心库里的定义（省略了注释）：
--
--   inductive List (α : Type u) where
--     | nil : List α
--     | cons (head : α) (tail : List α) : List α
--
-- `[]` 是 `List.nil`，`x :: xs` 是 `List.cons x xs`，`[1, 2, 3]` 是 `1 :: 2 :: 3 :: []`。

#check 1 :: [2, 3]       -- [1, 2, 3] : List Nat

def sumList (xs : List Nat) : Nat :=
  match xs with
  | []        => 0
  | x :: rest => x + sumList rest

#eval sumList [1, 2, 3, 4]    -- 10

-- ## 4. Lean 要求递归必须停下来
-- 上面两个函数能通过，是因为每次递归调用的参数都比原来「少一层构造子」
-- （`k` 比 `k + 1` 小，`rest` 比 `x :: rest` 小），Lean 自动认出了这一点。
-- 这叫结构递归（structural recursion）。
--
-- 去掉下面这行开头的 `--`，读一读报错，再注释回去：
-- def bad (n : Nat) : Nat := bad n + 1

/-
## 练习

让底部的 `#guard` 全部通过。三个函数都要自己用 `match` 和递归写，
不要调用标准库里现成的 `^`、`List.length`、`++`。

(a) `power`：`power x n` 计算 x 的 n 次方，x 和 n 都是 `Nat`。

(b) `myLength`：列表的长度，对任意元素类型 α 都能用。

(c) `myAppend`：把两个列表接起来，`myAppend [1, 2] [3]` 是 `[1, 2, 3]`。
    提示：只需要对其中一个列表做 `match`。先想清楚是哪一个。

思考题（把回答写成注释）：
假设 Lean 接受了第 4 节的 `bad`。那么 `bad 0` 满足什么等式？
bad 0 = bad 1 = bad 2 = bad 3
把它当成一个关于自然数的方程，能推出什么？
bad=Constant?
0=1=2=3?
-/

-- 在这里写你的定义 ↓

def power (x : Nat) (n : Nat) : Nat :=
  match n with
  | 0 => 1
  | n+1 => x * (power x n)
  -- Why cant I write instead of n=>x*(power x (n-1)), which given the error of structure recursion

def myLength {α : Type} (o : List α) : Nat :=
-- 这里的List α 到底是什么意思？ α 不是代表进来的Type？那就包括了List啊 怎么还能这样
  match o with
  | []        => 0
  | _x :: rest => myLength rest + 1

def myAppend (f : List α) (e : List α) : List α :=
  match f with
  | [] => e
  | x :: rest => x :: (myAppend rest e)

-- 测试（不要改）
#guard power 2 10 == 1024
#guard power 7 0 == 1
#guard power 0 3 == 0
#guard myLength [10, 20, 30] == 3
#guard myLength ([] : List Nat) == 0
#guard myLength ["a"] == 1
#guard myAppend [1, 2] [3, 4, 5] == [1, 2, 3, 4, 5]
#guard myAppend [] [1] == [1]
#guard myAppend ["a"] [] == ["a"]
