import { PageLayout, SharedLayout } from "./quartz/cfg"
import * as Component from "./quartz/components"

// components shared across all pages
export const sharedPageComponents: SharedLayout = {
  head: Component.Head(),
  header: [],
  afterBody: [],
  footer: Component.Footer({
    links: {
      GitHub: "https://github.com/jackyzha0/quartz",
      "Discord Community": "https://discord.gg/cRFFHYye7t",
    },
  }),
}

// components for pages that display a single page (e.g. a single note)
// Explorer: keep each story series in reading order ("Start here" first, then Parts I to III).
// Everything else keeps Quartz's default: folders first, then alphabetical.
const explorerOpts = {
  // Inside each series folder, show the series page as "Start here" so the
  // folder name and its first entry do not repeat. Only the sidebar label changes.
  mapFn: (node: any) => {
    if (!node.isFolder && (node.displayName === "The Second Sun" || node.displayName === "The Third Rome")) {
      node.displayName = "Start here"
    }
  },
  sortFn: (a: any, b: any) => {
    const seriesOrder = [
      "The Second Sun", "The Third Rome",
      "Start here", "The Crease", "The Fold", "The Shape",
      "Wind of Change", "Not One Inch", "A Fourth There Shall Not Be",
    ]
    const ia = seriesOrder.indexOf(a.displayName)
    const ib = seriesOrder.indexOf(b.displayName)
    if (ia !== -1 && ib !== -1 && ia !== ib) return ia - ib
    if ((!a.isFolder && !b.isFolder) || (a.isFolder && b.isFolder)) {
      return a.displayName.localeCompare(b.displayName, undefined, { numeric: true, sensitivity: "base" })
    }
    return !a.isFolder && b.isFolder ? 1 : -1
  },
}

export const defaultContentPageLayout: PageLayout = {
  beforeBody: [
    Component.ConditionalRender({
      component: Component.Breadcrumbs(),
      condition: (page) => page.fileData.slug !== "index",
    }),
    Component.ArticleTitle(),
    Component.ContentMeta(),
    Component.TagList(),
  ],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Flex({
      components: [
        {
          Component: Component.Search(),
          grow: true,
        },
        { Component: Component.Darkmode() },
        { Component: Component.ReaderMode() },
      ],
    }),
    Component.Explorer(explorerOpts),
  ],
  right: [
    Component.Graph(),
    Component.DesktopOnly(Component.TableOfContents()),
    Component.Backlinks(),
  ],
}

// components for pages that display lists of pages  (e.g. tags or folders)
export const defaultListPageLayout: PageLayout = {
  beforeBody: [Component.Breadcrumbs(), Component.ArticleTitle(), Component.ContentMeta()],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Flex({
      components: [
        {
          Component: Component.Search(),
          grow: true,
        },
        { Component: Component.Darkmode() },
      ],
    }),
    Component.Explorer(explorerOpts),
  ],
  right: [],
}
