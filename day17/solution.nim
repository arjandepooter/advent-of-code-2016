import std/deques
import std/rdstdin
import std/sequtils
import std/md5

type
    Point = tuple[x: int, y: int]
    Item = tuple[point: Point, path: string]

proc move(point: Point, c: char): Point =
    case c:
        of 'U': (x: point.x, y: point.y - 1)
        of 'D': (x: point.x, y: point.y + 1)
        of 'L': (x: point.x - 1, y: point.y)
        of 'R': (x: point.x + 1, y: point.y)
        else: point

proc isAccessible(point: Point): bool =
    point.x >= 0 and point.y >= 0 and point.x < 4 and point.y < 4

proc isEndpoint(point: Point): bool = point.x == 3 and point.y == 3

proc toHash(s: string, h: string): string = (h & s).getMD5()[0..3]

proc isValidKey(c: char): bool = c in 'b'..'f'

proc solveA(salt: string): string =
    var queue: Deque[Item] = [(point: (0, 0), path: "")].toDeque()

    while queue.len > 0:
        var cur = queue.popFirst()

        if cur.point.isEndpoint():
            return cur.path

        for (direction, key) in ['U', 'D', 'L', 'R'].zip(cur.path.toHash(salt)):
            var next = (
                point: cur.point.move(direction),
                path: cur.path & direction
            )

            if key.isValidKey() and next.point.isAccessible():
                queue.addLast(next)


proc solveB(salt: string): int =
    var queue: Deque[Item] = [(point: (0, 0), path: "")].toDeque()
    var longest = 0

    while queue.len > 0:
        var cur = queue.popFirst()

        if cur.point.isEndpoint():
            longest = cur.path.len()
            continue

        for (direction, key) in ['U', 'D', 'L', 'R'].zip(cur.path.toHash(salt)):
            var next = (
                point: cur.point.move(direction),
                path: cur.path & direction
            )

            if key.isValidKey() and next.point.isAccessible():
                queue.addLast(next)

    longest

var salt = readLineFromStdin("")
echo solveA(salt)
echo solveB(salt)
