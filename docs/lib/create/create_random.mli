(** Shuffle and randomise ([(create)/hooks/use-random.tsx],
    [lib/randomize-biases.ts]), keeping the locked fields, and choosing only
    what loon can show (Vega, Lucide, the bundled fonts). [random n] is a
    uniform integer in [\[0, n)]. *)

open! Core

(** shadcn's Shuffle: one of {!Create_shuffle.presets} (not the current one),
    with the locked fields kept. *)
val shuffle
  :  random:(int -> int)
  -> locks:Create_field.Set.t
  -> Create_preset.t
  -> Create_preset.t

(** [randomizeTrueRandom]: every unlocked field at random, with shadcn's
    biases (the theme's paired chart colours; a heading font in another
    category, 30% of the time; no bold accent with translucent menus). *)
val true_random
  :  random:(int -> int)
  -> locks:Create_field.Set.t
  -> Create_preset.t
  -> Create_preset.t
