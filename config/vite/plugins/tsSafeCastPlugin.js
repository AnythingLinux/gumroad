import path from "path";
import ts from "typescript";
import tsCast from "ts-safe-cast/transformer.js";

let service;
let program;

function ensureService() {
  if (service) return;
  const configPath = ts.findConfigFile(process.cwd(), ts.sys.fileExists, "tsconfig.json");
  const configFile = ts.readConfigFile(configPath, ts.sys.readFile);
  const tsConfigFile = ts.parseJsonConfigFileContent(configFile.config, ts.sys, path.dirname(configPath));
  service = ts.createLanguageService({
    getScriptFileNames: () => tsConfigFile.fileNames,
    getScriptVersion: () => "1",
    getScriptSnapshot: (fileName) => {
      if (!ts.sys.fileExists(fileName)) return undefined;
      return ts.ScriptSnapshot.fromString(ts.sys.readFile(fileName));
    },
    getCompilationSettings: () => tsConfigFile.options,
    getDefaultLibFileName: ts.getDefaultLibFilePath,
    getCurrentDirectory: ts.sys.getCurrentDirectory,
    readFile: ts.sys.readFile,
    realpath: ts.sys.realpath,
    fileExists: ts.sys.fileExists,
  });
  program = service.getProgram();
}

export default function tsSafeCastPlugin() {
  return {
    name: "vite-plugin-ts-safe-cast",
    enforce: "pre",
    transform(code, id) {
      // Only process .ts and .tsx files that might use ts-safe-cast
      if (!/\.(ts|tsx)$/u.test(id)) return null;
      if (id.includes("node_modules")) return null;
      // Quick check: does this file use cast/is/createCast/createIs from ts-safe-cast?
      if (!code.includes("ts-safe-cast")) return null;

      ensureService();

      const sourceFile = program.getSourceFile(id);
      if (!sourceFile) return null;

      const transformer = tsCast(program);
      const result = ts.transform(sourceFile, [transformer]);
      const printer = ts.createPrinter();
      const transformed = printer.printFile(result.transformed[0]);
      result.dispose();

      return { code: transformed, map: null };
    },
  };
}
