<template>
  <!-- Chat Window -->
  <div class="flex-grow flex flex-col bg-surface">
    <div class="flex items-center gap-5 justify-between rounded-t-lg p-2  bg-secondary">
      <div class="flex items-center gap-4">
        <!-- Floating button to open sidebar when hidden -->
        <v-btn
          icon
          :size="isMobile ? 'small' : 'large'"
          v-if="!isSidebarVisible"
          @click="$emit('toggleSidebar')"
        >
          <v-icon class="text-primary text-lg">mdi-chevron-right</v-icon>
        </v-btn>

        <!-- User Avatar and Info -->
        <user-avatar
          canShowOnline
          :isOnline="selectedConversation?.user?.is_online"
          @click.prevent="$emit('goToProfile', selectedConversation?.user?.id)"
          class="cursor-pointer"
          size="lg"
          :avatar="selectedConversation?.user?.avatar"
          :firstname="selectedConversation?.user?.lastname"
          :lastname="selectedConversation?.user?.firstname"
          :is-group="selectedConversation?.is_group"
        />

        <div class="flex flex-col">
          <!-- User Name, Email, and Link to Profile -->
          <div>
            <span
             @click.prevent="$emit('goToProfile', selectedConversation?.user?.id)"
            class="cursor-pointer hover:underline"
            >
              {{ selectedConversation?.user?.fullname }}
            </span>
            <br/>
            <span class="text-sm">
              {{ selectedConversation?.user?.email }}
            </span>
          </div>
        </div>
      </div>

      <!-- Placeholder for any additional options you might want -->
      <div class="flex">
        <!-- <v-btn icon :size="isMobile ? 'x-small' : 'large'" :disabled="true">
          <v-icon>mdi-phone</v-icon>
        </v-btn>
        <v-btn icon :size="isMobile ? 'x-small' : 'large'" class="ml-2" :disabled="true">
          <v-icon>mdi-video</v-icon>
        </v-btn>
        <v-btn icon :size="isMobile ? 'x-small' : 'large'" class="ml-2" :disabled="true">
          <v-icon>mdi-information-outline</v-icon>
        </v-btn> -->

        <v-menu>
          <template v-slot:activator="{ props }">
            <v-btn  v-bind="props" icon :size="isMobile ? 'small' : 'large'" class="ml-2">
              <v-icon>mdi-dots-vertical</v-icon>
            </v-btn>
          </template>
            <v-list dense>
              <v-list-item @click="$emit('softDeleteConversation', selectedConversation.id)">
                <v-list-item-title v-if="selectedConversation.can_delete" class="flex gap-3">
                  <v-icon class="text-primary">mdi-delete</v-icon>
                  Delete Conversation
                </v-list-item-title>
                <v-list-item-title v-else class="flex gap-3">
                  <v-icon class="text-primary">mdi mdi-close</v-icon>
                  Leave Conversation
                </v-list-item-title>
              </v-list-item>
            </v-list>
        </v-menu>
      </div>
    </div>

    <!-- Chat Messages Area -->
    <div class="flex flex-col-reverse space-y-4 overflow-y-auto h-full" ref="chatMessages">
      <MessageList
        :messages="selectedConversationMessages"
        :conversation="selectedConversation"
        :current-user-id="currentUser.id"
        @loadMoreData="loadMoreData"
        @goToProfile="$emit('goToProfile', $event)"
      />
    </div>

    <small class="p-4 text-primary" v-if="isTyping">
      {{ typingUser?.lastname }} is typing<span class="dots"></span>
    </small>

    <div class="border-t border-gray-200 p-4 " :class="isFocused ? '' : 'md:!mb-0 mb-[80px]'">
      <v-text-field
        v-model="newMessage"
        placeholder="Type a message..."
        append-icon="mdi-send"
        @click:append="$emit('sendMessage', newMessage), newMessage = ''"
        @keyup.enter="$emit('sendMessage', newMessage), newMessage = ''"
        @focus="isFocused = true"
        @blur="isFocused = false"
        dense
        class="rounded-lg"
        variant="solo-filled"
        @input="startTyping"
      >
        <!-- Emoji Picker Button -->
        <template #prepend>
          <v-menu
            v-model="emojiMenu"
            offset-y
            transition="scale-transition"
            close-on-content-click
          >
            <template #activator="{ props }">
              <v-btn icon v-bind="props">
                <v-icon>mdi-emoticon-outline</v-icon>
              </v-btn>
            </template>

            <!-- Emoji Picker -->
            <EmojiPicker @click.stop :native="true" @select="appendEmoji" />
          </v-menu>
        </template>
      </v-text-field>
    </div>
  </div>
</template>

<script setup>
import UserAvatar from '@/components/tools/Avatar.vue';
import { ref, watch, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import { useUserStore } from '@/stores/user.store';
import { useMobileStore } from "@/stores/mobile";
import { useRoute } from 'vue-router';
import filters from "@/tools/filters";
import EmojiPicker from 'vue3-emoji-picker'
import 'vue3-emoji-picker/css'
import { useConversationStore } from '@/stores/conversation.store';
import MessageList from '@/components/conversation/MessageList.vue';

const { isTyping, typingUser, page, pagination } = storeToRefs(useConversationStore());
const route = useRoute();
const { isMobile } = storeToRefs(useMobileStore());
const props = defineProps({
  selectedConversationMessages: { type: Array, default: () => [] },
  selectedConversation: { type: Object, default: () => {} },
  currentUser: { type: Object, default: () => {} },
  isSidebarVisible: { type: Boolean, default: false }
});

const emits = defineEmits(['updateIsTyping', 'loadMoreData'])
// Function to append emoji to input
const appendEmoji = (emoji) => {
  newMessage.value += emoji.i // Use 'i' property to get the emoji character
  emojiMenu.value = false
}

const isFocused = ref(false)

const { currentUser } = storeToRefs(useUserStore());
const newMessage = ref('');
const emojiMenu = ref(false)

onMounted(async() => {
})
watch(route, () => {
  newMessage.value = ''
})

const startTyping = () => {
  emits('updateIsTyping');
}

async function loadMoreData ({ done }) {
  emits('loadMoreData', { done })
}
</script>

<style scoped>
.dots::after {
  content: '.';
  animation: dotAnimation 1.5s steps(4, end) infinite;
}

@keyframes dotAnimation {
  0% {
    content: '.';
  }
  25% {
    content: '..';
  }
  50% {
    content: '...';
  }
  75% {
    content: '....';
  }
  85% {
    content: '.....';
  }
  100% {
    content: '';
  }
}
</style>