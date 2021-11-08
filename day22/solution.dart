import 'dart:convert';
import 'dart:io';

import 'dart:math';

final PATTERN = RegExp(
    r"^\/dev\/grid\/node\-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T\s+(\d+)\%$");

class Node {
  final int x, y, size, used;

  Node(this.x, this.y, this.size, this.used);

  factory Node.fromString(String line) {
    final matches = PATTERN.firstMatch(line)!;

    return Node(
      int.parse(matches[1]!),
      int.parse(matches[2]!),
      int.parse(matches[3]!),
      int.parse(matches[4]!),
    );
  }

  int get avail => size - used;

  bool isEmpty() => used == 0;
  bool fits(Node other) => avail >= other.used;
  bool isNeighbour(Node other) =>
      (x == other.x && (y - other.y).abs() == 1) ||
      (y == other.y && (x - other.x).abs() == 1);

  @override
  bool operator ==(o) => o is Node && x == o.x && y == o.y;

  @override
  String toString() {
    return "Node(x: $x, y: $y, size: $size, used: $used)";
  }
}

Stream<Node> parseInput() => stdin
    .transform(utf8.decoder)
    .transform(const LineSplitter())
    .map((line) => line.trim())
    .where(PATTERN.hasMatch)
    .map((line) => Node.fromString(line));

int solveA(List<Node> nodes) {
  var n = 0;

  for (var nodeA in nodes) {
    for (var nodeB in nodes) {
      if (!nodeA.isEmpty() && nodeA != nodeB && nodeB.fits(nodeA)) n++;
    }
  }

  return n;
}

void solveB(List<Node> nodes) {
  // Assumptions:
  // - only empty node can "move" throught the grid
  // - big nodes (>100T) are "walls"
  //
  // This will print the "maze" and should be solved by hand ¯\_(ツ)_/¯:
  // - Count the number of moves from the empty (_) node to the topright corner
  //   while going around the wall.
  // - Add 5 * (max X - 2)
  final maxX = nodes.map((node) => node.x).reduce(max);

  nodes.sort((a, b) {
    final compareY = a.y.compareTo(b.y);
    if (compareY == 0) return a.x.compareTo(b.x);
    return compareY;
  });

  for (Node node in nodes) {
    if (node.x == 0) stdout.write("\n");

    if (node.x == 0 && node.y == 0)
      stdout.write("0");
    else if (node.y == 0 && node.x == maxX)
      stdout.write("F");
    else if (node.size >= 100)
      stdout.write("#");
    else if (node.isEmpty())
      stdout.write("_");
    else
      stdout.write(".");
  }
}

void main() async {
  final nodes = await parseInput().toList();

  print(solveA(nodes));
  solveB(nodes);
}
