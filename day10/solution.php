<?php
function add_value(&$bots, $botId, $value)
{
    if (!array_key_exists($botId, $bots)) {
        $bots[$botId] = [];
    }

    $bot = &$bots[$botId];
    $hasLow = array_key_exists("lowValue", $bot);
    $hasHigh = array_key_exists("highValue", $bot);

    if (!$hasLow) {
        $bot["lowValue"] = $value;
    } elseif (!$hasHigh) {
        if ($value > $bot["lowValue"]) {
            $bot["highValue"] = $value;
        } else {
            $bot["highValue"] = $bot["lowValue"];
            $bot["lowValue"] = $value;
        }
    }
}

$bots = array();
$outputs = array();
while ($line = readline()) {
    $parts = explode(" ", $line);

    switch ($parts[0]) {
        case "bot":
            $botId = $parts[1];
            $low = $parts[6];
            $high = $parts[11];
            $lowOutput = $parts[5] == "output";
            $highOutput = $parts[10] == "output";

            $bot = [];
            if (array_key_exists($botId, $bots)) {
                $bot = $bots[$botId];
            }
            $bots[$botId] = array_merge([
                "low" => $low,
                "high" => $high,
                "lowOutput" => $lowOutput,
                "highOutput" => $highOutput,
            ], $bot);
            break;
        case "value":
            add_value($bots, $parts[5], intval($parts[1]));
            break;
    }
}

$changes = true;
while ($changes) {
    $changes = false;

    foreach ($bots as &$bot) {
        if (!array_key_exists("processed", $bot) && array_key_exists("lowValue", $bot) && array_key_exists("highValue", $bot)) {
            if (!$bot["lowOutput"])
                add_value($bots, $bot["low"], $bot["lowValue"]);
            else
                $outputs[$bot["low"]] = $bot["lowValue"];
            if (!$bot["highOutput"])
                add_value($bots, $bot["high"], $bot["highValue"]);
            else
                $outputs[$bot["high"]] = $bot["highValue"];
            $bot["processed"] = true;
            $changes = True;
        }
    }
}

foreach ($bots as $botId => $bot) {
    if ($bot["lowValue"] == 17 && $bot["highValue"] == 61)
        printf("Part 1: %s\n", $botId);
}

printf("Part 2: %d\n", $outputs["0"] * $outputs["1"] * $outputs["2"]);
