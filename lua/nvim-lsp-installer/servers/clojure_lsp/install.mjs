const VERSION = "2021.07.01-19.49.02";

const exitNotSupported = () => {
    console.error(
        chalk.red(`${os.platform()} ${os.arch()} is currently not supported.`)
    );
    process.exit(1);
};

const target = (() => {
    switch (os.platform()) {
        case "darwin":
            return "clojure-lsp-native-macos-amd64.zip";
        case "win32": {
            exitNotSupported();
            break;
        }
        default:
            return "clojure-lsp-native-linux-amd64.zip";
    }
})();

const downloadUrl = `https://github.com/clojure-lsp/clojure-lsp/releases/download/${VERSION}/${target}`;

await $`wget ${downloadUrl}`;
await $`unzip -o ${target}`;
await $`chmod +x clojure-lsp`;
await $`rm ${target}`;
