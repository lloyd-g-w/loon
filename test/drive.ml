open! Core
module Handle = Bonsai_web_test.Handle

let click h selector =
  Handle.click_on h ~get_vdom:Fn.id ~selector;
  Handle.recompute_view h
;;

let key h selector key =
  Handle.keydown h ~get_vdom:Fn.id ~selector ~key;
  Handle.recompute_view h
;;

let type_ h selector text =
  Handle.input_text h ~get_vdom:Fn.id ~selector ~text;
  Handle.recompute_view h
;;
