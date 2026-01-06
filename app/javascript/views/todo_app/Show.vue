<template>
  <div class="todo-show v-container h-full overflow-y-auto bg-background p-4 md:p-6">
    <!-- Skeleton Loading State -->
    <div v-if="loading" class="space-y-4">
      <div class="flex items-center gap-3">
        <v-skeleton-loader type="avatar" class="!h-8 !min-h-0 !w-8"></v-skeleton-loader>
        <v-skeleton-loader type="heading" class="!h-7 flex-1"></v-skeleton-loader>
      </div>

      <v-skeleton-loader type="text" class="!h-4 !w-48"></v-skeleton-loader>

      <v-card variant="outlined" class="overflow-hidden rounded-lg">
        <div v-for="n in 6" :key="n" class="border-b border-gray-800 last:border-b-0">
          <v-skeleton-loader type="list-item-avatar" class="px-4 py-1"></v-skeleton-loader>
        </div>
      </v-card>
    </div>

    <!-- Not Found State -->
    <div v-else-if="!selectedGroup" class="py-16 text-center">
      <v-icon size="64" class="mb-4 opacity-50">mdi-folder-alert</v-icon>
      <h3 class="mb-2 text-lg font-medium">List not found</h3>
      <p class="mb-4 opacity-70">This list doesn't exist or has been deleted</p>
      <v-btn
        variant="flat"
        prepend-icon="mdi-arrow-left"
        class="rounded-lg !bg-surface shadow-md hover:bg-primary"
        elevation="2"
        @click="goBack"
      >
        Back to Lists
      </v-btn>
    </div>

    <!-- Group Content -->
    <div v-else>
      <!-- Group Header -->
      <div class="mb-6">
        <div class="flex items-start gap-3">
          <v-btn icon variant="text" size="small" class="mt-1 !text-primary" @click="goBack">
            <v-icon>mdi-arrow-left</v-icon>
            <v-tooltip activator="parent">Back to all lists</v-tooltip>
          </v-btn>

          <div class="flex-1">
            <h1 class="flex items-center gap-2 text-2xl font-bold">
              <v-icon size="28" class="text-primary">mdi-format-list-checks</v-icon>
              {{ selectedGroup.name }}
            </h1>
            <p class="mt-1 text-sm opacity-70">
              {{ selectedGroup.pending_count || 0 }} pending ·
              {{ selectedGroup.completed_count || 0 }} completed
            </p>
            <p class="mt-1 flex items-center gap-3 text-xs opacity-60">
              <span v-if="selectedGroup.created_at" class="flex items-center gap-1">
                <v-icon size="10">mdi-calendar-plus</v-icon>
                Created {{ formatDate(selectedGroup.created_at) }}
              </span>
              <span v-if="isGroupUpdated" class="flex items-center gap-1">
                <v-icon size="10">mdi-pencil</v-icon>
                Updated {{ formatDate(selectedGroup.updated_at) }}
              </span>
            </p>
          </div>

          <!-- Actions Menu -->
          <v-menu location="bottom end">
            <template #activator="{ props }">
              <v-btn icon variant="text" class="!text-primary" v-bind="props">
                <v-icon>mdi-dots-vertical</v-icon>
              </v-btn>
            </template>
            <v-list density="compact" class="bg-background">
              <v-list-item @click="openRenameDialog">
                <template #prepend>
                  <v-icon size="small">mdi-pencil</v-icon>
                </template>
                <v-list-item-title>Rename List</v-list-item-title>
              </v-list-item>
              <v-list-item @click="confirmDeleteGroup">
                <template #prepend>
                  <v-icon size="small">mdi-delete</v-icon>
                </template>
                <v-list-item-title>Delete List</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
        </div>
      </div>

      <!-- Add Task Input -->
      <v-card class="mb-4 rounded-lg" variant="outlined">
        <div class="pa-3 flex items-center gap-2">
          <v-icon>mdi-plus-circle</v-icon>
          <v-text-field
            v-model="newTodoTitle"
            placeholder="Add a task..."
            variant="plain"
            hide-details
            density="compact"
            class="flex-1"
            @keyup.enter="createTodo"
          />
          <v-btn
            v-if="newTodoTitle.trim()"
            size="small"
            variant="flat"
            class="rounded-lg !bg-surface shadow-md hover:bg-primary"
            elevation="2"
            @click="createTodo"
          >
            Add
          </v-btn>
        </div>
      </v-card>

      <!-- Pending Tasks -->
      <div v-if="pendingTodos.length > 0" class="mb-6">
        <div class="mb-2 flex items-center gap-2">
          <span class="text-sm font-medium opacity-70">To Do</span>
          <v-chip size="x-small" variant="tonal">{{ pendingTodos.length }}</v-chip>
        </div>
        <v-card variant="outlined" class="overflow-hidden rounded-lg">
          <draggable
            v-model="pendingTodos"
            item-key="id"
            v-bind="dragOptions"
            handle=".drag-handle"
            @start="handleDragStart"
            @end="handleDragEnd"
          >
            <template #item="{ element }">
              <div class="flex items-center">
                <v-icon class="drag-handle cursor-move px-2 opacity-50" size="small">
                  mdi-drag
                </v-icon>
                <div class="flex-1">
                  <todo-item
                    :todo="element"
                    @toggle="toggleTodo(element.id)"
                    @delete="deleteTodo(element.id)"
                    @update="updateTodo(element.id, $event)"
                  />
                </div>
              </div>
            </template>
          </draggable>
        </v-card>
      </div>

      <!-- Completed Tasks -->
      <div v-if="completedTodos.length > 0">
        <div
          class="mb-2 flex cursor-pointer select-none items-center gap-2"
          @click="showCompleted = !showCompleted"
        >
          <v-icon
            size="small"
            :class="showCompleted ? 'rotate-90' : ''"
            class="transition-transform"
          >
            mdi-chevron-right
          </v-icon>
          <span class="text-sm font-medium opacity-70">Completed</span>
          <v-chip size="x-small" variant="tonal">{{ completedTodos.length }}</v-chip>
        </div>
        <v-expand-transition>
          <v-card v-show="showCompleted" variant="outlined" class="overflow-hidden rounded-lg">
            <draggable
              v-model="completedTodos"
              item-key="id"
              v-bind="dragOptions"
              handle=".drag-handle"
              @start="handleDragStart"
              @end="handleDragEnd"
            >
              <template #item="{ element }">
                <div class="flex items-center">
                  <v-icon class="drag-handle cursor-move px-2 opacity-50" size="small">
                    mdi-drag
                  </v-icon>
                  <div class="flex-1">
                    <todo-item
                      :todo="element"
                      @toggle="toggleTodo(element.id)"
                      @delete="deleteTodo(element.id)"
                      @update="updateTodo(element.id, $event)"
                    />
                  </div>
                </div>
              </template>
            </draggable>
          </v-card>
        </v-expand-transition>
      </div>

      <!-- Empty State -->
      <div
        v-if="pendingTodos.length === 0 && completedTodos.length === 0"
        class="py-16 text-center"
      >
        <v-icon size="64" class="mb-4 opacity-50">mdi-check-circle-outline</v-icon>
        <h3 class="mb-2 text-lg font-medium">All caught up!</h3>
        <p class="opacity-70">Add a task above to get started</p>
      </div>
    </div>

    <!-- Rename Group Dialog -->
    <v-dialog v-model="showRenameDialog" max-width="400">
      <v-card class="rounded-lg">
        <v-card-title class="flex items-center gap-2">
          <v-icon>mdi-pencil</v-icon>
          Rename List
        </v-card-title>
        <v-card-text>
          <v-text-field
            v-model="renameGroupName"
            label="List name"
            variant="outlined"
            autofocus
            counter="50"
            maxlength="50"
            @keyup.enter="renameGroup"
          ></v-text-field>
        </v-card-text>
        <v-card-actions class="pa-4">
          <v-spacer></v-spacer>
          <v-btn variant="text" class="!text-primary" @click="showRenameDialog = false">
            Cancel
          </v-btn>
          <v-btn
            variant="flat"
            class="rounded-lg !bg-surface shadow-md hover:bg-primary"
            elevation="2"
            :disabled="!renameGroupName.trim()"
            @click="renameGroup"
          >
            Save
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
            Are you sure you want to delete <strong>"{{ selectedGroup?.name }}"</strong>?
          </p>
          <p class="mt-2 text-sm opacity-70">
            All {{ selectedGroup?.todos_count || 0 }} tasks in this list will be permanently
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import draggable from 'vuedraggable';
import { storeToRefs } from 'pinia';
import { useRoute, useRouter } from 'vue-router';
import { useTodoStore } from '@/stores/todo_app/todo.store';
import TodoItem from '@/components/todo_app/TodoItem.vue';
import { showToast } from '@/utils/showToast';

