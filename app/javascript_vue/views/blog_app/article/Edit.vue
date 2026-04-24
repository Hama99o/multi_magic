<template>
  <v-app v-if="article">
    <v-app-bar flat class="flex items-center justify-center bg-background">
      <v-btn icon @click="goBack">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-toolbar-title class="text-subtitle-1 font-weight-medium">
        {{ article.title || 'Untitled Article' }}
      </v-toolbar-title>
      <v-spacer></v-spacer>

      <v-btn class="publish-btn" @click="publishArticle">
        <v-icon class="mr-2" left>mdi-send</v-icon>
        <span v-if="article.status === 'draft'"> Publish </span>
        <span v-else> Save </span>
      </v-btn>
      <v-btn class="publish-btn" @click="router.push({ name: 'article', params: { id: article.id }, query: { from_draft: true } })">
        <v-icon class="mr-2" left>mdi-eye</v-icon>
        Preview
      </v-btn>

      <v-menu>
        <template v-slot:activator="{ props }">
          <v-btn icon="mdi-dots-vertical" variant="text" v-bind="props"></v-btn>
        </template>

        <v-list>
          <v-btn variant="text" class="bg-error" @click="removeArticle">
            Delete Blog
          </v-btn>
        </v-list>
      </v-menu>
    </v-app-bar>

    <v-container class="mt-12">
      <v-row justify="center">
        <v-col cols="12" md="10" lg="7">
          <!-- Article Content -->
          <article>
            <!-- Cover image container (unchanged) -->
            <div
              class="cover-image-container group relative cursor-pointer"
              :class="article.cover_photo ? '' : 'bg-accent'"
              @click="
                article.cover_photo
                  ? openCoverImagePreview()
                  : (imageUploaderDialog.dialog = true)
              "
            >
              <v-img
                v-if="article.cover_photo"
                class="bg-grey-lighten-2"
                :height="isMobile ? '200' : '400'"
                :src="article.cover_photo"
                cover
              ></v-img>
              <div
                v-else
                class="empty-state bg-grey-lighten-3 flex h-[200px] md:h-[400px] flex-col items-center justify-center"
              >
                <v-icon size="64" color="grey-darken-1">mdi-image-plus</v-icon>
                <p class="text-grey-darken-1 mt-4 font-medium">Add a cover image</p>
              </div>
              <div
                class="edit-cover-btn absolute right-4 top-4 flex h-10 w-10 transform cursor-pointer items-center justify-center rounded-full border-2 bg-background text-primary shadow-lg transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-xl"
                @click.stop="imageUploaderDialog.dialog = true"
              >
                <Icon
                  :icon="
                    article.cover_photo
                      ? 'material-symbols:edit-outline-rounded'
                      : 'material-symbols:add'
                  "
                  class="h-6 w-6 transform transition-all duration-300 ease-in-out group-hover:scale-110"
                />
              </div>
            </div>

            <v-text-field
              v-model="article.title"
              variant="solo-filled"
              placeholder="Enter an engaging title for your post"
              class="mt-6"
              hide-details
              @update:model-value="debounceUpdateArticle"
            ></v-text-field>

            <v-text-field
              v-model="article.duration"
              type="number"
              label="Duration (minutes)"
              placeholder="Enter estimated duration"
              class="mt-4 max-w-[300px]"
              hide-details
              variant="solo-filled"
              @update:model-value="debounceUpdateArticle"
            />

            <!-- New Tag Selection Component -->
            <div class="tag-selection mt-4 bg-surface">
              <v-autocomplete
                :key="generator"
                ref="parentTagAutocomplete"
                v-model="article.tags"
                :items="tags"
                :label="`Category (Select up to 3 categories: ${article.tag_ids.length}/3)`"
                item-title="name"
                item-value="id"
                placeholder="Select a Category"
                clearable
                required
                variant="solo-filled"
                multiple
                hide-details
                :disabled="article?.tags?.length >= 3"
                :max="4"
                clear-icon="mdi-close"
                prepend-inner-icon="mdi-tag-plus"
                @update:model-value="updateTags"
                @update:search="searchTags"
              >
                <template #append-item>
                  <div v-intersect="onIntersect" />
                </template>
              </v-autocomplete>

              <p v-if="article?.tags?.length >= 3" class="text-sm m-1">
                Note: You cannot choose more than three categories.
              </p>

              <div class="top-tags m-2 ml-1">
                <div class="tag-list">
                  <v-chip
                    v-for="tag in article.tags"
                    :key="tag.id"
                    closable
                    class="mb-2 mr-2"
                    @click:close="removeTag(tag)"
                  >
                    {{ tag.name }}
                  </v-chip>
                </div>
              </div>
            </div>

            <tiptap-editor
              v-if="article.description"
              ref="tiptapEditor"
              :record-id="article.id"
              class="mt-4 rounded-lg bg-surface"
              :content="article.description"
              autofocus
              @on-save="debounceUpdateDescriptionArticle($event)"
            />
          </article>
        </v-col>
      </v-row>
    </v-container>
  </v-app>

  <ImageUploader ref="imageUploaderDialog" @update-image="uploadImage" />

  <image-preview
    ref="coverImagePreviewDialog"
    :image="article.cover_photo"
    @delete-avatar="deleteAvatar('cover_photo')"
    @open-edit-image-dialog="imageUploaderDialog.dialog = true"
  />
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { storeToRefs } from 'pinia';
import debounce from 'lodash/debounce';
import { Icon } from '@iconify/vue';
import { useArticleStore } from '@/stores/blog_app/article.store';
import { useBlogTagStore } from '@/stores/blog_app/tag.store';
import TiptapEditor from '@/components/richtext/TiptapEditor.vue';
import ImageUploader from '@/components/upload/ImageUploaderDialog.vue';
import ImagePreview from '@/components/users/ImagePreview.vue';
import { useMobileStore } from "@/stores/mobile";
import { usePopUpStore } from "@/stores/pop-up.store";
import { showToast } from '@/utils/showToast';

