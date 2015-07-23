%% -*- latex -*-

%% %let atwork = True

% Presentation
\documentclass{beamer}
%\documentclass[handout]{beamer}

\usefonttheme{serif}

\usepackage{hyperref}
\usepackage{color}

\definecolor{linkColor}{rgb}{0,0.42,0.3}
\definecolor{partColor}{rgb}{0,0,0.8}

\hypersetup{colorlinks=true,urlcolor=linkColor}

\usepackage{graphicx}
\usepackage{color}
\DeclareGraphicsExtensions{.pdf,.png,.jpg}

%% \usepackage{wasysym}
\usepackage{mathabx}
\usepackage{setspace}
\usepackage{enumerate}
\usepackage{tikzsymbols}

\useinnertheme[shadow]{rounded}
% \useoutertheme{default}
\useoutertheme{shadow}
\useoutertheme{infolines}
% Suppress navigation arrows
\setbeamertemplate{navigation symbols}{}

\input{macros}

%include polycode.fmt
%include forall.fmt
%include greek.fmt
%include mine.fmt

\title{A more elegant specification for FRP}
\author{\href{http://conal.net}{Conal Elliott}}
\date{LambdaJam 2015}
% \date{\emph{Draft of \today}}

\setlength{\itemsep}{2ex}
\setlength{\parskip}{1ex}

% \setlength{\blanklineskip}{1.5ex}

%%%%

% \setbeameroption{show notes} % un-comment to see the notes

\setstretch{1.2}

\begin{document}

\frame{\titlepage}

\partframe{The story so far}

\framet{FRP's two fundamental properties}{
\begin{itemize}\itemsep3ex
\item Precise, simple denotation.
  (Elegant \& rigorous.)
  \item \emph{Continuous} time.
  (Natural \& composable.)
\end{itemize}
%\pause

\vspace{2.5ex}

FRP \emph{is not} about:
\pause
\begin{itemize}\itemsep1.2ex
\item graphs,
\item updates and propagation,
\item streams,
\item doing % (operational)
\end{itemize}

}

\framet{Semantics}{

Central abstract type: |Behavior a| --- a ``flow'' of values.
\pause\\[5ex]

Precise \& simple semantics:

> meaning :: Behavior a -> (T -> a)

where |T = R| (reals).
\pause\\[4ex]

Much of API and its specification can follow from this one choice.
}

\partframe{Original formulation}

\framet{API}{

{ \small

> time       :: Behavior T
> lift0      :: a -> Behavior a
> lift1      :: (a -> b) -> Behavior a -> Behavior b
> lift2      :: (a -> b -> c) -> Behavior a -> Behavior b -> Behavior c
> timeTrans  :: Behavior a -> Behavior T -> Behavior a
> integral   :: VS a => Behavior a -> T -> Behavior a
> NOTHING ...

> instance Num a => Num (Behavior a) where ...
> ...

}
Reactivity later.

}

\framet{Semantics}{

> meaning time               = \ t -> t
> meaning (lift0 a)          = \ t -> a
> meaning (lift1 f xs)       = \ t -> f (meaning xs t)
> meaning (lift2 f xs ys)    = \ t -> f (meaning xs t) (meaning ys t)
> meaning (timeTrans xs tt)  = \ t -> meaning xs (meaning tt t)

> instance Num a => Num (Behavior a) where
>    fromInteger  = lift0 . fromInteger
>    (+)          = lift2 (+)
>    ...

}

\framet{Semantics}{

> meaning time               = id
> meaning (lift0 a)          = const a
> meaning (lift1 f xs)       = f . meaning xs
> meaning (lift2 f xs ys)    = liftA2 f (meaning xs) (meaning ys)
> meaning (timeTrans xs tt)  = meaning xs . meaning tt

> instance Num a => Num (Behavior a) where
>    fromInteger  = lift0 . fromInteger
>    (+)          = lift2 (+)
>    ...

}

\framet{Events}{

\emph{Secondary} type:

> meaning :: Event a -> [(T,a)]  -- non-decreasing times

> never      :: Event a
> once       :: T -> a -> Event a
> (.|.)      :: Event a -> Event a -> Event a
> (==>)      :: Event a -> (a -> b) -> Event b
> predicate  :: Behavior Bool -> Event ()
> snapshot   :: Event a -> Behavior b -> Event (a,b)

\\[2ex]
\emph{Exercise:} define semantics of these operations.
}

\partframe{A more elegant specification}

\framet{API}{

Replace several operations with standard abstractions:

> instance Functor Behavior where ...
> instance Applicative Behavior where ...
> instance Monoid a => Monoid (Behavior a) where ...
> SPACE
> instance Functor Event where ...
> instance Monoid a => Monoid (Event a) where ...

Why?\pause
\begin{itemize}
\item Less learning, more leverage.
\item Specifications and laws for free.

\end{itemize}

}

\framet{Semantic instances}{

> instance Functor      ((->) z) where ...
> instance Applicative  ((->) z) where ...
> SPACE
> instance Monoid  a => Monoid  (z -> a) where ...
> instance Num     a => Num     (z -> a) where ...
> ...

\ 

The |Behavior| instances follow in ``precise analogy'' to denotation.
}

\framet{Homomorphisms}{

A ``homomorphism'' $h$ is a function that preserves (distributes over) an algebraic structure.
For instance, for \texttt{Monoid}:\\[2ex]

> h mempty      == mempty
> h (as <> bs)  == h as <> h bs

\ 

\pause
Some monoid homomorphisms:\\[2ex]

> length' :: [a] -> Sum Int
> length' = Sum . length
> SPACE
> log' :: Product R -> Sum R
> log' = Sum . log . getProduct

\out{
\ 

\pause
\vspace{-5ex}where\vspace{-1ex}

> newtype Sum a = Sum a 
> instance Num a => Monoid (Sum a) where
>   mempty          = Sum 0
>   Sum x <> Sum y  = Sum (x + y)

}

\out{
\vspace{-3ex}
Note that:

> length (as ++ bs)  == length as ++ length bs
> log (a * b)        == log a + log b

}
}

\framet{More homomorphism properties}{

|Functor|:

> h (fmap f xs) == fmap f (h xs)

|Applicative|:

> h (pure a)     == pure a
> h (fs <*> xs)  == h fs <*> h xs

|Monad|:

> h (m >>= k) == h m >>= h . k

}

\framet{Specification by semantic homomorphism}{

Specification: |meaning| as homomorphism.
For instance,

> meaning (fmap f as)  == fmap f (meaning as)
> SPACE
> meaning (pure a)     == pure a
> meaning (fs <*> xs)  == meaning fs <*> meaning xs

}

\setlength{\fboxsep}{-1.7ex}

\framet{Semantic instances}{

> instance Monoid a => Monoid (z -> a) where
>   mempty  = \ z -> mempty
>   f <> g  = \ z -> f z <> g z

> instance Functor ((->) z) where
>   fmap g f = g . f

> instance Applicative  ((->) z) where
>  pure a     = \ z -> a
>  ff <*> fx  = \ z -> (ff z) (fx z)

}

\framet{Semantic homomorphisms}{

Put the pieces together:

\begin{center}
\fbox{\begin{minipage}[c]{0.48\textwidth}

>     meaning (pure a)
> ==  pure a
> SPACE
> ==  \ t -> a

\end{minipage}}
\hspace{0.02\textwidth}
\fbox{\begin{minipage}[c]{0.48\textwidth}

>     meaning (fs <*> xs)
> ==  meaning fs <*> meaning xs
> SPACE
> ==  \ t -> (meaning fs t) (meaning xs t)

\end{minipage}}
\end{center}

\vspace{1ex}
Likewise for |Functor|, |Monoid|, |Num|, etc.

\vspace{1.5ex}\pause

Notes:
\begin{itemize}
\item Corresponds exactly to the original FRP denotation.
\item Follows inevitably from semantic homomorphism principle.
\item Laws hold for free (already paid for).
\end{itemize}

}

\framet{Laws for free}{

%% Semantic homomorphisms guarantee class laws. For `Monoid`,

\begin{center}
\fbox{\begin{minipage}[c]{0.4\textwidth}

> meaning mempty    == mempty
> meaning (a <> b)  == meaning a <> meaning b

\end{minipage}}
\begin{minipage}[c]{0.07\textwidth}\begin{center}$\Rightarrow$\end{center}\end{minipage}
\fbox{\begin{minipage}[c]{0.45\textwidth}

> a <> mempty    == a
> mempty <> b    == b
> a <> (b <> c)  == (a <> b) <> c

\end{minipage}}
\end{center}
\vspace{-1ex}
where equality is \emph{semantic}.
\pause
Proofs:
\begin{center}
\fbox{\begin{minipage}[c]{0.3\textwidth}

>     meaning (a <> mempty)
> ==  meaning a <> meaning mempty
> ==  meaning a <> mempty
> ==  meaning a

\end{minipage}}
\fbox{\begin{minipage}[c]{0.3\textwidth}

>     meaning (mempty <> b)
> ==  meaning mempty <> meaning b
> ==  mempty <> meaning b
> ==  meaning b

\end{minipage}}
\fbox{\begin{minipage}[c]{0.39\textwidth}

>     meaning (a <> (b <> c))
> ==  meaning a <> (meaning b <> meaning c)
> ==  (meaning a <> meaning b) <> meaning c
> ==  meaning ((a <> b) <> c)

\end{minipage}}
\end{center}

Works for other classes as well.
}

\framet{Events}{

> newtype Event a = Event (Behavior [a])   -- discretely non-empty
>   deriving (Monoid,Functor)

\ \\

\pause
Derived instances:

> instance Monoid a => Monoid (Event a) where
>   mempty = Event (pure mempty)
>   Event u <> Event v = Event (liftA2 (<>) u v)

> instance Functor Event where
>   fmap f (Event b) = Event (fmap (fmap f) b)

\ \\[3ex]

\pause
Alternatively,

> type Event = Behavior :. []

}

\framet{Conclusion}{

\begin{itemize}\itemsep2ex
 \item Two fundamental properties:\\
   \begin{itemize}\itemsep1ex
     \item Precise, simple denotation. (Elegant \& rigorous.)
     \item Continuous time. (Natural \& composable.)
     \\[1ex]
   \end{itemize}

   \emph{Warning:} most recent ``FRP'' systems lack both.
 \pitem Semantic homomorphisms:
   \begin{itemize}\itemsep1ex
     \item Mine semantic model for API.
     \item Inevitable API semantics (minimize invention).
     \item Laws hold for free (already paid for).
     \item No abstraction leaks.
     \item Matches original FRP semantics.
     \item Generally useful principle for library design.
   \end{itemize}
\end{itemize}
}

\end{document}
