<template>
  <v-container class="mt-12">
    <v-row justify="center">
      <v-col cols="12" md="10" lg="7">
        <div class="w-full max-w-[1200px]">
          <h1 class="text-3xl font-bold text-center mb-8">Creation Hub</h1>

          <div class="bg-card shadow-lg rounded-lg overflow-hidden">
            <div class="p-6 sm:p-8">
              <div class="flex justify-center mb-5">
                <div
                  @click="createNewBlog()"
                  class="cursor-pointer transition-all duration-300 ease-in-out transform hover:-translate-y-1 hover:shadow-md rounded-lg border border-border p-6 flex flex-col items-center justify-center space-y-4"
                >
                  <v-icon icon="mdi-plus-circle" size="large" color="success"></v-icon>
                  <h2 class="text-xl font-semibold text-center">Create New Blog</h2>
                  <p class="text-center text-muted-foreground">Start a fresh new blog post</p>
                </div>
              </div>

              <DraftIndex
                :draftsArticles="draftsArticles"
                :draftsArticlesPagination="draftsArticlesPagination"
                @debounceSearch="debounceSearch"
                @selectDraft="selectDraft"
                @editDraft="editDraft"
                @deleteDraft="deleteDraft"
                @fetchNewDraftPage="fetchNewDraftPage"
              />
            </div>
          </div>
        </div>
      </v-col>
    </v-row>
  </v-container>

</template>
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import { useArticleStore } from '@/stores/blog_app/article.store';
import debounce from 'lodash/debounce';
import { useRouter, useRoute } from 'vue-router';
import DraftIndex from '@/components/blog_app/article/DraftIndex.vue';
import { usePopUpStore } from "@/stores/pop-up.store";
import { showToast } from '@/utils/showToast';

const router = useRouter();
const route = useRoute();
const articleStore = useArticleStore();
const { draftsArticles, draftsArticlesPagination, draftSearch, draftPage } = storeToRefs(articleStore);
const { fetchDraftsArticles, createArticle, articleDeletePermanently } = articleStore;
const { openPopUp, closePopUp } = usePopUpStore();

const pageName = 'Blog Creation Hub';
const showDraftsList = ref(false);
const showNewBlogForm = ref(false);
const newBlogTitle = ref('');
const newBlogDescription = ref('');
const selectedCategory = ref(null);
const selectedArticle = ref(null);

onMounted(async () => {
  if (route.query.id) {
    showNewBlogForm.value = true
  }
  await fetchDraftsArticles();
});

const debounceSearch = debounce((event) => {
  draftPage.value = 1;
  draftSearch.value = event
  fetchDraftsArticles();
}, 300);

const selectDraft = (draft) => {
  router.push({ name: 'article', params: { id: draft.id } });

};

const editDraft = (draft) => {
  router.push({ name: 'edit_article', params: { id: draft.id } });
};

const deleteDraft = async (draft) => {
  openPopUp({
    componentName: "pop-up-validation",
    title: ("Are you sure you want to delete this blog ?"),
    textClose: "No, cancel",
    textConfirm: "Yes, delete this blog",
    textLoading: "Deleting ...",
    icon: "mdi-trash-can-outline",
    customClass: "w-[400px]",
    showClose: false,
    async confirm() {
      try {
        await articleDeletePermanently(draft.id, 'draft')
        closePopUp();
        showToast(`${draft.title} blog delete successfully`, 'warning');
      } catch (error) {
        if (error.message.includes('not allowed')) {
          showToast(`Unable to delete "${draft.title}". This article may be associated with other user and cannot be deleted.`, 'error');
        } else {
          showToast(`There was a problem deleting "${draft.title}".`, 'error');
        }
      }
    },
  });
};

const createNewBlog = async () => {
  try {
    const newArticle = await createArticle({
      title: newBlogTitle.value || 'Untitled',
    });
    editDraft(newArticle)
  } catch (error) {
    console.error('Error creating new article:', error);
    // Handle error (e.g., show a notification to the user)
  }
};

const fetchNewDraftPage = async (newPage) => {
  draftPage.value = newPage;
  await fetchDraftsArticles();
};

</script>

<style scoped>
.create-blog-container {
  min-height: 100vh;
}

.create-blog-card {
  backdrop-filter: blur(10px);
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
}

.option-card {
  transition: all 0.3s ease;
  cursor: pointer;
  border-radius: 16px;
  box-shadow: 5px 5px 10px #d9d9d9, -5px -5px 10px #ffffff;
}

.option-card:hover {
  transform: translateY(-5px);
}

.draft-list .draft-item {
  transition: all 0.2s ease;
  border-radius: 12px;
  margin-bottom: 12px;
  box-shadow: 3px 3px 6px #d9d9d9, -3px -3px 6px #ffffff;
}

.draft-list .draft-item:hover {
  transform: translateX(5px);
}

.new-blog-form {
  padding: 20px;
  border-radius: 16px;
  box-shadow: inset 5px 5px 10px #d9d9d9, inset -5px -5px 10px #ffffff;
}

.create-btn {
  color: white;
  font-weight: bold;
  letter-spacing: 1px;
  transition: all 0.3s ease;
}

.create-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
}
</style>