<script setup lang="ts">
import { useNav } from '@slidev/client'
import { hasOptionalOrigin, returnFromOptionalSlide } from '../composables/optionalSlides'

const nav = useNav()

async function goBack(event: MouseEvent): Promise<void> {
  (event.currentTarget as HTMLButtonElement).blur()
  await returnFromOptionalSlide(nav)
}
</script>

<template>
  <button
    v-if="!nav.isPrintMode.value"
    type="button"
    class="optional-slide-return"
    @click.stop="goBack"
  >{{ hasOptionalOrigin ? '← Return' : nav.router.hasRoute('overview') ? '← Overview' : '← Start' }}</button>
</template>

<style scoped>
.optional-slide-return {
  color: #0369a1;
  text-decoration: underline;
  text-underline-offset: 3px;
  cursor: pointer;
  white-space: nowrap;
}
.optional-slide-return:hover { color: #075985; }
</style>
