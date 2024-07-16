<template>
  <transition name="slide-up">
    <div
      v-if="isOpen"
      class="fixed bottom-1 right-4 md:right-8 bg-background shadow-lg w-full md:w-96 max-w-sm rounded-lg overflow-hidden  border-secondary"
      style="z-index: 998;"
      :class="isMinimized ? '!w-[150px]': ''"
    >
      <!-- Header with Close and Minimize Icons -->
      <div class="bg-secondary flex justify-between items-center py-1 px-2">
        <div class="flex gap-2 my-1 items-center">
          <AvatarWithUserInfo
            canShowOnline
            :isOnline="conversation?.user?.is_online"
            class="cursor-pointer mr-1"
            size="md"
            withFullname
            :user="conversation?.user"
          />
        </div>
        <div class="flex items-center">
          <v-icon @click="goToConversation(conversation)" class="cursor-pointer p-4 hover:bg-primary rounded-full p-1">mdi mdi-resize</v-icon>
          <v-icon @click="toggleMinimize" class="cursor-pointer   hover:bg-primary p-4 rounded-full p-1">mdi-minus</v-icon>
          <v-icon @click="closeChat" class="cursor-pointer  hover:bg-primary p-4 rounded-full p-1">mdi-close</v-icon>
        </div>
      </div>

      <!-- Chat Body -->
      <div v-if="messages.length && !isMinimized" class="px-2 flex flex-col h-[500px] justify-end">
        <!-- Chat Messages -->
        <MessageList
          :messages="messages"
          :conversation="conversation"
          :current-user-id="currentUser.id"
          @loadMoreData="loadMoreData"
          @goToProfile="goToProfile($event)"
        />
        <span class="ml-6 text-primary h-[25px] pb-1 text-sm">
          <small v-if="isTyping">
            {{ conversation?.user?.lastname }} is typing<span class="dots"></span>
          </small>
        </span>

        <!-- Chat Input -->
        <div class="flex items-center gap-3 pb-1"  >
          <v-text-field
            v-model="message"
            placeholder="Type your message..."
            variant="solo"

            outlined
            hide-details
            class="flex-1 bg-background rounded-full"
            @keyup.enter="sendMessage"
            @input="ConversationChannel?.typing()"
          >
            <!-- Emoji Picker Button -->
            <template #prepend>
              <v-menu
                v-model="emojiMenu"
                offset-y
                transition="scale-transition"
                :close-on-content-click="true"
              >
                <template #activator="{ props }">
                  <v-btn size="small" class="hover:bg-success" icon v-bind="props">
                    <v-icon>mdi-emoticon-outline</v-icon>
                  </v-btn>
                </template>

                <!-- Emoji Picker -->
                <EmojiPicker @click.stop :native="true" @select="appendEmoji" />
              </v-menu>
            </template>
          </v-text-field>

          <v-btn size="small" @click="sendMessage" icon class="hover:bg-success rounded-full">
            <v-icon left>mdi-send</v-icon>
          </v-btn>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, computed, nextTick } from 'vue';
import { useMessageStore } from '@/stores/message.store';
import { storeToRefs } from 'pinia';
import filters from "@/tools/filters";
import { useActionCable } from '@/stores/cable.js';
import { useUserStore } from '@/stores/user.store';
import { useConversationStore } from '@/stores/conversation.store';
import EmojiPicker from 'vue3-emoji-picker'
import 'vue3-emoji-picker/css'
import { useRouter, useRoute } from 'vue-router';
import debounce from "lodash/debounce";
import AvatarWithUserInfo from '@/components/tools/AvatarWithUserInfo.vue';
import MessageList from '@/components/conversation/MessageList.vue';

const { currentUser } = storeToRefs(useUserStore());
const { fetchGlobalMessages } = useMessageStore();
const { cable } = storeToRefs(useActionCable());
const { conversations } = storeToRefs(useConversationStore());
const router = useRouter();
const { fetchUnreadMessagesCount } = useConversationStore();

const messages = ref([])
const pagination = ref({})
const page = ref(1)
const search = ref('')

const ConversationChannel = ref(null);
const chatContainer = ref(null); // Ref for chat container
const emojiMenu = ref(false)
const isTyping = ref(false)
// Props passed from parent
const props = defineProps({
  user: String,
  conversation: Object
});

const onMountedMethods = async() => {
  if (props.conversation?.id) {
    const res = await fetchGlobalMessages(props.conversation?.id, 1, '')
    messages.value = res.messages.reverse()
    pagination.value = {
      current_page: res.meta.pagy.page,
      total_pages: res.meta.pagy.pages,
      total_items: res.meta.total_count,
    };
    if (!ConversationChannel.value) {
      await websocketResponseChannel();
    }
  }
}
onMounted(async() => {
  await onMountedMethods()
})

 // Chat window visibility
const isOpen = computed( () => {
  return props.conversation  && props.conversation?.id
})

const isMinimized = ref(false); // Minimize state
const message = ref(""); // Input message

