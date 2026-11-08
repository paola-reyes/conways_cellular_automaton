class Cell {
  final int x;
  final int y;

  const Cell({required this.x, required this.y});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  // Override hashCode to get Cell position in Set<Cell> liveCells
  @override
  int get hashCode => Object.hash(x, y);

  // Debug method to print Cell position
  String print() => 'Cell($x, $y)';
}
