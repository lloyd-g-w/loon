import "./index.css"
import * as React from "react"
import { createRoot } from "react-dom/client"
import { Toaster } from "@/registry/new-york-v4/ui/sonner"
import { TooltipProvider } from "@/registry/new-york-v4/ui/tooltip"

// Also ./parity/<name>.tsx as #/parity-<name>: pages mirroring loon examples
// that shadcn has no example of (e.g. a sidebar block in a frame).
const examples: Record<string, () => Promise<unknown>> = {
  ...import.meta.glob("./registry/examples/*.tsx"),
  ...Object.fromEntries(
    Object.entries(import.meta.glob("./parity/*.tsx")).map(([k, v]) => [
      `./registry/examples/parity-${k.slice(9)}`,
      v,
    ]),
  ),
}

function useHash() {
  const [hash, setHash] = React.useState(location.hash)
  React.useEffect(() => {
    const f = () => setHash(location.hash)
    addEventListener("hashchange", f)
    return () => removeEventListener("hashchange", f)
  }, [])
  return hash
}

// #/<example>[?export=Name]: renders examples/<example>.tsx's default export
// (or the named one), centred as on ui.shadcn.com's previews.
function App() {
  const hash = useHash()
  const [Comp, setComp] = React.useState<React.ComponentType | null>(null)
  const [, name, query] = hash.match(/^#\/([^?]*)\??(.*)$/) ?? []
  React.useEffect(() => {
    setComp(null)
    const load = examples[`./registry/examples/${name}.tsx`]
    if (!load) return
    load().then((m: any) => {
      const exp = new URLSearchParams(query).get("export")
      const c = exp ? m[exp] : m.default ?? Object.values(m).find((v) => typeof v === "function")
      setComp(() => c)
    })
  }, [name, query])
  if (!name)
    return <ul className="p-4">{Object.keys(examples).map((k) => { const n = k.slice(20, -4); return <li key={n}><a href={`#/${n}`}>{n}</a></li> })}</ul>
  return (
    <div data-ref-preview className="flex min-h-svh w-full items-center justify-center p-10">
      {/* As ui.shadcn.com, whose layout has a TooltipProvider. */}
      <TooltipProvider>{Comp ? <Comp /> : null}</TooltipProvider>
      <Toaster />
    </div>
  )
}

createRoot(document.getElementById("root")!).render(<App />)
