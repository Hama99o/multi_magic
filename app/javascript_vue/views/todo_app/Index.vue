<template>
  <div ref="scrollContainer" class="todo-app v-container bg-background p-4 md:p-6">
    <!-- Header -->
    <div class="mb-6">
      <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 class="flex items-center gap-2 text-2xl font-bold">
            <v-icon size="28">mdi-checkbox-marked-outline</v-icon>
            My Tasks
          </h1>
          <p class="mt-1 text-sm opacity-70">
            {{ pendingGroupsCount }} pending ·
            {{ groupsPagination?.total_items || todoGroups.length }} lists
          </p>
        </div>

        <div class="flex items-center gap-3">
          <!-- Search -->
          <v-text-field
            v-model="search"
            class="w-full max-w-[600px] rounded-lg md:w-[258px]"
            variant="outlined"
            density="compact"
            hide-details
            clearable
            :loading="searching"
            prepend-inner-icon="mdi-magnify"
            placeholder="Search lists"
            @update:model-value="handleSearch"
            @click:clear="clearSearch"
          />

          <!-- New List Button -->
          <v-btn
            variant="flat"
            prepend-icon="mdi-plus"
            class="rounded-lg !bg-surface shadow-md hover:bg-primary"
            elevation="2"
            @click="showCreateGroupDialog = true"
          >
            New List
          </v-btn>
        </div>
      </div>
    </div>

    <!-- Search Results Info -->
    <div v-if="isSearching" class="mb-4">
      <p class="text-sm opacity-70">
        Showing {{ todoGroups.length }} lists matching "{{ search }}"
      </p>
    </div>

    <!-- No search results -->
    <div
      v-if="isSearching && todoGroups.length === 0 && !searching && !loading"
      class="py-16 text-center opacity-70"
    >
      <v-icon size="64" class="mb-4">mdi-magnify</v-icon>
      <p>No lists found</p>
      <p class="text-sm">Try a different search term</p>
    </div>

    <!-- Grid of Group Cards -->
    <div
      v-if="todoGroups.length > 0"
      class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
    >
      <v-card
        v-for="group in todoGroups"
        :key="group.id"
        variant="outlined"
        class="group cursor-pointer overflow-hidden rounded-lg transition-all hover:border-primary hover:shadow-lg"
        @click="selectGroup(group)"
      >
        <!-- Card Header -->
        <div class="flex items-center justify-between border-b border-gray-700 px-4 py-3">
          <div class="flex min-w-0 flex-1 items-center gap-2">
            <v-icon size="20" class="shrink-0 text-primary">mdi-format-list-checks</v-icon>
            <span class="truncate font-semibold">{{ group.name }}</span>
          </div>
          <div class="flex shrink-0 items-center gap-1">
            <v-chip size="x-small" variant="tonal" color="primary">
              {{ group.pending_count || 0 }}
            </v-chip>
            <v-btn
              icon
              size="x-small"
              variant="text"
              class="!text-error opacity-0 transition-opacity group-hover:opacity-100"
              @click.stop="confirmDeleteGroup(group)"
            >
              <v-icon size="16">mdi-delete-outline</v-icon>
              <v-tooltip activator="parent" location="top">Delete list</v-tooltip>
            </v-btn>
          </div>
        </div>

        <!-- Preview Todos -->
        <div class="min-h-[120px]">
          <template v-if="getGroupPreviewTodos(group).length > 0">
            <div
              v-for="todo in getGroupPreviewTodos(group)"
              :key="todo.id"
              class="flex items-center gap-2 border-b border-gray-800 px-4 py-2 last:border-b-0"
            >
              <v-icon size="14" class="shrink-0 opacity-50">
                {{
                  todo.completed
                    ? 'mdi-checkbox-marked-circle'
                    : 'mdi-checkbox-blank-circle-outline'
                }}
              </v-icon>
              <span
                class="flex-1 truncate text-sm"
                :class="{ 'line-through opacity-50': todo.completed }"
              >
                {{ todo.title }}
              </span>
            </div>
          </template>
          <div v-else class="flex h-[120px] items-center justify-center text-sm italic opacity-50">
            No pending tasks
          </div>
        </div>

        <!-- Card Footer -->
        <div
          class="flex items-center justify-between border-t border-gray-700 bg-surface/30 px-4 py-2"
        >
          <span class="text-xs opacity-60">{{ group.completed_count || 0 }} completed</span>
          <div v-if="(group.pending_count || 0) > 3" class="text-xs text-primary">
            +{{ (group.pending_count || 0) - 3 }} more
          </div>
          <v-icon size="16" class="opacity-50 transition-transform group-hover:translate-x-1">
            mdi-chevron-right
          </v-icon>
        </div>
      </v-card>
    </div>

    <!-- Loading More Skeleton -->
    <div
      v-if="loadingMoreGroups"
      class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
    >
      <v-card
        v-for="n in 4"
        :key="'more-' + n"
        variant="outlined"
        class="overflow-hidden rounded-lg"
      >
        <div class="flex items-center gap-2 border-b border-gray-700 px-4 py-3">
          <v-skeleton-loader type="avatar" class="!h-5 !min-h-0 !w-5"></v-skeleton-loader>
          <v-skeleton-loader type="text" class="!h-4 flex-1"></v-skeleton-loader>
        </div>
        <div class="min-h-[120px] px-4 py-2">
          <div v-for="i in 3" :key="i" class="border-b border-gray-800 last:border-b-0">
            <v-skeleton-loader type="list-item-avatar" class="py-1"></v-skeleton-loader>
          </div>
        </div>
        <div
          class="flex items-center justify-between border-t border-gray-700 bg-surface/30 px-4 py-2"
        >
          <v-skeleton-loader type="text" class="!h-3 !w-20"></v-skeleton-loader>
        </div>
      </v-card>
    </div>

    <!-- Empty State -->
    <div v-if="todoGroups.length === 0 && !loading && !isSearching" class="py-16 text-center">
      <v-icon size="80" class="mb-4 opacity-50">mdi-clipboard-list-outline</v-icon>
      <h3 class="mb-2 text-lg font-medium">Get Started</h3>
      <p class="mb-4 opacity-70">Create your first list to organize your tasks</p>
      <v-btn
        variant="flat"
        prepend-icon="mdi-plus"
        class="rounded-lg !bg-surface shadow-md hover:bg-primary"
        elevation="2"
        @click="showCreateGroupDialog = true"
      >
        Create List
      </v-btn>
    </div>

    <!-- Skeleton Loading State -->
    <div
      v-if="loading && todoGroups.length === 0"
      class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
    >
      <v-card v-for="n in 8" :key="n" variant="outlined" class="overflow-hidden rounded-lg">
        <div class="flex items-center gap-2 border-b border-gray-700 px-4 py-3">
          <v-skeleton-loader type="avatar" class="!h-5 !min-h-0 !w-5"></v-skeleton-loader>
          <v-skeleton-loader type="text" class="!h-4 flex-1"></v-skeleton-loader>
        </div>
        <div class="min-h-[120px] px-4 py-2">
          <div v-for="i in 3" :key="i" class="border-b border-gray-800 last:border-b-0">
            <v-skeleton-loader type="list-item-avatar" class="py-1"></v-skeleton-loader>
          </div>
        </div>
        <div
          class="flex items-center justify-between border-t border-gray-700 bg-surface/30 px-4 py-2"
        >
          <v-skeleton-loader type="text" class="!h-3 !w-20"></v-skeleton-loader>
        </div>
      </v-card>
    </div>

    <!-- Create Group Dialog -->
    <v-dialog v-model="showCreateGroupDialog" max-width="400">
      <v-card class="rounded-lg">
        <v-card-title class="flex items-center gap-2">
          <v-icon>mdi-folder-plus</v-icon>
          Create New List
        </v-card-title>
        <v-card-text>
          <v-text-field
            v-model="newGroupName"
            label="List name"
            placeholder="e.g., Work, Personal, Shopping"
            variant="outlined"
            autofocus
            counter="50"
            maxlength="50"
            :rules="[(v) => !!v.trim() || 'Name is required']"
            @keyup.enter="createGroup"
          ></v-text-field>
        </v-card-text>
        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn variant="text" class="!text-primary" @click="showCreateGroupDialog = false">
            Cancel
          </v-btn>
          <v-btn
            variant="flat"
            class="rounded-lg !bg-surface shadow-md hover:bg-primary"
            elevation="2"
            :disabled="!newGroupName.trim()"
            @click="createGroup"
          >
            Create
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Delete Confirmation Dialog -->
    <v-dialog v-model="showDeleteDialog" max-width="400">
      <v-card class="rounded-lg">
        <v-card-title class="flex items-center gap-2">
          <v-icon>mdi-alert-circle</v-icon>
          Delete List
        </v-card-title>
        <v-card-text>
          <p>
            Are you sure you want to delete <strong>"{{ groupToDelete?.name }}"</strong>?
          </p>
          <p class="mt-2 text-sm opacity-70">
            All {{ groupToDelete?.todos_count || 0 }} tasks in this list will be permanently
            deleted.
          </p>
        </v-card-text>
        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn variant="text" class="!text-primary" @click="showDeleteDialog = false">
            Cancel
          </v-btn>
          <v-btn variant="flat" color="error" @click="deleteGroup">Delete</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Infinite scroll sentinel -->
    <div ref="loadMoreSentinel" class="h-px"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue';
