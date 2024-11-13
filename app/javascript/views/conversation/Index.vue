<template>
  <div class="messenger-container flex h-[calc(100vh-64px)]">
    <div class="flex flex-1 overflow-hidden bg-secondary">
      <!-- Sidebar for Conversations -->
      <ConversationsSidebar
        :conversation-id="selectedConversationId"
        :conversations="conversations"
        :is-sidebar-visible="isSidebarVisible"
        :unread-messages-count="unreadMessagesCount"
        :current-user-id="currentUser?.id"
        @toggle-sidebar="toggleSidebar"
        @open-show-new-conversation-modal="openShowNewConversationModal"
        @select-conversation="selectConversation"
        @search-conversation="searchConversation"
        @load-more-data="loadMoreData"
      />
      <!-- Chat Messages Area -->
      <MessagesSidebar
        v-if="selectedConversationMessages && selectedConversation"
        :selected-conversation-messages="selectedConversationMessages"
        :selected-conversation="selectedConversation"
        :current-user="currentUser"
        :is-sidebar-visible="isSidebarVisible"
        @send-message="sendMessage"
        @soft-delete-conversation="softDeleteConversation"
        @toggle-sidebar="toggleSidebar"
        @update-is-typing="ConversationChannel?.typing()"
        @go-to-profile="goToProfile"
        @load-more-data="loadMoreMessageData"
        @search-users="searchUsers"
        :search-results="searchResults"
        @removeParticipant="removeParticipant"
        @addOrUpdateParticipant="addOrUpdateParticipant"
      />
    </div>

    <!-- New Conversation Modal -->
    <NewConversation
      ref="showNewConversationModal"
      :search-results="searchResults"
      @create-new-conversation="createNewConversation"
      @create-new-group-conversation="createNewGroupConversation"
      @search-users="searchUsers"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, onBeforeUnmount, nextTick } from 'vue';
import { storeToRefs } from 'pinia';
import { useRouter, useRoute } from 'vue-router';
import debounce from 'lodash/debounce';
import { useConversationStore } from '@/stores/conversation.store';
import { useMessageStore } from '@/stores/message.store';
import { useUserStore } from '@/stores/user.store';
import { useActionCable } from '@/stores/cable.js';
import ConversationsSidebar from '@/components/conversation/ConversationsSidebar.vue';
import MessagesSidebar from '@/components/conversation/MessagesSidebar.vue';
import NewConversation from '@/components/conversation/New.vue';
import { useMobileStore } from '@/stores/mobile';

const { isMobile } = storeToRefs(useMobileStore());
const { currentUser } = storeToRefs(useUserStore());
const {
  fetchConversations,
  fetchConversation,
  createConversation,
  createGroupConversation,
  deleteConversation,
  fetchUnreadMessagesCount,
  fetchConversationsWithInfiniteScroll,
  updateConversation,
} = useConversationStore();
const { conversations, page, search, isTyping, typingUser, unreadMessagesCount, pagination } = storeToRefs(
  useConversationStore(),
);
const { fetcGlobalhUsers } = useUserStore(); // Search user from user store
const { cable } = storeToRefs(useActionCable());
const { fetchMessages, fetchGlobalMessages } = useMessageStore();

const {
  messages,
  page: messagePage,
  pagination: messagePagination,
} = storeToRefs(useMessageStore());

const selectedConversationId = ref(null);
const selectedConversation = ref(null);
const ConversationChannel = ref(null);
const router = useRouter();
const route = useRoute();
const chatContainer = ref(null); // Ref for chat container
const showNewConversationModal = ref(false); // Control for modal visibility
const searchResults = ref([]); // Store search results

onMounted(async () => {
  // await fetchConversations();
  messagePage.value = 1;
  if (route.query.conversation_id) {
    const res = await fetchConversation(route.query.conversation_id);
    selectConversation(res.conversation); // Select conversation from query params
  } else {
    selectedConversation.value = conversations.value[0];
    selectedConversationId.value = selectedConversation.value?.id;

    selectConversation(selectedConversation.value); // Select conversation from query params
  }
  scrollToBottom(); // Ensure scroll is at the bottom on initial load
});

