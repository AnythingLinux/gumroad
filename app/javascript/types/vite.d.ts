declare module "*.css";
declare module "*.scss";

interface ImportMeta {
  glob<T = unknown>(pattern: string): Record<string, () => Promise<T>>;
}
