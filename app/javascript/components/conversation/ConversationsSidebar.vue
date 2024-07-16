<template>
  <div
    v-if="isSidebarVisible"
    class="w-full border-r border-gray-200 flex flex-col relative bg-background  min-w-[270px]"
    :style="{ width: isSidebarVisible ? sidebarWidth + 'px' : '0px' }"
  >
    <div class="p-4 border-b border-gray-200">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-2xl font-bold">Chats {{ unreadMessagesCount }}</h2>
        <div>
          <v-btn icon :size="isMobile ? 'small' : 'large'" @click="$emit('openShowNewConversationModal')">
            <v-icon  class="text-primary">mdi-pencil</v-icon>
          </v-btn>

          <!-- Toggle Button to close the sidebar -->
          <v-btn
            icon
            class="ml-2"
            v-if="isSidebarVisible"
            :size="isMobile ? 'small' : 'large'"
            @click="$emit('toggleSidebar')"
          >
            <v-icon class="text-primary">mdi-chevron-left</v-icon>
          </v-btn>
        </div>
      </div>


    </div>

    <div class="flex-grow overflow-y-auto">
      <!-- Conversations list -->
      <ConversationList
        :conversations="conversations"
        :conversationId="conversationId"
        isOverflowHidden
        :currentUserId="currentUserId"
        height="100%"
        @selectConversation="$emit('selectConversation', $event)"
        @loadMoreData="loadMoreData"
        @searchConversation="$emit('searchConversation', $event)"
      />
    </div>

    <!-- Resizable handle -->
    <div
      class="absolute top-0 right-0 h-full w-1 bg-gray-600 cursor-ew-resize"
      @mousedown="startResize"
    ></div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useMobileStore } from "@/stores/mobile";
import { storeToRefs } from 'pinia';
import { useConversationStore } from '@/stores/conversation.store';
import ConversationList from '@/components/conversation/ConversationList.vue';

const { isMobile } = storeToRefs(useMobileStore());
const { conversations } = storeToRefs(useConversationStore());

const props = defineProps({
  conversations: { type: Array, default: () => [] },
  messages: { type: Array, default: () => [] },
  conversationId: { type: Number, default: undefined },
  isSidebarVisible: { type: Boolean, default: false },
  currentUserId: { type: Number, default: undefined },
  unreadMessagesCount: { type: Number, default: 0 }
});

const emits = defineEmits(['loadMoreData'])
const selectedConversationId = ref(props.conversationId);

// Resizable sidebar state
const sidebarWidth = ref(300); // Initial width of the sidebar
let isResizing = false;
const search = ref('')

const startResize = (event) => {
  isResizing = true;
  document.addEventListener('mousemove', resizeSidebar);
  document.addEventListener('mouseup', stopResize);
};

const resizeSidebar = (event) => {
  if (isResizing && props.isSidebarVisible) {
    sidebarWidth.value = event.clientX; // Adjust width dynamically as mouse moves
  }
};

const stopResize = () => {
  isResizing = false;
  document.removeEventListener('mousemove', resizeSidebar);
  document.removeEventListener('mouseup', stopResize);
};

const conversationClasses = computed(() => {
  var conversationClasses = {}
  props.conversations.forEach((conversation) => {
    if (props.conversationId != conversation?.id && conversation?.last_message && !conversation?.last_message?.read_at && !conversation?.last_message?.sent_by_me) {
      conversationClasses[conversation.id] = '!bg-warning'
    } else if (props.conversationId === conversation?.id) {
      conversationClasses[conversation.id] = '!bg-accent'
    }
  })
  return conversationClasses
})

async function loadMoreData ({ done }) {
  emits('loadMoreData', { done })
}
</script>
