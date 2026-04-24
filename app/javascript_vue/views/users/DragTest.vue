<template>
  <v-container class="position-relative" style="height: 100vh;">
    <!-- Draggable Div -->
    <div
      class="draggable"
      :style="{ top: y + 'px', left: x + 'px' }"
      @mousedown="startDrag"
    >
      Drag me
    </div>
  </v-container>
</template>

<script setup>
import { ref } from 'vue';

const x = ref(100); // Initial X position
const y = ref(100); // Initial Y position

let offsetX = 0;
let offsetY = 0;

const startDrag = (event) => {
  offsetX = event.clientX - x.value;
  offsetY = event.clientY - y.value;

  document.addEventListener('mousemove', onDrag);
  document.addEventListener('mouseup', stopDrag);
};

const onDrag = (event) => {
  x.value = event.clientX - offsetX;
  y.value = event.clientY - offsetY;
};

const stopDrag = () => {
  document.removeEventListener('mousemove', onDrag);
  document.removeEventListener('mouseup', stopDrag);
};
</script>

<style scoped>
.draggable {
  position: absolute;
  width: 100px;
  height: 100px;
  background-color: #1976d2;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: grab;
  border-radius: 8px;
  user-select: none;
}
</style>
