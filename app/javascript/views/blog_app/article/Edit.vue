<template>
  <v-app>
    <v-app-bar flat class="flex items-center justify-center bg-background">
      <v-btn icon @click="goBack">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-toolbar-title class="text-subtitle-1 font-weight-medium">
        {{ article.title || 'Untitled Article' }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn class="publish-btn hover:bg-primary" @click="publishArticle">
        <v-icon class="mr-2" left>mdi-send</v-icon>
        <span v-if="article.status === 'draft'"> Publish </span>
        <span v-else> Save </span>
      </v-btn>
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
                :disabled="article?.tag_ids?.length >= 3"
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

              <p v-if="article?.tag_ids?.length >= 3" class="text-sm m-1">
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
import { useTagStore } from '@/stores/blog_app/tag.store';
import TiptapEditor from '@/components/richtext/TiptapEditor.vue';
import ImageUploader from '@/components/upload/ImageUploaderDialog.vue';
import ImagePreview from '@/components/users/ImagePreview.vue';
import { useMobileStore } from "@/stores/mobile";

const { isMobile } = storeToRefs(useMobileStore());
const route = useRoute();
const router = useRouter();

const tagStore = useTagStore();
const { tags, totalPages: totalTagPages, page: tagPage } = storeToRefs(tagStore);
const { fetchArticle, updateArticle, toggleTag } = useArticleStore();

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

const topTags = computed(() => {
  // Logic to determine top tags (e.g., most used or featured tags)
  return availableTags.value.slice(0, 5);
});

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
  article.value.tag_ids = article.value.tag_ids.filter((t) => t !== tag.id);
  const data = await toggleTag(article.value.id, article.value.tag_ids);
  article.value.tags = data.tags;
  generator.value += generator.value;
};
</script>
