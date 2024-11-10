<template>
  <v-container v-if="articles?.length" class="mt-12">
    <v-card>
      <v-data-iterator :items="articles" :items-per-page="4" :search="search">
        <!-- Articles Display -->
        <template #default="{ items }">
          <v-container class="pa-2" fluid>
            <v-row dense>
              <v-col v-for="item in items" :key="item.title" cols="12" md="6">
                <v-card class="pb-3" border flat @click="goToArticle(item.raw.id)">
                  <v-img height="325" cover :src="item.raw.cover_photo"></v-img>

                  <v-list-item>
                    <div class="d-flex align-center">
                      <user-avatar
                        class="mr-3 cursor-pointer"
                        size="sm"
                        :avatar="item.raw?.user?.avatar"
                        :firstname="item.raw?.user?.lastname"
                        :lastname="item.raw?.user?.firstname"
                      />
                      <div>
                        <span
                          class="font-weight-medium cursor-pointer text-sm hover:underline"
                          @click.stop="goToProfile(item.raw.user.id)"
                        >
                          {{ item.raw.user.fullname }}
                        </span>
                      </div>
                    </div>
                  </v-list-item>

                  <v-list-item :subtitle="item.raw.subtitle" class="mb-2">
                    <template #title>
                      <strong class="text-h6 mb-2">{{ item.raw.title }}</strong>
                    </template>
                  </v-list-item>

                  <div class="d-flex justify-space-between px-4">
                    <div class="d-flex align-center text-caption text-medium-emphasis me-1">
                      <v-icon icon="mdi-clock" start></v-icon>
                      <div class="text-truncate">{{ item.raw.duration }}</div>
                    </div>
                  </div>
                </v-card>
              </v-col>
            </v-row>
          </v-container>
        </template>

        <!-- Pagination Footer -->
        <template #footer="{ page, pageCount, prevPage, nextPage }">
          <div class="d-flex align-center pa-4 justify-center">
            <v-btn
              :disabled="page === 1"
              density="comfortable"
              icon="mdi-arrow-left"
              variant="tonal"
              rounded
              @click="prevPage"
            ></v-btn>

            <div class="text-caption mx-2">Page {{ page }} of {{ pageCount }}</div>

            <v-btn
              :disabled="page >= pageCount"
              density="comfortable"
              icon="mdi-arrow-right"
              variant="tonal"
              rounded
              @click="nextPage"
            ></v-btn>
          </div>
        </template>
      </v-data-iterator>
    </v-card>
  </v-container>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import debounce from 'lodash/debounce';
import { storeToRefs } from 'pinia';
import { useRouter } from 'vue-router';
import UserAvatar from '@/components/tools/Avatar.vue';
import { useArticleStore } from '@/stores/blog_app/article.store';

const articleStore = useArticleStore();
const { articles, page, search, pagination } = storeToRefs(articleStore);
const { fetchArticles, fetchArticle, resetArticle } = articleStore;

const router = useRouter();

const goToProfile = (userId: any) => {
  router.push({ name: 'user', params: { id: userId } });
};

const goToArticle = async (articleId: any) => {
  await resetArticle();
  router.push({ name: 'article', params: { id: articleId } });
  await fetchArticle(articleId);
  const article = document.getElementById(`article-${articleId}`);

  if (article) article.scrollIntoView({ behavior: 'smooth' });
};

watch(page, () => {
  fetchArticles();
});

onMounted(async () => {
  await fetchArticles();
});
</script>

<style scoped>
.v-card {
  transition: box-shadow 0.3s ease-in-out;
}

.v-card:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}
</style>
