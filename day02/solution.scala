import scala.io.Source;
import scala.collection.mutable.HashMap

enum Direction:
  case Up, Down, Left, Right

object Direction {
  def fromChar(c: Char): Direction = c match {
    case 'U' => Up
    case 'D' => Down
    case 'L' => Left
    case 'R' => Right
    case _   => Down
  }
}

trait Keypad {
  val connections: HashMap[(Char, Direction), Char]
  val start: Char = '5'

  def getCode(instructionSet: Array[Array[Direction]]): Array[Char] = {
    instructionSet
      .scanLeft(start) { (pos, instructions) =>
        instructions.foldLeft(pos) { (pos, direction) =>
          connections.get((pos, direction)) match {
            case Some(newPosition) => newPosition
            case _                 => pos
          }
        }
      }
      .drop(1)
  }
}

class SimpleKeypad extends Keypad {
  override val connections =
    HashMap(
      ('1', Direction.Right) -> '2',
      ('1', Direction.Down) -> '4',
      ('2', Direction.Left) -> '1',
      ('2', Direction.Right) -> '3',
      ('2', Direction.Down) -> '5',
      ('3', Direction.Left) -> '2',
      ('3', Direction.Down) -> '6',
      ('4', Direction.Up) -> '1',
      ('4', Direction.Right) -> '5',
      ('4', Direction.Down) -> '7',
      ('4', Direction.Left) -> '3',
      ('5', Direction.Up) -> '2',
      ('5', Direction.Right) -> '6',
      ('5', Direction.Down) -> '8',
      ('5', Direction.Left) -> '4',
      ('6', Direction.Up) -> '3',
      ('6', Direction.Down) -> '9',
      ('6', Direction.Left) -> '5',
      ('7', Direction.Up) -> '4',
      ('7', Direction.Right) -> '8',
      ('8', Direction.Up) -> '5',
      ('8', Direction.Right) -> '9',
      ('8', Direction.Left) -> '7',
      ('9', Direction.Up) -> '6',
      ('9', Direction.Left) -> '8'
    )
}

class WeirdKeypad extends Keypad {
  override val connections = HashMap(
    ('1', Direction.Down) -> '3',
    ('2', Direction.Right) -> '3',
    ('2', Direction.Down) -> '6',
    ('3', Direction.Up) -> '1',
    ('3', Direction.Right) -> '4',
    ('3', Direction.Down) -> '7',
    ('3', Direction.Left) -> '2',
    ('4', Direction.Down) -> '8',
    ('4', Direction.Left) -> '3',
    ('5', Direction.Right) -> '6',
    ('6', Direction.Up) -> '2',
    ('6', Direction.Right) -> '7',
    ('6', Direction.Down) -> 'A',
    ('6', Direction.Left) -> '5',
    ('7', Direction.Up) -> '3',
    ('7', Direction.Right) -> '8',
    ('7', Direction.Down) -> 'B',
    ('7', Direction.Left) -> '6',
    ('8', Direction.Up) -> '4',
    ('8', Direction.Right) -> '9',
    ('8', Direction.Down) -> 'C',
    ('8', Direction.Left) -> '7',
    ('9', Direction.Left) -> '8',
    ('A', Direction.Up) -> '6',
    ('A', Direction.Right) -> 'B',
    ('B', Direction.Up) -> '7',
    ('B', Direction.Right) -> 'C',
    ('B', Direction.Down) -> 'D',
    ('B', Direction.Left) -> 'A',
    ('C', Direction.Up) -> '8',
    ('C', Direction.Left) -> 'B',
    ('D', Direction.Up) -> 'B'
  )
}

object Day2Solution extends App {
  val instructions = Source
    .fromInputStream(System.in)
    .getLines()
    .map((line) => line.iterator.map(Direction.fromChar).toArray)
    .toArray

  val solutionA = String.valueOf(SimpleKeypad().getCode(instructions))
  println(solutionA)

  val solutionB = String.valueOf(WeirdKeypad().getCode(instructions))
  println(solutionB)
}
