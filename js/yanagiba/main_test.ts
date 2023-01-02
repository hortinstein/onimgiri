import { assert, assertEquals, assertNotEquals } from "https://deno.land/std@0.167.0/testing/asserts.ts";
import { carveOut, findCSA, replaceCSA } from "./main.ts";

Deno.test(function testFindCSA() {
  return new Promise(async (resolve, reject) => {
    const bin = await Deno.readFile('../bin/agent');
    const target = await Deno.readFile('../debug.config');
    const newConfig = await Deno.readFile('../release.config');

    assert(findCSA(bin, target, 0) !== -1, "substring was not found in binary");

    resolve();
  })
});

Deno.test(function testRepCSA() {
  return new Promise(async (resolve, reject) => {
    const bin = await Deno.readFile('../bin/agent');
    const target = await Deno.readFile('../debug.config');
    const newConfig = await Deno.readFile('../release.config');

    const index = findCSA(bin, target, 0)
    const newBin = replaceCSA(bin, newConfig, index)
    assertNotEquals(newBin, bin, "binary was not replaced");

    let difference = bin.filter(x => !newBin.includes(x));
    console.log(difference);
    await Deno.writeFile('../bin/newagent', newBin)
    resolve();
  })
});
