<script setup lang="ts">
import { computed } from 'vue'
import { useNav } from '@slidev/client'
import { openOptionalSlide } from '../composables/optionalSlides'

const props = defineProps<{ to: string | number }>()
const nav = useNav()
const href = computed(() => nav.router.resolve({
  name: nav.isPresenter.value ? 'presenter' : 'play',
  params: { no: props.to },
}).href)

async function open(event: MouseEvent): Promise<void> {
  // Slidev pauses keyboard navigation while a link or button retains focus.
  (event.currentTarget as HTMLAnchorElement).blur()
  await openOptionalSlide(nav, props.to)
}
</script>

<template>
  <a
    v-if="!nav.isPrintMode.value"
    :href="href"
    class="optional-slide-link"
    @click.prevent.stop="open"
  ><slot /></a>
</template>

<style scoped>
.optional-slide-link {
  color: #0369a1;
  text-decoration: underline;
  text-underline-offset: 3px;
  white-space: nowrap;
}
.optional-slide-link:hover { color: #075985; }
</style>
