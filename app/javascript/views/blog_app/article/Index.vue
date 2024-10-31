<template>
  <v-container class="mt-12">
    <v-row justify="center">
      <v-col cols="12" md="10" lg="7" >
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
    <v-row justify="center">
      <v-col v-for="article in articles" :key="article.id" @click="goToArticle(article.id)" cols="12" md="10" lg="7" class="cursor-pointer mb-4">
        <v-card class="d-flex items-center justify-center">
          <div class="flex-grow-1 pa-4">
            <div class="d-flex align-center mb-2">
              <!-- can-show-online
              :is-online="article?.user?.is_online" -->
              <AvatarWithUserInfo
                class="cursor-pointer mr-1"
                size="md"
                :user="article?.user"
                withFullname
              >
                <template #fullname>
                  <div>
                    <p class="text-sm font-weight-medium mb-0">{{ article.user?.fullname }}</p>
                    <p class="text-caption">
                      {{ filters.formatDate(article.created_at) }} · {{ article.duration || 0 }} min read
                    </p>
                  </div>
                </template>
              </AvatarWithUserInfo>
            </div>

            <h2 class="text-h6 font-weight-bold mb-2">{{ truncateText(article.title) }}</h2>
            <p class="text-subtitle-1 text-grey-darken-1 mb-3">{{ article.subtitle }}</p>

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
    <v-row>
      <v-col cols="12" class="text-center">
        <v-pagination
          v-if="pagination"
          :model-value="pagination.current_page"
          :length="pagination.total_pages"
          theme="primary"
          variant="text"
          class="my-6 !list-none"
          @update:model-value="fetchNewPage"
        ></v-pagination>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { storeToRefs } from 'pinia';
import debounce from 'lodash/debounce';
import { useArticleStore } from '@/stores/blog_app/article.store';
import AvatarWithUserInfo from '@/components/tools/AvatarWithUserInfo.vue';
import { useRouter, useRoute } from 'vue-router';
import filters from '@/tools/filters';
import { useMobileStore } from "@/stores/mobile";

const { isMobile } = storeToRefs(useMobileStore());

const articleStore = useArticleStore();
const { articles, page, search, pagination } = storeToRefs(articleStore);
const { fetchArticles } = articleStore;
const router = useRouter();

const debounceSearch = debounce(() => {
  page.value = 1;
  fetchArticles();
}, 300);

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
};

watch(page, () => {
  fetchArticles();
});

onMounted(async () => {
  await fetchArticles();
});

const goToProfile = (userId) => {
  router.push({ name: 'user', params: { id: userId } })
}

const goToArticle = (articleId) => {
  router.push({ name: 'article', params: { id: articleId } })
}

const fetchNewPage = async(e) => {
  try {
    page.value = e
    await fetchArticles();
  } catch (error) {
    console.log(error);
  }
};

const truncateText = (text) => {
  const length = isMobile ? 40 : 70
  return text.length > length ? text.slice(0, length) + '...' : text;
};
</script>

<style scoped>
.v-card {
  transition: box-shadow 0.3s ease-in-out;
}

.v-card:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}
</style>
