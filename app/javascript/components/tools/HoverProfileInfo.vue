<template>
  <div @click.stop>
    <!-- Hover card -->
    <v-card
      v-show="showCard"
      class="fixed z-50 transform bg-[#161b22] p-4 shadow-lg transition-all duration-500 ease-in-out"
      :class="{ 'opacity-100': showCard, 'opacity-0': !showCard }"
      :style="{ top: `${cardPosition.y}px`, left: `${cardPosition.x}px` }"
      max-width="300"
      @mouseover="$emit('cancelHideCard')"
      @mouseleave="$emit('scheduleHideCard')"
    >
      <div @click="goBack" class="cursor-pointer flex m-1 justify-center flex-col items-center flex-wrap">
        <user-avatar
          size="lg"
          :avatar="user?.avatar"
          :firstname="user?.lastname"
          :lastname="user?.firstname"
          withFullname
        />
        <span class="hover:underline justify-center text-wrap text-center p-2">
          {{ user.fullname }}
        </span>
      </div>
      <v-card-subtitle class="text-center">
        {{ `@${user.username}` || '' }} <br />
        {{ user.birth_date || '' }}
      </v-card-subtitle>
      <!-- <v-card-text class="text-center">
        <div>1 Post karma</div>
        <div>295 Comment karma</div>
        <a href="#" class="text-yellow-400 hover:underline">What is karma?</a>
      </v-card-text> -->
      <v-divider class="my-2"></v-divider>
      <v-card-actions class="d-flex justify-space-around">
        <v-btn @click="toggleFollowUser" small color="primary" class="bg-[#5d4b2d]">
          <span :class="user?.is_following ? 'mdi mdi-account-minus' : 'mdi mdi-account-plus'"></span>{{ user?.is_following ? 'Unfollow' : 'Follow' }}
        </v-btn>
        <v-btn small outlined color="primary" class="border-gray-500">
          <v-icon left>mdi-chat</v-icon>Chat
        </v-btn>
      </v-card-actions>
    </v-card>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import UserAvatar from '@/components/tools/Avatar.vue';
import { useUserStore } from '@/stores/user.store';
import { storeToRefs } from 'pinia';
import { useRouter, useRoute } from 'vue-router';
import { useFollowStore } from '@/stores/follow.store';

const { currentUser, theme, users, isImpersonating, search, openChats } = storeToRefs(useUserStore());
const { createFollow, deleteFollow } = useFollowStore();
const router = useRouter();

const emit = defineEmits(['update-user']);

const props = defineProps({
  showCard: { type: Boolean, default: false },
  cardPosition: { type: Object, default: () => {} },
  user: { type: Object, default: () => {} },
});

const toggleFollowUser = async () => {
  if (props.user?.is_following) {
    await deleteFollow(props.user.id);
  } else {
    await createFollow(props.user.id);
  }

  emit('update-user', !props.user?.is_following)
};

// Function to open a conversation window
const openConversation = async (conversation) => {
  dropdownOpen.value = false;

  // Check if the conversation is already open
  const existingChat = openChats.value.find((chat) => chat.id === conversation.id);
  if (!existingChat) {
    // await fetchMessages(conversation.id)
    // Add the new conversation to the list of open chat windows
    openChats.value.push({ ...conversation });
  }
};

const goBack = () => {
  router.push({ name: 'user', params: { id: props.user?.id } });
};
</script>

<style scoped>
/* Tailwind classes add styling, but additional custom styles can be added here if needed */
</style>
