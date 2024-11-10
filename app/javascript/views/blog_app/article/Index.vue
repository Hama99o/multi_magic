<template>
  <v-container class="mt-12">
    <v-row justify="center">
      <v-col cols="12" md="10" lg="7">
        <v-text-field
          v-model="search"
          label="Search"
          prepend-inner-icon="mdi-magnify"
          variant="solo"
          dense
          @input="debounceSearch"
        ></v-text-field>
      </v-col>
    </v-row>

    <!-- Infinite Scroll for Articles -->
    <v-infinite-scroll
      :onLoad="fetchMoreData"
      class="overflow-hidden"
    >
      <v-row justify="center">
        <v-col v-for="article in articles" :key="article.id" cols="12" md="10" lg="7">
          <v-card>
            <div @click="goToArticle(article.id)" class="d-flex items-center justify-center cursor-pointer">
              <div class="flex-grow-1 pa-4">
                <div class="d-flex align-center mb-2">
                  <AvatarWithUserInfo
                    class="cursor-pointer mr-1"
                    size="md"
                    :user="article?.user"
                    withFullname
                  >
                    <template #fullname>
                      <div class="mx-2">
                        <p class="md:text-sm text-xs font-weight-medium mb-0 hover:underline">{{ article.user?.fullname }}</p>
                        <p class="text-caption">
                          {{ filters.formatDate(article.created_at) }} · {{ article.duration || 0 }} min read
                        </p>
                      </div>
                    </template>
                  </AvatarWithUserInfo>
                </div>

                <h2 class="text-h6 font-weight-bold">{{ truncateText(article.title) }}</h2>
                <p v-if="article.description" class="text-subtitle-1 mb-3"> {{ truncateText(stripHtml(article.description), 100) }}</p>

                <div class="mt-2">
                  <v-chip v-for="tag in article.tags" :key="tag" x-small outlined class="mb-2 mr-2">
                    {{ tag.name }}
                  </v-chip>
                </div>
              </div>

              <v-img
                v-if="!isMobile"
                :src="article?.cover_photo"
                :alt="article.title"
                :width="200"
                :max-width="200"
                height="134"
                cover
                class="m-4 rounded"
              ></v-img>
            </div>

            <v-divider class="border-opacity-100" color="success"></v-divider>
            <!-- Article Information Section -->
            <div class="rounded d-flex align-center p-2 justify-space-between bg-surface">
              <!-- Reactions and Comments -->
              <div class="d-flex align-center">
                <!-- Reactions Icons and Count -->
                <div class="d-flex align-center">
                  <v-badge :content="article.reaction_count || 0" class="px-2 pt-1">
                    <v-icon
                      small
                      class="mr-1"
                      :color="article.is_reacted ? 'primary' : 'success'"
                      @click.stop="toggleReaction(article)"
                    >
                      {{ article.is_reacted ? 'mdi-heart' : 'mdi-heart-outline' }}
                    </v-icon>
                  </v-badge>
                </div>

                <!-- Comments Count -->
                <div
                  @click.stop="goToArticleComment(article)"
                  class="d-flex align-center ml-4 cursor-pointer hover:text-blue"
                  >
                  <v-badge  :content="article.comment_count || 0" class="px-2 pt-1">
                    <v-icon small class="mr-1" :color="article.comment_count ? 'primary' : 'success'">mdi-comment-text-outline</v-icon>
                  </v-badge>
                </div>
              </div>

              <!-- Reading Time and Bookmark -->
              <div class="d-flex align-center">
                <v-icon
                  :color="article.is_bookmarked ? 'primary' : 'success'"
                  @click.stop="toggleBookmark(article)"
                >
                  {{ article.is_bookmarked ? 'mdi-bookmark' : 'mdi-bookmark-outline' }}
                </v-icon>
                <v-badge  :content="article.unique_view_count" class="px-2 pt-1">
                  <v-icon :color="article.view_count ? 'primary' : 'success'" small >mdi mdi-eye</v-icon>
                </v-badge>
              </div>
            </div>
          </v-card>

        </v-col>
      </v-row>
      <template #empty />
    </v-infinite-scroll>
  </v-container>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { storeToRefs } from 'pinia';
import debounce from 'lodash/debounce';
import { useArticleStore } from '@/stores/blog_app/article.store';
import AvatarWithUserInfo from '@/components/tools/AvatarWithUserInfo.vue';
import { useRouter } from 'vue-router';
import filters from '@/tools/filters';
import { useMobileStore } from "@/stores/mobile";
import { useReactionStore } from '@/stores/blog_app/articles/reaction.store.ts';
import { useBookmarkStore } from '@/stores/blog_app/articles/bookmark.store.ts';
import { useUserStore } from '@/stores/user.store';

const { isMobile } = storeToRefs(useMobileStore());
const { currentUser } = storeToRefs(useUserStore());
const articleStore = useArticleStore();
const { articles, page, search, pagination } = storeToRefs(articleStore);
const { fetchArticles, fetchMoreArticles } = articleStore;
const router = useRouter();
const isLoadingMore = ref(false);


const {
  createReaction,
  deleteReaction
} = useReactionStore();

const {
  createBookmark,
  deleteBookmark
} = useBookmarkStore();

const debounceSearch = debounce(() => {
  page.value = 1;
  fetchArticles();
}, 300);

onMounted(async () => {
  page.value = 1;
  await fetchArticles();
});

// Function to go to the article detail page
const goToArticle = (articleId) => {
  router.push({ name: 'article', params: { id: articleId } });
};

// Function to go to the article detail page
const goToArticleComment = (article) => {
  router.push({ name: 'article', params: { id: article.id }, hash: '#comments-section' });
};

// Infinite Scroll - Load More Articles
async function fetchMoreData ({ done }) {
  if (page.value < pagination.value.total_pages) {
    try {
      page.value += 1;
      const moveArticles = await fetchMoreArticles();
      if (moveArticles.length) {
        articles.value.push(...moveArticles);
      }
      done('ok');
    } catch (error) {
      done('error');
    }
  } else {
    done('empty');
  }
}

// Truncate text based on screen size
const truncateText = (text, length = 70 ) => {
  return text.length > length ? text.slice(0, length) + '...' : text;
};

function stripHtml(html) {
  let tmp = document.createElement("DIV");
  tmp.innerHTML = html;
  return tmp.textContent || tmp.innerText || "";
}

const toggleReaction = async (article) => {
  if (!currentUser.value?.id) return;

  if (article.is_reacted) {
    await deleteReaction(article.id);
    article.reaction_count -= 1;
  } else {
    await createReaction(article.id);
    article.reaction_count += 1;
  }

  article.is_reacted = !article.is_reacted;
};

const toggleBookmark = async (article) => {
  if (!currentUser.value?.id) return;

  if (article.is_bookmarked) {
    await deleteBookmark(article.id);
  } else {
    await createBookmark(article.id);
  }

  // Toggle the bookmark state
  article.is_bookmarked = !article.is_bookmarked;
};
</script>
