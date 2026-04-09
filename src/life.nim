#[
  Conway's Game of Life
  Rules:
    1. Any live cell with fewer than two live neighbors dies (underpopulation)
    2. Any live cell with two or three live neighbors lives on
    3. Any live cell with more than three live neighbors dies (overpopulation)
    4. Any dead cell with exactly three live neighbors becomes live (reproduction)
]#

import raylib
import std/[random, deques, sequtils, strformat]

const
  W = 800
  H = 600
  CellSize = 10
  Cols = W div CellSize
  Rows = H div CellSize
  TickRate = 0.1
  Background = Color(r: 26, g: 26, b: 26, a: 255)
  Palette = [
    Color(r: 0, g: 217, b: 51, a: 255),
    Color(r: 217, g: 51, b: 0, a: 255),
    Color(r: 51, g: 102, b: 255, a: 255),
    Color(r: 255, g: 217, b: 0, a: 255),
    Color(r: 204, g: 51, b: 204, a: 255),
    Color(r: 0, g: 204, b: 204, a: 255),
    Color(r: 255, g: 128, b: 77, a: 255),
    Color(r: 128, g: 255, b: 128, a: 255),
    Color(r: 102, g: 51, b: 230, a: 255),
    Color(r: 230, g: 230, b: 102, a: 255),
  ]

type Cell = enum alive, dead

func neighbors(g: seq[seq[Cell]], r, c: int): int =
  for dr in -1..1:
    for dc in -1..1:
      if dr == 0 and dc == 0: continue
      let nr = r + dr; let nc = c + dc
      if nr in 0..<g.len and nc in 0..<g[0].len and g[nr][nc] == alive:
        result += 1

func step(g: seq[seq[Cell]]): seq[seq[Cell]] =
  result = new_seq_with(g.len, new_seq[Cell](g[0].len))
  for r in 0..<g.len:
    for c in 0..<g[0].len:
      let n = g.neighbors(r, c)
      result[r][c] = if g[r][c] == alive: (if n in 2..3: alive else: dead)
                     else: (if n == 3: alive else: dead)

proc random_grid(): seq[seq[Cell]] =
  result = new_seq_with(Rows, new_seq[Cell](Cols))
  for r in 0..<Rows:
    for c in 0..<Cols:
      result[r][c] = if rand(1.0) < 0.5: alive else: dead

proc flood_fill(g: seq[seq[Cell]], labels: var seq[seq[int]], r, c, id: int) =
  var q = init_deque[(int, int)]()
  labels[r][c] = id
  q.add_last((r, c))
  while q.len > 0:
    let (cr, cc) = q.pop_first()
    for dr in -1..1:
      for dc in -1..1:
        if dr == 0 and dc == 0: continue
        let nr = cr + dr
        let nc = cc + dc
        if nr in 0..<g.len and nc in 0..<g[0].len and
           g[nr][nc] == alive and labels[nr][nc] == 0:
          labels[nr][nc] = id
          q.add_last((nr, nc))

proc label_groups(g: seq[seq[Cell]]): seq[seq[int]] =
  result = new_seq_with(g.len, new_seq[int](g[0].len))
  var id = 0
  for r in 0..<g.len:
    for c in 0..<g[0].len:
      if g[r][c] == alive and result[r][c] == 0:
        id += 1
        flood_fill(g, result, r, c, id)

func count_alive(g: seq[seq[Cell]]): int =
  for row in g:
    for c in row:
      if c == alive: result += 1

proc main() =
  randomize()
  init_window(W, H, "Game of Life")
  defer: close_window()
  set_target_fps(60)

  var grid = random_grid()
  var groups = label_groups(grid)
  var last = get_time()

  while not window_should_close():
    let now = get_time()
    if now - last >= TickRate:
      grid = step(grid)
      groups = label_groups(grid)
      last = now

    begin_drawing()
    clear_background(Background)
    for r in 0..<grid.len:
      for c in 0..<grid[0].len:
        if grid[r][c] == alive:
          let col = Palette[(groups[r][c] - 1) mod Palette.len]
          draw_rectangle(int32(c * CellSize), int32(r * CellSize),
                        int32(CellSize), int32(CellSize), col)
    let text = &"Game of Life — {countAlive(grid)} alive"
    draw_text(text, 8, 8, 20, RayWhite)
    end_drawing()

main()
