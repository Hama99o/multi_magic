<template>
  <v-app :theme="theme">
    <MainMenu />

    <!-- Main content -->
    <div>
      <router-view></router-view>
      <bkt-pop-up />
    </div>

    <!-- Global Chat Window -->
    <chat-window ref="chatWindow" />

    <Toast />
  </v-app>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, onBeforeUnmount, nextTick } from 'vue';
import MainMenu from '@/components/layouts/MainMenu.vue';
import Toast from '@/components/Toast/Index.vue';
import BktPopUp from "@/components/popUpComponents/BktPopUp.vue";
import { useUserStore } from '@/stores/user.store';
import { storeToRefs } from 'pinia';
import { useActionCable } from '@/stores/cable.js';
import { useConversationStore } from '@/stores/conversation.store';

// Import the chat window component
import ChatWindow from "@/components/conversation/ChatWindow.vue";

const { theme, id } = storeToRefs(useUserStore());
const { cable } = storeToRefs(useActionCable());
const { conversations } = storeToRefs(useConversationStore());
const { fetchUnreadMessagesCount } = useConversationStore();

const MessageChannel = ref(null)

// Initialize WebSocket subscription for the selected conversation
watch(id, () => {
  if (id.value) {
    const subscribeOptions = {
      channel: 'MessageChannel',
      user_id: id.value,
    };
    console.log(subscribeOptions)
    // Unsubscribe from the previous channel, if any
    if (MessageChannel.value) {
      MessageChannel.value?.unsubscribe();
    }

    // Create a new WebSocket subscription
    MessageChannel.value = cable.value?.subscriptions.create(subscribeOptions, {
      connected: async function() {
        console.log('Connected to MessageChannel');
      },
      disconnected: function() {
        console.log('Disconnected from MessageChannel');
      },
      received: async function(data) {
        await fetchUnreadMessagesCount()
        const { message, conversation }= data
        conversations.value = conversations.value.map((conv) => {
          if (conv.id === conversation.id) {
            conv.last_message = message
          }
          return conv
        })
        // Handle the message data here, e.g., add it to the message list
      },
    });
  }
});


onBeforeUnmount(() => {
  MessageChannel.value?.unsubscribe();
})
</script>

<style>
@import 'vuetify/styles';
@import '@/assets/css/style.css';


::-webkit-scrollbar-track
{
	-webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.9);
	background-color: #5e5454;
}

::-webkit-scrollbar
{
	width: 14px;
	background-color: #F5F5F5;
}

::-webkit-scrollbar-thumb
{
	border-radius: 10px;
  background-color: #ad8484;

}
</style>
