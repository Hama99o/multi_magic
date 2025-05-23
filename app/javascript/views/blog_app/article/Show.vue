<template>
  <v-app v-if="article">
    <v-app-bar flat class="flex items-center justify-center bg-background">
      <!-- Go Back Button -->
      <v-btn :icon="!fromDraft" @click="goBack">
        <v-icon>mdi-arrow-left</v-icon>
        <span v-if="fromDraft">
          Back to Edit
        </span>
      </v-btn>

      <v-toolbar-title class="text-subtitle-1 font-weight-medium">
        {{ article.title }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn v-if="!fromDraft && currentUser?.id === article.user?.id" icon @click="goToEditArticle">
        <v-icon>mdi-pencil</v-icon>
      </v-btn>
    </v-app-bar>

    <v-container class="article-show-page mt-12">
      <v-row justify="center">
        <v-col cols="12" md="10" lg="10">
          <!-- Article Content -->
          <article>
            <span class="font-weight-bold mb-4" :class="isMobile ? 'text-h5' : 'text-h4'">{{ article.title }}</span>

            <!-- Author and Time Information -->
            <div class="d-flex align-center mb-6">
              <AvatarWithUserInfo
                class="cursor-pointer mr-1"
                size="md"
                :user="article?.user"
                withFullname
                @update-user="updateUser"
              >
                <template #fullname>
                  <div>
                    <p class="text-subtitle-1 font-weight-medium mb-0">{{ article.user?.fullname }}</p>
                    <p class="text-caption">
                      {{ filters.formatDate(article.created_at) }} · {{ article.duration }} min read
                    </p>
                  </div>
                </template>
              </AvatarWithUserInfo>
            </div>

            <!-- View Count Display -->
            <div class="m-1 d-flex items-center  text-caption">
              <v-icon small class="mr-1">mdi-eye</v-icon>
              <span>{{ article.unique_view_count }} Views</span>
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
                {{ `#${tag.name}` }}
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

            <!-- About the Author Section -->
            <div v-if="!fromDraft" class="article-footer bg-surface p-5 rounded my-2">
              <h3 class="text-h6 mb-4">About the author</h3>
              <auth-dialog hashId="#comments-section">
                <AvatarWithUserInfo
                  class="cursor-pointer mr-1"
                  size="lg"
                  :user="article?.user"
                  withFullname
                  hashId="#comments-section"
                  @update-user="updateUser"
                >
                  <template #fullname>
                    <div>
                      <p class="text-subtitle-1 font-weight-medium mb-0">{{ article.user?.fullname }}</p>
                      <p class="text-caption">
                        {{ article?.user?.about }}
                      </p>
                    </div>
                  </template>
                </AvatarWithUserInfo>

                <v-card-actions v-if="currentUser?.id !== article.user?.id || !currentUser?.id" class="d-flex justify-space-around">
                  <v-btn @click="toggleFollowUser()" small color="primary" class="bg-[#5d4b2d]">
                    <span :class="article.user?.is_following ? 'mdi mdi-account-minus' : 'mdi mdi-account-plus'"></span>{{ article.user?.is_following ? 'Unfollow' : 'Follow' }}
                  </v-btn>
                  <v-btn small @click="createNewConversation(article.user)" outlined color="primary" class="border-gray-500">
                    <v-icon left>mdi-chat</v-icon>Chat
                  </v-btn>
                </v-card-actions>
              </auth-dialog>
            </div>
          </article>

          <!-- Reaction, Bookmark, and Comment Buttons Section -->
          <auth-dialog hashId="#comments-section">
            <div v-if="!fromDraft" class="d-flex align-center mt-4 justify-between items-center">
                <!-- Reaction Button -->
                <div>
                  <v-badge :color="article.is_reacted ? 'primary' : 'success'" :content="article.reaction_count" class="px-2 pt-1">
                    <v-btn
                      icon
                      @click="toggleReaction"
                      size="small"
                    >
                      <v-icon :color="article.is_reacted ? 'primary' : 'success'">{{ article.is_reacted ? 'mdi-heart' : 'mdi-heart-outline' }}</v-icon>
                    </v-btn>
                  </v-badge>
                </div>

                <!-- Comment Button -->
                <div>
                  <v-badge :content="article.comment_count" class="px-2 pt-1">
                    <v-btn
                      icon
                      @click="isCommentOpen = true"
                      class="ml-4"
                      size="small"
                    >
                      <v-icon :color="isCommentOpen ? 'primary' : 'success'"> {{ isCommentOpen ? 'mdi-comment' : 'mdi mdi-comment-outline' }}</v-icon>
                    </v-btn>
                  </v-badge>
                </div>

                <!-- Bookmark Button -->
                 <div>
                   <v-btn
                     icon
                     @click="toggleBookmark"
                     class="ml-4"
                     size="small"
                   >
                     <v-icon :color="article.is_bookmarked ? 'primary' : 'success'">{{ article.is_bookmarked ? 'mdi-bookmark' : 'mdi-bookmark-outline' }}</v-icon>
                   </v-btn>
                 </div>
            </div>
          </auth-dialog>

          <!-- Comment Section -->
          <div id="comments-section"  v-if="!fromDraft && article.status === 'published'" class="flex flex-col gap-2 bg-surface comments-section mt-2">
            <auth-dialog v-if="isCommentOpen" hashId="#comments-section">
              <div class="bg-background">
                <!-- Add Comment Form -->
                <v-textarea
                  v-model="newComment"
                  placeholder="Write a comment..."
                  auto-grow
                  outlined
                  hide-details
                  rows="2"
                  class="mb-4"
                />
              </div>
              <v-btn color="primary" @click="submitComment">Add Comment</v-btn>
            </auth-dialog>

            <auth-dialog hashId="#comments-section">
              <!-- List of Comments -->
              <comment-item
                v-for="comment in comments"
                :key="comment.id"
                :comment="comment"
                :active-reply-id="activeReplyId"
                @reply="toggleReply"
                @submit-reply="submitReply"
                @update-user="comment.user.is_following = $event"
              />
            </auth-dialog>
          </div>
          <ArticleCards v-if="!fromDraft"/>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
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
import AuthDialog from '@/components/dialogs/AuthDialog.vue';
import { useFollowStore } from '@/stores/follow.store';
import { useConversationStore } from '@/stores/conversation.store';
import ArticleCards from '@/views/blog_app/article/ArticleCards.vue';
import { useReactionStore } from '@/stores/blog_app/articles/reaction.store.ts';
import { useBookmarkStore } from '@/stores/blog_app/articles/bookmark.store.ts';

const route = useRoute();
const router = useRouter();
const { currentUser, openChats } = storeToRefs(useUserStore());
const { isMobile } = storeToRefs(useMobileStore());

const articleStore = useArticleStore();
const { article } = storeToRefs(articleStore);

const {
  conversations
} = storeToRefs(useConversationStore());

const {
  createConversation,
} = useConversationStore();

const {
  createReaction,
  deleteReaction
} = useReactionStore();

const {
  createBookmark,
  deleteBookmark
} = useBookmarkStore();

const commentStore = useCommentStore();
const { comments } = storeToRefs(commentStore);
const { createFollow, deleteFollow } = useFollowStore();

const newComment = ref('');
const fromDraft = ref(false);
const isCommentOpen= ref(false)
const activeReplyId = ref<number | null>(null);

onMounted(async () => {
  try {
    await articleStore.fetchArticle(route.params.id);
    await commentStore.fetchComments(route.params.id);

    fromDraft.value = route.query.from_draft && currentUser.value.id === article.value.user.id
    // Set HTML title to article title
    document.title = article.value.title || 'Multi Magic';

    // Set meta description to article description
    document.querySelector("meta[name='description']").setAttribute(
      "content",
      article.value.description || "Multi Magic"
    );

    // Set og:image meta tag for article's cover photo
    if (article.value.cover_photo) {
      document.querySelector("meta[property='og:image']").setAttribute(
        "content",
        article.value.cover_photo
      );
    }

    scrollToHash()
  } catch (error) {
    if (error.error === "Article not found") {
      router.push({ name: 'articles' });
    }
  }
})

onUnmounted(async () => {
  // Reset HTML title
  document.title = 'Multi Magic | All-in-One App for Notes, Finances, Contacts, and More'

  document.querySelector("meta[name='description']").setAttribute(
    "content",
    "Multi Magic helps you manage notes, track finances, handle loans and expenses, save contacts, and more. With messaging, blogging, and future app expansions, it's your go-to productivity app."
  );

  // Reset og:image meta tag
  document.querySelector("meta[property='og:image']").setAttribute(
    "content",
    null
    );
})

function scrollToHash() {
  if (route.hash) {
    const hash = route.hash.substring(1); // Remove the '#' from the hash
    const element = document.getElementById(hash);
    if (element) {
      isCommentOpen.value = true
      element.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }
}

const goBack = () => {
  if(fromDraft.value) {
    router.push({ name: 'edit_article', params: { id: article.value.id } });
  } else {
    router.push({ name: 'articles' });
  }
};

const updateUser = (isFollowing) => {
  article.value.user.is_following = isFollowing
};

const goToEditArticle = () => {
  router.push({ name: 'edit_article', params: { id: article.id } });
};

const submitComment = async () => {
  if (newComment.value) {
    await commentStore.createComment({ body: newComment.value });
    newComment.value = '';
    article.value.comment_count = article.value.comment_count + 1
  }
};

const toggleReply = (commentId: number) => {
  activeReplyId.value = activeReplyId.value === commentId ? null : commentId;
};

const submitReply = async (data: object) => {
  await commentStore.createComment(data);
  activeReplyId.value = null;
  article.value.comment_count = article.value.comment_count + 1
  // if (replyComment.value) {
  //   replyComment.value = '';
  // }
};

const toggleFollowUser = async () => {
  if (!currentUser.value?.id) return

  if (article.value.user?.is_following) {
    await deleteFollow(article.value.user.id);
  } else {
    await createFollow(article.value.user.id);
  }

  article.value.user.is_following = !article.value.user?.is_following
};

// Create a new conversation when a user is selected
const createNewConversation = async (user) => {
  if (!currentUser.value?.id ) return
  const res = await createConversation(user.id);
  conversations.value.unshift(res.conversation);
  openConversation(res.conversation); // Automatically select the new conversation
};

// Function to open a conversation window
const openConversation = async (conversation) => {
  // Check if the conversation is already open
  const existingChat = openChats.value.find((chat) => chat.id === conversation.id);
  if (!existingChat) {
    // await fetchMessages(conversation.id)
    // Add the new conversation to the list of open chat windows
    openChats.value.push({ ...conversation });
  }
};

const toggleReaction = async () => {
  if (!currentUser.value?.id) return;

  if (article.value.is_reacted) {
    await deleteReaction(article.value.id);
    article.value.reaction_count -= 1;
  } else {
    await createReaction(article.value.id);
    article.value.reaction_count += 1;
  }

  article.value.is_reacted = !article.value.is_reacted;
};

const toggleBookmark = async () => {
  if (!currentUser.value?.id) return;

  if (article.value.is_bookmarked) {
    await deleteBookmark(article.value.id);
  } else {
    await createBookmark(article.value.id);
  }

  // Toggle the bookmark state
  article.value.is_bookmarked = !article.value.is_bookmarked;
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
