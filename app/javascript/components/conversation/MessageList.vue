<template>
  <!-- Chat Messages -->
  <v-infinite-scroll
    :items="messages"
    @load="loadMoreData"
    side="start"
    class="v-infinite-scroll-message w-full h-full flex-1"
  >
    <template
      v-for="msg in messages"
      :key="msg.id"
    >
      <div
        :data-id="msg.id"
        class="my-2"
        :id="`message-${msg.id}`"
        :class="msg.user_id === currentUserId ? 'flex justify-end' : 'flex justify-start'"
      >
        <div>
          <div :class="msg.user_id !== currentUserId ? 'flex items-center flex' : 'flex justify-end mr-2'">
            <user-avatar
              v-if="msg.user_id !== currentUserId"
              @click="$emit('goToProfile', conversation?.user?.id)"
              class="cursor-pointer mr-1"
              size="sm"
              :avatar="conversation?.user?.avatar"
              :firstname="conversation?.user?.lastname"
              :lastname="conversation?.user?.firstname"
            />
            <div
              :class="[
                'p-3',
                'rounded-lg',
                msg.user_id === currentUserId ? 'bg-error !pb-0' : 'bg-secondary',
              ]"
              class="max-w-xs text-wrap break-words flex flex-col"
            >
              {{ msg.body }}

              <!-- Seen indicator -->
              <span v-if="msg.user_id === currentUserId" class="text-xs flex justify-end">
                <span :class="msg.read_at ? 'text-blue-500' : ''" class="mdi mdi-check-all"></span>
              </span>
            </div>
          </div>
          <span v-if="msg.created_at" class="text-[10px] pr-2">{{ filters.formatDateHoursWithAmAndPm(msg.created_at) }}</span>
        </div>
      </div>
    </template>
    <template #empty/>
  </v-infinite-scroll>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, computed, nextTick } from 'vue';
import filters from "@/tools/filters";
import UserAvatar from '@/components/tools/Avatar.vue';

const props = defineProps({
  messages: { type: Array, default: () => [] },
  currentUserId: { type: Number, default: undefined },
  conversation: { type: Object, default: () => {} },
});

const emits  = defineEmits(['loadMoreData'])

async function loadMoreData ({ done }) {
  emits('loadMoreData', { done })
}
</script>