import { debounce } from 'lodash';
import { storeToRefs } from 'pinia';
import { useRouter } from 'vue-router';
import { useTodoStore } from '@/stores/todo_app/todo.store';
import { showToast } from '@/utils/showToast';

type Todo = {
  id: number;
  title: string;
  notes: string | null;
  completed: boolean;
  position: number;
  todo_group_id: number;
  created_at: string;
  updated_at: string;
};

type TodoGroup = {
  id: number;
  name: string;
  position: number;
  todos_count: number;
  completed_count: number;
  pending_count: number;
  todos: Todo[];
  preview_todos?: Todo[];
  created_at: string;
  updated_at: string;
};

const todoStore = useTodoStore();
const { todoGroups, searching, loading, loadingMoreGroups, groupsPagination } =
  storeToRefs(todoStore);

const router = useRouter();

// UI State
const scrollContainer = ref<HTMLElement | null>(null);
const loadMoreSentinel = ref<HTMLElement | null>(null);
const search = ref('');
const newGroupName = ref('');
const showCreateGroupDialog = ref(false);
const showDeleteDialog = ref(false);
const groupToDelete = ref<TodoGroup | null>(null);

let infiniteObserver: IntersectionObserver | null = null;

// Computed
const isSearching = computed(() => search.value.trim().length > 0);