// Watch for new messages and scroll to the bottom
watch(messages, async (newMessages) => {
  scrollToBottom();
});

const searchConversation = async (text) => {
  page.value = 1;
  search.value = text;
  await fetchConversations();
};
const selectedConversationMessages = computed(() => {
  return messages.value || [];
});

// Initialize WebSocket subscription for the selected conversation
const websocketResponseChannel = () => {
  if (!selectedConversationId.value) return;

  const subscribeOptions = {
    channel: 'ConversationChannel',
    conversation_id: selectedConversationId.value,
  };

  // Unsubscribe from the previous channel, if any
  if (ConversationChannel.value) {
    ConversationChannel.value.unsubscribe();
  }

  // Create a new WebSocket subscription
  ConversationChannel.value = cable.value?.subscriptions.create(subscribeOptions, {
    connected: async function () {
      await observeMessagesForVisibility();
    },
    disconnected: function () {
      console.log('Disconnected from ConversationChannel');
    },
    received: async function (data) {
      if (data.typing) {
        if (data.user.id !== currentUser.value.id) {
          isTyping.value = true;
          typingUser.value = data.user
          debounceStopTyping();
        }
      } else if (data.mark_read_at) {
        messages.value.forEach((message) => {
          if (message.id === data.message.id) {
            message.read_at = data.message.read_at;
          }
        });
        conversations.value = conversations.value.map((conv) => {
          if (conv.id === data.message.conversation_id) {
            conv.last_message = data.message;
          }
          return conv;
        });
        await fetchUnreadMessagesCount();
      } else {
        messages.value.push(data);
        await fetchUnreadMessagesCount();
        scrollToBottom();
      }
    },
    update: async function (data) {
      this.perform('update', data);
    },
    typing: async function () {
      this.perform('typing'); // Send typing event
    },
    markReadAt: async function (data) {
      this.perform('mark_read_at', data); // Send seen event when messages are viewed
    },
  });
};

// Toggle sidebar visibility
const isSidebarVisible = ref(true);

const toggleSidebar = () => {
  isSidebarVisible.value = !isSidebarVisible.value;
};

// Select a new conversation and set up the WebSocket
const selectConversation = async (conversation) => {
  if (!conversation) return null;

  router.push({ name: 'conversations', query: { conversation_id: conversation?.id } });

  // Fetch messages for the selected conversation
  messagePage.value = 1;
  await fetchMessages(conversation.id);
  selectedConversationId.value = conversation.id;
  selectedConversation.value = conversation;

  // Initialize WebSocket subscription for this conversation
  websocketResponseChannel();
  scrollToBottom(); // Scroll to bottom after selecting conversation
};

// Send a new message through WebSocket
const sendMessage = async (newMessage) => {
  if (!newMessage) return; // Ensure there's a message to send

  // Ensure WebSocket is initialized before sending the message
  if (!ConversationChannel.value) {
    websocketResponseChannel();
  }

  // Perform the 'update' action via WebSocket, sending the new message
  ConversationChannel.value.update({ message: newMessage });

  scrollToBottom(); // Scroll to bottom after sending message
};

// Search for users using search query
const searchUsers = debounce(async (searchQuery) => {
    // Start searching after 3 characters
    const results = await fetcGlobalhUsers(1, searchQuery);
    searchResults.value = results;
}, 300);

// Create a new conversation when a user is selected
const createNewConversation = async (userId) => {
  page.value = 1;
  const res = await createConversation(userId);
  selectedConversation.value = res.conversation;
  await fetchConversations();
  showNewConversationModal.value.dialog = false; // Close the modal
  selectConversation(selectedConversation.value); // Automatically select the new conversation
};

