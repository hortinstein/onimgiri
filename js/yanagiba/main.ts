import { readerFromStreamReader } from "https://deno.land/std@0.167.0/streams/reader_from_stream_reader.ts";
import config from "../configjs.js";

import { serve } from "https://deno.land/std/http/mod.ts";
const SAVE_PATH = "./";


export function findCSA(arr: Uint8Array, subarr: Uint8Array, from_index: number): number {
  var i = from_index >>> 0,
    sl = subarr.length,
    l = arr.length + 1 - sl;

  loop: for (; i < l; i++) {
    for (var j = 0; j < sl; j++)
      if (arr[i + j] !== subarr[j])
        continue loop;
    return i;
  }
  return -1;
}

export function replaceCSA(arr: Uint8Array, subarr: Uint8Array, index: number): Uint8Array {
  var i = 0;
  var newarr = new Uint8Array(arr);
  while (i < subarr.length) {
    newarr[index + i] = subarr[i];
    i++;
  }
  return newarr;
}

export function carveOut(newConfig: Uint8Array, target: Uint8Array, bin: Uint8Array): Uint8Array {
  console.log(newConfig.length, target.length, bin.length);
  console.log("bin", bin, "target\n", target, "newConfig\n", newConfig);
  console.log(findCSA(bin, target, 0));
  return newConfig;

}

async function reqHandler(req: Request) {
  const url = new URL(req.url);
  const fileName = url.searchParams.get("filename") || crypto.randomUUID();
  if (!req.body) {
    return new Response(null, { status: 400 });
  }
  const reader = req?.body?.getReader();
  const f = await Deno.open(SAVE_PATH + fileName, {
    create: true,
    write: true,
  });
  await Deno.copy(readerFromStreamReader(reader), f);
  await f.close();
  return new Response();
}
serve(reqHandler, { port: 8000 });