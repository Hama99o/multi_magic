<template>
  <!-- Avatar with Image -->
  <div class="relative inline-block" @mouseover="showHoverCard" @mouseleave="scheduleHideCard">
    <v-menu v-model="showCard" location="end" transition="slide-x-transition">
      <template #activator="{ props }">
        <div @click="goBack" class="flex items-center justify-between">
          <user-avatar
            :can-show-online="canShowOnline"
            :is-online="user?.is_online"
            class="mr-1 cursor-pointer"
            :size="size"
            :avatar="user?.avatar"
            :firstname="user?.lastname"
            :lastname="user?.firstname"
          />
          <slot v-if="withFullname" name="fullname">
            <span class="cursor-pointer text-sm font-semibold hover:underline">
              {{ user?.fullname }}
            </span>
          </slot>
        </div>
      </template>

      <HoverProfileInfo
        :user="user"
        :show-card="showCard"
        :card-position="cardPosition"
        @cancel-hide-card="cancelHideCard"
        @schedule-hide-card="scheduleHideCard"
      />
    </v-menu>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import HoverProfileInfo from '@/components/tools/HoverProfileInfo.vue';
import UserAvatar from '@/components/tools/Avatar.vue';
import { useRouter, useRoute } from 'vue-router';

const cardPosition = ref({ x: 0, y: 0 });
let timeout = null;
const router = useRouter();

// Props: Add `isOnline` prop to track user's status
const props = defineProps({
  user: { type: Object, default: () => {} },
  canShowOnline: { type: Boolean, default: false },
  size: { type: String },
  withFullname: { type: Boolean },
});

const showCard = ref(false);

// Show card on hover
function showHoverCard(event) {
  clearTimeout(timeout);
  cardPosition.value = { x: event.pageX + 10, y: event.pageY + 10 };
  timeout = setTimeout(() => {
    showCard.value = true;
  }, 100);
}

const goBack = () => {
  router.push({ name: 'user', params: { id: props.user?.id } });
};


// Hide card with delay to allow transition
function scheduleHideCard() {
  clearTimeout(timeout);
  timeout = setTimeout(() => {
    showCard.value = false;
  }, 1000);
}

// Prevent hiding card when hovering over it
function cancelHideCard() {
  clearTimeout(timeout);
}
</script>

<style scoped></style>
