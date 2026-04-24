<template>
  <v-tooltip :text="label" location="top">
    <template v-slot:activator="{ props }">
      <v-icon
        v-bind="props"
        @click="emit('click')"
        :size="isMobile ? 'small' : 'large'"
        :color="textColor"
        type="button"
        :class="[
          'inline-flex h-8 w-8 shrink-0 flex-row items-center justify-center rounded-md disabled:bg-transparent bg',
          isActive
            ? 'bg-primary hover:bg-opacity-80'
            : ' hover:bg-primary',
        ]"
        :aria-label="label"
      >
        <slot />
      </v-icon>
    </template>
  </v-tooltip>

</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { useMobileStore } from "@/stores/mobile";

const { isMobile } = storeToRefs(useMobileStore());

defineProps<{
  label: string
  isActive?: boolean,
  textColor?: String,
}>()

const emit = defineEmits(["click"])

</script>
