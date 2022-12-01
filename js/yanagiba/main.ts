import { readerFromStreamReader } from "https://deno.land/std@0.167.0/streams/reader_from_stream_reader.ts";

import { serve } from "https://deno.land/std/http/mod.ts";
const SAVE_PATH = "./";

export async function carveOut(newConfig: Uint8Array, target: Uint8Array, bin: Uint8Array){
  console.log(newConfig.length, target.length, bin.length);
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