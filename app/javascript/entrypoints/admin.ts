import "../packs/admin.scss";

import { createInertiaApp } from "@inertiajs/react";
import React, { createElement } from "react";
import { createRoot } from "react-dom/client";

import AdminAppWrapper, { GlobalProps } from "../inertia/admin_app_wrapper";
import Layout from "../layouts/Admin";

const AdminLayout = (page: React.ReactNode) => React.createElement(Layout, { children: page });

type PageComponent = React.ComponentType & { layout?: (page: React.ReactNode) => React.ReactElement };
type PageModule = { default?: unknown };

const isPageComponent = (value: unknown): value is PageComponent => typeof value === "function";

const pages: Record<string, () => Promise<PageModule>> = {
  ...import.meta.glob<PageModule>("../pages/Admin/**/*.tsx"),
  ...import.meta.glob<PageModule>("../pages/Admin/**/*.jsx"),
};

const resolvePageComponent = async (name: string): Promise<PageComponent> => {
  const tsxPath = `../pages/${name}.tsx`;
  const jsxPath = `../pages/${name}.jsx`;
  const resolver = pages[tsxPath] ?? pages[jsxPath];
  if (!resolver) {
    throw new Error(`Admin page component not found: ${name} (tried ${tsxPath}, ${jsxPath})`);
  }
  const module = await resolver();
  if (module && typeof module === "object" && "default" in module && isPageComponent(module.default)) {
    const component = module.default;
    component.layout = AdminLayout;
    return component;
  }
  throw new Error(`Invalid page component: ${name}`);
};

void createInertiaApp<GlobalProps>({
  progress: false,
  resolve: (name: string) => resolvePageComponent(name),
  setup({ el, App, props }) {
    const global = props.initialPage.props;

    const root = createRoot(el);
    root.render(createElement(AdminAppWrapper, { global, children: createElement(App, props) }));
  },
  title: (title: string) => (title ? `${title} - Admin` : "Admin"),
});
