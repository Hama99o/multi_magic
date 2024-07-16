<template>
  <div class="comment-item" :class="{ 'nested-comment': isNested }">
    <div class="comment-content">
      <div class="vote-buttons">
        <button @click="upvote" class="vote-btn">
          <i class="fas fa-chevron-up"></i>
        </button>
        <!-- <span class="vote-count">{{ voteCount }}</span> -->
        <button @click="downvote" class="vote-btn">
          <i class="fas fa-chevron-down"></i>
        </button>
      </div>
      <div class="comment-body">
        <div class="comment-header">
          <v-avatar size="24" class="mr-2">
            <v-img :src="comment.user.avatar" :alt="comment.user.fullname"></v-img>
          </v-avatar>
          <span class="username">{{ comment.user.fullname }}</span>
        </div>
        <p class="comment-text">{{ comment.body }}</p>
        <div class="comment-actions">
          <v-btn small text @click="reply" class="reply-btn">
            <i class="fas fa-reply mr-1"></i> Reply
          </v-btn>
        </div>

        <!-- Reply Form -->
        <div v-if="showReplyForm" class="reply-form">
          <v-textarea
            v-model="replyText"
            placeholder="Write a reply..."
            auto-grow
            outlined
            rows="2"
            class="mb-2"
          />
          <v-btn small color="primary" @click="submitReply">Reply</v-btn>
        </div>

        <!-- Nested Comments -->
        <div v-if="comment.replies && comment.replies.length" class="comment-replies">
          <comment-item
            v-for="reply in comment.replies"
            :key="reply.id"
            :comment="reply"
            :activeReplyId="nestedActiveReplyId"
            @reply="handleNestedReply"
            @submitReply="submitNestedReply"
            isNested
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';

const props = defineProps({
  comment: Object,
  activeReplyId: Number,
  isNested: { type: Boolean, default: false }
});

const emit = defineEmits(['submitReply', 'reply']);

const replyText = ref('');
const nestedActiveReplyId = ref(null);
const voteCount = ref(0);

const showReplyForm = computed(() => {
  return props.isNested
    ? nestedActiveReplyId.value === props.comment.id
    : props.activeReplyId === props.comment.id;
});

const submitReply = () => {
  if (replyText.value) {
    emit('submitReply', { parent_id: props.comment.id, body: replyText.value });
    replyText.value = '';
  }
};

const submitNestedReply = (data) => {
  emit('submitReply', data);
};

const reply = () => {
  if (props.isNested) {
    nestedActiveReplyId.value = nestedActiveReplyId.value === props.comment.id ? null : props.comment.id;
  } else {
    emit('reply', props.comment.id);
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
</script>

<style scoped>
.comment-item {
  margin-bottom: 1rem;
  background-color: #1a1a1b;
  border-radius: 4px;
  padding: 0.5rem;
}

.nested-comment {
  border-left: 2px solid #343536;
}

.comment-content {
  display: flex;
}

.vote-buttons {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-right: 0.5rem;
}

.vote-btn {
  background: none;
  border: none;
  color: #818384;
  cursor: pointer;
}

.vote-count {
  font-size: 0.875rem;
  font-weight: bold;
  color: #d7dadc;
}

.comment-body {
  flex-grow: 1;
}

.comment-header {
  display: flex;
  align-items: center;
  margin-bottom: 0.25rem;
}

.username {
  font-size: 0.75rem;
  font-weight: bold;
  color: #d7dadc;
}

.comment-text {
  font-size: 0.875rem;
  color: #d7dadc;
  margin-bottom: 0.5rem;
}

.comment-actions {
  margin-bottom: 0.5rem;
}

.reply-btn {
  font-size: 0.75rem;
  color: #818384;
}

.reply-form {
  margin-top: 0.5rem;
}

.nested-comments {
  margin-top: 1rem;
}

.comment-replies {
  position: relative;
}

.comment-replies:before {
  background-color: SlateGray;
  content: '';
  height: calc(100% + 1rem);
  left: 1rem;
  position: absolute;
  top: 0;
  width: 1px;
}

.comment-replies:last-child:before {
  height: calc(100% - 1rem);
}
</style>