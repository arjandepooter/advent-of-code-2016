val scala3Version = "3.0.2"

lazy val root = project
  .in(file("."))
  .settings(
    name := "AoC2016 day 2",
    version := "0.1.0-SNAPSHOT",
    scalaVersion := scala3Version
  )

Compile / scalaSource := baseDirectory.value
run / connectInput := true
run / fork := true
