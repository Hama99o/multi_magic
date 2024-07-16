<template>
  <v-progress-circular
    :model-value="modelValue"
    :color="color"
    :bg-color="bgColor"
    :indeterminate="indeterminate"
    :size="size ?? loadingSizeList[loadingSize]"
    :width="width ?? loadingWidthList[loadingSize]"
  >
    <template #default>
      <slot></slot>
    </template>
  </v-progress-circular>
</template>

<script setup>
import { ref } from "vue";

const emit = defineEmits(['update:modelValue']);

const loadingSizeList = ref({
  xs: 16,
  md: 24,
  lg: 32,
  xl: 60,
});

const loadingWidthList = ref({
  xs: 2,
  md: 3,
  lg: 4,
  xl: 6,
})

const props = defineProps({
  loadingSize: { type: String, default: 'xs'},
  modelValue: { type: String, default: null },
  color: { type: String, default: "primary" },
  bgColor: { type: String, default: "#F6F6F6" },
  size: { type: String, default: null },
  indeterminate: { type: Boolean, default: true },
  width: { type: String, default: null },
})
</script>
