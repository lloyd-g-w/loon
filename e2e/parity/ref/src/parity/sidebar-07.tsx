// shadcn's sidebar-07 block (a sidebar collapsing to icons) in the frame
// loon's Sidebar "Demo" example runs in.
import { AppSidebar } from "@/registry/bases/radix/blocks/sidebar-07/components/app-sidebar"
import {
  SidebarInset,
  SidebarProvider,
  SidebarTrigger,
} from "@/registry/bases/radix/ui/sidebar"

export default function Sidebar07() {
  return (
    <div className="relative flex h-[600px] w-[720px] overflow-hidden rounded-lg border [&_[data-slot=sidebar-container]]:absolute [&_[data-slot=sidebar-container]]:h-full">
      <SidebarProvider className="min-h-0">
        <AppSidebar />
        <SidebarInset>
          <header className="flex h-16 shrink-0 items-center gap-2 transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-12">
            <div className="flex items-center gap-2 px-4">
              <SidebarTrigger className="-ml-1" />
            </div>
          </header>
        </SidebarInset>
      </SidebarProvider>
    </div>
  )
}
