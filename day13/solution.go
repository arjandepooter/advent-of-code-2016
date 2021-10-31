package main

import (
	"fmt"
)

type Cell struct {
	x int
	y int
}

func isWall(cell Cell, designerNumber int) bool {
	n := cell.x*cell.x + 3*cell.x + 2*cell.x*cell.y + cell.y*cell.y + cell.y + designerNumber
	onesCount := 0

	for n > 0 {
		onesCount += n & 1
		n >>= 1
	}

	return onesCount%2 == 1
}

func neighbours(cell Cell, designerNumber int) []Cell {
	var neighbours = []Cell{}

	for dx := -1; dx <= 1; dx++ {
		for dy := -1; dy <= 1; dy++ {
			neighbour := Cell{cell.x + dx, cell.y + dy}
			if (dx == 0 || dy == 0) && !(dx == 0 && dy == 0) && !isWall(neighbour, designerNumber) && neighbour.x >= 0 && neighbour.y >= 0 {
				neighbours = append(neighbours, neighbour)
			}

		}
	}

	return neighbours
}

func step(seen *map[Cell]bool, current map[Cell]bool, designerNumber int) map[Cell]bool {
	next := map[Cell]bool{}

	for prev := range current {
		(*seen)[prev] = true

		for _, neighbour := range neighbours(prev, designerNumber) {
			if _, exists := (*seen)[neighbour]; !exists {
				next[neighbour] = true
			}
		}
	}

	return next
}

func solveA(designerNumber int) int {
	destination := Cell{31, 39}

	seen := map[Cell]bool{}
	current := map[Cell]bool{{1, 1}: true}
	steps := 0

	for found := false; !found; _, found = current[destination] {
		current = step(&seen, current, designerNumber)
		steps++
	}

	return steps

}

func solveB(designerNumber int) int {
	seen := map[Cell]bool{}
	current := map[Cell]bool{{1, 1}: true}

	for steps := 0; steps < 50; steps++ {
		current = step(&seen, current, designerNumber)
	}

	return len(seen) + len(current)

}

func main() {
	var designerNumber int
	fmt.Scan(&designerNumber)

	fmt.Println(solveA(designerNumber))
	fmt.Println(solveB(designerNumber))
}
