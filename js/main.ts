import {
  objectId,
  getDate,
  decodeString,
  isValid,
} from "https://deno.land/x/objectid@0.2.0/mod.ts";
import { encodeToString } from "https://deno.land/std@0.95.0/encoding/hex.ts";
import { createRequire } from "https://deno.land/std@0.103.0/node/module.ts";

const require = createRequire(import.meta.url);

export function add(a: number, b: number): number {
  return a + b;
}
const config = require("./configjs.js");

import { enc, dec, generateKeyPair } from "./encryption.ts";

// Learn more at https://deno.land/manual/examples/module_metadata#concepts
if (import.meta.main) {
}
