/-
L06 · 命题即类型，证明即程序

为什么学这个：
这是整个 Lean 的核心想法，也是前五课的回报。
Lean 没有另外一套「证明语言」。它把证明这件事翻译成了你已经会的事情：

  命题      是一个类型
  证明      是这个类型的一个值
  检查证明  就是类型检查

所以「证明一个定理」等于「写出一个类型正确的表达式」。
这一课只用前五课学过的语法写证明，不引入任何新工具。

检查：`lake env lean Lessons/L06_PropsAsTypes.lean`
-/

-- ## 1. 命题是类型

#check 2 + 2 = 4         -- 2 + 2 = 4 : Prop
#check 2 + 2 = 5         -- 2 + 2 = 5 : Prop     ← 假命题也是合法的类型，只是造不出它的值
#check Prop              -- Prop : Type          ← 所有命题组成的类型

-- ## 2. 证明是值
-- `theorem` 和 `def` 是一回事：名字、类型、值。只是类型换成了一个命题。
-- `rfl` 是「x = x」的证明。Lean 会把两边都算出来，再看是不是同一个东西。

theorem two_plus_two : 2 + 2 = 4 := rfl

#check two_plus_two      -- two_plus_two : 2 + 2 = 4

-- 去掉下面这行开头的 `--`，读一读报错，再注释回去：
-- theorem wrong : 2 + 2 = 5 := rfl

-- ## 3. 「蕴含」是函数（L01）
-- `p → q` 的证明：一个把「p 的证明」变成「q 的证明」的函数。
-- 下面的 `hp : p` 读作「hp 是 p 的一个证明」，和 `n : Nat` 是同一种写法。

theorem my_modus_ponens (p q : Prop) (hp : p) (hpq : p → q) : q :=
  hpq hp                 -- 函数调用

-- ## 4. 「且」是 structure（L03）
-- 核心库里的定义（省略了注释）：
--
--   structure And (a b : Prop) : Prop where
--     intro ::
--     left : a
--     right : b
--
-- `p ∧ q` 的证明：一个有两个字段的值，一个字段是 p 的证明，另一个是 q 的证明。

theorem my_and_swap (p q : Prop) (h : p ∧ q) : q ∧ p :=
  ⟨h.right, h.left⟩      -- 取字段，再用匿名构造子打包

-- ## 5. 「或」是 inductive（L04）
-- 核心库里的定义（省略了注释）：
--
--   inductive Or (a b : Prop) : Prop where
--     | inl (h : a) : Or a b
--     | inr (h : b) : Or a b
--
-- `p ∨ q` 的证明：要么是 p 的证明，要么是 q 的证明。分情况讨论就是 `match`。

theorem my_or_swap (p q : Prop) (h : p ∨ q) : q ∨ p :=
  match h with
  | .inl hp => .inr hp
  | .inr hq => .inl hq

/-
## 练习

把下面三个 `sorry` 换成真正的证明。
`sorry` 是占位符：它能冒充任何类型的值，让文件先编译过去，但会留下一条 warning。
目标是 `lake env lean` 没有任何 error，也没有任何 `sorry` 的 warning。
这次没有 `#guard`：类型检查通过，证明就是对的。

只用这一课和前五课出现过的写法：函数调用、`fun`、`.left` / `.right`、`⟨_, _⟩`、`match`。

思考题（把回答写成注释）：
(a) 的证明和你在 L02 写过的哪个函数是同一个东西？
-/

-- (a) 蕴含可以传递
theorem my_imp_trans (p q r : Prop) (hpq : p → q) (hqr : q → r) : p → r :=
  sorry

-- (b) 「且」的括号可以挪
theorem my_and_assoc (p q r : Prop) (h : (p ∧ q) ∧ r) : p ∧ (q ∧ r) :=
  sorry

-- (c) 「且」对「或」的分配律
theorem my_and_or (p q r : Prop) (h : p ∧ (q ∨ r)) : (p ∧ q) ∨ (p ∧ r) :=
  sorry
