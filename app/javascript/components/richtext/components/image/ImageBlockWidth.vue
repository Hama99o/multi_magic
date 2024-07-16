<template>
  <div class="flex items-center gap-3">
    <v-slider
      v-model="currentValue"
      hide-details
      :step="10"
      :min="2"
      :max="100"
      class="w-[120px]"
      @update:model-value="handleChange"
    />
    {{ currentValue }}%
  </div>
</template>

<script setup>
import { debounce } from 'lodash';
import { ref, onMounted, watch } from 'vue';

const props = defineProps({
  width: { type: String, default: null },
})

onMounted(() => {
  currentValue.value = parseInt(props.width)
})

const emit = defineEmits(['handle-change'])

const currentValue = ref(null);

const handleChange = debounce((value) => {
  const newValue = parseInt(value);
  currentValue.value = newValue;
  emit('handle-change', currentValue.value)
}, 150);

watch(props, (newValue, oldValue) => {
  if (newValue.width) {
    currentValue.value = parseInt(props.width)
  }
})
</script>
