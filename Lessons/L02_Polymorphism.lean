/-
L02 · 多态：类型也是参数

为什么学这个：
L01 的 `applyTwice` 只能用于 `Nat → Nat`，但 `f (f x)` 这段逻辑和 `Nat` 毫无关系。
Rust / TypeScript 用一套专门的泛型语法 `<T>` 解决这个问题。
Lean 没有泛型语法：类型本身就是值，把它当成一个普通参数传进去就行。
这是「依值类型」的第一步，后面的 `∀ n : Nat, ...` 用的是同一个机制。

检查：`lake env lean Lessons/L02_Polymorphism.lean`
-/

-- ## 1. 类型也是值，所以它们也有类型

#check Nat               -- Nat : Type
#check Nat → Nat         -- Nat → Nat : Type
#check Type              -- Type : Type 1     ← 宇宙层级，以后讲；现在只需知道它不是 `Type : Type`

-- ## 2. 把类型当参数传：显式写法

def myId (α : Type) (x : α) : α := x

#eval myId Nat 5         -- 5
#eval myId String "hi"   -- "hi"
#check myId Nat          -- myId Nat : Nat → Nat      ← 只给类型参数，也是 partial application

-- 注意这个类型：第一个参数有名字 `α`，因为后面的类型要用到它的「值」。
-- 这叫依值函数类型（dependent function type）。
#check (myId)            -- myId : (α : Type) → α → α

-- ## 3. 隐式参数：花括号，让 Lean 自己推断

def myId' {α : Type} (x : α) : α := x

#eval myId' 5            -- 5       Lean 从 `5` 推出 α
#eval myId' "hi"         -- "hi"

-- 想手动指定时有两种写法：
#eval @myId' Nat 5            -- 5      `@` 把所有隐式参数变回显式
#eval myId' (α := Nat) 5      -- 5      按名字指定

-- 看带隐式参数的完整类型要用 `@`：
#check @myId'            -- @myId' : {α : Type} → α → α

-- ## 4. 多个类型参数

def flipArgs {α β γ : Type} (f : α → β → γ) : β → α → γ :=
  fun b a => f a b

#check @flipArgs               -- @flipArgs : {α β γ : Type} → (α → β → γ) → β → α → γ
#eval flipArgs Nat.sub 2 10    -- 8      即 Nat.sub 10 2

/-
## 练习

让底部的 `#guard` 全部通过。

(a) `applyTwice`：L01 那个函数的多态版本，对任意类型 α 都能用。

(b) `compose`：接收两个函数 g 和 f，返回「先做 f，再做 g」的新函数。
    f 的输入、f 的输出、g 的输出可以是三个不同的类型，
    签名里的类型由你自己推出来。

思考题（把回答写成注释）：
先猜 `applyTwice applyTwice (· + 1) 0` 等于几，再用 `#eval` 验证。

0+1+1+1+1 = 4

这时最外层那个 `applyTwice` 的 α 是什么？用 `#check` 找证据。
是 Nat→ Nat，因为它的参数是一个函数，返回值也是一个函数。
-/

-- 在这里写你的定义 ↓
def applyTwice {α : Type} (f : α → α) (x : α) : α := f (f x)
def compose {α β γ : Type} (g : β → γ) (f : α → β) : α → γ := fun x => g (f x)
#eval applyTwice applyTwice (· + 1) 0 -- 4
#eval (String.length ∘ (· ++ "!")) "hi"
#check @applyTwice (Nat → Nat) applyTwice

-- 测试（不要改）
#guard applyTwice (· + 3) 10 == 16
#guard applyTwice (· ++ "!") "hi" == "hi!!"
#guard compose (· + 1) String.length "abc" == 4
#guard compose String.length (· ++ "!") "abc" == 4
