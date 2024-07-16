<template>
  <div id="menuContainer" class="bg-white border border-gray-200 rounded-lg shadow-md p-4 flex flex-col gap-2 max-h-60 overflow-auto">
    <template v-if="items.length">
      <button
        :class="['flex items-center gap-2 px-4 py-2 w-full text-left transition-colors',
                 index === selectedIndex ? 'bg-gray-200' : 'hover:bg-gray-100']"
        v-for="(item, index) in items"
        :key="index"
        @click="selectItem(index)"
      >
        {{ item.title }}
      </button>
    </template>
    <div class="text-gray-500 p-2" v-else>
      No result
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  items: {
    type: Array,
    required: true,
  },

  command: {
    type: Function,
    required: true,
  },
})

const selectedIndex = ref(0)

watch(() => props.items, () => {
  selectedIndex.value = 0
})

const onKeyDown = ({ event }) => {
  if (event.key === 'ArrowUp') {
    upHandler()
    return true
  }

  if (event.key === 'ArrowDown') {
    downHandler()
    return true
  }

  if (event.key === 'Enter') {
    enterHandler()
    return true
  }

  return false
}

const upHandler = () => {
  selectedIndex.value = ((selectedIndex.value + props.items.length) - 1) % props.items.length
}

const downHandler = () => {
  selectedIndex.value = (selectedIndex.value + 1) % props.items.length
}

const enterHandler = () => {
  selectItem(selectedIndex.value)
}

const selectItem = (index) => {
  const item = props.items[index]

  if (item) {
    props.command(item)
  }
}
</script>
