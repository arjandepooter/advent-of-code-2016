#include <iostream>
#include <string>
#include <vector>

#define WIDTH 50
#define HEIGHT 6

using namespace std;

void fill_rect(bool *screen, int a, int b)
{
    for (int x = 0; x < a; x++)
        for (int y = 0; y < b; y++)
            screen[WIDTH * y + x] = true;
}

void rotate_row(bool *screen, int row, int rotate)
{
    bool new_row[WIDTH];
    rotate = rotate % WIDTH;

    for (int i = 0; i < WIDTH; i++)
    {
        int offset = (i + rotate) % WIDTH;
        new_row[offset] = screen[row * WIDTH + i];
    }

    memcpy(screen + row * WIDTH, new_row, WIDTH);
}

void rotate_col(bool *screen, int col, int rotate)
{
    bool new_col[HEIGHT];
    rotate = rotate % HEIGHT;

    for (int i = 0; i < HEIGHT; i++)
    {
        int offset = (i + rotate) % HEIGHT;
        new_col[offset] = screen[col + i * WIDTH];
    }

    for (int i = 0; i < HEIGHT; i++)
    {
        screen[col + i * WIDTH] = new_col[i];
    }
}

void build_screen(vector<string> *lines, bool *screen)
{
    fill_n(screen, WIDTH * HEIGHT, false);

    for (int i = 0; i < lines->size(); i++)
    {
        string line = lines->at(i);
        int a, b;

        if (sscanf(line.c_str(), "rect %dx%d", &a, &b))
            fill_rect(screen, a, b);
        else if (sscanf(line.c_str(), "rotate row y=%d by %d", &a, &b))
            rotate_row(screen, a, b);
        else if (sscanf(line.c_str(), "rotate column x=%d by %d", &a, &b))
            rotate_col(screen, a, b);
    }
}

void print_screen(bool *screen)
{
    for (int y = 0; y < HEIGHT; y++)
    {
        for (int x = 0; x < WIDTH; x++)
        {
            cout << (screen[y * WIDTH + x] ? "#" : " ");
        }
        cout << endl;
    }
}

int count_pixels(bool *screen)
{
    int result = 0;
    for (int i = 0; i < WIDTH * HEIGHT; i++)
    {
        if (screen[i])
            result++;
    }
    return result;
}

int solve_a(bool *screen)
{
    return count_pixels(screen);
}

int main()
{
    vector<string> lines;

    for (string line; getline(cin, line);)
        lines.push_back(line);

    bool *screen;
    build_screen(&lines, screen);

    printf("Part 1: %d\n", solve_a(screen));
    cout << "Part 2:" << endl;
    print_screen(screen);
}