const todoStore = useTodoStore();
const { selectedGroup } = storeToRefs(todoStore);

const route = useRoute();
const router = useRouter();

// UI State
const loading = ref(false);
const newTodoTitle = ref('');
const renameGroupName = ref('');
const showRenameDialog = ref(false);
const showDeleteDialog = ref(false);
const showCompleted = ref(true);
const drag = ref(false);

// Get group ID from route
const groupId = computed(() => {
  const raw = route.params?.groupId;
  if (raw === undefined || raw === null || raw === '') return null;
  const id = Number(raw);
  return Number.isFinite(id) ? id : null;
});

// Computed
const isGroupUpdated = computed(() => {
  if (!selectedGroup.value?.created_at || !selectedGroup.value?.updated_at) return false;
  const created = new Date(selectedGroup.value.created_at).getTime();
  const updated = new Date(selectedGroup.value.updated_at).getTime();
  return Math.abs(updated - created) > 1000;
});

// Writable computed for draggable
const pendingTodos = computed({
  get: () => (selectedGroup.value?.todos || []).filter((t) => !t.completed),
  set: (newList) => {
    if (selectedGroup.value) {
      const completed = (selectedGroup.value.todos || []).filter((t) => t.completed);
      selectedGroup.value.todos = [...newList, ...completed];
    }
  },
});