const pendingGroupsCount = computed(() => {
  return todoGroups.value.filter((g) => (g.pending_count || 0) > 0).length;
});

// Get preview todos for grid card
const getGroupPreviewTodos = (group: TodoGroup) => {
  if (group.preview_todos && group.preview_todos.length > 0) {
    return group.preview_todos;
  }
  return (group.todos || []).filter((t) => !t.completed).slice(0, 3);
};

const setupInfiniteObserver = () => {
  if (infiniteObserver) {
    infiniteObserver.disconnect();
    infiniteObserver = null;
  }

  // If this page ends up inside a scrollable container, use it as the root.
  // Otherwise fall back to viewport.
  const rootEl = scrollContainer.value;
  const root = rootEl && getComputedStyle(rootEl).overflowY !== 'visible' ? rootEl : null;

  infiniteObserver = new IntersectionObserver(
    async (entries) => {
      const anyVisible = entries.some((e) => e.isIntersecting);
      if (!anyVisible) return;
      await todoStore.fetchMoreTodoGroups();
    },
    {
      root,
      rootMargin: '200px',
      threshold: 0,
    },
  );

  if (loadMoreSentinel.value) {
    infiniteObserver.observe(loadMoreSentinel.value);
  }
};

// Lifecycle
onMounted(async () => {
  await todoStore.fetchTodoGroups();
  await nextTick();
  setupInfiniteObserver();
});

onUnmounted(() => {
  infiniteObserver?.disconnect();
});

// Methods
const handleSearch = debounce(() => {
  todoStore.search = search.value;
  todoStore.fetchTodoGroups(1, false);
}, 300);

const clearSearch = () => {
  search.value = '';
  todoStore.search = '';
  todoStore.fetchTodoGroups(1, false);
};

const selectGroup = (group: TodoGroup) => {
  router.push({ name: 'todo_group', params: { groupId: group.id } });
};

const createGroup = async () => {
  if (!newGroupName.value.trim()) return;
  try {
    const newGroup = await todoStore.createTodoGroup(newGroupName.value.trim());
    await todoStore.fetchTodoGroups();
    if (newGroup?.id) {
      router.push({ name: 'todo_group', params: { groupId: newGroup.id } });
    }
    newGroupName.value = '';
    showCreateGroupDialog.value = false;
    showToast('List created successfully', 'success');
  } catch {
    showToast('Failed to create list', 'error');
  }
};

const confirmDeleteGroup = (group: TodoGroup) => {
  groupToDelete.value = group;
  showDeleteDialog.value = true;
};

const deleteGroup = async () => {
  if (!groupToDelete.value) return;
  try {
    await todoStore.deleteTodoGroup(groupToDelete.value.id);
    await todoStore.fetchTodoGroups();
    showDeleteDialog.value = false;
    showToast('List deleted successfully', 'success');
  } catch {
    showToast('Failed to delete list', 'error');
  }
};
</script>
