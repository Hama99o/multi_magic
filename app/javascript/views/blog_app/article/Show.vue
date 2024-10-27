<template>
  <v-app>
    <v-app-bar flat class="flex items-center justify-center bg-background">
      <!-- Go Back Button -->
      <v-btn icon @click="goBack">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-toolbar-title class="text-subtitle-1 font-weight-medium">
        {{ article.title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn v-if="currentUser?.id === article.user?.id" icon @click="goToEditArticle">
        <v-icon>mdi-pencil</v-icon>
      </v-btn>
    </v-app-bar>

    <v-container class="article-show-page mt-12">
      <v-row justify="center">
        <v-col cols="12" md="10" lg="7">
          <!-- Article Content -->
          <article>
            <span class="font-weight-bold mb-4" :class="isMobile ? 'text-h5' : 'text-h4'">{{ article.title }}</span>

            <!-- Author and Time Information -->
            <div class="d-flex align-center mb-6">
              <AvatarWithUserInfo
                class="cursor-pointer mr-1"
                size="lg"
                :user="article?.user"
                withFullname
              >
                <template #fullname>
                  <div>
                    <p class="text-subtitle-1 font-weight-medium mb-0">{{ article.user?.fullname }}</p>
                    <p class="text-caption">
                      {{ filters.formatDate(article.created_at) }} · {{ article.read_time }} min read
                    </p>
                  </div>
                </template>
              </AvatarWithUserInfo>
            </div>

            <!-- Cover Photo -->
            <div v-if="article.cover_photo" class="article-cover mb-6">
              <v-img :src="article.cover_photo" :alt="article.title" height="400" cover></v-img>
            </div>

            <!-- Tags -->
            <div class="article-tags mb-6">
              <v-chip
                v-for="tag in article.tags"
                :key="tag.id"
                class="mb-2 mr-2"
                color="primary"
                variant="outlined"
                size="small"
              >
                {{ tag.name }}
              </v-chip>
            </div>

            <!-- Article Body -->
            <tiptap-editor
              v-if="article.description"
              ref="tiptapEditor"
              :record-id="article.id"
              class="mt-6 rounded-lg bg-surface"
              :content="article.description"
              :is-editable="false"
            />

            <v-divider class="my-8"></v-divider>

            <!-- About the Author Section -->
            <div class="article-footer">
              <h3 class="text-h6 mb-4">About the author</h3>
              <div class="d-flex">
                <v-avatar size="64" class="mr-4">
                  <v-img :src="article.user?.avatar" :alt="article.user?.fullname"></v-img>
                </v-avatar>
                <div>
                  <p class="text-h6 font-weight-medium mb-1">{{ article.user?.fullname }}</p>
                  <p class="text-body-2">{{ article.user?.bio }}</p>
                </div>
              </div>
            </div>
          </article>

          <!-- Comment Section -->
          <div v-if="article.status === 'published'" class="comments-section mt-2">
            <h2 class="text-h5 mb-6">Comments</h2>

            <!-- Add Comment Form -->
            <v-textarea
              v-model="newComment"
              placeholder="Write a comment..."
              auto-grow
              outlined
              rows="3"
              class="mb-4"
            />
            <v-btn color="primary" @click="submitComment">Add Comment</v-btn>

            <v-divider class="my-8"></v-divider>

            <!-- List of Comments -->
            <comment-item
              v-for="comment in comments"
              :key="comment.id"
              :comment="comment"
              :active-reply-id="activeReplyId"
              @reply="toggleReply"
              @submit-reply="submitReply"
            />
          </div>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useArticleStore } from '@/stores/blog_app/article.store';
import TiptapEditor from '@/components/richtext/TiptapEditor.vue';
import { useCommentStore } from '@/stores/blog_app/articles/comment.store';
import CommentItem from '@/components/articles/CommentItem.vue';
import { useUserStore } from '@/stores/user.store';
import filters from '@/tools/filters';
import AvatarWithUserInfo from '@/components/tools/AvatarWithUserInfo.vue';
import { useMobileStore } from "@/stores/mobile";

const route = useRoute();
const router = useRouter();
const { currentUser } = storeToRefs(useUserStore());
const { isMobile } = storeToRefs(useMobileStore());

const articleStore = useArticleStore();
const { article } = storeToRefs(articleStore);

const commentStore = useCommentStore();
const { comments } = storeToRefs(commentStore);

const newComment = ref('');
const replyComment = ref('');
const activeReplyId = ref<number | null>(null);

onMounted(async () => {
  await articleStore.fetchArticle(route.params.id);
  await commentStore.fetchComments(route.params.id);

  // Set HTML title to article title
  document.title = article.value.title || 'Multi Magic';

  // Set meta description to article description
  document.querySelector("meta[name='description']").setAttribute(
    "content",
    article.value.description || "Multi Magic"
  );
});

const goBack = () => {
  router.push({ name: 'articles' });
};

const goToEditArticle = () => {
  router.push({ name: 'edit_article', params: { id: article.id } });
};

const submitComment = async () => {
  if (newComment.value) {
    await commentStore.createComment({ body: newComment.value });
    newComment.value = '';
  }
};

const toggleReply = (commentId: number) => {
  activeReplyId.value = activeReplyId.value === commentId ? null : commentId;
};

const submitReply = async (data: object) => {
  await commentStore.createComment(data);
  activeReplyId.value = null;
  // if (replyComment.value) {
  //   replyComment.value = '';
  // }
};
</script>

<style scoped>
.article-show-page {
  background-color: var(--v-background-base);
}

.article-content {
  background-color: var(--v-surface-base);
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.article-cover {
  border-radius: 8px;
  overflow: hidden;
}

.comments-section {
  background-color: var(--v-background-paper);
  padding: 1.5rem;
  border-radius: 8px;
}

.comments-section .comment {
  background-color: var(--v-surface-variant-base);
  padding: 1rem;
  border-radius: 8px;
}

.reply-comment {
  background-color: var(--v-surface-variant-base);
  padding: 0.5rem;
  border-radius: 8px;
  margin-left: 40px;
}
</style>
