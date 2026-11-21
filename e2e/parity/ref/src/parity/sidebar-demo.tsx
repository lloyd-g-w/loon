// Mirrors loon's Sidebar "Demo": shadcn's sidebar-07 in the docs page's frame
// (the sidebar absolute in the frame, not fixed to the window).
import { AppSidebar } from "@/registry/new-york-v4/blocks/sidebar-07/components/app-sidebar"
import {
  SidebarInset,
  SidebarProvider,
  SidebarTrigger,
} from "@/registry/new-york-v4/ui/sidebar"

export default function SidebarDemo() {
  return (
    <div className="relative flex h-[600px] w-full overflow-hidden rounded-lg border [&_[data-slot=sidebar-container]]:absolute [&_[data-slot=sidebar-container]]:h-full">
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
