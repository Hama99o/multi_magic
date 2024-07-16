<template>
  <v-container>
    <v-row>
      <v-col cols="12" class="mb-4">
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
    <v-row>
      <v-col v-for="article in articles" :key="article.id" @click="goToArticle(article.id)"cols="12" class="cursor-pointer mb-4">
        <v-card class="d-flex flex-column flex-sm-row">
          <div class="flex-grow-1 pa-4">
            <div class="d-flex align-center mb-2">
              <!-- can-show-online
              :is-online="article?.user?.is_online" -->
              <user-avatar
                class="mr-3 cursor-pointer"
                size="lg"
                :avatar="article?.user?.avatar"
                :firstname="article?.user?.lastname"
                :lastname="article?.user?.firstname"
              />
              <div>
                <span @click="goToProfile(article.user.id)" class="font-weight-medium cursor-pointer hover:underline">{{ article.user.fullname }}</span>
                <span class="text-caption ml-2 text-grey">in {{ 'group_name' }}</span>
              </div>
            </div>

            <h2 class="text-h5 font-weight-bold mb-2">{{ article.title }}</h2>
            <p class="text-subtitle-1 text-grey-darken-1 mb-3">{{ article.subtitle }}</p>

            <div class="d-flex align-center text-caption text-grey">
              <span>{{ formatDate(article.created_at) }}</span>
              <v-icon small class="mx-1">mdi-circle-small</v-icon>
              <span>{{ 'article.readTime' }} min read</span>
              <!-- <v-chip v-if="article.memberOnly" x-small color="success" class="ml-2">Member only</v-chip> -->
              <v-chip x-small color="success" class="ml-2">Member only</v-chip>
            </div>
            <div class="mt-2">
              <v-chip v-for="tag in article.tags" :key="tag" x-small outlined class="mb-2 mr-2">
                {{ tag.name }}
              </v-chip>
            </div>
          </div>
          <v-img
            :src="article?.cover_photo"
            :alt="article.title"
            class="flex-shrink-0"
            width="200"
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
import UserAvatar from '@/components/tools/Avatar.vue';
import { useRouter, useRoute } from 'vue-router';

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
  console.log(articleId)
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

</script>

<style scoped>
.v-card {
  transition: box-shadow 0.3s ease-in-out;
}

.v-card:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}
</style>
