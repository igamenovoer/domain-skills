import { useNav, useSlideContext } from '@slidev/client'
import { toRaw } from 'vue'
import { optionalNavigation } from '../composables/optionalSlides'

export default function setupOptionalSlides(): void {
  const nav = useNav()
  const { $slidev } = useSlideContext()
  $slidev.nav = { ...toRaw($slidev).nav, ...optionalNavigation(nav) }
}
