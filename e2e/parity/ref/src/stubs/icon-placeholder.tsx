// shadcn's create app renders the chosen icon library; here, Lucide.
import * as Lucide from "lucide-react"

export function IconPlaceholder({ lucide, tabler, hugeicons, phosphor, remixicon, ...props }: any) {
  const Icon = (Lucide as any)[lucide] ?? (Lucide as any)[lucide.replace(/Icon$/, "")]
  return Icon ? <Icon {...props} /> : null
}
