<template>
  <div class="comment-item" :class="[isNested ? 'nested-comment' : '', `nesting-level-${nestingLevel}`]">
    <div class="flex items-start space-x-2 sm:space-x-3">
      <div class="hidden sm:flex flex-col items-center space-y-1 flex-shrink-0">
        <v-btn icon="mdi-chevron-up" variant="text" density="compact" size="x-small" @click="upvote" :color="voteCount > 0 ? 'success' : ''"></v-btn>
        <span class="text-xs sm:text-sm font-medium" :class="{ 'text-success': voteCount > 0, 'text-error': voteCount < 0 }">{{ voteCount }}</span>
        <v-btn icon="mdi-chevron-down" variant="text" density="compact" size="x-small" @click="downvote" :color="voteCount < 0 ? 'error' : ''"></v-btn>
      </div>

      <div class="flex-grow min-w-0">
        <div class="flex flex-wrap items-center space-x-2 mb-2">
          <AvatarWithUserInfo
            class="cursor-pointer flex-shrink-0"
            :size="isNested ? 'xs' : 'sm'"
            :user="comment?.user"
            withFullname
            @update-user="updateUser"
          />
          <span class="text-xs text-gray-500 truncate">{{ formatDate(comment.created_at) }}</span>
        </div>

        <p class="text-sm mb-3 break-words">{{ comment.body }}</p>

        <div class="flex flex-wrap items-center space-x-2 sm:space-x-3 mb-3">
          <div class="flex sm:hidden items-center space-x-2 mr-2 flex-shrink-0">
            <v-btn icon="mdi-chevron-up" variant="text" density="compact" size="x-small" @click="upvote" :color="voteCount > 0 ? 'success' : ''"></v-btn>
            <span class="text-xs font-medium" :class="{ 'text-success': voteCount > 0, 'text-error': voteCount < 0 }">{{ voteCount }}</span>
            <v-btn icon="mdi-chevron-down" variant="text" density="compact" size="x-small" @click="downvote" :color="voteCount < 0 ? 'error' : ''"></v-btn>
          </div>
          <v-btn
            v-if="!showReplyForm"
            prepend-icon="mdi-reply"
            size="x-small"
            density="comfortable"
            variant="tonal"
            @click="reply"
          >
            Reply
          </v-btn>
          <v-btn
            icon="mdi-flag-outline"
            size="x-small"
            density="comfortable"
            variant="text"
            color="gray"
            @click="reportComment"
          ></v-btn>
        </div>

        <v-expand-transition>
          <div v-if="showReplyForm" class="reply-form mb-4">
            <v-textarea
              v-model="replyText"
              placeholder="Write a reply..."
              auto-grow
              variant="outlined"
              density="comfortable"
              hide-details
              rows="3"
              class="mb-3"
            />
            <div class="flex justify-end space-x-2">
              <v-btn @click="cancelReply" size="small" variant="text">Cancel</v-btn>
              <v-btn @click="submitReply" size="small" color="primary" :disabled="!replyText.trim()">Submit</v-btn>
            </div>
          </div>
        </v-expand-transition>

        <div v-if="comment.replies && comment.replies.length" class="comment-replies mt-4">
          <comment-item
            v-for="reply in comment.replies"
            :key="reply.id"
            :comment="reply"
            :active-reply-id="nestedActiveReplyId"
            @reply="handleNestedReply"
            @submit-reply="submitNestedReply"
            @update-user="updateNestedUser"
            :is-nested="true"
            :nesting-level="nestingLevel + 1"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import AvatarWithUserInfo from '@/components/tools/AvatarWithUserInfo.vue';

const props = defineProps({
  comment: {
    type: Object,
    required: true
  },
  activeReplyId: {
    type: Number,
    default: null
  },
  isNested: {
    type: Boolean,
    default: false
  },
  nestingLevel: {
    type: Number,
    default: 0
  }
});

const emit = defineEmits(['submit-reply', 'reply', 'update-user']);

const replyText = ref('');
const nestedActiveReplyId = ref(null);
const voteCount = ref(0);

const showReplyForm = computed(() => {
  return props.isNested
    ? nestedActiveReplyId.value === props.comment.id
    : props.activeReplyId === props.comment.id;
});

const submitReply = () => {
  if (replyText.value.trim()) {
    emit('submit-reply', { parent_id: props.comment.id, body: replyText.value });
    replyText.value = '';
    cancelReply();
  }
};

const submitNestedReply = (data) => {
  emit('submit-reply', data);
};

const reply = () => {
  if (props.isNested) {
    nestedActiveReplyId.value = nestedActiveReplyId.value === props.comment.id ? null : props.comment.id;
  } else {
    emit('reply', props.comment.id);
  }
};

const cancelReply = () => {
  if (props.isNested) {
    nestedActiveReplyId.value = null;
  } else {
    emit('reply', null);
  }
};

const handleNestedReply = (replyId) => {
  nestedActiveReplyId.value = replyId;
};

const upvote = () => {
  voteCount.value++;
};

const downvote = () => {
  voteCount.value--;
};

const updateUser = (isFollowing) => {
  emit('update-user', isFollowing);
};

const updateNestedUser = (isFollowing) => {
  emit('update-user', isFollowing);
};

const reportComment = () => {
  // Implement report functionality
  console.log('Comment reported');
};

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
};
</script>

<style scoped>
.comment-item {
  @apply mb-4 last:mb-0;
}

.nested-comment {
  @apply border-l-2 border-gray-200 dark:border-gray-700;
}

.nesting-level-0 {
  @apply pl-0;
}

.nesting-level-1 {
  @apply pl-2 sm:pl-4;
}

.nesting-level-2 {
  @apply pl-3 sm:pl-6;
}

.nesting-level-3 {
  @apply pl-4 sm:pl-8;
}

.nesting-level-4, .nesting-level-5, .nesting-level-6, .nesting-level-7, .nesting-level-8, .nesting-level-9 {
  @apply pl-5 sm:pl-10;
}

@media (max-width: 640px) {
  .nesting-level-3, .nesting-level-4, .nesting-level-5, .nesting-level-6, .nesting-level-7, .nesting-level-8, .nesting-level-9 {
    @apply pl-4;
  }
}
</style>