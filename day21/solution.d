import std.stdio;
import std.format;
import std.algorithm;
import std.array;
import std.range;

enum MutationType
{
    RotateByN,
    RotateByChar,
    SwapByPosition,
    SwapByChar,
    Reverse,
    Move
}

struct Mutation
{
    MutationType type;
    int p1, p2;
    char ch1, ch2;
    bool reverse;

    this(MutationType type)
    {
        this.type = type;
    }

    public static Mutation parse(string line)
    {
        Mutation function(string)[] parsers = [
            &parseRotateByN, &parseRotateByChar, &parseSwapByChar,
            &parseSwapByPosition, &parseReverse, &parseMove
        ];

        foreach (parser; parsers)
        {
            try
            {
                return parser(line);
            }
            catch (Exception e)
            {
            }
        }

        return Mutation();
    }

    public void apply(char[]* password) const
    {
        debug writeln(this);
        switch (this.type)
        {
        case MutationType.RotateByN:
            password.rotateByN(this.p1, this.reverse);
            break;
        case MutationType.SwapByPosition:
            password.swapByPosition(this.p1, this.p2);
            break;
        case MutationType.SwapByChar:
            password.swapByChar(this.ch1, this.ch2);
            break;
        case MutationType.RotateByChar:
            password.rotateByChar(this.ch1);
            break;
        case MutationType.Reverse:
            password.reverseRange(this.p1, this.p2);
            break;
        case MutationType.Move:
            password.move(this.p1, this.p2);
            break;
        default:
            break;
        }
        debug writeln(*password);
    }
}

void rotateByN(char[]* password, int n, bool reverse)
{
    if (reverse)
    {
        bringToFront((*password)[0 .. n], (*password)[n .. $]);
    }
    else
    {
        bringToFront((*password)[n .. $], (*password)[0 .. n]);
    }
}

void swapByPosition(char[]* password, int p1, int p2)
{
    swap((*password)[p1], (*password)[p2]);
}

void swapByChar(char[]* password, char ch1, char ch2)
{
    const auto p1 = countUntil(*password, ch1);
    const auto p2 = countUntil(*password, ch2);

    swap((*password)[p1], (*password)[p2]);
}

void rotateByChar(char[]* password, char ch)
{
    auto n = 1 + countUntil(*password, ch);

    bringToFront((*password)[n .. $], (*password)[0 .. n]);
    if (n > 4)
    {
        bringToFront((*password)[1 .. $], (*password)[0 .. 1]);
    }
}

void reverseRange(char[]* password, int p1, int p2)
{
    reverse((*password)[p1 .. p2 + 1]);
}

void move(char[]* password, int p1, int p2)
{
    const char toMove = (*password)[p1];
    *password = (*password).remove(p1);
    (*password).insertInPlace(p2, toMove);
}

Mutation parseRotateByN(string line)
{
    Mutation m = Mutation(MutationType.RotateByN);
    string direction;

    formattedRead(line.dup, "rotate %s %d step", &direction, &m.p1);

    m.reverse = direction == "left";

    return m;
}

Mutation parseSwapByPosition(string line)
{
    Mutation m = Mutation(MutationType.SwapByPosition);

    formattedRead(line.dup, "swap position %d with position %d", &m.p1, &m.p2);

    return m;
}

Mutation parseSwapByChar(string line)
{
    Mutation m = Mutation(MutationType.SwapByChar);

    formattedRead(line.dup, "swap letter %c with letter %c", &m.ch1, &m.ch2);

    return m;
}

Mutation parseRotateByChar(string line)
{
    Mutation m = Mutation(MutationType.RotateByChar);

    formattedRead(line.dup, "rotate based on position of letter %c", &m.ch1);

    return m;
}

Mutation parseReverse(string line)
{
    Mutation m = Mutation(MutationType.Reverse);

    formattedRead(line.dup, "reverse positions %d through %d", &m.p1, &m.p2);

    return m;
}

Mutation parseMove(string line)
{
    Mutation m = Mutation(MutationType.Move);

    formattedRead(line.dup, "move position %d to position %d", &m.p1, &m.p2);

    return m;
}

void scramble(char[]* password, Mutation[] mutations)
{
    foreach (mutation; mutations)
    {
        mutation.apply(password);
    }
}

string solveA(Mutation[] mutations)
{
    char[] password = "abcdefgh".dup;

    (&password).scramble(mutations);

    return password.dup;
}

string solveB(Mutation[] mutations)
{

    string target = "fbgdceah";
    byte[] passwordChars = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

    foreach (perm; passwordChars.permutations())
    {
        char[] password = (cast(char[]) array(perm));
        string result = password.dup;

        (&password).scramble(mutations);

        if (password == target)
        {
            return result;
        }
    }

    return target;
}

void main()
{
    Mutation[] mutations;
    auto mutationAppender = appender(&mutations);
    string line;

    while ((line = readln()) !is null)
    {
        mutationAppender ~= Mutation.parse(line);
    }

    writeln(solveA(mutations));
    writeln(solveB(mutations));
}
