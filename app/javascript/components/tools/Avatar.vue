<template>
  <!-- Avatar with Image -->
  <div class="relative inline-block">
    <v-avatar
      v-if="display_avatar"
      :image="avatar"
      :size="sizeList[size]"
      :class="vAvatarClass"
    />

    <!-- Avatar with Initials -->
    <v-avatar
      v-else-if="firstname"
      :color="
        colors[
          firstname.charAt(0).toUpperCase() === firstname.charAt(0)
            ? firstname.charCodeAt(0) - 65
            : firstname.charCodeAt(0) - 97
        ]
      "
      :size="sizeList[size]"
      class="select-none"
    >
      <span :class="fontSizeList[size]">
        {{ firstname?.substring(0, 1) + lastname?.substring(0, 1) }}
      </span>
    </v-avatar>

    <!-- Online/Offline Status Dot -->
    <span
      v-if="canShowOnline"
      class="absolute rounded-full border-white border-2"
      :class="[
        isOnline ? 'light' : 'bg-gray-400',
        sizeDotList[size]
      ]"
      aria-label="Online Status"
    ></span>
  </div>
</template>

<script setup>
import { ref, watch } from "vue";
import checkImageStatus from "@/tools/imageStatus.js";

const display_avatar = ref(true);

// Props: Add `isOnline` prop to track user's status
const props = defineProps({
  avatar: { type: String, default: null },
  firstname: { type: String, default: null },
  lastname: { type: String, default: null },
  size: { type: String, default: 'md' },
  alt: { type: String, default: "User profile avatar" },
  canShowOnline: { type: Boolean, default: false },
  isOnline: { type: Boolean, default: false },  // New prop for online status
  vAvatarClass: { type: String, default: '' },
});

checkImageStatus(props.avatar, (exists) => {
  display_avatar.value = exists;
});

watch(
  () => props.avatar,
  () => {
    checkImageStatus(props.avatar, (exists) => {
      display_avatar.value = exists;
    });
  }
);

// Avatar Sizes
const sizeList = ref({
  xs: 16,
  '20': 20,
  sm: 24,
  md: 32,
  lg: 40,
  xl: 64,
  '2xl': 88
})

// Font Sizes for Initials
const fontSizeList = ref({
  xs: 'text-[9px]',
  sm: 'text-[12px]',
  md: 'text-[14px]',
  lg: 'text-[16px]',
  xl: 'text-[24px]',
  '2xl': 'text-[32px]',
})

// Sizes for Online/Offline Dot
const sizeDotList = ref({
  xs: 'w-1 h-1 bottom-[2px] right-[1px]',
  sm: 'w-2 h-2 -bottom-[1px] -right-[1px]',
  md: 'w-3 h-3 -bottom-[1px] -right-[1px]',
  lg: 'w-3 h-3 bottom-0 right-0',
  xl: 'w-4 h-4 -bottom-[2px] right-2',
  '2xl': 'w-5 h-5 -bottom-[2px] right-2',
})

// xs: 'w-2 h-2 bottom-0 right-0',
//   sm: 'w-2.5 h-2.5 bottom-0 right-0',
//   md: 'w-3 h-3 bottom-0 right-0',
//   lg: 'w-3.5 h-3.5 bottom-1 right-1',
//   xl: 'w-4 h-4 bottom-1 right-1',
//   '2xl': 'w-5 h-5 bottom-2 right-2',
// Color list for initials avatar background
const colors = [
  "red lighten-1", // A
  "pink lighten-1", // B
  "purple lighten-1", // C
  "deep-purple lighten-1", // D
  "indigo lighten-1", // E
  "blue lighten-1", // F
  "light-blue lighten-1", // G
  "cyan lighten-1", // H
  "teal lighten-1", // I
  "green lighten-1", // J
  "light-green lighten-1", // K
  "lime lighten-1", // L
  "yellow lighten-1", // M
  "amber lighten-1", // N
  "orange lighten-1", // O
  "deep-orange lighten-1", // P
  "brown lighten-1", // Q
  "blue-grey lighten-1", // R
  "red lighten-1", // S
  "pink lighten-1", // T
  "purple lighten-1", // U
  "deep-purple lighten-1", // V
  "indigo lighten-1", // W
  "blue lighten-1", // X
  "light-blue lighten-1", // Y
  "cyan lighten-1", // Z
];
</script>


<style scoped>


.light {
  background-color: #84e00b;
  animation: glow 1s infinite ease-in-out;
}

@keyframes glow {
  0% {
    background-color: #84de16;
  }
  30% {
    background-color: #84de15;
    transform: rotateZ(45deg);
  }
  50% {
    background-color: #84dc18;
    transform: rotateZ(45deg);
  }
  80% {
    background-color: #84e30f;
    transform: rotateZ(45deg);
  }
  0% {
    background-color: #84e310;
    transform: rotateZ(80deg);
  }
}
</style>