import { assertEquals } from "https://deno.land/std@0.167.0/testing/asserts.ts";
import { carveOut } from "./main.ts";

Deno.test(function testCarve() {
  return new Promise(async () => {
    const bin = await Deno.readFile('../../bin/agent');
    const target = await Deno.readFile('../../debug.config');
    const newConfig = await Deno.readFile('../../release.config');
    carveOut(newConfig, target, bin);
  })
});
