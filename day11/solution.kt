import kotlin.math.abs

typealias PositionMap = Map<Item, Int>

enum class ItemType {
    CHIP,
    GENERATOR;

    companion object {
        fun fromString(s: String): ItemType {
            return when (s) {
                "generator" -> ItemType.GENERATOR
                "microchip" -> ItemType.CHIP
                else -> error("unknown itemtype")
            }
        }
    }
}

data class Item(val material: String, val type: ItemType) {
    fun counterPart(): Item {
        return when (type) {
            ItemType.CHIP -> copy(type = ItemType.GENERATOR)
            ItemType.GENERATOR -> copy(type = ItemType.CHIP)
        }
    }
}

fun <T> pairs(it: Iterable<T>) =
        sequence<Pair<T, T>> {
            val lst = it.toList()

            for (i in (0..lst.size - 2)) {
                for (j in (i + 1..lst.size - 1)) {
                    yield(Pair(lst[i], lst[j]))
                }
            }
        }

data class State(val elevator: Int, val positions: PositionMap) {
    fun isCompleted(): Boolean {
        return positions.values.all({ it == 4 })
    }

    fun nextStates(): Iterable<State> {
        val newFloors =
                when (elevator) {
                    1 -> listOf(2)
                    2 -> listOf(1, 3)
                    3 -> listOf(2, 4)
                    4 -> listOf(3)
                    else -> listOf()
                }

        return newFloors
                .flatMap { floor ->
                    val singleCarries =
                            currentItems().map {
                                val newPositions = positions.toMutableMap()
                                newPositions[it] = floor
                                copy(elevator = floor, positions = newPositions)
                            }
                    val doubleCarries =
                            pairs(currentItems()).toList().map {
                                val (a, b) = it
                                val newPositions = positions.toMutableMap()
                                newPositions[a] = floor
                                newPositions[b] = floor

                                copy(elevator = floor, positions = newPositions)
                            }

                    listOf(singleCarries, doubleCarries).flatten()
                }
                .filter({ it.isValid() })
    }

    fun currentItems(): Set<Item> {
        return positions.filter({ it.value == elevator }).keys
    }

    fun isValid(): Boolean {
        return positions.filterKeys { it.type == ItemType.CHIP }.all {
            positions.get(it.key.counterPart()) == it.value || !floorContainsGenerator(it.value)
        }
    }

    fun floorContainsGenerator(floor: Int): Boolean {
        return positions.any { it.value == floor && it.key.type == ItemType.GENERATOR }
    }

    fun score(): Int {
        val scores: List<Int> =
                positions.entries.map {
                    val offsetFromGoal = 4 - it.value
                    val counterPartFloor = positions.get(it.key.counterPart())!!
                    val offsetFromPair = 1 + abs(it.value - counterPartFloor)

                    offsetFromGoal * offsetFromPair
                }

        return scores.sum()
    }
}

fun readLines(): List<String> {
    return generateSequence(::readLine).toList()
}

fun linesToState(lines: List<String>): State {
    val positions: List<Pair<Item, Int>> =
            lines.flatMap {
                val (prefix, rest) = it.split(" floor contains ")

                if (rest == "nothing relevant.") {
                    listOf<Pair<Item, Int>>()
                } else {
                    val floor: Int =
                            when (prefix.replace("The ", "")) {
                                "first" -> 1
                                "second" -> 2
                                "third" -> 3
                                "fourth" -> 4
                                else -> 0
                            }
                    rest.split(", and ", "and ", ", ").map {
                        var (_, material, type) = it.split(' ')

                        material = material.split('-')[0]
                        val itemType = ItemType.fromString(type.trimEnd({ it == '.' }))

                        Pair(Item(material, itemType), floor)
                    }
                }
            }

    return State(1, mapOf(*positions.toTypedArray()))
}

// Not ideal but it does the job ...
fun pruneStates(states: Set<State>): Set<State> {
    val minScore = states.map { it.score() }.minOrNull()!!
    return states.toList().filter { it.score() < minScore + 15 }.toSet()
}

fun solve(state: State): Int {
    var steps = 0
    var states: Set<State> = hashSetOf(state)
    var seenStates: Set<State> = HashSet<State>()

    while (states.none({ it.isCompleted() })) {
        seenStates = seenStates.plus(states)
        states = pruneStates(states)
        states = states.flatMap({ it.nextStates() }).toHashSet().minus(seenStates)

        steps++
    }

    return steps
}

fun solveA(state: State) {
    println(solve(state))
}

fun solveB(state: State) {
    val newPositions = state.positions.toMutableMap()
    newPositions.put(Item("elerium", ItemType.CHIP), 1)
    newPositions.put(Item("elerium", ItemType.GENERATOR), 1)
    newPositions.put(Item("dilithium", ItemType.CHIP), 1)
    newPositions.put(Item("dilithium", ItemType.GENERATOR), 1)

    println(solve(state.copy(positions = newPositions)))
}

fun main() {
    val lines = readLines()
    val initialState = linesToState(lines)

    solveA(initialState)
    solveB(initialState)
}
