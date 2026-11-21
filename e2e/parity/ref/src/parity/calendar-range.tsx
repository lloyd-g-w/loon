// loon's Calendar "Range Calendar" example, in shadcn.
import * as React from "react"
import { type DateRange } from "react-day-picker"

import { Calendar } from "@/registry/new-york-v4/ui/calendar"
import { Card, CardContent } from "@/registry/new-york-v4/ui/card"

export default function CalendarRange() {
  const today = new Date()
  const from = new Date(today.getFullYear(), 0, 12)
  const [range, setRange] = React.useState<DateRange | undefined>({
    from,
    to: new Date(from.getFullYear(), 0, 12 + 30),
  })
  return (
    <Card className="mx-auto w-fit p-0">
      <CardContent className="p-0">
        <Calendar
          mode="range"
          defaultMonth={from}
          numberOfMonths={2}
          selected={range}
          onSelect={setRange}
          disabled={(date) => date > today || date < new Date("1900-01-01")}
        />
      </CardContent>
    </Card>
  )
}
