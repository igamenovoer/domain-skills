---
theme: default
routeAlias: source-a
clicks: 3
---
# Source A
<OptionalSlideLink to="detail">Open detail A</OptionalSlideLink>
<div v-click="1">A click 1</div>
<div v-click="2">A click 2</div>
<div v-click="3">A click 3</div>

---
routeAlias: detail
optionalSlide: true
hideInToc: true
---
# Detail
<OptionalSlideReturn />
<OptionalSlideLink to="nested">Open nested</OptionalSlideLink>

---
routeAlias: source-b
clicks: 2
---
# Source B
<OptionalSlideLink to="detail">Open detail B</OptionalSlideLink>
<div v-click="1">B click 1</div>
<div v-click="2">B click 2</div>

---
routeAlias: nested
optionalSlide: true
hideInToc: true
---
# Nested detail
<OptionalSlideReturn />

---
routeAlias: end
---
# End
