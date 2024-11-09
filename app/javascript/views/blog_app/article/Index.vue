<template>
  <v-container class="mt-12">
    <v-row justify="center">
      <v-col cols="12" md="10" lg="7">
        <v-text-field
          v-model="search"
          label="Search articles"
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
        <v-col v-for="article in articles" :key="article.id" cols="12" md="10" lg="7" class="cursor-pointer">
          <v-card  @click="goToArticle(article.id)" class="d-flex items-center justify-center">
            <div class="flex-grow-1 pa-4">
              <div class="d-flex align-center mb-2">
                <AvatarWithUserInfo
                  class="cursor-pointer mr-1"
                  size="md"
                  :user="article?.user"
                  withFullname
                >
                  <template #fullname>
                    <div>
                      <p class="text-sm font-weight-medium mb-0 hover:underline">{{ article.user?.fullname }}</p>
                      <p class="text-caption">
                        {{ filters.formatDate(article.created_at) }} · {{ article.duration || 0 }} min read
                      </p>
                    </div>
                  </template>
                </AvatarWithUserInfo>
              </div>
              <h2 class="text-h6 font-weight-bold">{{ truncateText(article.title) }}</h2>
              <p v-if="article.description" class="text-subtitle-1 text-grey-darken-1 mb-3"> {{ truncateText(stripHtml(article.description), 100) }}</p>
              <div class="mt-2">
                <v-chip v-for="tag in article.tags" :key="tag" x-small outlined class="mb-2 mr-2">
                  {{ tag.name }}
                </v-chip>
              </div>
            </div>
            <v-img
              :src="article?.cover_photo"
              :alt="article.title"
              :width="isMobile ? 100 : 200"
              :max-width="isMobile ? 100 : 200"
              height="134"
              cover
            ></v-img>
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

const { isMobile } = storeToRefs(useMobileStore());

const articleStore = useArticleStore();
const { articles, page, search, pagination } = storeToRefs(articleStore);
const { fetchArticles, fetchMoreArticles } = articleStore;
const router = useRouter();
const isLoadingMore = ref(false);

const debounceSearch = debounce(() => {
  page.value = 1;
  fetchArticles();
}, 300);

onMounted(async () => {
  await fetchArticles();
});

// Function to go to the article detail page
const goToArticle = (articleId) => {
  router.push({ name: 'article', params: { id: articleId } });
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
  const newLength = isMobile ? length / 2 : length;
  return text.length > newLength ? text.slice(0, newLength) + '...' : text;
};

function stripHtml(html) {
  let tmp = document.createElement("DIV");
  tmp.innerHTML = html;
  return tmp.textContent || tmp.innerText || "";
}
</script>
