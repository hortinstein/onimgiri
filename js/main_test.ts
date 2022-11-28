import {
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.166.0/testing/asserts.ts";

import { enc, dec, generateKeyPair } from "./encryption.ts";

import { createRequire } from "https://deno.land/std@0.103.0/node/module.ts";
const require = createRequire(import.meta.url);
const config = require("./configjs.js");

//this is a test release configuration to test loading and parsing
const TEST_CONFIG = new TextEncoder().encode(
  "AG6xAI4kzBVcuVY6aI7UxD5UkiypM_x4qSkoiiDR844eOmHGcgCC79FypQp7EyghX6ELlSogVwlkFn0IavOdeyk6YcZyAILv0XKlCnsTKCFfoQuVKiBXCWQWfQhq8517Kd5kydlXV2IZZu__sUc2WrVp6583ROO8KiOCBX4j7kh9dCexotZpXmtFAQAAAAAAAEUBAAAAAAAAk7baEWKLuRaXc0C6l5g95F1ACLqqKpobjtOEjQG-12JWnaPwtoscxF2X9l_Gs8zoTh9EgGrfgjqzOwkohJziQ4gbw0-_Tu21k18C8zGqluwX0En2Beu05gSxPEpMYPNEnnewUu4qjdyuEwodeL5Q2TNl5oIBOtXlLwrorkrTYrrYZlvNzaluJPVex7-MgVJuX3WPjcN-V0Hx9xAZ15ONRkSdzghR4ti2Xik-frgrYiXcihPGHvUrCaQEg2gpQX6DseWo0Ft6Hq4wkSRXoNSaljXC2atWmrAL7qTJ0W_D5avW61_WApTlZQWaqlo2-NoJGiW3hs4FKUwWMz97XuMqMF-elX2nUlbyljfjWQQSUDHNVq5JTYj04rZER87BNkJ61lDpMQf4IhoZOlC0aW8hvMNrZ5LrmgM2iCVKDfJhTCeELbNQ2g=="
);

Deno.test(function encrypt_decrypt() {
  const hello_world = new TextEncoder().encode("Hello World");
  const [priv, pub] = generateKeyPair();
  const [priv2, pub2] = generateKeyPair();

  const [pub3, nonce, mac, cipher] = enc(priv, pub2, hello_world);

  const plain = dec(priv2, pub, nonce, mac, cipher);

  assertEquals(hello_world, plain);
});

Deno.test(function loadconfig() {
  const config2 = config.unb64Str(TEST_CONFIG);
  const EncConfigObj = config.desEncConfig(config2);

  const privKey = new Uint8Array(EncConfigObj.privKey);
  const pubKey = new Uint8Array(EncConfigObj.pubKey);
  const nonce = new Uint8Array(EncConfigObj.encObj.nonce);
  const mac = new Uint8Array(EncConfigObj.encObj.mac);
  const cipher = new Uint8Array(EncConfigObj.encObj.cipherText);
  console.log(EncConfigObj.encObj.ciphertext);
  const serConfigObj = dec(privKey, pubKey, nonce, mac, cipher);
  const configObj = config.desConfig(serConfigObj);
  console.log(configObj);
  const callback = new Uint8Array(configObj.callback);
  const callbackString = new TextDecoder().decode(callback);
  const callbackTrimmed = callbackString;
  console.log("{", callbackTrimmed, "}");
  assertStringIncludes(callbackTrimmed, "http://localhost:8080/release");
});
