Path = Class()

function Path:init(tiles, height, width)
  self.nodes = {}
  for i = 1, height do
    self.nodes[i] = {}
    for j = 1, width do
      local node = {}
      node.x = tiles[i][j].x + 32
      node.y = tiles[i][j].y + 32
      node.up, node.down, node.left, node.right = nil, nil, nil, nil
      self.nodes[i][j] = node
      
      