#[
  Conway's Game of Life
  Rules:
    1. Any live cell with fewer than two live neighbors dies (underpopulation)
    2. Any live cell with two or three live neighbors lives on
    3. Any live cell with more than three live neighbors dies (overpopulation)
    4. Any dead cell with exactly three live neighbors becomes live (reproduction)
]#

import std/sequtils
import std/random

let cell_size = 10

type Cell = enum
  alive
  dead

func count_live_neighbors(cells: seq[seq[Cell]], row, col: int): int =
  let offsets = @[-1, 0, 1]
  for offset in offsets:
    if row + offset < 0 or row + offset >= cells.len: continue
    for col2 in 0..<cells[row + offset].len:
      if col2 + col < 0 or col2 + col >= cells[row + offset].len: continue
      if cells[row + offset][col2] == alive:
        result += 1

func next_grid(cells: seq[seq[Cell]]): seq[seq[Cell]] =
  result = new_seq[seq[Cell]](cells.len)
  for row in 0..<cells.len:
    result[row] = new_seq[Cell](cells[row].len)
    for col in 0..<cells[row].len:
      let live_neighbors = cells.count_live_neighbors(row, col)
      if cells[row][col] == alive:
        result[row][col] = if live_neighbors < 2 or live_neighbors > 3: dead else: alive
      else:
        result[row][col] = if live_neighbors == 3: alive else: dead

proc random_grid(width, height: int): seq[seq[Cell]] =
  result = new_seq[seq[Cell]](height)
  for i in 0..<height:
    result[i] = new_seq[Cell](width)
    for j in 0..<width:
      result[i][j] = if rand(1.0) < 0.5: alive else: dead

proc draw_grid(cells: seq[seq[Cell]]) =
  echo "1"

proc main() =
  var grid = random_grid(cell_size, cell_size)
  while true:
    draw_grid(grid)
    grid = next_grid(grid)

main()
