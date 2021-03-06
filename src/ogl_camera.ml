module V = Typedvec.Std.Algebra.Vec
module M = Typedvec.Std.Algebra.Mat

let v_x t = V.unsafe_get t 0
let v_y t = V.unsafe_get t 1
let v_z t = V.unsafe_get t 2

let make_matrix ~pos ~at ~up =
  let camera_direct = V.sub at pos |> V.normalize in
  let up = V.normalize up in
  let camera_x = V.cross up camera_direct |> V.normalize in
  let up = V.cross camera_direct camera_x |> V.normalize in
  let open V in
  let m = Ogl_util.identity_mat4 () in
  let ex = -. (V.dot pos camera_x)
  and ey = -. (V.dot pos up)
  and ez = -. (V.dot pos camera_direct) in

  M.set m ~row:0 ~col:0 ~v:(v_x up);
  M.set m ~row:0 ~col:1 ~v:(v_y up);
  M.set m ~row:0 ~col:2 ~v:(v_z up);
  M.set m ~row:0 ~col:3 ~v:ex;

  M.set m ~row:1 ~col:0 ~v:(v_x camera_x);
  M.set m ~row:1 ~col:1 ~v:(v_y camera_x);
  M.set m ~row:1 ~col:2 ~v:(v_z camera_x);
  M.set m ~row:1 ~col:3 ~v:ey;

  M.set m ~row:2 ~col:0 ~v:(v_x camera_direct);
  M.set m ~row:2 ~col:1 ~v:(v_y camera_direct);
  M.set m ~row:2 ~col:2 ~v:(v_z camera_direct);
  M.set m ~row:2 ~col:3 ~v:ez;
  m

let make_perspective_projection ~fov ~ratio ~near ~far =
  let pi = 3.14159265358979323846 in
  let f = tan (fov /. 2.0 *. pi /. 180.0) in
  let range = near -. far in
  let a = ((-.near) -. far) /. range
  and b = (2.0 *. far *. near) /. range in
  let m = Ogl_util.empty_mat4 () in
  M.set m ~row:0 ~col:0 ~v:(1.0 /. (f *. ratio));
  M.set m ~row:1 ~col:1 ~v:(1.0 /. f);
  M.set m ~row:2 ~col:2 ~v:a;
  M.set m ~row:2 ~col:3 ~v:b;
  M.set m ~row:3 ~col:2 ~v:1.0;
  m

let make_ortho_projection ~left ~right ~top ~bottom ~near ~far =
  let width_ratio = 2.0 /. (right -. left)
  and height_ratio = 2.0 /. (top -. bottom)
  and z_ratio = -2.0 /. (far -. near)
  and tx = -1.0 *. (right +. left) /. (right -. left)
  and ty = -1.0 *. (top +. bottom) /. (top -. bottom)
  and tz = -1.0 *. (far +. near) /. (far -. near) in
  let m = Ogl_util.empty_mat4 () in

  M.set m ~row:0 ~col:0 ~v:width_ratio ;
  M.set m ~row:0 ~col:3 ~v:tx;

  M.set m ~row:1 ~col:1 ~v:height_ratio;
  M.set m ~row:1 ~col:3 ~v:ty;

  M.set m ~row:2 ~col:2 ~v:z_ratio;
  M.set m ~row:2 ~col:3 ~v:tz;

  M.set m ~row:3 ~col:3 ~v:1.0;
  m
