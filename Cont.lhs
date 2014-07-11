Continuation Passing Style
==========================

Cont monad memodelkan suspended computation (komputasi tertunda).

> module Cont where
> import Control.Applicative
> newtype Cont r a = Cont { run :: (a -> r) -> r }

Karena (Cont r a) adalah komputasi yang tertunda, kita harus ngasih makan
mereka fungsi bertipe (a -> r) agar komputasinya berjalan. type variable a di
(Cont r a) disini merupakan monadic value dari model komputasi ini. Juga tipe
input dari fungsi yang dikasih makan ke si Cont monad. Sedangkan type variable
r merupakan tipe dari result yang diharapkan ntar bakal dihasilkan oleh si
fungsi dan si suspended computation itu sendiri.

Contoh sederhananya:

> -- >>> let x = ($ 42)
> -- >>> :type x
> -- x :: Num a => (a -> r) -> r

Variabel x diatas adalah komputasi tertunda kita. Agar berjalan, feed dengan
fungsi bertipe (Num a => (a -> r)).

> -- >>> x show
> -- "42"
> -- >>> x (*3)
> -- 126
> -- >>> x Just
> -- Just 42

Karena x juga merupakan first class function, kita bisa umpankan dia ke fungsi
map.

> -- >>> map x [\a -> a + 1, (+9), (*3), length.show]
> -- [43, 51, 126, 2]

Seolah-olah suspended computation x kita akhirnya jalan setelah diberikan
argumen berupa fungsi yang inputnya sesuai dengan Monadic value di dalam x

Lalu apa serunya?

(Cont r) sebagai Monad
----------------------

Ngubah nilai biasa jadi Monad (Cont r) sama seperti yang kita lakukan ke
contoh diatas. Section nilai tersebut di ruas kanannya operator ($).
Sedangkan operator bind-nya juga gak kalah seru, cek aja ini:

> instance Monad (Cont r) where
>     return x = Cont ($ x)
>     Cont ma >>= f = Cont $ \k -> ma $ \a -> run (f a) k

Variabel k diatas adalah fungsi bertipe (b -> r) yang nanti kita umpankan
ke hasil binding ma dan f yang masing masing bertipe (Cont r a) dan
(a -> Cont r b). Perhatikan juga bahwa untuk mengakses monadic value di
variabel ma, kita umpankan fungsi yang argumennya (di kasus ini variabel a)
merupakan monadic value-nya Cont monad kita.

Karena f :: a -> Cont r b dan argumen f tadi, a :: a, kita akan dapati
f a :: Cont r b. Itu sebabnya kita bisa jadikan k :: (b -> r) sebagai
argumen dari f a. Suspended computation gak lagi suspended dan menghasilkan
komputasi bertipe r. Sehingga keseluruhan ekspresi tersebut akan bertipe
(b -> r) -> r.

Selanjutnya ke Applicative.

(Cont r) sebagai Applicative
----------------------------

> instance Applicative (Cont r) where
>     pure x = Cont ($ x)
>     Cont mf <*> Cont ma = Cont $ \k -> ma $ \a -> mf $ \f -> k $ f a

Kalau ngerti yang diatas, yang ini pasti bakalan mudah juga. Gak ada sulap
ataupun sihir. Cuman nyocokin tipe biasa. Bisa juga pakai bind dan return
punya si Monad.

Terakhir ke Functor.

(Cont r) sebagai Functor
------------------------

> instance Functor (Cont r) where
>     fmap f (Cont ma) = Cont $ \k -> ma $ \a -> k $ f a

Masih mirip-mirip dengan bind-nya monad. Bedanya cuma di bagian akhir. Tipenya
mustinya cocok.
