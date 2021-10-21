#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

struct Vec
{
    int x, y;
};

struct Seen
{
    // 2000 should be enough right?
    struct Vec points[1000];
    int count;
} seen;

void rotate(struct Vec *v, bool reverse)
{
    v->x = v->x ^ v->y;
    v->y = v->x ^ v->y;
    v->x = v->x ^ v->y;

    if (reverse)
        v->x = v->x * -1;
    else
        v->y = v->y * -1;
}

void addSeen(struct Vec *point)
{
    seen.points[seen.count] = *point;
    seen.count++;
}

struct Vec getDoubleVisit()
{
    for (int start = 0; start < seen.count; start++)
    {
        struct Vec p1 = seen.points[start];

        for (int stop = start + 1; stop < seen.count; stop++)
        {
            struct Vec p2 = seen.points[stop];

            if (p1.x == p2.x && p1.y == p2.y)
                return p1;
        }
    }
}

int main()
{
    struct Vec direction = {0, 1};
    struct Vec location = {0, 0};

    char d;
    int offset;

    addSeen(&location);

    while (scanf("%c%d, ", &d, &offset) > 0)
    {
        // rotate the direction vector
        rotate(&direction, d == 'L');

        for (int i = 1; i <= offset; i++)
        {
            // Just add every in between point to the list of seen points.
            // Not very efficient but good enough for this problem.
            // Better would be to store the linesegments and check
            // for intersections
            struct Vec between = {location.x + i * direction.x, location.y + i * direction.y};
            addSeen(&between);
        }

        // move to direction
        location.x += direction.x * offset;
        location.y += direction.y * offset;
    }

    // Part 1
    printf("%d\n", abs(location.x) + abs(location.y));

    // Part 2
    struct Vec bunny = getDoubleVisit();
    printf("%d\n", abs(bunny.x) + abs(bunny.y));
}
