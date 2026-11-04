import type { LocationQuery } from 'vue-router'
import type { useNav } from '@slidev/client'
import { computed, ref } from 'vue'

type Navigation = ReturnType<typeof useNav>
type Slide = Navigation['slides']['value'][number]
interface ReturnLocation {
  path: string
  query: LocationQuery
  hash: string
}

const origins = ref<ReturnLocation[]>([])
let returning = false

export const hasOptionalOrigin = computed(() => origins.value.length > 0)

function isOptional(slide: Slide | undefined): boolean {
  return slide?.meta.slide.frontmatter.optionalSlide === true
}

function resolveSlide(nav: Navigation, no: string | number): Slide | undefined {
  return nav.slides.value.find(slide =>
    slide.no === Number(no) || slide.meta.slide.frontmatter.routeAlias === no,
  )
}

export function optionalNavigation(nav: Navigation) {
  function adjacent(direction: 1 | -1): Slide | undefined {
    const slides = nav.slides.value
    for (let index = nav.currentPage.value - 1 + direction; index >= 0 && index < slides.length; index += direction) {
      if (!isOptional(slides[index]))
        return slides[index]
    }
  }

  async function move(direction: 1 | -1, lastClicks = false): Promise<void> {
    const target = adjacent(direction)
    if (target)
      await nav.go(target.no, lastClicks ? nav.getPrimaryClicks(target).total : 0)
  }

  // Record the actual origin route, including its click position. This also
  // works for direct links, presenter/viewer synchronization, and nested visits.
  nav.router.afterEach((to, from, failure) => {
    if (failure || returning)
      return
    const target = resolveSlide(nav, String(to.params.no ?? ''))
    const origin = resolveSlide(nav, String(from.params.no ?? ''))
    if (target && origin && target.no === origin.no)
      return
    if (isOptional(target) && origin) {
      origins.value.push({ path: from.path, query: { ...from.query }, hash: from.hash })
    }
    else if (!isOptional(target)) {
      origins.value = []
    }
  })

  return {
    nextRoute: computed(() => adjacent(1) ?? nav.currentSlideRoute.value),
    prevRoute: computed(() => adjacent(-1) ?? nav.currentSlideRoute.value),
    hasNext: computed(() => nav.clicks.value < nav.clicksTotal.value || adjacent(1) !== undefined),
    hasPrev: computed(() => nav.clicks.value > nav.clicksStart.value || adjacent(-1) !== undefined),
    nextSlide: (lastClicks = false) => move(1, lastClicks),
    prevSlide: (lastClicks = false) => move(-1, lastClicks),
    async next(): Promise<void> {
      if (nav.clicks.value < nav.clicksTotal.value)
        await nav.next()
      else
        await move(1)
    },
    async prev(): Promise<void> {
      if (nav.clicks.value > nav.clicksStart.value)
        await nav.prev()
      else
        await move(-1, true)
    },
  }
}

export async function openOptionalSlide(nav: Navigation, target: string | number): Promise<void> {
  if (!isOptional(resolveSlide(nav, target)))
    throw new Error(`Optional slide not found: ${target}`)
  await nav.go(target)
}

export async function returnFromOptionalSlide(nav: Navigation): Promise<void> {
  const origin = origins.value.pop()
  if (!origin) {
    if (nav.router.hasRoute('overview')) {
      await nav.router.push({ name: 'overview' })
    }
    else {
      const start = nav.slides.value.find(slide => !isOptional(slide))
      if (start)
        await nav.go(start.no)
    }
    return
  }
  returning = true
  try {
    await nav.router.push(origin)
  }
  finally {
    returning = false
  }
}
