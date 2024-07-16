<template>
  <div class="space-y-6">
    <v-text-field
      v-model="draftSearch"
      label="Search drafts"
      prepend-inner-icon="mdi-magnify"
      variant="outlined"
      @update:model-value="$emit('debounceSearch', $event)"
    ></v-text-field>

    <div v-if="draftsArticles.length > 0" class="space-y-4">
      <div
        v-for="draft in draftsArticles"
        :key="draft.id"
        @click="$emit('selectDraft', draft)"
        class="flex items-center space-x-4 p-4 rounded-lg border border-border cursor-pointer transition-all duration-300 ease-in-out hover:shadow-md"
      >
        <v-avatar :color="draft.color" size="48">
          <span class="text-lg font-semibold">{{ draft.title.charAt(0).toUpperCase() }}</span>
        </v-avatar>
        <div class="flex-grow">
          <h3 class="text-lg font-semibold">{{ draft.title }}</h3>
          <p>{{ draft.subtitle }}</p>
          <p class="text-sm text-muted-foreground">Last edited: {{ filters.formatDate(draft.updated_at, 'DD/MM/YYYY') }}</p>
        </div>
        <v-btn icon="mdi-pencil" variant="text" @click.stop="$emit('editDraft', draft)"></v-btn>
      </div>
    </div>
    <!-- <v-alert type="info" text="No drafts found. Start a new blog post!" class="mt-4"></v-alert> -->

    <div class="flex justify-center mt-6">
      <v-pagination
        v-if="draftsArticlesPagination"
        :model-value="draftsArticlesPagination.current_page"
        :length="draftsArticlesPagination.total_pages"
        @update:model-value="$emit('fetchNewDraftPage', $event)"
      ></v-pagination>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import filters from "@/tools/filters";

const props = defineProps({
  draftsArticles: { type: Array },
  draftsArticlesPagination: { type: Object, default: () => {} },
});

const draftSearch = ref('')
</script>
