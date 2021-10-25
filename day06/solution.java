import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.Collections;

class Solution {
    private static String[] readLines() {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        return br.lines().toArray(String[]::new);

    }

    public static void main(String[] args) {
        var lines = readLines();
        var counts = new HashMap<Integer, HashMap<Character, Integer>>();

        for (String line : lines) {
            for (int i = 0; i < line.length(); i++) {
                var chr = line.charAt(i);
                counts.putIfAbsent(i, new HashMap<Character, Integer>());

                var current = counts.get(i).getOrDefault(chr, 0);
                counts.get(i).put(chr, current + 1);
            }
        }

        System.out.print("Part 1: ");
        for (int i = 0; i < counts.size(); i++) {
            var c = counts.get(i);
            var max = Collections.max(c.entrySet(), Map.Entry.comparingByValue());
            System.out.print(max.getKey());

        }
        System.out.print("\n");

        System.out.print("Part 2: ");
        for (int i = 0; i < counts.size(); i++) {
            var c = counts.get(i);
            var min = Collections.min(c.entrySet(), Map.Entry.comparingByValue());
            System.out.print(min.getKey());
        }
        System.out.print("\n");
    }
}