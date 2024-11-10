<template>
  <div class="flex flex-col gap-2">
    <!-- Search Input -->
    <v-text-field
      v-model="conversationSearch"
      @click.stop
      placeholder="Search for conversations..."
      @update:model-value="$emit('searchConversation', $event)"
      hide-details
      clearable
      @click:clear="$emit('searchConversation', '')"
      density="compact"
    />

    <v-infinite-scroll
      v-if="conversations.length"
      :items="conversations"
      :onLoad="loadMoreData"
      :max-height="listHeight"
      :class="isOverflowHidden ? 'overflow-hidden' : ''"
    >
      <template
        v-for="conversation in conversations"
        :key="conversation"
      >
        <div
          @click="$emit('selectConversation', conversation)"
          class="cursor-pointer hover:bg-secondary px-2 max-w-[100%] "
          :class="conversationClasses[conversation.id]"
        >
          <div class="flex gap-2 my-1">
            <user-avatar
              canShowOnline
              :isOnline="conversation?.user?.is_online"
              class="cursor-pointer mr-2"
              size="lg"
              :avatar="conversation?.user?.avatar"
              :firstname="conversation?.user?.lastname"
              :lastname="conversation?.user?.firstname"
              :isGroup="conversation?.is_group"
            />
            <div class="flex flex-col gap-1 flex-grow w-[200px]">
              <v-list-item-title class="truncate">{{ conversation.user.fullname }}</v-list-item-title>
              <v-list-item-subtitle >
                <span>
                  <span v-if="conversation?.last_message?.user_id === currentUserId" class="text-xs flex justify-start gap-1">
                    <span :class="conversation?.last_message?.read_at ? 'text-blue-500' : ''" class="mdi mdi-check-all"></span>
                    <span>
                      {{ conversation?.last_message?.body || '' }}
                    </span>
                  </span>
                  <span v-else>
                    {{ conversation?.last_message?.body || '' }}
                  </span>
                </span>
              </v-list-item-subtitle>
            </div>
          </div>
        </div>
      </template>
      <template #empty />
    </v-infinite-scroll>

    <!-- Conditional rendering for empty state -->
    <div v-else>
      <div class="flex flex-col items-center justify-center text-center p-8">
        <v-icon size="48" class="mb-4 text-primary">mdi-message-off</v-icon>
        <p>You have no conversations.</p>
        <p>Start a new conversation to see it here.</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import UserAvatar from '@/components/tools/Avatar.vue';

const props = defineProps({
  conversations: { type: Array, default: () => [] },
  conversationId: { type: Number, default: undefined },
  currentUserId: { type: Number, default: undefined },
  isOverflowHidden: { type: Boolean, default: false },
  listHeight: { type: String, default: '100%' },
});

const emits = defineEmits(['loadMoreData'])
const conversationSearch = ref('')

const conversationClasses = computed(() => {
  var conversationClasses = {}
  props.conversations.forEach((conversation) => {
    if (props.conversationId != conversation?.id && conversation?.last_message && !conversation?.last_message?.read_at && !conversation?.last_message?.sent_by_me) {
      conversationClasses[conversation.id] = '!bg-warning'
    } else if (props.conversationId === conversation?.id) {
      conversationClasses[conversation.id] = '!bg-accent'
    } else {
      return ''
    }
  })
  return conversationClasses
})

async function loadMoreData ({ done }) {
  emits('loadMoreData', { done })
}
</script>