const emit = defineEmits(['close'])

// Initialize WebSocket subscription for the selected conversation
const websocketResponseChannel = async() => {
  if (!props.conversation.id) return;

  const subscribeOptions = {
    channel: 'ConversationChannel',
    conversation_id: props.conversation.id,
  };

  // Unsubscribe from the previous channel, if any
  if (ConversationChannel.value) {
    ConversationChannel.value?.unsubscribe();
  }

  // Create a new WebSocket subscription
  ConversationChannel.value = cable.value?.subscriptions.create(subscribeOptions, {
    connected: async function() {
    },
    disconnected: function() {
      console.log('Disconnected from ConversationChannel');
    },
    received: async function(data) {

      if (data.typing) {
        if (data.user_id !== currentUser.value.id) {
          isTyping.value = true;
          debounceStopTyping()
        }
      } else if (data.mark_read_at) {
        await fetchUnreadMessagesCount()

        messages.value.forEach((message) => {
          if (message.id === data.message.id) {
            message.read_at = data.message.read_at
          }
        })
        conversations.value = conversations.value.map((conv) => {
          if (conv.id === data.message.conversation_id) {
            conv.last_message = data.message
          }
          return conv
        })
      } else {
        await fetchUnreadMessagesCount()
        messages.value.push(data);
        scrollToBottom()
      }
    },
    update: async function(data) {
      this.perform('update', data);
    },
    typing: async function() {
      this.perform('typing'); // Send typing event
    },
    markReadAt: async function(data) {
      this.perform('mark_read_at', data); // Send seen event when messages are viewed
    }
  });
};

// Close chat window
const closeChat = () => {
  // isOpen.value = false;
  // Emit event to parent to remove this chat window
  ConversationChannel.value?.unsubscribe();
  emit('close');
};

// Minimize chat window
const toggleMinimize = () => {
  isMinimized.value = !isMinimized.value;
};

// Send message function
// const sendMessage = () => {
//   if (message.value.trim()) {
//     messages.value.push({ body: message.value, sent_by_me: true });
//     message.value = ""; // Reset input
//   }
// };

// Send a new message through WebSocket
const sendMessage = async () => {
  if (!message.value?.trim()) return; // Ensure there's a message to send

  // Ensure WebSocket is initialized before sending the message
  if (!ConversationChannel.value) {
    websocketResponseChannel();
  }

  // Perform the 'update' action via WebSocket, sending the new message
  ConversationChannel.value.update({ message: message.value.trim() });
  message.value = ""; // Reset input
};

// Scroll to bottom helper function
const scrollToBottom = () => {
  const container = document.querySelector('.v-infinite-scroll');
  if (container) {
    nextTick(async() => {
      container.scrollTop = container.scrollHeight;
    })
  }
};

const observeMessagesForVisibility = async() => {
  messages.value.filter(message => message.user_id !== currentUser.value.id).forEach((msg) => {
    const messageElement = document.getElementById(`message-${msg.id}`);

    if (messageElement) {
      const observer = new IntersectionObserver(async (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            // Await to mark the message as seen
            await markMessageAsSeen(msg);
            observer.unobserve(entry.target); // Stop observing once marked as seen
          }
        }
      }, { threshold: 0.01 }); // Trigger when 1% of the message is visible

      // Start observing the message element
      observer.observe(messageElement);
    }
  });
}

async function markMessageAsSeen(message) {
  if (message.read_at) return null
  // Call WebSocket or API to mark this message as seen
  ConversationChannel.value.markReadAt({ message_id: message.id });
}

// Function to append emoji to input
const appendEmoji = (emoji) => {
  message.value += emoji.i // Use 'i' property to get the emoji character
  emojiMenu.value = false
}

const goToProfile = (userId) => {
  router.push({ name: 'user', params: { id: userId } })
}

const debounceStopTyping = debounce(function () {
  isTyping.value = false;
}, 1000)

const goToConversation = async(conversation) => {
  closeChat()
  router.push({ name: 'conversations', query: { conversation_id: conversation?.id } });
};

// Function to check if the last message has been seen
const isLastMessageSeen = (msg) => {
  return msg.read_at
};

async function loadMoreData ({ done }) {
  if (page.value < pagination.value.total_pages) {
    try {
      page.value++
      const messageData = await fetchGlobalMessages(props.conversation?.id, page.value, '')
      if (messageData.messages.length) {
        messages.value.unshift(...messageData.messages.reverse())
      }
      done('ok')
    } catch (error) {
      done('error')
    }
  }  else {
    done('empty')
  }
}

watch(messages, async() => {
  nextTick(async() => {
    await observeMessagesForVisibility()
  })

}, { deep: true })

</script>

<style scoped>
/* Animation for the chat window sliding up */
.slide-up-enter-active, .slide-up-leave-active {
  transition: transform 0.3s ease;
}
.slide-up-enter, .slide-up-leave-to {
  transform: translateY(100%);
}
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