const completedTodos = computed({
  get: () => (selectedGroup.value?.todos || []).filter((t) => t.completed),
  set: (newList) => {
    if (selectedGroup.value) {
      const pending = (selectedGroup.value.todos || []).filter((t) => !t.completed);
      selectedGroup.value.todos = [...pending, ...newList];
    }
  },
});

// Date formatting helper
const formatDate = (dateString?: string | null) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMinutes = Math.floor(diffMs / (1000 * 60));
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (diffMinutes < 1) return 'just now';
  if (diffMinutes < 60) return `${diffMinutes}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays === 1) return 'yesterday';
  if (diffDays < 7) return `${diffDays}d ago`;
  return date.toLocaleDateString();
};

// Fetch group on mount
const fetchGroup = async () => {
  if (!groupId.value) {
    todoStore.selectGroup(null);
    return;
  }

  loading.value = true;
  try {
    const group = await todoStore.fetchTodoGroup(groupId.value);
    if (group) {
      todoStore.selectGroup(group);
    } else {
      todoStore.selectGroup(null);
    }
  } catch {
    todoStore.selectGroup(null);
    showToast('Failed to load list', 'error');
  } finally {
    loading.value = false;
  }
};

onMounted(fetchGroup);

// Watch for route changes
watch(
  () => groupId.value,
  () => {
    fetchGroup();
  },
);

// Methods
const goBack = () => {
  router.push({ name: 'todos' });
};

const openRenameDialog = () => {
  if (!selectedGroup.value) return;
  renameGroupName.value = selectedGroup.value.name;
  showRenameDialog.value = true;
};

const renameGroup = async () => {
  if (!renameGroupName.value.trim() || !selectedGroup.value) return;
  try {
    await todoStore.updateTodoGroup(selectedGroup.value.id, { name: renameGroupName.value.trim() });
    showRenameDialog.value = false;
    showToast('List renamed successfully', 'success');
  } catch {
    showToast('Failed to rename list', 'error');
  }
};

const confirmDeleteGroup = () => {
  showDeleteDialog.value = true;
};

const deleteGroup = async () => {
  if (!selectedGroup.value) return;
  try {
    await todoStore.deleteTodoGroup(selectedGroup.value.id);
    showDeleteDialog.value = false;
    showToast('List deleted successfully', 'success');
    router.push({ name: 'todos' });
  } catch {
    showToast('Failed to delete list', 'error');
  }
};

const createTodo = async () => {
  if (!newTodoTitle.value.trim()) return;
  try {
    await todoStore.createTodo(newTodoTitle.value.trim());
    newTodoTitle.value = '';
  } catch {
    showToast('Failed to create task', 'error');
  }
};

const toggleTodo = async (id: number) => {
  try {
    await todoStore.toggleTodo(id);
  } catch {
    showToast('Failed to update task', 'error');
  }
};

const deleteTodo = async (id: number) => {
  try {
    await todoStore.deleteTodo(id);
    showToast('Task deleted', 'success');
  } catch {
    showToast('Failed to delete task', 'error');
  }
};

const updateTodo = async (id: number, data: { title?: string; notes?: string }) => {
  try {
    await todoStore.updateTodo(id, data);
  } catch {
    showToast('Failed to update task', 'error');
  }
};

const handleDragStart = () => {
  drag.value = true;
};

const handleDragEnd = () => {
  drag.value = false;
  onDragEnd();
};

// Drag and drop
const dragOptions = {
  animation: 200,
  group: 'todos',
  disabled: false,
  ghostClass: 'ghost',
};

const onDragEnd = async () => {
  if (!selectedGroup.value) return;

  const allTodos = selectedGroup.value.todos || [];
  try {
    const todoIds = allTodos.map((t) => t.id);
    await todoStore.reorderTodos(todoIds);
  } catch {
    showToast('Failed to reorder tasks', 'error');
    await todoStore.fetchTodoGroup(selectedGroup.value.id);
  }
};
</script>

<style scoped>
.rotate-90 {
  transform: rotate(90deg);
}

.transition-transform {
  transition: transform 0.2s ease;
}

/* Drag and drop styles */
.ghost {
  opacity: 0.5;
  background: rgba(var(--v-theme-primary), 0.1);
}

.drag-handle {
  cursor: grab;
}

.drag-handle:active {
  cursor: grabbing;
}
</style>
