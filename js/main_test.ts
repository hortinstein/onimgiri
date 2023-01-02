import {
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.166.0/testing/asserts.ts";

import { enc, dec, generateKeyPair } from "./encryption.ts";

import { createRequire } from "https://deno.land/std@0.103.0/node/module.ts";
const require = createRequire(import.meta.url);
const config = require("./configjs.js");

// uses the release config for the tests
const TEST_CONFIG = await Deno.readFile("../release.config")

// this function tests whether the encryption and decryption functions work
Deno.test(function encrypt_decrypt() {
  const hello_world = new TextEncoder().encode("Hello World");
  const [priv, pub] = generateKeyPair();
  const [priv2, pub2] = generateKeyPair();

  const [pub3, nonce, mac, cipher] = enc(priv, pub2, hello_world);

  const plain = dec(priv2, pub, nonce, mac, cipher);

  assertEquals(hello_world, plain);
});

// this function tests whether the release config can be loaded and decrypted
// additionally, it tests whether the callback url is correct
Deno.test(function loadconfig() {

  const config2 = config.unb64Str(TEST_CONFIG);
  const EncConfigObj = config.desEncConfig(config2);

  const privKey = new Uint8Array(EncConfigObj.privKey);
  const pubKey = new Uint8Array(EncConfigObj.pubKey);
  const nonce = new Uint8Array(EncConfigObj.encObj.nonce);
  const mac = new Uint8Array(EncConfigObj.encObj.mac);
  const cipher = new Uint8Array(EncConfigObj.encObj.cipherText);
  //console.log(EncConfigObj.encObj.ciphertext);
  const serConfigObj = dec(privKey, pubKey, nonce, mac, cipher);
  const configObj = config.desConfig(serConfigObj);
  //console.log(configObj);
  const callback = new Uint8Array(configObj.callback);
  const callbackString = new TextDecoder().decode(callback);
  const callbackTrimmed = callbackString;
  //console.log("{", callbackTrimmed, "}");
  assertStringIncludes(callbackTrimmed, "http://localhost:8080/release");
});
