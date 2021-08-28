import { getDownloadUrl } from "./common.mjs";

await $`wget -O rust-analyzer.exe.gz ${getDownloadUrl()}`;
await $`gzip -fd rust-analyzer.exe.gz`;