const createNewGroupConversation = async (userIds, name) => {
  page.value = 1;

  const res = await createGroupConversation(userIds, name);
  selectedConversation.value = res.conversation;
  await fetchConversations();
  showNewConversationModal.value.dialog = false; // Close the modal
  selectConversation(selectedConversation.value); // Automatically select the new conversation
};

// open a new conversation dialog
const openShowNewConversationModal = async () => {
  showNewConversationModal.value.dialog = true; // Close the modal
  const results = await fetcGlobalhUsers();
  searchResults.value = results;
};

// Clean up the WebSocket subscription when the component is unmounted
onBeforeUnmount(() => {
  if (ConversationChannel.value) {
    ConversationChannel.value.unsubscribe();
  }
});

const addOrUpdateParticipant = async(data = {}) => {
  const conversation = await updateConversation(selectedConversationId.value, data);
  selectedConversation.value.participants = conversation.participants
}

const softDeleteConversation = async (conversationId, userId = null) => {
  page.value = 1;

  // Call an API or action to soft delete the conversation
  await deleteConversation(conversationId, userId);
  await fetchConversations();
  selectedConversation.value = conversations.value[0];
  selectedConversationId.value = selectedConversation.value?.id;

  selectConversation(selectedConversation.value); // Select conversation from query params
  if (currentUser.id === userId){
    router.push({ name: 'conversations' });
  }
};

const goToProfile = (userId) => {
  router.push({ name: 'user', params: { id: userId } });
};

const debounceStopTyping = debounce(function () {
  isTyping.value = false;
  typingUser.value = {}
}, 1000);

async function markMessageAsSeen(message) {
  if (message.read_at) return null;

  // Call WebSocket or API to mark this message as seen
  ConversationChannel.value.markReadAt({ message_id: message.id });
}

const observeMessagesForVisibility = async () => {
  selectedConversationMessages.value
    .filter((message) => message.user_id !== currentUser.value.id)
    .forEach((msg) => {
      const messageElement = document.getElementById(`message-${msg.id}`);
      if (messageElement) {
        const observer = new IntersectionObserver(
          async (entries) => {
            for (const entry of entries) {
              if (entry.isIntersecting) {
                // Await to mark the message as seen
                await markMessageAsSeen(msg);
                observer.unobserve(entry.target); // Stop observing once marked as seen
              }
            }
          },
          { threshold: 0.01 },
        ); // Trigger when 1% of the message is visible

        // Start observing the message element
        observer.observe(messageElement);
      }
    });
};

async function loadMoreData({ done }) {
  if (page.value < pagination.value.total_pages) {
    try {
      page.value++;
      const conversationData = await fetchConversationsWithInfiniteScroll();
      if (conversationData.length) {
        conversations.value.push(...conversationData);
      }
      done('ok');
    } catch (error) {
      done('error');
    }
  } else {
    done('empty');
  }
}

async function loadMoreMessageData({ done }) {
  if (messagePage.value < messagePagination.value.total_pages) {
    try {
      messagePage.value++;
      const messageData = await fetchGlobalMessages(
        selectedConversation.value?.id,
        messagePage.value,
        '',
      );
      if (messageData.messages.length) {
        messages.value.unshift(...messageData.messages.reverse());
      }
      done('ok');
    } catch (error) {
      done('error');
    }
  } else {
    done('empty');
  }
}

// Scroll to bottom helper function
const scrollToBottom = () => {
  const container = document.querySelector('.v-infinite-scroll-message');
  if (container) {
    nextTick(async () => {
      container.scrollTop = container.scrollHeight;
    });
  }
};

watch(
  messages,
  async () => {
    nextTick(async () => {
      await observeMessagesForVisibility();
    });
  },
  { deep: true },
);
</script>

<style scoped>
.messenger-container {
  height: calc(100vh - 66px); /* Adjust this value based on your header height */
}
</style>
