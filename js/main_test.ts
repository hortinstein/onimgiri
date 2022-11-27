import { assertEquals } from "https://deno.land/std@0.166.0/testing/asserts.ts";
import { add } from "./main.ts";

import { enc, dec, generateKeyPair } from "./encryption.ts";

Deno.test(function addTest() {
  assertEquals(add(2, 3), 5);
});

Deno.test(function addTest2() {
 
  const hello_world = new TextEncoder().encode("Hello World");
  const [ priv, pub ] = generateKeyPair();
  const [ priv2, pub2 ] = generateKeyPair();

  const [pub3, nonce, mac, cipher] = enc(
    priv,
    pub2,
    hello_world
  );

  const plain = dec(priv2, pub, nonce, mac, cipher);
  
  assertEquals(hello_world, plain);
}