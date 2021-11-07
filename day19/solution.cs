using System;
using System.Linq;
using System.Collections.Generic;

class Item
{
    public Item next;
    public Item prev;
    public int value;

    public Item(int value)
    {
        this.value = value;
    }

    public void remove()
    {
        prev.next = next;
        next.prev = prev;
    }
}

class Solution
{
    static int msb(int n)
    {
        int msb = 1;
        while (n > 1)
        {
            n = n >> 1;
            msb = msb << 1;
        }

        return msb;
    }

    static int solveA(int n)
    {
        // Josephus problem:
        return n - msb(n) << 1 | 1;
    }

    static int solveB(int n)
    {
        List<Item> list = new List<Item>();
        list.AddRange(Enumerable.Range(1, n).Select(n => new Item(n)));
        for (int i = 1; i < n - 1; i++)
        {
            list[i].next = list[i + 1];
            list[i].prev = list[i - 1];
        }
        list[n - 1].next = list[0];
        list[n - 1].prev = list[n - 2];
        list[0].next = list[1];
        list[0].prev = list[n - 1];

        var current = list[0];
        var toDelete = list[n / 2];

        while (n > 1)
        {
            toDelete.remove();
            toDelete = toDelete.next;
            if (n % 2 == 1)
            {
                toDelete = toDelete.next;
            }
            current = current.next;
            n--;
        }

        return current.value;
    }

    static void Main(string[] args)
    {
        int input = Convert.ToInt32(Console.ReadLine());
        Console.WriteLine($"{solveA(input)}");
        Console.WriteLine($"{solveB(input)}");
    }
}