const { isMobile } = storeToRefs(useMobileStore());
const route = useRoute();
const router = useRouter();
const { openPopUp, closePopUp } = usePopUpStore();

const tagStore = useBlogTagStore();
const { tags, totalPages: totalTagPages, page: tagPage } = storeToRefs(tagStore);
const { fetchArticle, updateArticle, toggleTag, articleDeletePermanently } = useArticleStore();

const article = ref({
  id: '',
  title: '',
  subtitle: '',
  description: '',
  cover_photo: '',
  tag_ids: [],
  duration: 0, // Add duration field here
});

const coverImagePreviewDialog = ref(false);
const imageUploaderDialog = ref(null);
const selectedTags = ref([]);
const generator = ref(1);

const availableTags = computed(() => {
  return tags.value.map((tag) => ({
    name: tag.name,
    id: tag.id,
    description: tag.description,
  }));
});

const removeArticle = async () => {
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
        await articleDeletePermanently(article.value.id)
        router.push({ name: 'new_article' });
        closePopUp();
        showToast(`${article.value.title} blog delete successfully`, 'warning');
      } catch (error) {
        if (error.message.includes('not allowed')) {
          showToast(`Unable to delete "${article.value.title}". This article may be associated with other user and cannot be deleted.`, 'error');
        } else {
          showToast(`There was a problem deleting "${article.value.title}".`, 'error');
        }
      }
    },
  });
}

onMounted(async () => {
  const fetchedArticle = await fetchArticle(route.params.id);
  article.value = { ...article.value, ...fetchedArticle };
  await tagStore.fetchTags();
  selectedTags.value = article.value.tag_ids.map((id) =>
    availableTags.value.find((tag) => tag.id === id),
  );
});

const goBack = () => {
  router.push({ name: 'new_article' });
};

const publishArticle = () => {
  updateArticle(article.value.id, { status: 'published' });
  router.push({ name: 'article', params: { id: article.value.id } });
};

const uploadImage = async (file) => {
  const formData = new FormData();
  formData.append('cover_photo', file);
  if (formData) {
    const updatedArticle = await updateArticle(article.value.id, formData);
    article.value.cover_photo = updatedArticle.cover_photo;
  }
};

const openCoverImagePreview = () => {
  coverImagePreviewDialog.value.dialog = true;
};

const debounceUpdateDescriptionArticle = debounce((articleDescription) => {
  article.value.description = articleDescription;
  updateArticle(article.value.id, {
    description: article.value.description,
  });
}, 300);

const debounceUpdateArticle = debounce(() => {
  updateArticle(article.value.id, {
    title: article.value.title,
    description: article.value.description,
    subtitle: article.value.subtitle,
    duration: article.value.duration,
  });
}, 300);

const deleteAvatar = (field) => {
  article.value[field] = null;
  updateArticle(article.value.id, { [field]: null });
};

const updateTags = async (tag_ids) => {
  const data = await toggleTag(article.value.id, tag_ids);
  article.value.tags = data.tags;
  generator.value += generator.value;
};

const searchTags = async (text) => {
  await tagStore.fetchTags(text)
};

const onIntersect = async (isIntersecting, entries, observer) => {
  if (isIntersecting && tagPage.value < totalTagPages.value) {
    tagPage.value = tagPage.value + 1
    const newTags = await tagStore.fetchSearchTags('', tagPage.value)
    tags.value = [...tags.value, ...newTags]
  }
}

const removeTag = async (tag) => {
  article.value.tags = article.value.tags.filter((t) => t.id !== tag.id);
  const data = await toggleTag(article.value.id, article.value.tags.map(tag => tag.id));
  article.value.tags = data.tags;
  generator.value += generator.value;
};
</script>
